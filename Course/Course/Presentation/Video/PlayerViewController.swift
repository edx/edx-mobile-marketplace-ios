//
//  PlayerViewController.swift
//  Course
//
//  Created by Vladimir Chekyrta on 13.02.2023.
//

import Combine
import Core
import SwiftUI
import UIKit
import _AVKit_SwiftUI

struct PlayerViewController: UIViewControllerRepresentable {
    var playerController: CustomAVPlayerViewController
    @Binding var subtitleText: String

    func makeUIViewController(context: Context) -> CustomAVPlayerViewController {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print(error.localizedDescription)
        }
        
        return playerController
    }
    
    func updateUIViewController(_ playerController: CustomAVPlayerViewController, context: Context) {
        playerController.subtitleText = subtitleText
    }
}

class CustomAVPlayerViewController: AVPlayerViewController {
    private let overlayViewModel = VideoPlayerOverlayViewModel()
    private var overlayController: UIHostingController<VideoPlayerOverlay>?
    private let subtitleLabel = UILabel()

    private let speedUpRate: Float = 2.0
    private var originalRate: Float?
    private var mediaSelectionObserver: NSObjectProtocol?

    var subtitleText: String = "" {
        didSet {
            subtitleLabel.text = subtitleText
            updateSubtitleVisibility()
        }
    }
    
    var hideSubtitle: Bool = true {
        didSet {
            updateSubtitleVisibility()
        }
    }
    
    override var player: AVPlayer? {
        didSet {
            observeMediaSelection(for: player?.currentItem)
            updateSubtitleVisibility()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupOverlay()
        setupGestures()

        // Configure the subtitle label
        subtitleLabel.textColor = .white
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        subtitleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.layer.cornerRadius = 8
        subtitleLabel.layer.masksToBounds = true
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.isHidden = true
        subtitleLabel.text = subtitleText
        
        self.delegate = self

        // Add subtitle label to the content overlay view of AVPlayerViewController
        contentOverlayView?.addSubview(subtitleLabel)

        // Set constraints for the subtitle label
        NSLayoutConstraint.activate([
            subtitleLabel.centerXAnchor.constraint(equalTo: contentOverlayView!.centerXAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentOverlayView!.bottomAnchor, constant: -20),
            subtitleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentOverlayView!.widthAnchor, multiplier: 0.9)
        ])
    }
    
    deinit {
        if let mediaSelectionObserver {
            NotificationCenter.default.removeObserver(mediaSelectionObserver)
        }
    }
    
    private func observeMediaSelection(for item: AVPlayerItem?) {
        if let mediaSelectionObserver {
            NotificationCenter.default.removeObserver(mediaSelectionObserver)
            self.mediaSelectionObserver = nil
        }
        
        guard let item else { return }
        
        mediaSelectionObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.mediaSelectionDidChangeNotification,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.updateSubtitleVisibility()
        }
    }
    
    private func updateSubtitleVisibility() {
        let hasSubtitleText = !subtitleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let subtitlesEnabledInPlayer = isLegibleMediaOptionSelected()
        
        subtitleLabel.isHidden = hideSubtitle || !hasSubtitleText || !subtitlesEnabledInPlayer
    }
    
    private func isLegibleMediaOptionSelected() -> Bool {
        guard let asset = player?.currentItem?.asset,
              let group = asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else {
            return false
        }
        
        return player?.currentItem?.currentMediaSelection.selectedMediaOption(in: group) != nil
    }

    private func setupOverlay() {
        guard let contentOverlayView else { return }

        let hosting = UIHostingController(
            rootView: VideoPlayerOverlay(viewModel: overlayViewModel)
        )
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        contentOverlayView.addSubview(hosting.view)

        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: contentOverlayView.safeAreaLayoutGuide.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: contentOverlayView.safeAreaLayoutGuide.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: contentOverlayView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: contentOverlayView.trailingAnchor)
        ])

        self.overlayController = hosting
    }

    private func setupGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        contentOverlayView?.addGestureRecognizer(longPress)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let player else { return }

            if player.rate > 0 && player.rate < speedUpRate {
                originalRate = player.rate
                player.rate = speedUpRate
                overlayViewModel.showSpeedOverlay = true
            }
        case .ended, .cancelled, .failed:
            if let rate = originalRate {
                player?.rate = rate
                originalRate = nil
            }
            overlayViewModel.showSpeedOverlay = false
        default:
            break
        }
    }
}

extension CustomAVPlayerViewController: AVPlayerViewControllerDelegate {
    func playerViewController(
        _ playerViewController: AVPlayerViewController,
        willBeginFullScreenPresentationWithAnimationCoordinator coordinator: any UIViewControllerTransitionCoordinator
    ) {
        hideSubtitle = false
    }
    
    func playerViewController(
        _ playerViewController: AVPlayerViewController,
        willEndFullScreenPresentationWithAnimationCoordinator coordinator: any UIViewControllerTransitionCoordinator
    ) {
        coordinator.animate(alongsideTransition: nil) { [ weak self ] context in
            if !context.isCancelled {
                self?.hideSubtitle = true
            }
        }
    }
}
