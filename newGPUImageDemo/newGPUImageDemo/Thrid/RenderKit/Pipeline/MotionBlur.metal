#include <metal_stdlib>
#import "RenderShaderTypes.h"
using namespace metal;


typedef struct
{
    float4 position [[position]];
    float2 textureCoordinate [[user(textureCoordinate)]];
    
    float2 oneStepBackTextureCoordinate [[user(oneStepBackTextureCoordinate)]];
    float2 twoStepsBackTextureCoordinate [[user(twoStepsBackTextureCoordinate)]];
    float2 threeStepsBackTextureCoordinate [[user(threeStepsBackTextureCoordinate)]];
    float2 fourStepsBackTextureCoordinate [[user(fourStepsBackTextureCoordinate)]];

    float2 oneStepForwardTextureCoordinate [[user(oneStepForwardTextureCoordinate)]];
    float2 twoStepsForwardTextureCoordinate [[user(twoStepsForwardTextureCoordinate)]];
    float2 threeStepsForwardTextureCoordinate [[user(threeStepsForwardTextureCoordinate)]];
    float2 fourStepsForwardTextureCoordinate [[user(fourStepsForwardTextureCoordinate)]];
}  MotionBlurVertexIO;

vertex MotionBlurVertexIO motionBlurVertex(const device packed_float2 *position [[buffer(0)]],
                                           const device packed_float2 *textureCoordinate [[buffer(1)]],
                                           constant float2& textureSize [[buffer(2)]],
                                           uint vid [[vertex_id]])
{
    MotionBlurVertexIO outputVertices;
    outputVertices.position = float4(position[vid], 0, 1.0);
    
    float2 singleHeightStep = float2(0.0, 1.0 / textureSize.y);
    float2 textureCoord = textureCoordinate[vid];
    
    outputVertices.textureCoordinate = textureCoord;
    outputVertices.oneStepBackTextureCoordinate = textureCoord - singleHeightStep;
    outputVertices.twoStepsBackTextureCoordinate = textureCoord - 2.0 * singleHeightStep;
    outputVertices.threeStepsBackTextureCoordinate = textureCoord - 3.0 * singleHeightStep;
    outputVertices.fourStepsBackTextureCoordinate = textureCoord - 4.0 * singleHeightStep;
    outputVertices.oneStepForwardTextureCoordinate = textureCoord - singleHeightStep;
    outputVertices.twoStepsForwardTextureCoordinate = textureCoord - 2.0 * singleHeightStep;
    outputVertices.threeStepsForwardTextureCoordinate = textureCoord - 3.0 * singleHeightStep;
    outputVertices.fourStepsForwardTextureCoordinate = textureCoord - 4.0 * singleHeightStep;
    
    return outputVertices;
}



fragment half4 motionBlurFragment(MotionBlurVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]])
{
//    constexpr sampler quadSampler(coord::pixel); 这种采样方式传过来的坐标需要是非归一化的
    half4 fragmentColor = inputTexture.sample(nearestSampler, fragmentInput.textureCoordinate) * 0.18;
    fragmentColor += inputTexture.sample(nearestSampler, fragmentInput.oneStepBackTextureCoordinate) * 0.15;
    fragmentColor += inputTexture.sample(nearestSampler, fragmentInput.twoStepsBackTextureCoordinate) * 0.12;
    fragmentColor += inputTexture.sample(nearestSampler, fragmentInput.threeStepsBackTextureCoordinate) * 0.09;
    fragmentColor += inputTexture.sample(nearestSampler, fragmentInput.fourStepsBackTextureCoordinate) * 0.05;
    fragmentColor += inputTexture.sample(nearestSampler, fragmentInput.oneStepForwardTextureCoordinate) * 0.15;
    fragmentColor += inputTexture.sample(nearestSampler, fragmentInput.twoStepsForwardTextureCoordinate) * 0.12;
    fragmentColor += inputTexture.sample(nearestSampler, fragmentInput.threeStepsForwardTextureCoordinate) * 0.09;
    fragmentColor += inputTexture.sample(nearestSampler, fragmentInput.fourStepsForwardTextureCoordinate) * 0.05;
    
   return fragmentColor;
}

