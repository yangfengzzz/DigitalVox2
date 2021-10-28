//
//  CPxMaterial.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/28.
//

#ifndef CPxMaterial_h
#define CPxMaterial_h

#import <Foundation/Foundation.h>

@interface CPxMaterial : NSObject

- (void)setDynamicFriction:(float)coef;

- (float)getDynamicFriction;

- (void)setStaticFriction:(float)coef;

- (float)getStaticFriction;

- (void)setRestitution:(float)rest;

- (float)getRestitution;

- (void)setFrictionCombineMode:(int)combMode;

- (int)getFrictionCombineMode;

- (void)setRestitutionCombineMode:(int)combMode;

- (int)getRestitutionCombineMode;

@end

#endif /* CPxMaterial_h */
