//
//  VolumeButtonObserver.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 5/3/25.
//


import Foundation
import AVFoundation
import MediaPlayer
import Combine

class VolumeButtonObserver: ObservableObject {
    private var audioSession = AVAudioSession.sharedInstance()
    private var lastVolume: Float = 0.5
    private var volumeObservation: NSKeyValueObservation?

    var onVolumeButtonPressed: ((Bool) -> Void)? // true = up, false = down

    init() {
        setup()
    }

    private func setup() {
        try? audioSession.setActive(true)
        lastVolume = audioSession.outputVolume

        volumeObservation = audioSession.observe(\.outputVolume, options: [.new]) { [weak self] _, change in
            guard let self = self, let newVolume = change.newValue else { return }
            if newVolume > self.lastVolume {
                self.onVolumeButtonPressed?(true) // volume up
            } else if newVolume < self.lastVolume {
                self.onVolumeButtonPressed?(false) // volume down
            }
            self.lastVolume = newVolume
        }

        // Hide system volume HUD
        let volumeView = MPVolumeView(frame: .zero)
        volumeView.isHidden = true
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.view.addSubview(volumeView)
        }

    }

    deinit {
        volumeObservation?.invalidate()
    }
}
