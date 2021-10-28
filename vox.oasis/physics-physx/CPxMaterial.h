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

- (void)setStaticFriction:(float)coef;

- (void)setRestitution:(float)rest;

- (void)setFrictionCombineMode:(int)combMode;

- (void)setRestitutionCombineMode:(int)combMode;

@end

#endif /* CPxMaterial_h */
