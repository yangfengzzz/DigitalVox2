//
//  CPxControllerDesc.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxControllerDesc_h
#define CPxControllerDesc_h

enum CPxControllerNonWalkableMode {
    //!< Stops character from climbing up non-walkable slopes, but doesn't move it otherwise
    ePREVENT_CLIMBING,
    //!< Stops character from climbing up non-walkable slopes, and forces it to slide down those slopes
    ePREVENT_CLIMBING_AND_FORCE_SLIDING
};

#endif /* CPxControllerDesc_h */
