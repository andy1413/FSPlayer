//
//  OCPlayerManager.m
//  FSPlayer
//
//  Created by andy on 2022/8/1.
//

#import <UIKit/UIKit.h>

#import "OCPlayerManager.h"
#import "videoplayer.h"
#import "FSPlayer-Swift.h"

@interface OCPlayerManager ()

@property (nonatomic, strong) OCPlayerViewManager *viewManager;

@property (nonatomic, assign) VideoPlayer *player;

@end

@interface OCPlayerViewManager ()

@property (nonatomic, strong) VideoPlayerModel *model;

- (void)onPlayerFrameDecoded:(VideoPlayer *)player
                        data:(uint8_t *)data
                        spec:(VideoPlayer::VideoSwsSpec&)spec;

- (void)onPlayerStateChanged:(VideoPlayer *)player;

@end

@implementation OCPlayerManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.model = [[VideoPlayerModel alloc] init];
        self.viewManager = [[OCPlayerViewManager alloc] init];
        self.viewManager.model = self.model;
        [self initPlayer];
    }
    return self;
}

- (void)dealloc {
    delete _player;
}

- (void)initPlayer {
    self.model.timeEditing = NO;
    
    self.player = new VideoPlayer((__bridge void *)self);
    self.player->stateChanged = onPlayerStateChanged;
    self.player->timeChanged = onPlayerTimeChanged;
    self.player->initFinished = onPlayerInitFinished;
    self.player->playFailed = onPlayerPlayFailed;
    self.player->frameDecoded = onPlayerFrameDecoded;
    
    self.model.volumnMin = VideoPlayer::Volumn::Min;
    self.model.volumnMax = VideoPlayer::Volumn::Max;
    self.model.volumnValue = (int)self.model.volumnMax >> 2;
    [self on_volumnSlider_valueChanged];
}

#pragma mark -Callback
void onPlayerStateChanged(VideoPlayer *player) {
    dispatch_async(dispatch_get_main_queue(), ^{
        OCPlayerManager *manager = (__bridge OCPlayerManager *)player->parent;
        [manager.viewManager onPlayerStateChanged:player];
        
        VideoPlayer::State state = player->getState();
        if (state == VideoPlayer::Playing) {
            manager.model.playTitle = @"暂停";
        } else {
            manager.model.playTitle = @"播放";
        }
        manager.model.stopped = state == VideoPlayer::Stopped;
    });
}

void onPlayerTimeChanged(VideoPlayer *player) {
    dispatch_async(dispatch_get_main_queue(), ^{
        OCPlayerManager *manager = (__bridge OCPlayerManager *)player->parent;
        if (!manager.model.timeEditing) {
            manager.model.timeValue = player->getTime();
            [manager reloadTimeText];
        }
    });
}

void onPlayerInitFinished(VideoPlayer *player) {
    dispatch_async(dispatch_get_main_queue(), ^{
        OCPlayerManager *manager = (__bridge OCPlayerManager *)player->parent;
        
        int duration = player->getDuration();
        manager.model.timeMin = 0;
        manager.model.timeMax = duration;
        manager.model.durationText = [manager getTimeText:duration];
    });
}

void onPlayerPlayFailed(VideoPlayer *player) {
    dispatch_async(dispatch_get_main_queue(), ^{
        OCPlayerManager *manager = (__bridge OCPlayerManager *)player->parent;
        manager.model.playFail = true;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            manager.model.playFail = false;
        });
    });
}

void onPlayerFrameDecoded(VideoPlayer *player,
                          uint8_t *data,
                          VideoPlayer::VideoSwsSpec &spec) {
    dispatch_async(dispatch_get_main_queue(), ^{
        OCPlayerManager *manager = (__bridge OCPlayerManager *)player->parent;
        [manager.viewManager onPlayerFrameDecoded:player data:data spec:spec];
    });
}

#pragma mark -PrivateMethods
- (NSString *)getTimeText:(int)value {
    int h = value / 3600;
    int m = (value / 60) % 60;
    int s = value % 60;
    
    NSString *time = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
    return time;
}

#pragma mark -Action
- (void)on_playBtn_clicked {
    VideoPlayer::State state = _player->getState();
    if (state == VideoPlayer::Playing) {
        _player->pause();
    } else {
        _player->play();
    }
}

- (void)on_stopBtn_clicked {
    _player->stop();
}

- (void)on_timeSlider_touchDown {
    //开始滑动
    self.model.timeEditing = YES;
    [self reloadTimeText];
}

- (void)on_timeSlider_valueChange {
    [self reloadTimeText];
}

- (void)on_timeSlider_touchUpInside {
    //结束滑动
    [self reloadTimeText];
    self.player->setTime((int)self.model.timeValue);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.model.timeEditing = NO;
    });
}

- (void)reloadTimeText {
    self.model.timeText = [self getTimeText:(int)self.model.timeValue];
}

- (void)on_muteBtn_clicked {
    if (_player->isMute()) {
        _player->setMute(NO);
        self.model.muteTitle = @"静音";
    } else {
        _player->setMute(YES);
        self.model.muteTitle = @"开音";
    }
}

- (void)on_volumnSlider_valueChanged {
    self.model.volumnText = [NSString stringWithFormat:@"%d", (int)self.model.volumnValue];
    _player->setVolumn((int)self.model.volumnValue);
}

- (void)on_openFileBtn_clicked {
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"in" ofType:@"mp4"];
    _player->setFilename([filename cStringUsingEncoding:NSUTF8StringEncoding]);
    _player->play();
}

@end

@implementation OCPlayerViewManager

- (void)onPlayerFrameDecoded:(VideoPlayer *)player
                        data:(uint8_t *)data
                        spec:(VideoPlayer::VideoSwsSpec&)spec {
    if (player->getState() == VideoPlayer::Stopped) {
        return;
    }
    if (data != nil) {
        @autoreleasepool {
            size_t bitsPerComponent = 8;
            size_t bytesPerRow = static_cast<size_t>(4 * spec.width);
            CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
             
            // set the alpha mode RGBA
            CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;

            
            CGContextRef cgBitmapCtx =
                     CGBitmapContextCreate(
                            data,
                            static_cast<size_t>(spec.width),
                            static_cast<size_t>(spec.height),
                            bitsPerComponent,
                            bytesPerRow,
                            colorSpaceRef,
                            bitmapInfo);
             
            CGImageRef cgImg = CGBitmapContextCreateImage(cgBitmapCtx);
            CGContextRelease(cgBitmapCtx);
             
            UIImage *retImg = [UIImage imageWithCGImage:cgImg];
            CGImageRelease(cgImg);

            self.model.image = retImg;
            
            av_freep(&data);
        }
    }
}

- (void)onPlayerStateChanged:(VideoPlayer *)player {
    if (player->getState() != VideoPlayer::Stopped) {
        return;
    }
    self.model.image = nil;
}

@end
