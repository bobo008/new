#include <metal_stdlib>

#include "RenderShaderTypes.h"


constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);

kernel void grayscaleKernel(uint2 gid [[ thread_position_in_grid ]],
                            texture2d<half, access::read> baseTexture [[ texture(0) ]],
                            texture2d<half, access::write> outputTexture [[ texture(1) ]]
                            ) {
    
    if((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height()))
    {
        // Return early if the pixel is out of bounds
        return;
    }

    half4 inColor  = baseTexture.read(gid);
    half  gray     = dot(inColor.rgb, kRec709Luma);
    outputTexture.write(half4(gray, gray, gray, 1.0), gid);
}
