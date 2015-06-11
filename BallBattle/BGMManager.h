//
//  BGMManager.h
//  MarbleFireworks
//
//  Created by Yukinaga Azuma on 2013/11/19.
//  Copyright (c) 2013年 Yukinaga Azuma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"

@interface BGMManager : NSObject{
    AVAudioPlayer *bGMPlayer;
}

@property(nonatomic) float soundVolume;
@property(nonatomic) NSInteger numberOfLoop;

- (void)startBGM:(NSString *)soundName;
- (void)stopBGM;
- (void)resumePlay;

@end
