//
//  THBMainVC.swift
//  THBExampleDemo
//
//  Created by tanghongbo on 2022/12/14.
//

import UIKit
import MetalKit

class THBMainVC: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .red
        self.view.addSubview(view)
        
        self.render()
    }
    
    
    
    func render() {
        let textureLoader = MTKTextureLoader(device: sharedMetalRenderingDevice.device)
        guard let path = Bundle.main.path(forResource: "comics_22.png", ofType: nil) else { return  }
        let image = UIImage(contentsOfFile: path)
        let texture = try! textureLoader.newTexture(cgImage:image!.cgImage!, options: [MTKTextureLoader.Option.SRGB : false])
        
//        let texDescriptor = MTLTextureDescriptor()
//        texDescriptor.textureType = MTLTextureType.type2D
//        texDescriptor.width = 1000
//        texDescriptor.height = 1000
//        texDescriptor.sampleCount = 1
//        texDescriptor.pixelFormat = .rgba8Unorm
//        texDescriptor.storageMode = .shared
//        texDescriptor.usage = .renderTarget.union(.shaderWrite)
//
//        let dsttexture = sharedMetalRenderingDevice.device.makeTexture(descriptor: texDescriptor)
        
        let pixel = PixelbufferUtil.pixelBuffer(width: 1000, height: 1000)!
        let dsttexture = Texture.makeTexture(pixelBuffer: pixel)?.texture

        
        let commandbuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer()!
        
        let pipeline = GrayComputePipeline.init()
        pipeline.input = texture
        pipeline.output = dsttexture
        pipeline.render(with: commandbuffer)
        
        let pass = PassthroughRenderPipeline()
        pass.input = texture
        pass.output = dsttexture
        pass.render(commandBuffer: commandbuffer)
        
        commandbuffer.commit()
        
        
        let image2 = PixelbufferUtil.image(from: dsttexture!)

        let a = 0;
    }

    
    
//    - (CVPixelBufferRef)getPixelBufferFromBGRAMTLTexture:(id<MTLTexture>)texture {
//        CVPixelBufferRef pxbuffer = NULL;
//        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
//                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
//                                 nil];
//
//        size_t imageByteCount = texture.width * texture.height * 4;
//        void *imageBytes = malloc(imageByteCount);
//        NSUInteger bytesPerRow = texture.width * 4;
//
//        MTLRegion region = MTLRegionMake2D(0, 0, texture.width, texture.height);
//        [texture getBytes:imageBytes bytesPerRow:bytesPerRow fromRegion:region mipmapLevel:0];
//
//        CVPixelBufferCreateWithBytes(kCFAllocatorDefault,texture.width,texture.height,kCVPixelFormatType_32BGRA,imageBytes,bytesPerRow,NULL,NULL,(__bridge CFDictionaryRef)options,&pxbuffer);
//
//    //    free(imageBytes); CVPixelBufferCreateWithBytes 不会拷贝 因此这里不能直接释放
//
//        return pxbuffer;
//    }

    

}
