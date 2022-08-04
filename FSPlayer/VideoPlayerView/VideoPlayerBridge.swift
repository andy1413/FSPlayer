//
//  VideoPlayerSwift.swift
//  FSPlayer
//
//  Created by andy on 2022/7/31.
//

import Foundation
import UIKit
import SwiftUI

@objcMembers class VideoPlayerBridge: NSObject {
    var playerManager: OCPlayerManager = {
        OCPlayerManager()
    }()
    
    func initRootVC(for window: UIWindow) {
        window.rootViewController = UIHostingController(rootView: VideoPlayerView(playerManager: playerManager).environmentObject(playerManager.model))
        window.makeKeyAndVisible()
    }
}
