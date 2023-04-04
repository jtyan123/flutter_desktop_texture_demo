#import <Foundation/Foundation.h>
#import "TextureRenderer.h"
@interface TextureRender ()
{
    CVPixelBufferRef _pixelBufferRef;
}
@end


@implementation TextureRender

- (instancetype)init {
    self = [super init];
    //获取渲染本地图片
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSImage *image = [testBundle imageForResource:@"1"];
    if (image != nil) {
        _pixelBufferRef = [self CVPixelBufferRefFromUiImage:image];
    }
    return self;
}
    

- (void)dealloc {
    NSLog(@"%s",__func__);
}


static OSType inputPixelFormat(){
    return kCVPixelFormatType_32BGRA;
}

static uint32_t bitmapInfoWithPixelFormatType(OSType inputPixelFormat, bool hasAlpha){
    
    if (inputPixelFormat == kCVPixelFormatType_32BGRA) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        if (!hasAlpha) {
            bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
        }
        return bitmapInfo;
    }else if (inputPixelFormat == kCVPixelFormatType_32ARGB) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big;
        return bitmapInfo;
    }else{
        NSLog(@"不支持此格式");
        return 0;
    }
}


BOOL CGImageRefContainsAlpha(CGImageRef imageRef) {
    if (!imageRef) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}

- (nullable CGImageRef)CGImage:(NSImage *)img{
    NSRect imageRect = NSMakeRect(0, 0, img.size.width, img.size.height);
    CGImageRef cgImage = [img CGImageForProposedRect:&imageRect context:nil hints:nil];
    return cgImage;
}

- (CVPixelBufferRef)CVPixelBufferRefFromUiImage:(NSImage *)img {
    CGSize size = img.size;
    CGImageRef image = [self CGImage:img];
    
    BOOL hasAlpha = CGImageRefContainsAlpha(image);
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             empty, kCVPixelBufferIOSurfacePropertiesKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, inputPixelFormat(), (__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    uint32_t bitmapInfo = bitmapInfoWithPixelFormatType(inputPixelFormat(), (bool)hasAlpha);
    
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace, bitmapInfo);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    return pxbuffer;
}


#pragma mark - FlutterTexture
- (CVPixelBufferRef _Nullable)copyPixelBuffer {
    NSLog(@"%s",__func__);
    if (_pixelBufferRef != nil) {
        return CVPixelBufferRetain(_pixelBufferRef);
    }
    
    return nil;
}

- (void)onTextureUnregistered:(NSObject<FlutterTexture> *)texture {
    NSLog(@"%s",__func__);
    if (_pixelBufferRef != nil) {
        CVPixelBufferRelease(_pixelBufferRef);
        _pixelBufferRef = nil;
    }
    if (self.textureUnregisteredCallback) {
        self.textureUnregisteredCallback();
    }
}

@end

