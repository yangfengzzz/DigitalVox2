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
    
    USE_SH = 8,
    USE_SPECULAR_ENV = 9,
    
    None = 8,
} MacroName;

#endif /* MacroName_h */
