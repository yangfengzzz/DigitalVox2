//
//  MotionController.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/1.
//

import CoreMotion
import simd

class MotionController {
    let motionManager = CMMotionManager()
    var motionClosure: ((CMDeviceMotion?, Error?) -> Void)?
    var acceleration: SIMD3<Float> = [0, 0, 0]
    var previousAcceleration: SIMD3<Float> = [0, 0, 0]
    
    var deltaAcceleration: SIMD3<Float> {
        return previousAcceleration - acceleration
    }
    
    func setupCoreMotion() {
        motionManager.accelerometerUpdateInterval = 0.2
        let queue = OperationQueue()
        
        motionManager.startDeviceMotionUpdates(to: queue, withHandler: {
            motion, error in
            self.motionClosure?(motion, error)
        })
        motionManager.startAccelerometerUpdates(to: queue, withHandler: {
            accelerometerData, error in
            guard let accelerometerData = accelerometerData else { return }
            let acceleration = accelerometerData.acceleration
            self.previousAcceleration = self.acceleration
            self.acceleration.x = (Float(acceleration.x) * 0.75) + (self.acceleration.x * 0.25)
            self.acceleration.y = (Float(acceleration.y) * 0.75) + (self.acceleration.y * 0.25)
            self.acceleration.z = (Float(acceleration.z) * 0.75) + (self.acceleration.z * 0.25)
        })
    }
}
