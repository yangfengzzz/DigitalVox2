//
//  CPxJointLinearLimit.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxJointLinearLimit_h
#define CPxJointLinearLimit_h

#import <Foundation/Foundation.h>
#import "CPxSpring.h"
#import "CPxTolerancesScale.h"

@interface CPxJointLinearLimit : NSObject

- (instancetype)initWithHardLimit:(struct CPxTolerancesScale)scale :(float)extent :(float)contactDist;

- (instancetype)initWithSoftLimit:(float)extent :(CPxSpring *)spring;

@end

#endif /* CPxJointLinearLimit_h */
