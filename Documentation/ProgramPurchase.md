# Program Purchase Architecture

## Overview

Program purchase is triggered by intercepting URLs navigated to inside the Discovery webview. When the user taps a purchase button rendered by the web frontend, the native app intercepts the navigation, suppresses it, and initiates a StoreKit purchase flow instead.

## Flow

```
User taps purchase button in webview
        │
        ▼
DiscoveryWebviewViewModel.webView(_:shouldLoad:navigationAction:)
        │
        ├── DiscoveryWebPurchaseHandler.canHandlePurchase(for:) ──► false → existing navigation logic
        │
        ▼ true
showProgress = true
DiscoveryWebPurchaseHandler.handlePurchase(for:completion:)
        │
        ├── completion(.processing)  →  (spinner already showing, no-op)
        │
        ▼
StoreKitHandlerProtocol.purchaseProduct(sku)
        │
        ├── success  →  markPurchaseComplete(sku, type: .purchase)
        │              [TODO: POST receipt to backend fulfillment API]
        │              completion(.success)  →  showProgress = false
        │
        └── failure  →  completion(.error(UpgradeError))  →  showProgress = false, errorMessage = ...
```

## Key Types

### `ProgramPurchaseState` — `Discovery` module

State enum passed through the completion callback to drive UI updates.

```swift
public enum ProgramPurchaseState {
    case processing  // StoreKit sheet is presenting — spinner stays visible
    case success     // purchase complete
    case error(Error)
}
```

### `DiscoveryWebPurchaseHandler` — `Discovery` module

Protocol defined in `Discovery` so the module stays unaware of StoreKit and app-level IAP infrastructure. Marked `//sourcery: AutoMockable` for test generation.

```swift
public protocol DiscoveryWebPurchaseHandler {
    typealias PurchaseCompletion = (ProgramPurchaseState) -> Void
    func canHandlePurchase(for url: URL) -> Bool
    func handlePurchase(for url: URL, completion: @escaping PurchaseCompletion)
}
```

### `ProgramPurchaseHandler` — `OpenEdX` app target

Concrete implementation. Lives in the app target so it can import both `Discovery` (protocol) and `Core` (StoreKit infrastructure) without violating the module dependency rule.

- `canHandlePurchase` — gates on `PROGRAM_PURCHASE.ENABLED`, non-empty SKU, and URL host/path matching config values. Path matching is optional: if `PURCHASE_URL_PATH` is empty, any path on the matching host triggers purchase.
- `handlePurchase` — calls `StoreKitHandlerProtocol.purchaseProduct(sku)`, then `markPurchaseComplete` on success. The `TODO` comment in this method marks the exact insertion point for the backend receipt fulfillment API call.

### `ProgramPurchaseConfig` — `Core` module

Read from the `PROGRAM_PURCHASE` YAML key. Accessible via `ConfigProtocol.programPurchase`.

| YAML key | Type | Purpose |
|---|---|---|
| `ENABLED` | Bool | Master switch — `canHandlePurchase` returns false when disabled |
| `SKU` | String | App Store Connect product identifier |
| `PURCHASE_URL_HOST` | String | Host to match (e.g. `authn.edx.org`) |
| `PURCHASE_URL_PATH` | String | Path to match (e.g. `/login`). Empty = match any path on host |

## Configuration

Add to `default_config/<env>/ios.yaml`:

```yaml
PROGRAM_PURCHASE:
  ENABLED: true
  SKU: 'your.app.store.connect.sku'
  PURCHASE_URL_HOST: 'authn.edx.org'
  PURCHASE_URL_PATH: '/login'
```

Set `ENABLED: false` (or omit the block) to disable without code changes.

## Module Dependency

```
OpenEdX (app)
  └── ProgramPurchaseHandler
        ├── imports Discovery  →  DiscoveryWebPurchaseHandler (protocol)
        └── imports Core       →  StoreKitHandlerProtocol, ConfigProtocol

Discovery
  └── DiscoveryWebPurchaseHandler (protocol only — no StoreKit import)

Core
  └── StoreKitHandlerProtocol, ProgramPurchaseConfig
```

`Discovery` never imports StoreKit or app-level IAP code. The protocol boundary keeps it clean.

## DI Registration

`OpenEdX/DI/ScreenAssembly.swift`:

```swift
container.register(DiscoveryWebPurchaseHandler.self) { r in
    ProgramPurchaseHandler(
        config: r.resolve(ConfigProtocol.self)!,
        storeKitHandler: r.resolve(StoreKitHandlerProtocol.self)!
    )
}.inObjectScope(.container)
```

Registered as `.container` scope (singleton) — one instance shared across all `DiscoveryWebviewViewModel` resolutions.

## Extending to Custom URI Scheme

When the backend is ready and may emit a custom URI scheme URL (e.g. `edxapp://purchase?...`) instead of or alongside HTTPS, update only `ProgramPurchaseHandler.canHandlePurchase`:

```swift
func canHandlePurchase(for url: URL) -> Bool {
    // HTTPS URL
    if url.scheme == "https", url.host == config.programPurchase.purchaseUrlHost { ... }
    // Custom URI scheme
    if url.scheme == config.URIScheme, url.host == "purchase" { return true }
    return false
}
```

No changes to the protocol, VM, or DI registration are needed.

## Adding Backend Fulfillment

When the backend program purchase API is available, update `ProgramPurchaseHandler.handlePurchase`:

```swift
if response.success, let receipt = response.receipt {
    do {
        try await programPurchaseInteractor.fulfillOrder(receipt: receipt)
        storeKitHandler.markPurchaseComplete(sku, type: .purchase)
        completion(.success)
    } catch {
        // Do NOT call markPurchaseComplete — transaction stays open for retry
        completion(.error(error))
    }
}
```

`markPurchaseComplete` must only be called after the backend confirms fulfillment, otherwise the transaction is finished in StoreKit before the user receives access.

## Testing

The `DiscoveryWebPurchaseHandler` protocol is annotated `//sourcery: AutoMockable`. After modifying the protocol, regenerate mocks:

```bash
cd Discovery && ../Pods/SwiftyMocky/bin/swiftymocky generate
```

To test `ProgramPurchaseHandler` in isolation, inject a `StoreKitHandlerProtocolMock` (already generated in `Core`) and a `ConfigProtocol` stub with known `programPurchase` values.
