

import UIKit

class PixelbufferUtil {
    
    
    static func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        return pixelBuffer(width: width, height: height, type: kCVPixelFormatType_32BGRA)
    }
    
    static func pixelBuffer(width: Int, height: Int, type: OSType) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        

        let attrs: [String: Any] = [kCVPixelBufferCGImageCompatibilityKey as String: true,
                                    kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
                                    kCVPixelBufferIOSurfacePropertiesKey as String: [:]]
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, type, attrs as CFDictionary, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        return pixelBuffer;
    }
    

    
    
    
    
    

    static func pixelBuffer(image: UIImage) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage else {return nil}
        return pixelBuffer(cgImage: cgImage, type: kCVPixelFormatType_32BGRA)
    }
    
    static func pixelBuffer(cgImage: CGImage) -> CVPixelBuffer? {
        return pixelBuffer(cgImage: cgImage, type: kCVPixelFormatType_32BGRA)
    }
    
    static func pixelBuffer(cgImage: CGImage, type: OSType) -> CVPixelBuffer? {
        var pxbuffer: CVPixelBuffer? = nil
        let options: [String: Any] = [kCVPixelBufferCGImageCompatibilityKey as String: true,
                                      kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
                                      kCVPixelBufferMetalCompatibilityKey as String: true,
                                      kCVPixelBufferIOSurfacePropertiesKey as String: [:]]
        
        let width =  cgImage.width
        let height = cgImage.height
        let bytesPerRow = cgImage.bytesPerRow
        
        let dataFromImageDataProvider = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, cgImage.dataProvider!.data)
        
        
        CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, CFDataGetMutableBytePtr(dataFromImageDataProvider), bytesPerRow, nil, nil, options as CFDictionary, &pxbuffer)
        return pxbuffer!;
    }
    
    
    static func image(from texture: MTLTexture) -> UIImage? {
        let bytesPerPixel = 4
        let imageByteCount = texture.width * texture.height * bytesPerPixel
        let bytesPerRow = texture.width * bytesPerPixel
        var src = [UInt8](repeating: 0, count: Int(imageByteCount))
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        texture.getBytes(&src, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue))
        let bitsPerComponent = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &src, width: texture.width, height: texture.height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        guard let dstImage = context?.makeImage() else { return nil }
        
        return UIImage(cgImage: dstImage, scale: 0.0, orientation: .up)
    }
    
    
    static func buffer(from image: UIImage) -> CVPixelBuffer? {
        let options: [String: Any] = [kCVPixelBufferCGImageCompatibilityKey as String: true,
                                      kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
                                      kCVPixelBufferMetalCompatibilityKey as String: true,
                                      kCVPixelBufferIOSurfacePropertiesKey as String: [:]]
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
}
