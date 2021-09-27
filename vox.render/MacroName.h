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

    ALPHA_CUTOFF = 7,
    NEED_WORLDPOS = 8,
    NEED_TILINGOFFSET = 9,
    DIFFUSE_TEXTURE = 10,
    SPECULAR_TEXTURE = 11,
    EMISSIVE_TEXTURE = 12,
    NORMAL_TEXTURE = 13,
    OMIT_NORMAL = 14,
    BASE_TEXTURE = 15,
    BASE_COLORMAP = 16,
    HAS_EMISSIVEMAP = 17,
    HAS_OCCLUSIONMAP = 18,
    HAS_SPECULARGLOSSINESSMAP = 19,
    HAS_METALROUGHNESSMAP = 20,
    IS_METALLIC_WORKFLOW = 21,
    
    DIRECT_LIGHT_COUNT = 22,
    POINT_LIGHT_COUNT = 23,
    SPOT_LIGHT_COUNT = 24,

    USE_SH = 25,
    USE_SPECULAR_ENV = 26,

    None = 27,
} MacroName;

#endif /* MacroName_h */
