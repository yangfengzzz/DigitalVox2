//
//  mesh_io.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/18.
//

#import "mesh_io.h"
#import "mesh_io+Internal.h"

@implementation MeshIO

- (instancetype)initWithMesh:(Mesh)mesh {
    self = [super init];
    if (self) {
        _c_mesh = mesh;
    }
    return self;
}

@end
