//
//  ViewController.m
//  BallRolling
//
//  Created by Ryosei Takahashi on 2015/03/14.
//  Copyright (c) 2015年 Ryosei Takahashi. All rights reserved.
//

#import "ViewController.h"
#import "BGMManager.h"

@interface ViewController (){
    ConnectionManager *connectionManager;
    
    IBOutlet UIImageView *base;
    
    // 玉の画像用
    IBOutlet UIImageView *gem;
    
    // スタートの画像用
    IBOutlet UIImageView *start;
    
    // ゴールの画像用
    IBOutlet UIImageView *goal;
    IBOutlet UIImageView *goal2;
    IBOutlet UIImageView *goal3;
    
    
    BGMManager *bGMKanri;
    // 障害物1~6の画像用
    
    IBOutlet UIImageView *pin1;
    IBOutlet UIImageView *pin2;
    IBOutlet UIImageView *pin3;
    IBOutlet UIImageView *pin4;
    IBOutlet UIImageView *pin5;
    IBOutlet UIImageView *pin6;
    // ゲームオーバーの画像用
    IBOutlet UIImageView *game_over;
    
    // スコア表示用のラベル
    IBOutlet UILabel *scoreLabel;
    
    // スタートボタン
    IBOutlet UIButton *startButton;
    
    
    // あそびを付けた各軸座標の値
    UIAccelerationValue accelX, accelY, accelZ;
    // CoreMotionを利用するためのオブジェクト
    CMMotionManager *motionManager;
    // 玉の加速度
    CGSize vec;
    
    // タイマー
    NSTimer *aTimer;
    
    //　スコア計算用
    NSInteger score;

}

@end


#pragma mark - View lifecycle methods
 
@implementation ViewController
@synthesize connectButton;


// タイマーをストップさせるメソッド
-(void)stopTimer {
    //　もしタイマーが存在するとき
    if ( aTimer ) {
        //　タイマーを無効にする
        [aTimer invalidate];
        //　タイマーに何もセットしない
        aTimer = nil;
    }
}
// タイマーを開始するメソッド
-(void)startTimer {
    //　もしタイマーが存在するなら
    if ( aTimer )
        //タイマーを終了させるメソッドを呼ぶ
        [self stopTimer];
    
    //タイマーをセットする
    aTimer = [NSTimer scheduledTimerWithTimeInterval:
              kTimerInterval target:self selector:@selector(tick:)
                                            userInfo:nil repeats:YES];
}


//　スタートボタンが押されたときに呼ばれるメソッド
-(IBAction)doStart:(id)sender {
    [startButton setHidden:YES];
    //　ゲームオーバー用の画像を非表示にする
    [game_over setHidden:YES];
    //　玉をスタート画像の上に配置する
    [gem setCenter:[start center]];
    //　加速度を0にする
    vec = CGSizeMake(0.0f, 0.0f);
    //　スコアの初期値を200にする
    score = 200;
    //　スコア計算のメソッドを呼び、最初の減算を0にする
    [self calcScore:0];
    //　加速度センサを開始する
    [self startAccelerometer];
    [self startTimer];
    bGMKanri = [BGMManager new];
    [bGMKanri startBGM:@"Skyward.mp3"];
}


//終了するときに呼ばれるメソッド
-(void)doStop {
    [startButton setHidden:NO];
    //ゲームオーバー用の画像を表示させる
    [game_over setHidden:NO];
    //　加速度センサを終了する
    [self stopAccelerometer];
    [self stopTimer];
}


// タイマーを使って玉を動かすメソッド
- (void)tick:(NSTimer *)theTimer {
    //　ボールの中心点のx座標に加速度で取得した値を加算する
    CGFloat x = [gem center].x+vec.width;
    //　ボールの中心点y座標に加速度で取得した値を加算する
    CGFloat y = [gem center].y+vec.height;
    // もし、移動先の座標（ボールの半径も加味）が320よりも大きい時
    if ( (x+kRadius) > 320 ) {
        // 反射させるための座標を設定
        //　点数を減点する処理
        [self calcScore:(-10)];
        vec.width = fabs(vec.width)*(-1) * kWallRefPower;
        //　玉を移動させる先の座標
        x = [gem center].x+vec.width;
    }
    if ( (x-kRadius) < 0 ) {
        [self calcScore:(-10)];
        vec.width = fabs(vec.width)*kWallRefPower;
        x = [gem center].x+vec.width;
    }
    //画面サイズ（縦の幅）を取得（iPhone5も考慮して端末の画面サイズを取得）
    int screenSizeHeight =[[UIScreen mainScreen]bounds].size.height;
    if ( (y+kRadius) > screenSizeHeight ) {
        [self calcScore:(-10)];
        vec.height = fabs(vec.height)*(-1) * kWallRefPower;
        y = [gem center].y+vec.height;
    }
    if ( (y-kRadius) < 0 ) {
        [self calcScore:(-10)];
        vec.height = fabs(vec.height)* kWallRefPower;
        y = [gem center].y+vec.height;
    }
    
    // checkPinメソッドを呼び、障害物のピンの情報も読み込む
    [self checkPin:pin1];
    [self checkPin:pin2];
    [self checkPin:pin3];
    [self checkPin:pin4];
    [self checkPin:pin5];
    [self checkPin:pin6];
    
    [self checkGoal];
    [self checkGoal2];
    [self checkGoal3];
    //　玉の中心座標を指定する
    [gem setCenter:CGPointMake(x,y)];
}


//　スコアを計算するメソッド
-(void)calcScore:(NSInteger)value {
    //　スコアの合計を計算する
    score += value;
    //　もし、スコアが0点以上なら
    if ( score > 0 ) {
        //　スコアのラベルに点数を表示する
        [scoreLabel setText:[NSString stringWithFormat:@"%d",score]];
        //　それ以外なら
    } else {
        //　スコアラベルに0点と表示させる
        [scoreLabel setText:@"0"];
        //　ゲームを終了するメソッドを呼ぶ
        [self doStop];
    }
}


