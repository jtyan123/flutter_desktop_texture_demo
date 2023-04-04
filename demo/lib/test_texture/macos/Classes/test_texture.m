
#import "test_texture.h"
#import <AVFoundation/AVFoundation.h>
#import "TextureRenderer.h"
#pragma mark - TestTexturePlugin

@interface TestTexturePlugin ()
@property(nonatomic, weak) id<FlutterTextureRegistry> textureRegistrar;
@property(nonatomic) NSMutableDictionary<NSNumber *, TextureRender *> *textureRenders;

@end

@implementation TestTexturePlugin

+ (void)registerWithRegistrar:(id<FlutterPluginRegistrar>)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"test_texture"
                                     binaryMessenger:[registrar messenger]];
    TestTexturePlugin *instance = [[TestTexturePlugin alloc] init];
    instance.textureRegistrar = registrar.textures;
    instance.textureRenders = [NSMutableDictionary dictionary];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        NSOperatingSystemVersion systemVer =[[NSProcessInfo processInfo] operatingSystemVersion];
        NSString *systemVersion = [NSString stringWithFormat:@"%ld.%ld.%ld",
                                   (long)systemVer.majorVersion, (long)systemVer.minorVersion, (long)systemVer.patchVersion];
        result([@"macOS " stringByAppendingString:systemVersion]);
    }
    else if ([@"createTextureRender" isEqualToString:call.method]) {
        TextureRender *render = [[TextureRender alloc] init];
        int64_t textureId = [self.textureRegistrar registerTexture:render];
        NSLog(@"%s createTextureRender:%lld",__func__,textureId);
        __weak typeof(self) weakSelf = self;
        render.textureUnregisteredCallback = ^(){
            NSLog(@"unregistered callback");
            [weakSelf.textureRenders removeObjectForKey:@(textureId)];
        };
        self.textureRenders[@(textureId)] = render;
        result(@(textureId));
    } else if ([@"destroyTextureRender" isEqualToString:call.method]) {
        NSNumber *textureIdValue = call.arguments;
        TextureRender *render = [self.textureRenders objectForKey:textureIdValue];
        if (render != nil) {
            NSLog(@"%s destroyTextureRender:%lld",__func__,textureIdValue.longLongValue);
            [self.textureRegistrar unregisterTexture:textureIdValue.longLongValue];
        }
        result(@(YES));
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}


@end
