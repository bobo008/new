
import Foundation
import Metal


final class GrayComputePipeline {
    var input: MTLTexture?
    var output: MTLTexture?
    
    
    var uniformSettings:ShaderUniformSettings
    let computePipelineState: MTLComputePipelineState
    let operationName: String
    
    
    public init() {
        self.operationName = "grayscaleKernel"
        let (pipelineState, lookupTable, bufferSize) = sharedMetalRenderingDevice.generateComputePipelineState(kernelFunctionName: "grayscaleKernel")
        self.computePipelineState = pipelineState
        self.uniformSettings = ShaderUniformSettings(uniformLookupTable:lookupTable, bufferSize:bufferSize)
    }
    
    
    func render(with commandBuffer: MTLCommandBuffer) {
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder(), let input = input, let output = output else {
            fatalError("Could not create compute encoder")
        }
        computeEncoder.label = operationName
        computeEncoder.setComputePipelineState(computePipelineState)
        
        computeEncoder.setTexture(input, index: 0)
        computeEncoder.setTexture(output, index: 1)
        
        uniformSettings.restoreShaderSettings(computeEncoder: computeEncoder)

        guard let (threadgroupSize, threadgroupCount) = obtainThreadgroup(computePipelineState: computePipelineState, width: input.width, height: input.height) else {
            computeEncoder.endEncoding()
            fatalError("fail obtain threadgroup")
        }
        computeEncoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
        
        computeEncoder.endEncoding()
    }
}
