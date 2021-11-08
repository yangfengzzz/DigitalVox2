//
//  CPxSpring.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/8.
//

#ifndef CPxSpring_h
#define CPxSpring_h

struct CPxSpring {
    //!< the spring strength of the drive: that is, the force proportional to the position error
    float stiffness;
    //!< the damping strength of the drive: that is, the force proportional to the velocity error
    float damping;
};

#endif /* CPxSpring_h */
