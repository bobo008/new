
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
        let (pipelineState, lookupTable) = sharedMetalRenderingDevice.generateComputePipelineState(kernelFunctionName: "grayscaleKernel")
        self.computePipelineState = pipelineState
        self.uniformSettings = ShaderUniformSettings(uniformLookupTable:lookupTable)
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
    
    
    func obtainThreadgroup(computePipelineState: MTLComputePipelineState, width: Int, height: Int) -> (MTLSize, MTLSize)? {
        var size = 32
        while size * size > computePipelineState.maxTotalThreadsPerThreadgroup {
            size /= 2
        }
        if size == 0 {
            assertionFailure()
            return nil
        }
        let threadgroupSize = MTLSize.init(width: size, height: size, depth: 1)
        // 加 size - 1 起到ceil的效果
        let threadgroupCount = MTLSize.init(width: (width + size - 1) / size, height: (height + size - 1) / size, depth: 1)
        
        return (threadgroupSize, threadgroupCount)
    }
}
