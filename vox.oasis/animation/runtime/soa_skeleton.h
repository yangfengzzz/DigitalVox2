//
//  soa_skeleton.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/7.
//

#ifndef soa_skeleton_h
#define soa_skeleton_h

#import <Foundation/Foundation.h>
#import "../maths/soa_float.h"

@interface SoaSkeletonLoader : NSObject

- (bool)LoadSkeleton:(nullable const NSString *)_filename;

-(size_t) NumberOfNames;

-(NSString *_Nonnull) NameWithIndex:(size_t)index;

-(size_t) NumberOfParents;

-(void) ParentWithIndex:(size_t)index :(size_t *_Nonnull) parent;

-(size_t) NumberOfBindPose;

-(void) PoseWithIndex:(size_t)index :(struct SoaTransform *_Nonnull) pose;

@end

#endif /* soa_skeleton_h */
