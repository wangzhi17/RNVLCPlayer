#import "React/RCTConvert.h"
#import "RNVLCPlayer.h"
#import "React/RCTBridgeModule.h"
#import "React/RCTEventDispatcher.h"
#import "React/UIView+React.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import <AVFoundation/AVFoundation.h>
#import "hcnetsdk.h"
#import "LinuxPlayM4.h"

static NSString *const statusKeyPath = @"status";
static NSString *const playbackLikelyToKeepUpKeyPath = @"playbackLikelyToKeepUp";
static NSString *const playbackBufferEmptyKeyPath = @"playbackBufferEmpty";
static NSString *const readyForDisplayKeyPath = @"readyForDisplay";
static NSString *const playbackRate = @"rate";

@implementation RNVLCPlayer
{
    /* Required to publish events */
    RCTEventDispatcher *_eventDispatcher;
    VLCMediaPlayer *_vlcPlayer;

    NSDictionary * _source;

    AVPlayer *player;
    AVPlayerLayer *avLayer;
    BOOL _paused;
    BOOL _started;
}

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher
{
    if ((self = [super init])) {
        _eventDispatcher = eventDispatcher;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if (!_paused) {
        [self setPaused:_paused];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    //NSLog(@"开始预览");
    [self play];
}

- (void)setPaused:(BOOL)paused
{
    if(player){
        [player pause];
        stopPreview(previewID);
        //NSLog(@"停止预览");
        _paused =  YES;
        _started = NO;
    }
    if(_vlcPlayer){
        [_vlcPlayer pause];
        _paused =  YES;
        _started = NO;
    }
}

bool stopPreview(LONG previewID)
{
   return NET_DVR_StopRealPlay(previewID);
}
LONG previewID = -1;

NSString* dvrType = @"";

-(void)setSource:(NSDictionary *)source
{
    @try {
        if(player){
            [self _release];
        }
        _source = source;

        // [bavv edit start]
        NSString* uri = [source objectForKey:@"uri"];
        player=[AVPlayer new];
        avLayer=[AVPlayerLayer playerLayerWithPlayer:player];

        NSArray* info = [uri componentsSeparatedByString:@"-"];
        NSString* type = info[0];
        if([type  isEqual: @"hk"]){
            dvrType = @"hk";
            NSString* ip = info[1];
            NSString* userName = info[2];
            NSString* password = info[3];
            NSString* port = info[4];
            channel = [info[5] integerValue];
            dwStreamType = [info[6] integerValue];

            NET_DVR_DEVICEINFO_V40 logindeviceInfo = {0};

            NET_DVR_USER_LOGIN_INFO struLoginInfo = {0};

            strcpy(struLoginInfo.sDeviceAddress, (char*)[ip UTF8String]);
            struLoginInfo.wPort = [port integerValue];
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            strcpy(struLoginInfo.sUserName, (char*)[userName cStringUsingEncoding:enc]);
            strcpy(struLoginInfo.sPassword, (char*)[password UTF8String]);

            m_lUserID = NET_DVR_Login_V40(&struLoginInfo, &logindeviceInfo);

            if(m_lUserID == -1)
            {
                return ;
            }
            if(logindeviceInfo.struDeviceV30.byStartDChan == 33)
                channel += 32;
        }else{
            VLCMedia *media = [VLCMedia mediaWithURL:info[1]];
            _vlcPlayer = [VLCMediaPlayer new];
            [_vlcPlayer setDrawable:self];
            _vlcPlayer.delegate = (id) self;
            _vlcPlayer.scaleFactor = 0;
            _vlcPlayer.media = media;

        }
        self.onVideoLoadStart(@{
                               @"target": self.reactTag
                               });
        [self play];
    } @catch (NSException *exception) {

    }

}

LONG channel = -1;
LONG dwStreamType = -1 ;

LONG m_lUserID = -1;
int port = -1;

LONG startPreview(LONG lUserID,LONG channel,int dwStreamType, UIView *pView)
{
    NET_DVR_PREVIEWINFO lpPreviewInfo={0};
    lpPreviewInfo.lChannel = channel;
    lpPreviewInfo.dwStreamType = dwStreamType;
    lpPreviewInfo.bBlocked = 0;
    lpPreviewInfo.bPassbackRecord = 0;
    lpPreviewInfo.byPreviewMode = 0;
    lpPreviewInfo.hPlayWnd = (__bridge HWND)pView;
    previewID = NET_DVR_RealPlay_V40(lUserID, &lpPreviewInfo,NULL,NULL);
    return previewID;
}
-(void)play
{

    if([dvrType isEqual: @"hk"]){
        if(player){
            [player play];
            startPreview(m_lUserID, channel,dwStreamType, self);
            _paused = NO;
            _started = YES;
        }
        return;
    }

    if(_vlcPlayer){
        [_vlcPlayer play];
        //NSLog(@"播放");
    }
    _paused = NO;
    _started = YES;
}
- (void)_release
{
    if([dvrType  isEqual: @"hk"]){
        if(player){
            [player pause];
            stopPreview(previewID);
            NET_DVR_Logout(m_lUserID);
            dvrType = @"";
            channel = -1;
            m_lUserID = -1;
            dwStreamType = -1;
            player = nil;
            port = -1;
        }
    }
    else if(_vlcPlayer){
            [_vlcPlayer pause];
            [_vlcPlayer stop];
        }
        //注销登录并清理资源

    _eventDispatcher = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Lifecycle
- (void)removeFromSuperview
{
    //NSLog(@"removeFromSuperview");
    [self _release];
    [super removeFromSuperview];
}
@end
