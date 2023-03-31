#import <Foundation/Foundation.h>
#import "VideoViewController.h"
#import "TextureRenderer.h"
#import <AgoraRtcWrapper/iris_engine_base.h>
#import <AgoraRtcWrapper/iris_video_processor_cxx.h>

@interface VideoViewController ()
@property(nonatomic, weak) NSObject<FlutterTextureRegistry> *textureRegistry;
@property(nonatomic, weak) NSObject<FlutterBinaryMessenger> *messenger;
@property(nonatomic) NSMutableDictionary<NSNumber *, TextureRender *> *textureRenders;

@property(nonatomic, strong) FlutterMethodChannel *methodChannel;
@end

@implementation VideoViewController

- (instancetype)initWith:(NSObject<FlutterTextureRegistry> *)textureRegistry
               messenger: (NSObject<FlutterBinaryMessenger> *)messenger {
    self = [super init];
    if (self) {
      self.textureRegistry = textureRegistry;
      self.messenger = messenger;
      self.textureRenders = [NSMutableDictionary new];
        
        self.methodChannel = [FlutterMethodChannel
            methodChannelWithName:
                                  @"agora_rtc_ng/video_view_controller"
                  binaryMessenger:messenger];
        
        __weak typeof(self) weakSelf = self;
        [self.methodChannel setMethodCallHandler:^(FlutterMethodCall *_Nonnull call,
                                                   FlutterResult _Nonnull result) {
          if (weakSelf != nil) {
            [weakSelf onMethodCall:call result:result];
          }
        }];
        


    }
    return self;
}

- (void)onMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"createTextureRender" isEqualToString:call.method]) {
      NSDictionary *data = call.arguments;
      NSNumber *videoFrameBufferManagerNativeHandle = data[@"videoFrameBufferManagerNativeHandle"];
      NSNumber *uid = data[@"uid"];
      NSString *channelId = data[@"channelId"];
      NSNumber *videoSourceType = data[@"videoSourceType"];

      int64_t textureId = [self createTextureRender:(intptr_t)[videoFrameBufferManagerNativeHandle longLongValue]
                                                uid:uid
                                          channelId:channelId
                                    videoSourceType:videoSourceType];
      result(@(textureId));
  } else if ([@"destroyTextureRender" isEqualToString:call.method]) {
      NSNumber *textureIdValue = call.arguments;
      BOOL success = [self destroyTextureRender: [textureIdValue longLongValue]];
      result(@(success));
  } else if ([@"updateTextureRenderData" isEqualToString:call.method]) {
      NSDictionary *data = call.arguments;
      int64_t textureId = [data[@"uid"] longLongValue];
      NSNumber *uid = data[@"uid"];
      NSString *channelId = data[@"channelId"];
      NSNumber *videoSourceType = data[@"videoSourceType"];
      
      [self updateTextureRenderData:textureId uid:uid channelId:channelId  videoSourceType:videoSourceType];
      result(@(YES));
  }
}

- (int64_t)createPlatformRender {
    return 0;
}

- (BOOL)destroyPlatformRender:(int64_t)platformRenderId {
    return true;
}

- (int64_t)createTextureRender:(intptr_t)videoFrameBufferManagerIntPtr
                           uid:(NSNumber *)uid
                     channelId:(NSString *)channelId
               videoSourceType:(NSNumber *)videoSourceType {
    agora::iris::IrisVideoFrameBufferManager *videoFrameBufferManager = reinterpret_cast<agora::iris::IrisVideoFrameBufferManager *>(videoFrameBufferManagerIntPtr);
    TextureRender *textureRender = [[TextureRender alloc]
        initWithTextureRegistry:self.textureRegistry
                      messenger:self.messenger
                       videoFrameBufferManager:videoFrameBufferManager];
    int64_t textureId = [textureRender textureId];
    [textureRender updateData:uid channelId:channelId videoSourceType:videoSourceType];
    __weak typeof(self) weakSelf = self;
        textureRender.textureUnregisteredCallback = ^(){
            NSLog(@"textureRenders is removed callback");
            [weakSelf.textureRenders removeObjectForKey:@(textureId)];
        };
    self.textureRenders[@(textureId)] = textureRender;
    return textureId;
}

- (void)updateTextureRenderData:(int64_t)textureId uid:(NSNumber *)uid channelId:(NSString *)channelId videoSourceType:(NSNumber *)videoSourceType {
    [self.textureRenders[@(textureId)] updateData:uid channelId:channelId videoSourceType:videoSourceType];
}

- (BOOL)destroyTextureRender:(int64_t)textureId {
    TextureRender *textureRender = [self.textureRenders objectForKey:@(textureId)];
    if (textureRender != nil) {
        NSLog(@"%s",__func__);
      [textureRender dispose];
      return YES;
    }
    return NO;
}

@end
