//
//  LitePhysicsManager.swift
//  vox.render
//
//  Created by 杨丰 on 2021/10/27.
//

import Foundation

/**
 * A manager is a collection of bodies and constraints which can interact.
 */
class LitePhysicsManager: IPhysicsManager {
    private static var _tempSphere: BoundingSphere = BoundingSphere()
    private static var _tempBox: BoundingBox = BoundingBox()
    private static var _currentHit: LiteHitResult = LiteHitResult()
    private static var _hitResult: LiteHitResult = LiteHitResult()

    private var _onContactEnter: ((Int, Int) -> Void)?
    private var _onContactExit: ((Int, Int) -> Void)?
    private var _onContactStay: ((Int, Int) -> Void)?
    private var _onTriggerEnter: ((Int, Int) -> Void)?
    private var _onTriggerExit: ((Int, Int) -> Void)?
    private var _onTriggerStay: ((Int, Int) -> Void)?

    private var _colliders: [LiteCollider] = []
    private var _sphere: BoundingSphere = BoundingSphere()
    private var _box: BoundingBox = BoundingBox()

    private var _currentEvents: DisorderedArray<TriggerEvent> = DisorderedArray()
    private var _eventMap: [Int: [Int: TriggerEvent]] = [:]
    private var _eventPool: [TriggerEvent] = []

    init(_ onContactEnter: ((Int, Int) -> Void)?,
         _ onContactExit: ((Int, Int) -> Void)?,
         _ onContactStay: ((Int, Int) -> Void)?,
         _ onTriggerEnter: ((Int, Int) -> Void)?,
         _ onTriggerExit: ((Int, Int) -> Void)?,
         _ onTriggerStay: ((Int, Int) -> Void)?) {
        _onContactEnter = onContactEnter
        _onContactExit = onContactExit
        _onContactStay = onContactStay
        _onTriggerEnter = onTriggerEnter
        _onTriggerExit = onTriggerExit
        _onTriggerStay = onTriggerStay
    }

    func setGravity(_ value: Vector3) {
        fatalError("Physics-lite don't support gravity. Use Physics-PhysX instead!")
    }

    func addColliderShape(_ colliderShape: IColliderShape) {
        _eventMap[(colliderShape as! LiteColliderShape)._id] = [:]
    }

    func removeColliderShape(_ colliderShape: IColliderShape) {
        _eventMap.removeValue(forKey: (colliderShape as! LiteColliderShape)._id)
    }

    func addCollider(_ actor: ICollider) {
        _colliders.append(actor as! LiteCollider)
    }

    func removeCollider(_ collider: ICollider) {
        _colliders.removeAll { c in
            c === (collider as! LiteCollider)
        }
    }

    func addCharacterController(_ characterController: ICharacterController) {
        fatalError("Physics-lite don't support character controller. Use Physics-PhysX instead!")
    }

    func removeCharacterController(_ characterController: ICharacterController) {
        fatalError("Physics-lite don't support character controller. Use Physics-PhysX instead!")
    }

    func createControllerManager() -> ICharacterControllerManager {
        fatalError("Physics-lite don't support character controller. Use Physics-PhysX instead!")
    }

    func update(_ deltaTime: Float) {
        let colliders = _colliders
        for i in 0..<colliders.count {
            _collisionDetection(deltaTime, colliders[i])
        }
        _fireEvent()
    }

    func raycast(_ ray: Ray,
                 _ distance: Float,
                 _  hit: ((Int, Float, Vector3, Vector3) -> Void)?) -> Bool {
        var distance = distance

        var hitResult: LiteHitResult? = nil
        if (hit != nil) {
            hitResult = LitePhysicsManager._hitResult
        }

        var isHit = false
        let curHit = LitePhysicsManager._currentHit
        for i in 0..<_colliders.count {
            let collider = _colliders[i]

            if (collider._raycast(ray, curHit)) {
                isHit = true
                if (curHit.distance < distance) {
                    if (hitResult != nil) {
                        curHit.normal.cloneTo(target: hitResult!.normal)
                        curHit.point.cloneTo(target: hitResult!.point)
                        hitResult!.distance = curHit.distance
                        hitResult!.shapeID = curHit.shapeID
                    } else {
                        return true
                    }
                    distance = curHit.distance
                }
            }
        }

        if (!isHit && hitResult != nil) {
            hitResult!.shapeID = -1
            hitResult!.distance = 0
            _ = hitResult!.point.setValue(x: 0, y: 0, z: 0)
            _ = hitResult!.normal.setValue(x: 0, y: 0, z: 0)
        } else if (isHit && hitResult != nil) {
            hit!(hitResult!.shapeID, hitResult!.distance, hitResult!.point, hitResult!.normal)
        }
        return isHit
    }

    /**
     * Calculate the boundingbox in world space from boxCollider.
     * @param boxCollider - The boxCollider to calculate
     * @param out - The calculated boundingBox
     */
    private static func _updateWorldBox(_ boxCollider: LiteBoxColliderShape, _ out: BoundingBox) {
        let mat = boxCollider._transform.worldMatrix
        boxCollider._boxMax.cloneTo(target: out.max)
        boxCollider._boxMin.cloneTo(target: out.min)
        BoundingBox.transform(source: out, matrix: mat, out: out)
    }

    /**
     * Get the sphere info of the given sphere collider in world space.
     * @param sphereCollider - The given sphere collider
     * @param out - The calculated boundingSphere
     */
    private static func _upWorldSphere(_ sphereCollider: LiteSphereColliderShape, _ out: BoundingSphere) {
        Vector3.transformCoordinate(v: sphereCollider._transform.position, m: sphereCollider._transform.worldMatrix, out: out.center)
        out.radius = sphereCollider.worldRadius
    }

