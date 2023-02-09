#include <metal_stdlib>
#import "RenderShaderTypes.h"
using namespace metal;



//using namespace metal;


fragment half4 passthroughFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                   texture2d<half> inputTexture [[texture(0)]])
{
    half4 color = inputTexture.sample(nearestSampler, fragmentInput.textureCoordinate);
    
    return color;
}

