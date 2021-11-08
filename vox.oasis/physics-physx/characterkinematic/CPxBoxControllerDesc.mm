//
//  CPxControllerDesc.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/8.
//

#import "CPxBoxControllerDesc.h"
#import "CPxBoxControllerDesc+Internal.h"
#import "CPxController.h"
#import "CPxController+Internal.h"
#import "CPxObstacle+Internal.h"
#import "../CPxShape+Internal.h"
#import "../CPxRigidActor+Internal.h"
#include <functional>

@implementation CPxBoxControllerDesc

- (void)setToDefault {
    _c_desc.setToDefault();
}

-(void)setControllerBehaviorCallback:(uint8_t (^ _Nullable)(CPxShape *_Nonnull shape, CPxRigidActor *_Nonnull actor))getShapeBehaviorFlags
                                    :(uint8_t (^ _Nullable)(CPxController *_Nonnull controller))getControllerBehaviorFlags
                                    :(uint8_t (^ _Nullable)(CPxObstacle *_Nonnull obstacle))getObstacleBehaviorFlags {
    class PxControllerBehaviorCallbackWrapper : public PxControllerBehaviorCallback {
    public:
        std::function<uint8_t(CPxShape *shape, CPxRigidActor *actor)> getShapeBehaviorFlags;
        std::function<uint8_t(CPxController *controller)> getControllerBehaviorFlags;
        std::function<uint8_t(CPxObstacle *obstacle)> getObstacleBehaviorFlags;

        PxControllerBehaviorCallbackWrapper(std::function<uint8_t(CPxShape *shape, CPxRigidActor *actor)> getShapeBehaviorFlags,
                                            std::function<uint8_t(CPxController *controller)> getControllerBehaviorFlags,
                                            std::function<uint8_t(CPxObstacle *obstacle)> getObstacleBehaviorFlags) :
        getShapeBehaviorFlags(getShapeBehaviorFlags),
        getControllerBehaviorFlags(getControllerBehaviorFlags),
        getObstacleBehaviorFlags(getObstacleBehaviorFlags) {}
            
        PxControllerBehaviorFlags getBehaviorFlags(const PxShape& shape, const PxActor& actor) override {
            return PxControllerBehaviorFlags(getShapeBehaviorFlags([[CPxShape alloc] initWithShape:const_cast<PxShape*>(&shape)],
                                                                   [[CPxRigidActor alloc]initWithActor:
                                                                    const_cast<PxRigidActor*>(static_cast<const PxRigidActor*>(&actor))]));
        }
        
        PxControllerBehaviorFlags getBehaviorFlags(const PxController& controller) override {
            return PxControllerBehaviorFlags(getControllerBehaviorFlags([[CPxController alloc] initWithController:const_cast<PxController*>(&controller)]));
        }
        
        PxControllerBehaviorFlags getBehaviorFlags(const PxObstacle& obstacle) override {
            if (obstacle.getType() == PxGeometryType::Enum::eBOX) {
                return PxControllerBehaviorFlags(getObstacleBehaviorFlags([[CPxBoxObstacle alloc]initWithObstacle:static_cast<const PxBoxObstacle&>(obstacle)]));
            } else if (obstacle.getType() == PxGeometryType::Enum::eBOX) {
                return PxControllerBehaviorFlags(getObstacleBehaviorFlags([[CPxCapsuleObstacle alloc]initWithObstacle:static_cast<const PxCapsuleObstacle&>(obstacle)]));
            } else {
                assert(false);
            }
        }
    };
    
    _c_desc.behaviorCallback = new PxControllerBehaviorCallbackWrapper(getShapeBehaviorFlags, getControllerBehaviorFlags, getObstacleBehaviorFlags);
}

@end
