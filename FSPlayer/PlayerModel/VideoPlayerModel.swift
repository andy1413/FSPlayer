//
//  VideoPlayerModel.swift
//  FSPlayer
//
//  Created by andy on 2022/8/1.
//

import Foundation
import SwiftUI

@objcMembers class VideoPlayerModelWrap: NSObject {
    var model = VideoPlayerModel()
}

@objcMembers class VideoPlayerModel: NSObject, ObservableObject
{
    @Published var volumnMin: Float = 0
    @Published var volumnMax: Float = 0
    @Published var volumnValue: Float = 0
    @Published var playTitle: String = "播放"
    @Published var stopped: Bool = true
    @Published var timeEditing: Bool = false
    @Published var timeMin: Float = 0
    @Published var timeMax: Float = 0
    @Published var timeValue: Float = 0
    @Published var durationText: String = ""
    @Published var timeText: String = ""
    @Published var muteTitle: String = "静音"
    @Published var volumnText: String = ""
    @Published var image: UIImage?
    @Published var playFail: Bool = false
}
