//
//  VideoPlayerSwiftUIView.swift
//  FSPlayer
//
//  Created by andy on 2022/7/31.
//

import SwiftUI

struct VideoPlayerView: View {
    @EnvironmentObject var model : VideoPlayerModel
    weak var playerManager: OCPlayerManager?
    
    var body: some View {
        ZStack {
            VStack {
                TopVideoView(playerManager: playerManager)
                Spacer()
                    .frame(height: 50)
            }
            VStack {
                Spacer()
                ZStack {
                    Color.white
                    HStack {
                        PlayAndStopView(playerManager:playerManager)
                        ProgressView(playerManager:playerManager)
                        VolumnView(playerManager:playerManager)
                    }
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                }
                .frame(height:50)
            }
        }
        .ignoresSafeArea()
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            VideoPlayerView()
                .previewInterfaceOrientation(.landscapeRight)
        } else {
            VideoPlayerView()
        }
    }
}

struct TopVideoView: View {
    @EnvironmentObject var model : VideoPlayerModel
    weak var playerManager: OCPlayerManager?
    
    var body: some View {
        ZStack {
            Color.black
            if let image = model.image, !model.stopped {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                
            }
            if model.stopped {
                Button("打开文件") {
                    print("打开文件")
                    playerManager?.on_openFileBtn_clicked()
                }
                .modifier(FSButton())
            }
            if model.playFail {
                Text("播放失败了")
                    .offset(y: 50)
            }
        }
    }
}

struct PlayAndStopView: View {
    @EnvironmentObject var model : VideoPlayerModel
    weak var playerManager: OCPlayerManager?
    
    var body: some View {
        HStack {
            Button(model.playTitle) {
                print("播放")
                playerManager?.on_playBtn_clicked()
            }
            .disabled(model.stopped)
            .modifier(FSButton(isDisable: model.stopped))
            
            Spacer().frame(width: 5)
            
            Button("停止") {
                print("停止")
                playerManager?.on_stopBtn_clicked()
            }
            .disabled(model.stopped)
            .modifier(FSButton(isDisable: model.stopped))
            
            Spacer().frame(width: 5)
        }
    }
}

struct ProgressView: View {
    @EnvironmentObject var model : VideoPlayerModel
    weak var playerManager: OCPlayerManager?
    
    var body: some View {
        HStack {
            Slider(value: $model.timeValue, in: model.timeMin...model.timeMax) { onEditing in
                print(onEditing)
                model.timeEditing = onEditing
                if onEditing {
                    playerManager?.reloadTimeText()
                } else {
                    playerManager?.on_timeSlider_touchUpInside()
                }
            }
            .disabled(model.stopped)
            
            Spacer().frame(width: 5)
            
            Text(model.stopped ? "00:00:00" : model.timeText)
            
            Spacer().frame(width: 5)
            
            Text("/")
            
            Spacer().frame(width: 5)
            
            Text(model.stopped ? "00:00:00" : model.durationText)
            
            Spacer().frame(width: 5)
        }
    }
}

struct VolumnView: View {
    @EnvironmentObject var model : VideoPlayerModel
    weak var playerManager: OCPlayerManager?
    
    var body: some View {
        HStack {
            Button(model.muteTitle) {
                print("静音")
                playerManager?.on_muteBtn_clicked()
            }
            .disabled(model.stopped)
            .modifier(FSButton(isDisable: model.stopped))
            
            Spacer().frame(width: 5)
            
            Slider(value: $model.volumnValue, in: model.volumnMin...model.volumnMax) { onEditing in
                print(onEditing)
                playerManager?.on_volumnSlider_valueChanged()
            }
            .frame(width: 100)
            .disabled(model.stopped)
            
            Spacer().frame(width: 5)
            
            Text(model.volumnText)
        }
    }
}
