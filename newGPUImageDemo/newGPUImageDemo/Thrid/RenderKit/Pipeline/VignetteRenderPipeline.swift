import Foundation
import Metal

// 渐变光晕的效果
public class VignetteRenderPipeline {
    
    var input: MTLTexture?
    var output: MTLTexture?
    
    public var center:Position = Position.center { didSet { uniformSettings["vignetteCenter"] = center } }
    public var color:Color = Color.black { didSet { uniformSettings["vignetteColor"] = color } }
    public var start:Float = 0.3 { didSet { uniformSettings["vignetteStart"] = start } }
    public var end:Float = 0.75 { didSet { uniformSettings["vignetteEnd"] = end } }
    
    var uniformSettings:ShaderUniformSettings
    let renderPipelineState: MTLRenderPipelineState
    let operationName: String

    public init() {
        self.operationName = "VignetteRenderPipeline"
        let (pipelineState, lookupTable, size) = sharedMetalRenderingDevice.generateRenderPipelineState(vertexFunctionName: "oneInputVertex", fragmentFunctionName: "vignetteFragment")
        self.renderPipelineState = pipelineState
        self.uniformSettings = ShaderUniformSettings(uniformLookupTable:lookupTable, bufferSize: size)
        
        ({center = Position.center})()
        ({color = Color.black})()
        ({start = 0.3})()
        ({end = 0.75})()
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
        
        // 设置纹理
        renderEncoder.setFragmentTexture(input, index: 0)
        
        // 设置片段 uniform 数据
        uniformSettings.restoreShaderSettings(renderEncoder: renderEncoder)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
    
    

}
