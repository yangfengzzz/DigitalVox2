//
//  imgui_bridge.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/7.
//

#ifndef imgui_bridge_h
#define imgui_bridge_h

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface IMGUI : NSObject

- (void)createWith:(MTKView *_Nonnull)view :(id <MTLDevice> _Nonnull)device;

- (void)prepareInMTKView:(MTKView *_Nonnull)view;

- (void)drawInMTKView
        :(MTKView *_Nonnull)view
        :(id <MTLCommandBuffer> _Nonnull)commandBuffer
        :(id <MTLRenderCommandEncoder> _Nonnull)commandEncoder;

- (bool)handleEvent:(NSEvent *_Nonnull)event :(NSView *_Nullable)view;

//MARK: - Widgets
- (void)Begin:(NSString *_Nonnull)fmt;

- (void)End;

- (void)Text:(NSString *_Nonnull)fmt;

- (void)ShowFrameRate;

- (void)SliderFloat:(NSString *_Nonnull)fmt :(float *_Nonnull)value :(float)min :(float)max;


@end


#endif /* imgui_bridge_h */
