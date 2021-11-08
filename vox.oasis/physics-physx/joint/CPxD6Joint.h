//
//  CPxD6Joint.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxD6Joint_h
#define CPxD6Joint_h

#import "CPxJoint.h"

enum CPxD6Axis {
    CPxD6Axis_eX = 0,    //!< motion along the X axis
    CPxD6Axis_eY = 1,    //!< motion along the Y axis
    CPxD6Axis_eZ = 2,    //!< motion along the Z axis
    CPxD6Axis_eTWIST = 3,    //!< motion around the X axis
    CPxD6Axis_eSWING1 = 4,    //!< motion around the Y axis
    CPxD6Axis_eSWING2 = 5,    //!< motion around the Z axis
    CPxD6Axis_eCOUNT = 6
};

enum CPxD6Motion {
    CPxD6Motion_eLOCKED,    //!< The DOF is locked, it does not allow relative motion.
    CPxD6Motion_eLIMITED,    //!< The DOF is limited, it only allows motion within a specific range.
    CPxD6Motion_eFREE        //!< The DOF is free and has its full range of motion.
};

enum CPxD6Drive {
    CPxD6Drive_eX = 0,    //!< drive along the X-axis
    CPxD6Drive_eY = 1,    //!< drive along the Y-axis
    CPxD6Drive_eZ = 2,    //!< drive along the Z-axis
    CPxD6Drive_eSWING = 3,    //!< drive of displacement from the X-axis
    CPxD6Drive_eTWIST = 4,    //!< drive of the displacement around the X-axis
    CPxD6Drive_eSLERP = 5,    //!< drive of all three angular degrees along a SLERP-path
    CPxD6Drive_eCOUNT = 6
};

enum CPxD6JointDriveFlag {
    CPxD6JointDriveFlag_eACCELERATION = 1    //!< drive spring is for the acceleration at the joint (rather than the force)
};

@interface CPxD6Joint : CPxJoint

@end

#endif /* CPxD6Joint_h */
