//public class : BasicOperation {
//    public var blurSize:Float = 1.0 { didSet { uniformSettings["size"] = blurSize } }
//    public var blurCenter:Position = Position.center { didSet { uniformSettings["center"] = blurCenter } }
//
//    public init() {
//        super.init(fragmentFunctionName:"zoomBlurFragment", numberOfInputs:1)
//
//        ({blurSize = 1.0})()
//        ({blurCenter = Position.center})()
//    }
//}


import Foundation
import Metal




open class ZoomBlurRenderPipeline {
    
    var input: MTLTexture?
    var output: MTLTexture?
    
    public var blurSize:Float = 1.0 { didSet { uniformSettings["size"] = blurSize } }
    public var blurCenter:Position = Position.center { didSet { uniformSettings["center"] = blurCenter } }

    var uniformSettings:ShaderUniformSettings
    let renderPipelineState: MTLRenderPipelineState
    let operationName: String

    public init() {
        self.operationName = "ZoomBlurRenderPipeline"
        let (pipelineState, lookupTable, size) = sharedMetalRenderingDevice.generateRenderPipelineState(vertexFunctionName: "oneInputVertex", fragmentFunctionName: "zoomBlurFragment")
        self.renderPipelineState = pipelineState
        self.uniformSettings = ShaderUniformSettings(uniformLookupTable:lookupTable, bufferSize: size)
        
        ({blurSize = 1.0})()
        ({blurCenter = Position.center})()
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
        renderEncoder.setVertexBuffer(textureBuffer, offset: 0, index: 2)
        
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
