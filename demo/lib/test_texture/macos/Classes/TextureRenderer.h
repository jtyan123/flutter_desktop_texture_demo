#ifndef TextureRenderer_h
#define TextureRenderer_h

#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#else
#import <FlutterMacOS/FlutterMacOS.h>
#endif

@interface TextureRender : NSObject<FlutterTexture>
@property(nonatomic, copy)dispatch_block_t textureUnregisteredCallback;
@end


#endif /* TextureRenderer_h */
