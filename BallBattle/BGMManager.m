//
//  BGMManager.m
//  MarbleFireworks
//
//  Created by Yukinaga Azuma on 2013/11/19.
//  Copyright (c) 2013年 Yukinaga Azuma. All rights reserved.
//

#import "BGMManager.h"

@implementation BGMManager

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        _soundVolume = 1.0;
        _numberOfLoop = -1;
    }
    return self;
}

- (void)startBGM:(NSString *)bGMName{
    
    if (!bGMName) {
        return;
    }
    
    [bGMPlayer stop];
    bGMPlayer = nil;
    
    NSString *soundPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:bGMName];
    NSURL *urlOfSound = [NSURL fileURLWithPath:soundPath];
    bGMPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlOfSound error:nil];
    [bGMPlayer setNumberOfLoops:_numberOfLoop];
    bGMPlayer.volume = _soundVolume;
    bGMPlayer.delegate = (id)self;
    [bGMPlayer prepareToPlay];
    [bGMPlayer play];
}

- (void)stopBGM{
    if (bGMPlayer) {
        [bGMPlayer stop];
    }
}

- (void)resumePlay{
    if (bGMPlayer) {
        [bGMPlayer play];
    }
}

@end
