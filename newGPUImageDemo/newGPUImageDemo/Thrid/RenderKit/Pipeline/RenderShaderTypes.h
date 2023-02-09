#include <metal_stdlib>
using namespace metal;

#ifndef OPERATIONSHADERTYPES_H
#define OPERATIONSHADERTYPES_H

// Luminance Constants
constant half3 luminanceWeighting = half3(0.2125, 0.7154, 0.0721);  // Values from "Graphics Shaders: Theory and Practice" by Bailey and Cunningham

struct SingleInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
};

struct TwoInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
    float2 textureCoordinate2 [[user(texturecoord2)]];
};



// GL_LINEAR_MIPMAP_LINEAR 对比 opengl mip_filter 对比前一段 min_filter 对比后一段 三线性插值效果更好
constexpr sampler mipmapSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::linear, mip_filter::linear, min_filter::linear);
constexpr sampler nearestSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::nearest, min_filter::nearest);
constexpr sampler linearSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::linear, min_filter::linear);
constexpr sampler nearestLinearSampler (s_address::mirrored_repeat, t_address::mirrored_repeat, mag_filter::nearest, min_filter::linear);

#endif
