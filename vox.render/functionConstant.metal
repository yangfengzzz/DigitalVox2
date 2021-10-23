//
//  functionConstant.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/21.
//

#include <metal_stdlib>
using namespace metal;
#import "ShaderCommon.h"

constant bool hasUV [[function_constant(HAS_UV)]];
constant bool hasNormal [[function_constant(HAS_NORMAL)]];
constant bool hasTangent [[function_constant(HAS_TANGENT)]];
constant bool hasVertexColor [[function_constant(HAS_VERTEXCOLOR)]];
constant bool omitNormal [[function_constant(OMIT_NORMAL)]];
constant bool notOmitNormalAndHasNormal = !omitNormal && hasNormal;
constant bool notOmitNormalAndHasTangent = !omitNormal && hasTangent;

constant bool hasBlendShape [[function_constant(HAS_BLENDSHAPE)]];
constant bool hasBlendShapeNormal [[function_constant(HAS_BLENDSHAPE_NORMAL)]];
constant bool hasBlendShapeTangent [[function_constant(HAS_BLENDSHAPE_TANGENT)]];
constant bool hasBlendShapeAndHasBlendShapeNormal = hasBlendShape && hasBlendShapeNormal;
constant bool hasBlendShapeAndhasBlendShapeTangent = hasBlendShape && hasBlendShapeTangent;

constant bool hasSkin [[function_constant(HAS_SKIN)]];
constant bool hasJointTexture [[function_constant(HAS_JOINT_TEXTURE)]];
constant bool hasSkinAndHasJointTexture = hasSkin && hasJointTexture;
constant bool hasSkinNotHasJointTexture = hasSkin && !hasJointTexture;
constant int jointsNum [[function_constant(JOINTS_NUM)]];

constant bool needAlphaCutoff [[function_constant(NEED_ALPHA_CUTOFF)]];
constant bool needWorldPos [[function_constant(NEED_WORLDPOS)]];
constant bool needTilingOffset [[function_constant(NEED_TILINGOFFSET)]];
constant bool hasDiffuseTexture [[function_constant(HAS_DIFFUSE_TEXTURE)]];
constant bool hasSpecularTexture [[function_constant(HAS_SPECULAR_TEXTURE)]];
constant bool hasEmissiveTexture [[function_constant(HAS_EMISSIVE_TEXTURE)]];
constant bool hasNormalTexture [[function_constant(HAS_NORMAL_TEXTURE)]];
constant bool hasNormalAndHasTangentAndHasNormalTexture = hasNormal && hasTangent && hasNormalTexture;
constant bool hasNormalNotHasTangentOrHasNormalTexture = hasNormal && (!hasTangent || !hasNormalTexture);

constant bool hasBaseTexture [[function_constant(HAS_BASE_TEXTURE)]];
constant bool hasBaseColorMap [[function_constant(HAS_BASE_COLORMAP)]];
constant bool hasEmissiveMap [[function_constant(HAS_EMISSIVEMAP)]];
constant bool hasOcclusionMap [[function_constant(HAS_OCCLUSIONMAP)]];
constant bool hasSpecularGlossinessMap [[function_constant(HAS_SPECULARGLOSSINESSMAP)]];
constant bool hasMetalRoughnessMap [[function_constant(HAS_METALROUGHNESSMAP)]];
constant bool isMetallicWorkFlow [[function_constant(IS_METALLIC_WORKFLOW)]];

constant int directLightCount [[function_constant(DIRECT_LIGHT_COUNT)]];
constant int pointLightCount [[function_constant(POINT_LIGHT_COUNT)]];
constant int spotLightCount [[function_constant(SPOT_LIGHT_COUNT)]];

constant bool useSH [[function_constant(USE_SH)]];
constant bool useSpecularEnv [[function_constant(USE_SPECULAR_ENV)]];

constant bool particleTexture [[function_constant(PARTICLE_TEXTURE)]];
constant bool rotateToVelocity [[function_constant(ROTATE_TO_VELOCITY)]];
constant bool useOriginColor [[function_constant(USE_ORIGIN_COLOR)]];
constant bool ScaleByLifetime [[function_constant(SCALE_BY_LIFE_TIME)]];
constant bool twoDimension [[function_constant(TWO_DIMENSION)]];
constant bool fadeIn [[function_constant(FADE_IN)]];
constant bool fadeOut [[function_constant(FADE_OUT)]];

constant bool generateShadowMap [[function_constant(GENERATE_SHADOW_MAP)]];
constant int shadowMapCount [[function_constant(SHADOW_MAP_COUNT)]];
