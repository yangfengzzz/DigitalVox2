//
//  imgui_bridge.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/7.
//

#import "imgui_bridge.h"
#import "imgui_impl_metal.h"
#import "imgui_impl_osx.h"

@implementation IMGUI

- (void)createWith:(MTKView *)view :(id <MTLDevice>)device {
    // Setup Dear ImGui context
    // FIXME: This example doesn't have proper cleanup...
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO &io = ImGui::GetIO();
    (void) io;
    //io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls
    //io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls

    // Setup Dear ImGui style
    ImGui::StyleColorsDark();
    //ImGui::StyleColorsClassic();

    // Setup Renderer backend
    ImGui_ImplMetal_Init(device);

    //MARK: -
    // Add a tracking area in order to receive mouse events whenever the mouse is within the bounds of our view
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                                options:NSTrackingMouseMoved | NSTrackingInVisibleRect | NSTrackingActiveAlways
                                                                  owner:view
                                                               userInfo:nil];
    [view addTrackingArea:trackingArea];

    // If we want to receive key events, we either need to be in the responder chain of the key view,
    // or else we can install a local monitor. The consequence of this heavy-handed approach is that
    // we receive events for all controls, not just Dear ImGui widgets. If we had native controls in our
    // window, we'd want to be much more careful than just ingesting the complete event stream.
    // To match the behavior of other backends, we pass every event down to the OS.
    NSEventMask eventMask = NSEventMaskKeyDown | NSEventMaskKeyUp | NSEventMaskFlagsChanged;
    [NSEvent addLocalMonitorForEventsMatchingMask:eventMask handler:^NSEvent *_Nullable(NSEvent *event) {
        ImGui_ImplOSX_HandleEvent(event, view);
        return event;
    }];

    ImGui_ImplOSX_Init();
}

- (void)prepareInMTKView:(MTKView *_Nonnull)view {
    ImGuiIO &io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;

    CGFloat framebufferScale = view.window.screen.backingScaleFactor ?: NSScreen.mainScreen.backingScaleFactor;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);

    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 60);

    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    // Start the Dear ImGui frame
    ImGui_ImplMetal_NewFrame(renderPassDescriptor);

    ImGui_ImplOSX_NewFrame(view);

    ImGui::NewFrame();
}

- (void)drawInMTKView:(MTKView *)view :(id <MTLCommandBuffer>)commandBuffer :(id <MTLRenderCommandEncoder>)commandEncoder {
    ImGui::Render();
    ImDrawData *draw_data = ImGui::GetDrawData();

    [commandEncoder pushDebugGroup:@"Dear ImGui rendering"];
    ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, commandEncoder);
    [commandEncoder popDebugGroup];
}

- (bool)handleEvent:(NSEvent *_Nonnull)event :(NSView *_Nullable)view {
    return ImGui_ImplOSX_HandleEvent(event, view);
}

//MARK: - Widgets
- (void)Begin:(NSString *_Nonnull)fmt {
    ImGui::Begin([fmt cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)End {
    ImGui::End();
}

- (void)Text:(NSString *_Nonnull)fmt {
    ImGui::Text("%s", [fmt cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)ShowFrameRate {
    ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
}

- (void)SliderFloat:(NSString *_Nonnull)fmt :(float *)value :(float)min :(float)max {
    ImGui::SliderFloat([fmt cStringUsingEncoding:NSUTF8StringEncoding], value, min, max);
}

@end
