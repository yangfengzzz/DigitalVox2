//
//  CPxSpring.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxSpring_h
#define CPxSpring_h

#import <Foundation/Foundation.h>

@interface CPxSpring : NSObject
//!< the spring strength of the drive: that is, the force proportional to the position error
@property(nonatomic, assign) float stiffness;
//!< the damping strength of the drive: that is, the force proportional to the velocity error
@property(nonatomic, assign) float damping;
@end

#endif /* CPxSpring_h */
