//
//  GyroCamApp.swift
//  GyroCam
//
//  Created by Fayaz Shaikh on 1/22/25.
//

import SwiftUI

@main
struct GyroCamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