//　加速度に変化が起こったときに呼ばれるメソッド
- (void)didAccelerate:(CMAcceleration)acceleratio
{
    // 取得した加速度の値に制限を加えて「あそび」をつくる（x,y,z軸それぞれ）
    accelX = (accelX * kFilteringFactor) + (acceleratio.x * (1.0f - kFilteringFactor));
    accelY = (accelY * kFilteringFactor) + (acceleratio.y * (1.0f - kFilteringFactor));
    accelZ = (accelZ * kFilteringFactor) + (acceleratio.z * (1.0f - kFilteringFactor));
    //　加速度により玉を動かすための座標を生成する
    vec = CGSizeMake(vec.width+accelX, vec.height-accelY);
}


//　ゴールを判別するメソッド
-(void)checkGoal {
    //　ゴールと玉の距離を計算する
    CGFloat dx = ([goal center].x - [gem center].x);
    CGFloat dy = ([goal center].y - [gem center].y);
    //　もし、ゴールと玉の距離が一定距離以下になったら
    if ( sqrt(dx*dx+dy*dy) < 12 ) {
        //　スコアに100点加算する
        [self calcScore:(+100)];
        // ゴールの中心の座標を取得する
        CGPoint pos = [goal center];
        //　ゴールの中心点を、スタート画像の中心点に移動させる
        [goal setCenter:[start center]];
        // スタート画像を、ゴールの中心点があった場所に移動する
        [start setCenter:pos];
    }
}


//　ゴール2を判別するメソッド
-(void)checkGoal2 {
    //　ゴールと玉の距離を計算する
    CGFloat dx = ([goal2 center].x - [gem center].x);
    CGFloat dy = ([goal2 center].y - [gem center].y);
    //　もし、ゴールと玉の距離が一定距離以下になったら
    if ( sqrt(dx*dx+dy*dy) < 12 ) {
        //　スコアに100点加算する
        [self calcScore:(+100)];
        // ゴールの中心の座標を取得する
        CGPoint pos = [goal2 center];
        //　ゴールの中心点を、スタート画像の中心点に移動させる
        [goal2 setCenter:[start center]];
        // スタート画像を、ゴールの中心点があった場所に移動する
        [start setCenter:pos];
    }
}

//　ゴール3を判別するメソッド
-(void)checkGoal3 {
    //　ゴールと玉の距離を計算する
    CGFloat dx = ([goal3 center].x - [gem center].x);
    CGFloat dy = ([goal3 center].y - [gem center].y);
    //　もし、ゴールと玉の距離が一定距離以下になったら
    if ( sqrt(dx*dx+dy*dy) < 12 ) {
        //　スコアに100点加算する
        [self calcScore:(+100)];
        // ゴールの中心の座標を取得する
        CGPoint pos = [goal3 center];
        //　ゴールの中心点を、スタート画像の中心点に移動させる
        [goal3 setCenter:[start center]];
        // スタート画像を、ゴールの中心点があった場所に移動する
        [start setCenter:pos];
    }
}


//　加速度センサを終了するメソッド
-(void)stopAccelerometer {
    // 加速度センサを終了する
    [motionManager stopAccelerometerUpdates];
}

//　加速度センサを開始するメソッド
-(void)startAccelerometer {
    //　加速度センサを利用するために読み込む
    motionManager = [[CMMotionManager alloc] init];
    //　加速度センサを読み込む間隔を設定
    motionManager.accelerometerUpdateInterval = (1.0f / kAccelerometerFrequency);
    //　加速度に変化が起きたときに実行される処理を指定
    CMAccelerometerHandler acceleHandler = ^(CMAccelerometerData *data, NSError *error) {
        [self didAccelerate:data.acceleration];
    };
    //　加速度センサを開始する
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:acceleHandler];
}


//ピンの当たり判定判別メソッド
- (void)checkPin:(UIImageView *)pin {
    //　ピンと玉の距離を求める
    CGFloat dx = ([pin center].x - [gem center].x);
    CGFloat dy = ([pin center].y - [gem center].y);
    //　もし、ピンと玉の距離が一定以上近づいたら
    if ( sqrt(dx*dx+dy*dy) < (9+kRadius) ) {
        CGFloat inp =  vec.width*dx+vec.height*dy;
        if ( inp > 0 ) {
            //　スコアから10点減点する処理
            [self calcScore:(-10)];
            //　内積を使ったベクトル演算
            CGFloat ddl = dx*dx+dy*dy;
            //　跳ね返りの度合いを加味して方向を反転させる
            vec.width -= dx * inp / ddl * kRefPwoer;
            vec.height -= dy * inp / ddl * kRefPwoer;
        }
    }
}

- (void)connectionManagerDidConnect:(ConnectionManager *)manager
{
    connectButton.title = @"切断";
}

- (void)connectionManagerDidDisconnect:(ConnectionManager *)manager
{
    connectButton.title = @"接続";
}


- (IBAction)connectButonTouched:(id)sender
{
    if (connectionManager.isConnecting)
    {
        [connectionManager disconnect];
    }
    else
    {
        [connectionManager connect];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //　ステータスバーを隠す
    [UIApplication sharedApplication].statusBarHidden = YES;
    connectButton.title = @"接続";
    // P2P接続のマネージャーを生成
    connectionManager = [[ConnectionManager alloc] init];
    connectionManager.delegate = self;
}


- (void)viewDidUnload
{
    connectionManager.delegate = nil;
    connectionManager = nil;
    [self setConnectButton:nil];
    [super viewDidUnload];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
