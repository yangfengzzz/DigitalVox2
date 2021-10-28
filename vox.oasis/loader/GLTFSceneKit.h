
#import "GLTFAsset.h"
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const GLTFAssetPropertyKeyCopyright;
extern NSString *const GLTFAssetPropertyKeyGenerator;
extern NSString *const GLTFAssetPropertyKeyVersion;
extern NSString *const GLTFAssetPropertyKeyMinVersion;
extern NSString *const GLTFAssetPropertyKeyExtensionsUsed;
extern NSString *const GLTFAssetPropertyKeyExtensionsRequired;

@interface GLTFSCNAnimationChannel : NSObject
@property(nonatomic, strong) SCNNode *target;
@property(nonatomic, strong) SCNAnimation *animation;
@end

@interface GLTFSCNAnimation : NSObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSArray<GLTFSCNAnimationChannel *> *channels;

- (void)play;
@end

@interface SCNScene (GLTFSceneKit)
+ (instancetype)sceneWithGLTFAsset:(GLTFAsset *)asset;
@end

@interface GLTFSCNSceneSource : NSObject

@property(nonatomic, nullable, readonly) SCNScene *defaultScene;
@property(nonatomic, readonly) NSArray<SCNScene *> *scenes;
@property(nonatomic, readonly) NSArray<SCNNode *> *nodes;
@property(nonatomic, readonly) NSArray<SCNLight *> *lights;
@property(nonatomic, readonly) NSArray<SCNCamera *> *cameras;
@property(nonatomic, readonly) NSArray<SCNGeometry *> *geometries;
@property(nonatomic, readonly) NSArray<SCNMaterial *> *materials;
@property(nonatomic, readonly) NSArray<GLTFSCNAnimation *> *animations;

- (instancetype)initWithAsset:(GLTFAsset *)asset;

/*!
 @method propertyForKey:
 @param key The key for which to return the corresponding metadata property.
 @abstract Returns the value corresponding to the provided key, if present in the asset.
 */
- (nullable id)propertyForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
