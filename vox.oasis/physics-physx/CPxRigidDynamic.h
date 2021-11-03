//
//  CPxRigidDynamic.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/29.
//

#ifndef CPxRigidDynamic_h
#define CPxRigidDynamic_h

#import "CPxRigidActor.h"
#import <simd/simd.h>

enum CPxForceMode {
    eFORCE,              //!< parameter has unit of mass * distance/ time^2, i.e. a force
    eIMPULSE,            //!< parameter has unit of mass * distance /time
    eVELOCITY_CHANGE,    //!< parameter has unit of distance / time, i.e. the effect is mass independent: a velocity change.
    eACCELERATION        //!< parameter has unit of distance/ time^2, i.e. an acceleration. It gets treated just like a force except the mass is not divided out before integration.
};

enum CPxRigidDynamicLockFlag {
    eLOCK_LINEAR_X = (1 << 0),
    eLOCK_LINEAR_Y = (1 << 1),
    eLOCK_LINEAR_Z = (1 << 2),
    eLOCK_ANGULAR_X = (1 << 3),
    eLOCK_ANGULAR_Y = (1 << 4),
    eLOCK_ANGULAR_Z = (1 << 5)
};

enum CPxRigidBodyFlag {
    eKINEMATIC = (1 << 0),        //!< Enable kinematic mode for the body.

    eUSE_KINEMATIC_TARGET_FOR_SCENE_QUERIES = (1 << 1),

    eENABLE_CCD = (1 << 2),        //!< Enable CCD for the body.

    eENABLE_CCD_FRICTION = (1 << 3),

    eENABLE_POSE_INTEGRATION_PREVIEW = (1 << 4),

    eENABLE_SPECULATIVE_CCD = (1 << 5),

    eENABLE_CCD_MAX_CONTACT_IMPULSE = (1 << 6),

    eRETAIN_ACCELERATIONS = (1 << 7)
};

@interface CPxRigidDynamic : CPxRigidActor

//MARK: - Damping
/// Sets the linear damping coefficient.
/// @param angDamp Linear damping coefficient.
- (void)setAngularDampingWith:(float)angDamp;

/// Retrieves the linear damping coefficient.
- (float)getAngularDamping;

/// Sets the angular damping coefficient.
/// @param linDamp Angular damping coefficient.
- (void)setLinearDampingWith:(float)linDamp;

/// Retrieves the angular damping coefficient.
- (float)getLinearDamping;

//MARK: - Velocity
/// Sets the angular velocity of the actor.
/// @param angVel New angular velocity of actor.
- (void)setAngularVelocityWith:(simd_float3)angVel;

/// Retrieves the angular velocity of the actor.
- (simd_float3)getAngularVelocity;

/// Sets the linear velocity of the actor.
/// @param linVel New linear velocity of actor.
- (void)setLinearVelocityWith:(simd_float3)linVel;

/// Retrieves the linear velocity of an actor.
- (simd_float3)getLinearVelocity;

/// Lets you set the maximum angular velocity permitted for this actor.
/// @param maxAngVel Max allowable angular velocity for actor.
- (void)setMaxAngularVelocityWith:(float)maxAngVel;

/// Retrieves the maximum angular velocity permitted for this actor.
- (float)getMaxAngularVelocity;

/// Lets you set the maximum linear velocity permitted for this actor.
/// @param maxLinVel Max allowable linear velocity for actor.
- (void)setMaxLinearVelocityWith:(float)maxLinVel;

/// Retrieves the maximum angular velocity permitted for this actor.
- (float)getMaxLinearVelocity;

//MARK: - Mass Manipulation
/// Sets the mass of a dynamic actor.
/// @param mass New mass value for the actor.
- (void)setMassWith:(float)mass;

/// Retrieves the mass of the actor.
- (float)getMass;

/// Sets the pose of the center of mass relative to the actor.
- (void)setCMassLocalPoseWith:(simd_float3)position rotation:(simd_quatf)rotation;

/// Retrieves the center of mass pose relative to the actor frame.
- (void)getCMassLocalPose:(simd_float3 *)position rotation:(simd_quatf *)rotation;

/// Computation of mass properties for a rigid body actor
- (void)setMassAndUpdateInertiaWith:(float)mass;

//MARK: - Forces
/// Applies a force (or impulse) defined in the global coordinate frame to the actor at its center of mass.
/// @param force Force/Impulse to apply defined in the global frame.
- (void)addForceWith:(simd_float3)force;

