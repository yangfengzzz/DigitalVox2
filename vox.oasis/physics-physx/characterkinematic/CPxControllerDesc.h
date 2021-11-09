//
//  CPxControllerDesc.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxControllerDesc_h
#define CPxControllerDesc_h

#import <Foundation/Foundation.h>

enum CPxControllerShapeType {
    /// A box controller.
    CPxControllerShapeType_eBOX,

    /// A capsule controller
    CPxControllerShapeType_eCAPSULE,

    CPxControllerShapeType_eFORCE_DWORD = 0x7fffffff
};

enum CPxControllerNonWalkableMode {
    //!< Stops character from climbing up non-walkable slopes, but doesn't move it otherwise
    ePREVENT_CLIMBING,
    //!< Stops character from climbing up non-walkable slopes, and forces it to slide down those slopes
    ePREVENT_CLIMBING_AND_FORCE_SLIDING
};

@interface CPxControllerDesc : NSObject

-(enum CPxControllerShapeType) getType;

@end

#endif /* CPxControllerDesc_h */
