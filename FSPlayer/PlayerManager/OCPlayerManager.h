//
//  OCPlayerManager.h
//  FSPlayer
//
//  Created by andy on 2022/8/1.
//

#import <Foundation/Foundation.h>

@class VideoPlayerModel;
NS_ASSUME_NONNULL_BEGIN

@interface OCPlayerManager : NSObject

@property (nonatomic, strong) VideoPlayerModel *model;

- (void)on_playBtn_clicked;

- (void)on_stopBtn_clicked;

- (void)on_timeSlider_touchDown;

- (void)on_timeSlider_valueChange;

- (void)on_timeSlider_touchUpInside;

- (void)reloadTimeText;

- (void)on_muteBtn_clicked;

- (void)on_volumnSlider_valueChanged;

- (void)on_openFileBtn_clicked;

@end

@interface OCPlayerViewManager : NSObject

@end

NS_ASSUME_NONNULL_END