/// Applies an impulsive torque defined in the global coordinate frame to the actor.
/// @param torque Torque to apply defined in the global frame. <b>Range:</b> torque vector
- (void)addTorqueWith:(simd_float3)torque;

/// Raises or clears a particular rigid body flag.
/// @param flag The PxRigidBody flag to raise(set) or clear.
/// @param value The new boolean value for the flag.
- (void)setRigidBodyFlagWith:(enum CPxRigidBodyFlag)flag value:(bool)value;

//MARK: - Extension
/// Applies a force (or impulse) defined in the global coordinate frame, acting at a particular point in global coordinates, to the actor.
/// @param force Force/impulse to add, defined in the global frame.
/// @param pos Position in the global frame to add the force at.
- (void)addForceAtPosWith:(simd_float3)force pos:(simd_float3)pos mode:(enum CPxForceMode)mode;

/// Applies a force (or impulse) defined in the global coordinate frame, acting at a particular point in local coordinates, to the actor.
/// @param force Force/impulse to add, defined in the global frame.
/// @param pos Position in the local frame to add the force at.
- (void)addForceAtLocalPosWith:(simd_float3)force pos:(simd_float3)pos mode:(enum CPxForceMode)mode;

///  Applies a force (or impulse) defined in the actor local coordinate frame, acting at a particular point in global coordinates, to the actor.
/// @param force Force/impulse to add, defined in the local frame.
/// @param pos Position in the global frame to add the force at.
- (void)addLocalForceAtPosWith:(simd_float3)force pos:(simd_float3)pos mode:(enum CPxForceMode)mode;

/// Applies a force (or impulse) defined in the actor local coordinate frame, acting at a particular point in local coordinates, to the actor.
/// @param force Force/impulse to add, defined in the local frame.
/// @param pos Position in the local frame to add the force at.
- (void)addLocalForceAtLocalPosWith:(simd_float3)force pos:(simd_float3)pos mode:(enum CPxForceMode)mode;

/// Computes the velocity of a point given in world coordinates if it were attached to the  specified body and moving with it.
/// @param pos Position we wish to determine the velocity for, defined in the global frame.
- (simd_float3)getVelocityAtPos:(simd_float3)pos;

/// Computes the velocity of a point given in local coordinates if it were attached to the specified body and moving with it.
/// @param pos Position we wish to determine the velocity for, defined in the local frame.
- (simd_float3)getLocalVelocityAtLocalPos:(simd_float3)pos;

//MARK: - Sleeping
/// Returns true if this body is sleeping.
- (bool)isSleeping;

/// Sets the mass-normalized kinetic energy threshold below which an actor may go to sleep.
/// @param threshold Energy below which an actor may go to sleep.
- (void)setSleepThresholdWith:(float)threshold;

/// Returns the mass-normalized kinetic energy below which an actor may go to sleep.
- (float)getSleepThreshold;

/// Raises or clears a particular rigid dynamic lock flag.
/// @param flag The PxRigidDynamicLockBody flag to raise(set) or clear.
/// @param value The new boolean value for the flag.
- (void)setRigidDynamicLockFlagWith:(enum CPxRigidDynamicLockFlag)flag value:(bool)value;

/// Sets the wake counter for the actor.
/// @param wakeCounterValue Wake counter value.
- (void)setWakeCounterWith:(float)wakeCounterValue;

/// Returns the wake counter of the actor.
- (float)getWakeCounter;

/// Wakes up the actor if it is sleeping.
- (void)wakeUp;

/// Forces the actor to sleep.
- (void)putToSleep;

/// Sets the solver iteration counts for the body.
/// @param minPositionIters Number of position iterations the solver should perform for this body.
/// @param minVelocityIters Number of velocity iterations the solver should perform for this body.
- (void)setSolverIterationCountsWith:(unsigned int)minPositionIters minVelocityIters:(unsigned int)minVelocityIters;

/// Retrieves the solver iteration counts.
- (void)getSolverIterationCounts:(unsigned int *)minPositionIters minVelocityIters:(unsigned int *)minVelocityIters;

//MARK: - Kinematic Actors
/// Moves kinematically controlled dynamic actors through the game world.
- (void)setKinematicTargetWith:(simd_float3)position rotation:(simd_quatf)rotation;

/// Get target pose of a kinematically controlled dynamic actor.
- (bool)getKinematicTarget:(simd_float3 *)position rotation:(simd_quatf *)rotation;

@end

#endif /* CPxRigidDynamic_h */
