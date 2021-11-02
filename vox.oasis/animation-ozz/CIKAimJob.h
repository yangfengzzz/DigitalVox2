//
//  CIKAimJob.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/2.
//

#ifndef CIKAimJob_h
#define CIKAimJob_h

#import <Foundation/Foundation.h>
#import <simd/simd.h>

@interface CIKAimJob : NSObject

/// Target position to aim at, in model-space
@property(nonatomic, assign) simd_float4 target;

- (bool)Run;

@end

#endif /* CIKAimJob_h */
