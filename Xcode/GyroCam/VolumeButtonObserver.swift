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
    private var volumeObservation: NSKeyValueObservation?

    var onVolumeButtonPressed: ((Bool) -> Void)? 

    init() {
        setup()
    }

    private func setup() {
        try? audioSession.setActive(true)
        
        volumeObservation = audioSession.observe(\.outputVolume, options: [.new]) { [weak self] _, change in
            guard let self = self, let _ = change.newValue else { return }
            self.onVolumeButtonPressed?(true)
        }

    }

    deinit {
        volumeObservation?.invalidate()
    }
}
