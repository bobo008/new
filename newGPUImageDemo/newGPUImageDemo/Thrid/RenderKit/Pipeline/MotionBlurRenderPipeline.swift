import Foundation
import simd
import Metal

public class MotionBlurRenderPipeline {

    var input: MTLTexture?
    var output: MTLTexture?

    var uniformSettings:ShaderUniformSettings
    let renderPipelineState: MTLRenderPipelineState
    let operationName: String

    public init() {
        self.operationName = "MotionBlurRenderPipeline"
        let (pipelineState, lookupTable, size) = sharedMetalRenderingDevice.generateRenderPipelineState(vertexFunctionName: "motionBlurVertex", fragmentFunctionName: "motionBlurFragment")
        self.renderPipelineState = pipelineState
        self.uniformSettings = ShaderUniformSettings(uniformLookupTable:lookupTable, bufferSize: size)
    }

    
    
    func render(commandBuffer: MTLCommandBuffer) {
        let renderPass = obtainRenderPassDescriptor(output: output!)
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass) else {
            fatalError("Could not create render encoder")
        }
        
        renderEncoder.label = operationName
        renderEncoder.setRenderPipelineState(renderPipelineState)

        // 设置顶点, 如果定点有uniform数据 需要额外设置一下
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(textureBuffer, offset: 0, index: 1)
        var textureSize: SIMD2<Float> = SIMD2<Float>(Float(input!.width), Float(input!.height))
        renderEncoder.setVertexBytes(&textureSize, length: MemoryLayout<SIMD2<Float>>.stride, index: 2)
 
        // 设置纹理
        renderEncoder.setFragmentTexture(input, index: 0)
        
        // 设置片段 uniform 数据
        uniformSettings.restoreShaderSettings(renderEncoder: renderEncoder)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
    

}
