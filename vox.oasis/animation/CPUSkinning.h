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

- (bool)LoadSkeleton:(NSString *_Nonnull)filename;

- (bool)loadSkin:(NSString *_Nonnull)filename;

- (bool)LoadAnimation:(NSString *_Nonnull)filename;

- (bool)OnUpdate:(float)_dt;

- (bool)FreshSkinnedMesh:(id <MTLDevice> _Nonnull)device
        :(void (^ _Nullable)(NSArray<id <MTLBuffer>> *_Nonnull vertexBuffer, id <MTLBuffer> _Nonnull indexBuffer, size_t indexCount,
                MDLVertexDescriptor *_Nonnull descriptor))meshInfo;

- (void)UpdateWeight:(int)index :(float)weight;

@end

#endif /* CPUSkinning_h */
