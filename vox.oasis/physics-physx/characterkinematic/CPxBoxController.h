//
//  CPxBoxController.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/9.
//

#ifndef CPxBoxController_h
#define CPxBoxController_h

#import "CPxController.h"

@interface CPxBoxController : CPxController

- (float)getHalfHeight;

- (float)getHalfSideExtent;

- (float)getHalfForwardExtent;

- (bool)setHalfHeight:(float)halfHeight;

- (bool)setHalfSideExtent:(float)halfSideExtent;

- (bool)setHalfForwardExtent:(float)halfForwardExtent;

@end

#endif /* CPxBoxController_h */
