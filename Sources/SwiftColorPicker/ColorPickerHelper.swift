///
//  @filename   ColorPickerHelper.swift
//  @package    
//  
//  @author     jeffy
//  @date       2023/5/31 
//  @abstract   
//
//  Copyright © 2023 and Confidential to jeffy All rights reserved.
//

import Foundation
import CoreGraphics

enum InfComponentIndex: Int {
    case hue = 0
    case saturation = 1
    case brightness = 2
}

//------------------------------------------------------------------------------
// MARK: - Floating point conversion
//------------------------------------------------------------------------------

private func hueToComponentFactors(_ h: Float, _ r: inout Float, _ g: inout Float, _ b: inout Float) {
    let h_prime = h / 60.0
    let x = 1.0 - abs(fmodf(h_prime, 2.0) - 1.0)
    
    if h_prime < 1.0 {
        r = 1
        g = x
        b = 0
    } else if h_prime < 2.0 {
        r = x
        g = 1
        b = 0
    } else if h_prime < 3.0 {
        r = 0
        g = 1
        b = x
    } else if h_prime < 4.0 {
        r = 0
        g = x
        b = 1
    } else if h_prime < 5.0 {
        r = x
        g = 0
        b = 1
    } else {
        r = 1
        g = 0
        b = x
    }
}

//------------------------------------------------------------------------------

func HSVtoRGB(h: Float, s: Float, v: Float) -> (r: Float, g: Float, b: Float) {
    var r: Float = 0, g: Float = 0, b: Float = 0
    hueToComponentFactors(h, &r, &g, &b)
    
    let c = v * s
    let m = v - c
    
    r = r * c + m
    g = g * c + m
    b = b * c + m
    
    return (r, g, b)
}

func RGBToHSV(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
    var h: CGFloat = 0.0
    var s: CGFloat = 0.0
    var v: CGFloat = 0.0
    
    let maxVal = max(r, max(g, b))
    let minVal = min(r, min(g, b))
    let delta = maxVal - minVal
    v = maxVal
    s = (maxVal != 0.0) ? delta / maxVal : 0.0
    if s != 0.0 {
        if r == maxVal {
            h = (g - b) / delta
        } else if g == maxVal {
            h = 2.0 + (b - r) / delta
        } else {
            h = 4.0 + (r - g) / delta
        }
        h *= 60.0
        if h < 0.0 {
            h += 360.0
        }
    }
    
    return (h, s, v)
}

//------------------------------------------------------------------------------
// MARK: - Square/Bar image creation
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

private func createBGRxImageContext(_ w: Int, _ h: Int, _ data: UnsafeMutableRawPointer?) -> CGContext? {
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
    
    let kBGRxBitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue
    // BGRA is the most efficient on the iPhone.
    
    guard let context = CGContext(data: data, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4, space: colorSpace, bitmapInfo: kBGRxBitmapInfo) else { return nil }
    
    return context
}

//------------------------------------------------------------------------------

private func blend(_ value: UInt8, _ percentIn255: UInt8) -> UInt8 {
    return UInt8(Int(value) * Int(percentIn255) / 255)
}

func createSaturationBrightnessSquareContentImageWithHue(_ hue: Float) -> CGImage? {
    guard let data = malloc(256 * 256 * 4) else { return nil }
    

    guard let context = createBGRxImageContext(256, 256, data) else {
        free(data)
        return nil
    }
    
    var dataPtr = data.bindMemory(to: UInt8.self, capacity: 256 * 256 * 4)
    let rowBytes = context.bytesPerRow
    
    var r: Float = 0, g: Float = 0, b: Float = 0
    hueToComponentFactors(hue, &r, &g, &b)

    var s:UInt8 = 0
    while (s <= UInt8.max) {
        
        var ptr = dataPtr
        
        let b_s = 1 - Float(s)/255.0*(1-b)
        let g_s = 1 - Float(s)/255.0*(1-g)
        let r_s = 1 - Float(s)/255.0*(1-r)
        var v:UInt8 = UInt8.max
        while (v >= 0) {
            //        for v in (0...UInt8.max).reversed() {
            let fv = Float(v)
            ptr[0] = UInt8(fv*b_s)
            ptr[1] = UInt8(fv*g_s)
            ptr[2] = UInt8(fv*r_s)
            ptr += rowBytes
            if v == 0 { break }
            v -= 1
        }

        dataPtr += 4
        if s == UInt8.max { break }
        s += 1
    }

    // Return an image of the context's content:
    let image = context.makeImage()

    free(data)

    return image
}

