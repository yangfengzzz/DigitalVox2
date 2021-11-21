//
//  mesh_io+Internal.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/18.
//

#ifndef mesh_io_Internal_h
#define mesh_io_Internal_h

#import <Foundation/Foundation.h>
#import "mesh.h"

@interface MeshIO ()

@property(nonatomic, readonly) Mesh c_mesh;

- (instancetype)initWithMesh:(Mesh)mesh;

@end

#endif /* mesh_io_Internal_h */
