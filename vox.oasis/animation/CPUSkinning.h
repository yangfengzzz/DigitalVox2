//
//  CPUSkinning.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/21.
//

#ifndef CPUSkinning_h
#define CPUSkinning_h

#import <Foundation/Foundation.h>

@class MDLVertexDescriptor;
@protocol MTLDevice, MTLBuffer;

@interface CCPUSkinning : NSObject

- (bool)OnInitialize:(NSString *_Nonnull)OPTIONS_skeleton :(NSString *_Nonnull)OPTIONS_mesh;

- (bool)LoadAnimation:(NSString *_Nonnull)OPTIONS_animation;

- (bool)OnUpdate:(float)_dt;

- (bool)FreshSkinnedMesh:(id <MTLDevice> _Nonnull)device
        :(void (^ _Nullable)(NSArray<id <MTLBuffer>> *_Nonnull vertexBuffer, id <MTLBuffer> _Nonnull indexBuffer, size_t indexCount,
                MDLVertexDescriptor *_Nonnull descriptor))meshInfo;


@end

#endif /* CPUSkinning_h */
