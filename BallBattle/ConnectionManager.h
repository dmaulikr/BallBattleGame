//
//  ConnectionManager.h
//  BluetoothTest
//
//  Created by 敦史 掛川 on 12/05/22.
//  Copyright (c) 2012年 Classmethod Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
@class ConnectionManager;

@protocol ConnectionManagerDelegate <NSObject>

@optional
// データ受信時に呼び出される
- (void)connectionManager:(ConnectionManager *)manager
           didReceiveData:(NSData *)data
                 fromPeer:(NSString *)peer;
// P2P接続完了時に呼び出される
- (void)connectionManagerDidConnect:(ConnectionManager *)manager;
// P2P接続切断時に呼び出される
- (void)connectionManagerDidDisconnect:(ConnectionManager *)manager;

@end

@interface ConnectionManager : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate>

@property (nonatomic, strong) id<ConnectionManagerDelegate> delegate;
@property (nonatomic) BOOL isConnecting;

- (void)connect;
- (void)disconnect;
- (void)sendDataToAllPeers:(NSData *)data;

@end
