//
//  ConnectionManager.m
//  BluetoothTest
//
//  Created by 敦史 掛川 on 12/05/22.
//  Copyright (c) 2012年 Classmethod Inc.. All rights reserved.
//

#import "ConnectionManager.h"

@interface ConnectionManager () {
    GKSession *currentSession;
}

@end

@implementation ConnectionManager

@synthesize delegate;
@synthesize isConnecting = _isConnecting;

#pragma mark - GKPeerPickerControllerDelegate methods

- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *)session
{
    // セッションを保管
    currentSession = session;
    // デリゲートのセット
    session.delegate = self;
    // データ受信時のハンドラを設定
    [session setDataReceiveHandler:self withContext:nil];
    
    // ピアピッカーを閉じる
    picker.delegate = nil;
    [picker dismiss];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    picker.delegate = nil;
}

#pragma mark - GKSession methods

- (void)session:(GKSession *)session
           peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state
{
    switch (state) {
        case GKPeerStateAvailable:
            NSLog(@"%@", @"Peer state changed - available");
            break;
            
        case GKPeerStateConnecting:
            NSLog(@"%@", @"Peer state changed - connecting");
            break;
            
        case GKPeerStateConnected:
            NSLog(@"%@", @"Peer state changed - connected");
            // 接続完了を通知
            self.isConnecting = YES;
            [self.delegate connectionManagerDidConnect:self];
            break;
            
        case GKPeerStateDisconnected:
            NSLog(@"%@", @"Peer state changed - disconnected");
            // 切断を通知
            currentSession = nil;
            self.isConnecting = NO;
            [self.delegate connectionManagerDidDisconnect:self];
            break;
            
        case GKPeerStateUnavailable:
            NSLog(@"%@", @"Peer state changed - unavailable");
            break;
            
        default:
            break;
    }
}

- (void)receiveData:(NSData *)data
           fromPeer:(NSString *)peer
          inSession:(GKSession *)session
            context:(void *)context
{
    // データ受信を通知
    [self.delegate connectionManager:self
                      didReceiveData:data
                            fromPeer:peer];
}

#pragma mark - Public methods

- (void)connect
{
    // ピアピッカーを作成
    GKPeerPickerController* picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    // 接続タイプはBluetoothのみ
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    // ピアピッカーを表示
    [picker show];
}

- (void)disconnect
{
    if (currentSession)
    {
        // P2P接続を切断する
        [currentSession disconnectFromAllPeers];
        currentSession = nil;
    }
    self.isConnecting = NO;
    // 切断を通知
    [self.delegate connectionManagerDidDisconnect:self];
}

- (void)sendDataToAllPeers:(NSData *)data
{
    if (currentSession)
    {
        NSError *error = nil;
        // 接続中の全てのピアにデータを送信
        [currentSession sendDataToAllPeers:data
                              withDataMode:GKSendDataReliable
                                     error:&error];
        if (error)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

@end