//------------------------------------------------------------------------------

func createHSVBarContentImage(barComponentIndex: InfComponentIndex, hsv: inout [Float]) -> CGImage? {
    var data = [UInt8](repeating: 0, count: 256 * 4)
    
    // Set up the bitmap context for filling with color:
    
    guard let context = createBGRxImageContext(256, 1, &data) else { return nil }
    
    // Draw into context here:
    
    var ptr = context.data?.bindMemory(to: UInt8.self, capacity: 256 * 4)
    if ptr == nil {
        return nil
    }
    
    var r: Float = 0, g: Float = 0, b: Float = 0
    for x in 0..<256 {
        hsv[barComponentIndex.rawValue] = Float(x) / 255.0
        (r, g, b) = HSVtoRGB(h: hsv[0] * 360.0, s: hsv[1], v: hsv[2])
        
        ptr![0] = UInt8(b * 255.0)
        ptr![1] = UInt8(g * 255.0)
        ptr![2] = UInt8(r * 255.0)
        
        ptr = ptr?.advanced(by: 4)
    }
    
    // Return an image of the context's content:
    
    let image = context.makeImage()
    
    return image
}

//
//private func blend(_ value: UInt8, _ percentIn255: UInt8) -> UInt8 {
//    return UInt8(Int(value) * Int(percentIn255) / 255)
//}
//
//func createSaturationBrightnessSquareContentImageWithHue(_ hue: Float) -> CGImage? {
//    guard let data = malloc(256 * 256 * 4) else { return nil }
//
//
//    guard let context = createBGRxImageContext(256, 256, data) else {
//        free(data)
//        return nil
//    }
//
//    var dataPtr = data.bindMemory(to: UInt8.self, capacity: 256 * 256 * 4)
//    let rowBytes = context.bytesPerRow
//
//    var r: Float = 0, g: Float = 0, b: Float = 0
//    hueToComponentFactors(hue, &r, &g, &b)
//
//    let r_s: UInt8 = UInt8((1.0 - r) * 255)
//    let g_s: UInt8 = UInt8((1.0 - g) * 255)
//    let b_s: UInt8 = UInt8((1.0 - b) * 255)
//
//    let t_start = CFAbsoluteTimeGetCurrent()
//
//    for s in 0..<256 {
//        var ptr = dataPtr
//
////        let r_hs = 255 - blend(UInt8(s), r_s)
////        let g_hs = 255 - blend(UInt8(s), g_s)
////        let b_hs = 255 - blend(UInt8(s), b_s)
//
//        for v in (0...255).reversed() {
//            let vs = Float(v*s)/255.0
////            ptr[0] = blend(UInt8(v), b_hs);
////            ptr[1] = blend(UInt8(v), g_hs);
////            ptr[2] = blend(UInt8(v), r_hs);
//            ptr[0] = UInt8(v - Int(vs*(1.0-b)))
//            ptr[1] = UInt8(v - Int(vs*(1.0-g)))
//            ptr[2] = UInt8(v - Int(vs*(1.0-r)))
//
//            ptr += rowBytes
//        }
//
//        dataPtr += 4
//    }
//
//    let t_end = CFAbsoluteTimeGetCurrent()
//    NSLog("+++ 耗时: %f", t_end - t_start);
//
//    // Return an image of the context's content:
//    let image = context.makeImage()
//
//    free(data)
//
//    return image
//}
