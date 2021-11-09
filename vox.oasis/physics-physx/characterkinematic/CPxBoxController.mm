//
//  CPxBoxController.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/9.
//

#import "CPxBoxController.h"
#import "CPxController+Internal.h"

@implementation CPxBoxController

- (float)getHalfHeight {
    return static_cast<PxBoxController *>(super.c_controller)->getHalfHeight();
}

- (float)getHalfSideExtent {
    return static_cast<PxBoxController *>(super.c_controller)->getHalfSideExtent();
}

- (float)getHalfForwardExtent {
    return static_cast<PxBoxController *>(super.c_controller)->getHalfForwardExtent();
}

- (bool)setHalfHeight:(float)halfHeight {
    return static_cast<PxBoxController *>(super.c_controller)->setHalfHeight(halfHeight);
}

- (bool)setHalfSideExtent:(float)halfSideExtent {
    return static_cast<PxBoxController *>(super.c_controller)->setHalfSideExtent(halfSideExtent);
}

- (bool)setHalfForwardExtent:(float)halfForwardExtent {
    return static_cast<PxBoxController *>(super.c_controller)->setHalfForwardExtent(halfForwardExtent);
}

@end
