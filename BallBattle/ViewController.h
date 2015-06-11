//
//  ViewController.h
//  BallRolling
//
//  Created by Ryosei Takahashi on 2015/03/14.
//  Copyright (c) 2015年 Ryosei Takahashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "ConnectionManager.h"
//　加速度センサから値を取得する間隔
#define kAccelerometerFrequency 20.0f
//　加速度センサの感度を制限する
#define kFilteringFactor 0.2f

//　タイマーの間隔
#define kTimerInterval 0.01f
//　あたり判定用の玉の半径
#define kRadius 26.0f
//　壁反射の度合い
#define kWallRefPower 0.8f

// Pin反射の度合い
#define kRefPwoer 2.2f

@interface ViewController : UIViewController<ConnectionManagerDelegate>


@property (weak, nonatomic) IBOutlet UIBarButtonItem *connectButton;
- (IBAction)connectButonTouched:(id)sender;



@end

