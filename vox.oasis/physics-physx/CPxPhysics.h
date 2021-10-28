//
//  CPxPhysics.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/28.
//

#ifndef CPxPhysics_h
#define CPxPhysics_h

#import <Foundation/Foundation.h>
#import "CPxMaterial.h"

@interface CPxPhysics : NSObject
- (CPxMaterial *)createMaterialWithStaticFriction:(float)staticFriction
                                  dynamicFriction:(float)dynamicFriction
                                      restitution:(float)restitution;
@end

#endif /* CPxPhysics_h */
