//
//  CPxCapsuleController.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/9.
//

#ifndef CPxCapsuleController_h
#define CPxCapsuleController_h

#import "CPxController.h"
#import "CPxCapsuleControllerDesc.h"

@interface CPxCapsuleController : CPxController

- (float)getRadius;

- (bool)setRadius:(float)radius;

- (float)getHeight;

- (bool)setHeight:(float)height;

- (enum CPxCapsuleClimbingMode)getClimbingMode;

- (bool)setClimbingMode:(enum CPxCapsuleClimbingMode)mode;

@end

#endif /* CPxCapsuleController_h */
