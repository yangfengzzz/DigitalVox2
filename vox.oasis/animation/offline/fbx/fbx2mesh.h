//
//  fbx2mesh.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/11/18.
//

#ifndef fbx2mesh_h
#define fbx2mesh_h

#import "mesh_io.h"

@interface FBX2Mesh : NSObject

- (NSArray<MeshIO *> *)LoadMesh:(const NSString *)_filename :(const NSString *)_skeleton;

@end

#endif /* fbx2mesh_h */
