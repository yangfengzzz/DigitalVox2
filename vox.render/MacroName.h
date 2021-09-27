//
//  MacroName.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/20.
//

#ifndef MacroName_h
#define MacroName_h

typedef enum {
    HAS_UV = 0,
    HAS_NORMAL = 1,
    HAS_TANGENT = 2,
    HAS_VERTEXCOLOR = 3,

    BLENDSHAPE = 4,
    BLENDSHAPE_NORMAL = 5,
    BLENDSHAPE_TANGENT = 6,
    
    HAS_SKIN = 7,
    USE_JOINT_TEXTURE = 8,
    JOINTS_NUM = 9,

    ALPHA_CUTOFF = 10,
    NEED_WORLDPOS = 11,
    NEED_TILINGOFFSET = 12,
    DIFFUSE_TEXTURE = 13,
    SPECULAR_TEXTURE = 14,
    EMISSIVE_TEXTURE = 15,
    NORMAL_TEXTURE = 16,
    OMIT_NORMAL = 17,
    BASE_TEXTURE = 18,
    BASE_COLORMAP = 19,
    HAS_EMISSIVEMAP = 20,
    HAS_OCCLUSIONMAP = 21,
    HAS_SPECULARGLOSSINESSMAP = 22,
    HAS_METALROUGHNESSMAP = 23,
    IS_METALLIC_WORKFLOW = 24,
    
    DIRECT_LIGHT_COUNT = 25,
    POINT_LIGHT_COUNT = 26,
    SPOT_LIGHT_COUNT = 27,

    USE_SH = 28,
    USE_SPECULAR_ENV = 29,

    None = 30,
} MacroName;

#endif /* MacroName_h */
