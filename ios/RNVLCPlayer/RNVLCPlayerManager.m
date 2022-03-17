#import "RNVLCPlayerManager.h"
#import "RNVLCPlayer.h"
#import "React/RCTBridge.h"

@implementation RNVLCPlayerManager

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

- (UIView *)view
{
    return [[RNVLCPlayer alloc] initWithEventDispatcher:self.bridge.eventDispatcher];
}

/* Should support: onLoadStart, onLoad, and onError to stay consistent with Image */
RCT_EXPORT_VIEW_PROPERTY(onVideoProgress, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoPaused, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoStopped, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoBuffering, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoPlaying, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoEnded, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoError, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoOpen, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoLoadStart, RCTDirectEventBlock);

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary);

@end
