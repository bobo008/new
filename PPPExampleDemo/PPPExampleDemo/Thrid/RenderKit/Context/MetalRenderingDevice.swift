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
    
    public var renderCache = [MTLRenderPipelineDescriptor: (MTLRenderPipelineState, [String:(Int, MTLDataType)])]()
    public var computeCache = [MTLComputePipelineDescriptor: (MTLComputePipelineState, [String:(Int, MTLDataType)])]()
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
    
    
    
    
    func generateComputePipelineState(kernelFunctionName:String, operationName:String = "Off Screen Render", pixelFormat:MTLPixelFormat = MTLPixelFormat.rgba8Unorm) -> (MTLComputePipelineState, [String:(Int, MTLDataType)]) {
        guard let kernelFunction = self.shaderLibrary.makeFunction(name: kernelFunctionName) else {
            fatalError("\(operationName): could not compile kernel function \(kernelFunctionName)")
        }
        
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = kernelFunction

        if let (pipelineState, uniformLookupTable) = computeCache[descriptor] {
            return (pipelineState, uniformLookupTable)
        } else {
            do {
                var reflection:MTLAutoreleasedComputePipelineReflection?
                let pipelineState = try self.device.makeComputePipelineState(descriptor: descriptor, options: [.bufferTypeInfo, .argumentInfo], reflection: &reflection)
                var uniformLookupTable:[String:(Int, MTLDataType)] = [:]
                if let kernelArguments = reflection?.arguments {
                    for kernelArgument in kernelArguments where kernelArgument.type == .buffer {
                        if (kernelArgument.bufferDataType == .struct), let members = kernelArgument.bufferStructType?.members.enumerated() {
                            for (index, uniform) in members {
                                uniformLookupTable[uniform.name] = (index, uniform.dataType)
                            }
                        }
                    }
                }

                computeCache[descriptor] = (pipelineState, uniformLookupTable)
                return (pipelineState, uniformLookupTable)
            } catch {
                fatalError("Could not create compute pipeline state for kernel:\(kernelFunctionName), error:\(error)")
            }
        }
        
    }
    
    func generateRenderPipelineState(vertexFunctionName:String, fragmentFunctionName:String, operationName:String = "Off Screen Render", pixelFormat:MTLPixelFormat = MTLPixelFormat.rgba8Unorm) -> (MTLRenderPipelineState, [String:(Int, MTLDataType)]) {
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
        
        if let (pipelineState, uniformLookupTable) = renderCache[descriptor] {
            return (pipelineState, uniformLookupTable)
        } else {
            do {
                var reflection:MTLAutoreleasedRenderPipelineReflection?
                let pipelineState = try self.device.makeRenderPipelineState(descriptor: descriptor, options: [.bufferTypeInfo, .argumentInfo], reflection: &reflection)
                var uniformLookupTable:[String:(Int, MTLDataType)] = [:]
                if let fragmentArguments = reflection?.fragmentArguments {
                    for fragmentArgument in fragmentArguments where fragmentArgument.type == .buffer {
                        if (fragmentArgument.bufferDataType == .struct), let members = fragmentArgument.bufferStructType?.members.enumerated() {
                            for (index, uniform) in members {
                                uniformLookupTable[uniform.name] = (index, uniform.dataType)
                            }
                        }
                    }
                }
                renderCache[descriptor] = (pipelineState, uniformLookupTable)
                return (pipelineState, uniformLookupTable)
            } catch {
                fatalError("Could not create render pipeline state for vertex:\(vertexFunctionName), fragment:\(fragmentFunctionName), error:\(error)")
            }
        }
    }
}