    private func _getTrigger(_ index1: Int, _ index2: Int) -> TriggerEvent {
        let event = _eventPool.count != 0 ? _eventPool.popLast() : TriggerEvent(index1, index2)
        _eventMap[index1]![index2] = event
        return event!
    }

    private func _collisionDetection(_ deltaTime: Float, _ myCollider: LiteCollider) {
        let myColliderShapes = myCollider._shapes
        for i in 0..<myColliderShapes.count {
            let myShape = myColliderShapes[i]
            if (myShape is LiteBoxColliderShape) {
                LitePhysicsManager._updateWorldBox(myShape as! LiteBoxColliderShape, _box)
                for i in 0..<_colliders.count {
                    let colliderShape = _colliders[i]._shapes
                    for i in 0..<colliderShape.count {
                        let shape = colliderShape[i]
                        let index1 = shape._id
                        let index2 = myShape._id
                        let event = index1! < index2! ? _eventMap[index1!]![index2!] : _eventMap[index2!]![index1!]
                        if (event != nil && !event!.needUpdate) {
                            continue
                        }
                        if (shape !== myShape && _boxCollision(shape)) {
                            if (event == nil) {
                                let event = index1! < index2! ? _getTrigger(index1!, index2!) : _getTrigger(index2!, index1!)
                                event.state = TriggerEventState.Enter
                                event.needUpdate = false
                                _currentEvents.add(event)
                            } else if (event!.state == TriggerEventState.Enter) {
                                event!.state = TriggerEventState.Stay
                                event!.needUpdate = false
                            } else if (event!.state == TriggerEventState.Stay) {
                                event!.needUpdate = false
                            }
                        }
                    }
                }
            } else if (myShape is LiteSphereColliderShape) {
                LitePhysicsManager._upWorldSphere(myShape as! LiteSphereColliderShape, _sphere)
                for i in 0..<_colliders.count {
                    let colliderShape = _colliders[i]._shapes
                    for i in 0..<colliderShape.count {
                        let shape = colliderShape[i]
                        let index1 = shape._id
                        let index2 = myShape._id
                        let event = index1! < index2! ? _eventMap[index1!]![index2!] : _eventMap[index2!]![index1!]
                        if (event != nil && !event!.needUpdate) {
                            continue
                        }
                        if (shape !== myShape && _sphereCollision(shape)) {
                            if (event == nil) {
                                let event = index1! < index2! ? _getTrigger(index1!, index2!) : _getTrigger(index2!, index1!)
                                event.state = TriggerEventState.Enter
                                event.needUpdate = false
                                _currentEvents.add(event)
                            } else if (event!.state == TriggerEventState.Enter) {
                                event!.state = TriggerEventState.Stay
                                event!.needUpdate = false
                            } else if (event!.state == TriggerEventState.Stay) {
                                event!.needUpdate = false
                            }
                        }
                    }
                }
            }
        }
    }

    private func _fireEvent() {
        var i = 0
        var n = _currentEvents.length
        while i < n {
            let event = _currentEvents.get(i)!
            if (!event.needUpdate) {
                if (event.state == TriggerEventState.Enter) {
                    _onTriggerEnter!(event.index1, event.index2)
                    event.needUpdate = true
                    i += 1
                } else if (event.state == TriggerEventState.Stay) {
                    _onTriggerStay!(event.index1, event.index2)
                    event.needUpdate = true
                    i += 1
                }
            } else {
                event.state = TriggerEventState.Exit
                _eventMap[event.index1]![event.index2] = nil

                _onTriggerExit!(event.index1, event.index2)

                _ = _currentEvents.deleteByIndex(i)
                _eventPool.append(event)
                n -= 1
            }
        }
    }

    private func _boxCollision(_ other: LiteColliderShape) -> Bool {
        if (other is LiteBoxColliderShape) {
            let box = LitePhysicsManager._tempBox
            LitePhysicsManager._updateWorldBox(other as! LiteBoxColliderShape, box)
            return CollisionUtil.intersectsBoxAndBox(boxA: box, boxB: _box)
        } else if (other is LiteSphereColliderShape) {
            let sphere = LitePhysicsManager._tempSphere
            LitePhysicsManager._upWorldSphere(other as! LiteSphereColliderShape, sphere)
            return CollisionUtil.intersectsSphereAndBox(sphere: sphere, box: _box)
        }
        return false
    }

    private func _sphereCollision(_ other: LiteColliderShape) -> Bool {
        if (other is LiteBoxColliderShape) {
            let box = LitePhysicsManager._tempBox
            LitePhysicsManager._updateWorldBox(other as! LiteBoxColliderShape, box)
            return CollisionUtil.intersectsSphereAndBox(sphere: _sphere, box: box)
        } else if (other is LiteSphereColliderShape) {
            let sphere = LitePhysicsManager._tempSphere
            LitePhysicsManager._upWorldSphere(other as! LiteSphereColliderShape, sphere)
            return CollisionUtil.intersectsSphereAndSphere(sphereA: sphere, sphereB: _sphere)
        }
        return false
    }
}

/// Physics state
enum TriggerEventState {
    case Enter
    case Stay
    case Exit
}

/// Trigger event to store interactive object ids and state.
class TriggerEvent: EmptyInit {
    var state: TriggerEventState
    var index1: Int
    var index2: Int
    var needUpdate: Bool = false

    required init() {
        index1 = 0
        index2 = 0
        state = .Exit
    }

    init(_ index1: Int, _ index2: Int) {
        self.index1 = index1
        self.index2 = index2
        state = .Exit
    }
}
