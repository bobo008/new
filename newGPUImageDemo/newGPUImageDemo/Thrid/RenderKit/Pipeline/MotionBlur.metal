#include <metal_stdlib>
#import "RenderShaderTypes.h"
using namespace metal;


typedef struct
{
    float4 position [[position]];
    float2 textureCoordinate [[user(textureCoordinate)]];
    
//    float2 oneStepBackTextureCoordinate [[user(oneStepBackTextureCoordinate)]];
//    float2 twoStepsBackTextureCoordinate [[user(twoStepsBackTextureCoordinate)]];
//    float2 threeStepsBackTextureCoordinate [[user(threeStepsBackTextureCoordinate)]];
//    float2 fourStepsBackTextureCoordinate [[user(fourStepsBackTextureCoordinate)]];
//
//    float2 oneStepForwardTextureCoordinate [[user(oneStepForwardTextureCoordinate)]];
//    float2 twoStepsForwardTextureCoordinate [[user(twoStepsForwardTextureCoordinate)]];
//    float2 threeStepsForwardTextureCoordinate [[user(threeStepsForwardTextureCoordinate)]];
//    float2 fourStepsForwardTextureCoordinate [[user(fourStepsForwardTextureCoordinate)]];
}  MotionBlurVertexIO;

vertex MotionBlurVertexIO motionBlurVertex(const device packed_float2 *position [[buffer(0)]],
                                           const device packed_float2 *textureCoordinate [[buffer(1)]],
                                           uint vid [[vertex_id]])
{
    MotionBlurVertexIO outputVertices;
    outputVertices.position = float4(position[vid], 0, 1.0);
    
//    float2 singleHeightStep = float2(0.0, 0.0);
    
    outputVertices.textureCoordinate = textureCoordinate[vid];
//    outputVertices.oneStepBackTextureCoordinate = textureCoordinate[vid] - singleHeightStep;
//    outputVertices.twoStepsBackTextureCoordinate = textureCoordinate[vid] - 2.0 * singleHeightStep;
//    outputVertices.threeStepsBackTextureCoordinate = textureCoordinate[vid] - 3.0 * singleHeightStep;
//    outputVertices.fourStepsBackTextureCoordinate = textureCoordinate[vid] - 4.0 * singleHeightStep;
//    outputVertices.oneStepForwardTextureCoordinate = textureCoordinate[vid] - singleHeightStep;
//    outputVertices.twoStepsForwardTextureCoordinate = textureCoordinate[vid] - 2.0 * singleHeightStep;
//    outputVertices.threeStepsForwardTextureCoordinate = textureCoordinate[vid] - 3.0 * singleHeightStep;
//    outputVertices.fourStepsForwardTextureCoordinate = textureCoordinate[vid] - 4.0 * singleHeightStep;
    
    return outputVertices;
}



fragment half4 motionBlurFragment(MotionBlurVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler(coord::pixel);
    half4 fragmentColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
//    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.oneStepBackTextureCoordinate) * 0.15;
//    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.twoStepsBackTextureCoordinate) * 0.12;
//    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.threeStepsBackTextureCoordinate) * 0.09;
//    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.fourStepsBackTextureCoordinate) * 0.05;
//    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.oneStepForwardTextureCoordinate) * 0.15;
//    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.twoStepsForwardTextureCoordinate) * 0.12;
//    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.threeStepsForwardTextureCoordinate) * 0.09;
//    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.fourStepsForwardTextureCoordinate) * 0.05;
    
   return fragmentColor;
//    return half4(1,0,0,1);
}

