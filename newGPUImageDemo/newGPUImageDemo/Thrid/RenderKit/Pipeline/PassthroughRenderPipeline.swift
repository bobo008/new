import Foundation
import Metal


open class PassthroughRenderPipeline {
    
    var input: MTLTexture?
    var output: MTLTexture?

    var uniformSettings:ShaderUniformSettings
    let renderPipelineState: MTLRenderPipelineState
    let operationName: String

    public init() {
        self.operationName = "PassthroughRenderPipeline"
        let (pipelineState, lookupTable) = sharedMetalRenderingDevice.generateRenderPipelineState(vertexFunctionName: "oneInputVertex", fragmentFunctionName: "passthroughFragment")
        self.renderPipelineState = pipelineState
        self.uniformSettings = ShaderUniformSettings(uniformLookupTable:lookupTable)
    }

    
    func render(commandBuffer: MTLCommandBuffer) {
        let renderPass = obtainRenderPassDescriptor()
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass) else {
            fatalError("Could not create render encoder")
        }
        
        renderEncoder.label = operationName
        renderEncoder.setRenderPipelineState(renderPipelineState)

        // 设置顶点, 如果定点有uniform数据 需要额外设置一下
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(textureBuffer, offset: 0, index: 1)
        // 设置纹理
        renderEncoder.setFragmentTexture(input, index: 0)
        // 设置片段 uniform 数据
        uniformSettings.restoreShaderSettings(renderEncoder: renderEncoder)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
    
    
    func obtainRenderPassDescriptor() -> MTLRenderPassDescriptor {
        let renderPass = MTLRenderPassDescriptor()
        renderPass.colorAttachments[0].texture = output
        renderPass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
        renderPass.colorAttachments[0].storeAction = .store
        renderPass.colorAttachments[0].loadAction = .clear
        return renderPass
    }
}
