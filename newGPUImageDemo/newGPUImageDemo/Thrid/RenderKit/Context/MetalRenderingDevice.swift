import Foundation
import Metal
import MetalPerformanceShaders

public let sharedMetalRenderingDevice = MetalRenderingDevice()

public let standardImageVertices:[Float] = [-1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0]
public let standardImageTextureCoordinates:[Float] = [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0]
public let vertexBuffer = sharedMetalRenderingDevice.device.makeBuffer(bytes: standardImageVertices, length: standardImageVertices.count * MemoryLayout<Float>.size, options: [])!
public let textureBuffer = sharedMetalRenderingDevice.device.makeBuffer(bytes: standardImageTextureCoordinates, length: standardImageTextureCoordinates.count * MemoryLayout<Float>.size, options: [])!







public class MetalRenderingDevice {
    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue
    public let shaderLibrary: MTLLibrary
    
    public var renderCache = [MTLRenderPipelineDescriptor: (MTLRenderPipelineState, [String:(Int, MTLStructMember)], Int)]()
    public var computeCache = [MTLComputePipelineDescriptor: (MTLComputePipelineState, [String:(Int, MTLStructMember)], Int)]()
    public lazy var textureCache: TextureCache = { TextureCache() }()

    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {fatalError("Could not create Metal Device")}
        self.device = device
        
        guard let queue = self.device.makeCommandQueue() else {fatalError("Could not create command queue")}
        self.commandQueue = queue
        
        do {
            let frameworkBundle = Bundle(for: MetalRenderingDevice.self)
            let metalLibraryPath = frameworkBundle.path(forResource: "default", ofType: "metallib")!
            
            self.shaderLibrary = try device.makeLibrary(filepath:metalLibraryPath)
        } catch {
            fatalError("Could not load library")
        }
    }
    
    
    
    
    func generateComputePipelineState(kernelFunctionName:String, operationName:String = "Off Screen Render", pixelFormat:MTLPixelFormat = MTLPixelFormat.bgra8Unorm) -> (MTLComputePipelineState, [String:(Int, MTLStructMember)], Int) {
        guard let kernelFunction = self.shaderLibrary.makeFunction(name: kernelFunctionName) else {
            fatalError("\(operationName): could not compile kernel function \(kernelFunctionName)")
        }
        
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = kernelFunction

        if let (pipelineState, uniformLookupTable, size) = computeCache[descriptor] {
            return (pipelineState, uniformLookupTable,size)
        } else {
            do {
                
                var reflection:MTLAutoreleasedComputePipelineReflection?
                let pipelineState = try self.device.makeComputePipelineState(descriptor: descriptor, options: [.bufferTypeInfo, .argumentInfo], reflection: &reflection)

                var uniformLookupTable:[String:(Int, MTLStructMember)] = [:]
                var bufferSize: Int = 0
                if let fragmentArguments = reflection?.arguments {
                    for fragmentArgument in fragmentArguments where fragmentArgument.type == .buffer {
                        if
                          (fragmentArgument.bufferDataType == .struct),
                          let members = fragmentArgument.bufferStructType?.members.enumerated() {
                            bufferSize = fragmentArgument.bufferDataSize
                            for (index, uniform) in members {
                                uniformLookupTable[uniform.name] = (index, uniform)
                            }
                        }
                    }
                }
                return (pipelineState, uniformLookupTable, bufferSize)
            } catch {
                fatalError("Could not create compute pipeline state for kernel:\(kernelFunctionName), error:\(error)")
            }
        }
        
    }
    
    func generateRenderPipelineState(vertexFunctionName:String, fragmentFunctionName:String, operationName:String = "Off Screen Render", pixelFormat:MTLPixelFormat = MTLPixelFormat.bgra8Unorm) -> (MTLRenderPipelineState, [String:(Int, MTLStructMember)], Int) {
        guard let vertexFunction = self.shaderLibrary.makeFunction(name: vertexFunctionName) else {
            fatalError("\(operationName): could not compile vertex function \(vertexFunctionName)")
        }
        
        guard let fragmentFunction = self.shaderLibrary.makeFunction(name: fragmentFunctionName) else {
            fatalError("\(operationName): could not compile fragment function \(fragmentFunctionName)")
        }
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = pixelFormat
        descriptor.rasterSampleCount = 1
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        
        if let (pipelineState, uniformLookupTable, size) = renderCache[descriptor] {
            return (pipelineState, uniformLookupTable, size)
        } else {
            do {
                var reflection:MTLAutoreleasedRenderPipelineReflection?
                let pipelineState = try self.device.makeRenderPipelineState(descriptor: descriptor, options: [.bufferTypeInfo, .argumentInfo], reflection: &reflection)

                var uniformLookupTable:[String:(Int, MTLStructMember)] = [:]
                var bufferSize: Int = 0
                if let fragmentArguments = reflection?.fragmentArguments {
                    for fragmentArgument in fragmentArguments where fragmentArgument.type == .buffer {
                        if
                          (fragmentArgument.bufferDataType == .struct),
                          let members = fragmentArgument.bufferStructType?.members.enumerated() {
                            bufferSize = fragmentArgument.bufferDataSize
                            for (index, uniform) in members {
                                uniformLookupTable[uniform.name] = (index, uniform)
                            }
                        }
                    }
                }
                
                return (pipelineState, uniformLookupTable, bufferSize)
            } catch {
                fatalError("Could not create render pipeline state for vertex:\(vertexFunctionName), fragment:\(fragmentFunctionName), error:\(error)")
            }
        }
    }
}


// 一些公共的方法可以放在这边，合理一些
public func obtainRenderPassDescriptor(output: MTLTexture) -> MTLRenderPassDescriptor {
    let renderPass = MTLRenderPassDescriptor()
    renderPass.colorAttachments[0].texture = output
    renderPass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
    renderPass.colorAttachments[0].storeAction = .store
    renderPass.colorAttachments[0].loadAction = .clear
    return renderPass
}

public func obtainThreadgroup(computePipelineState: MTLComputePipelineState, width: Int, height: Int) -> (MTLSize, MTLSize)? {
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
