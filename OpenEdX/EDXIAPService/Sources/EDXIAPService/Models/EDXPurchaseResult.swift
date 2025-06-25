import OEXFoundation

public struct EDXPurchaseResult: IAPPurchaseResult {
    public let isSuccess: Bool
    public let receipt: String?
    public let error: Error?
}
