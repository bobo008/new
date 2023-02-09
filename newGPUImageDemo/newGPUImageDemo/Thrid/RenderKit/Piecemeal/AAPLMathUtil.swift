
import simd
import Foundation

class AAPLMathUtil {
    
    // projection Matrix
    static func matrix_ortho_left_hand(left: Float, right: Float, bottom: Float, top: Float, nearZ: Float, farZ: Float) -> simd_float4x4 {
        return matrix_make_rows(m00: 2 / (right - left), m10:                  0, m20:                  0, m30: (left + right) / (left - right),
                                m01:                  0, m11: 2 / (top - bottom), m21:                  0, m31: (top + bottom) / (bottom - top),
                                m02:                  0, m12:                  0, m22: 1 / (farZ - nearZ), m32:          nearZ / (nearZ - farZ),
                                m03:                  0, m13:                  0, m23:                  0, m33:                               1)
    }
    
    // look at Matrix
    static func  matrix_look_at_left_hand(eye: simd_float3, target: simd_float3, up: simd_float3) -> simd_float4x4  {
        let z = simd_normalize(target - eye)
        let x = simd_normalize(simd_cross(up, z))
        let y = simd_cross(z, x)
        let t = vector_float3(-simd_dot(x, eye), -simd_dot(y, eye), -simd_dot(z, eye))

        return matrix_make_rows(m00: x.x, m10: x.y, m20: x.z, m30: t.x,
                                m01: y.x, m11: y.y, m21: y.z, m31: y.y,
                                m02: z.x, m12: z.y, m22: z.z, m32: t.x,
                                m03:   0, m13:   0, m23:   0, m33:   1)
    }
    

    static func matrix_make_rows(m00: Float, m10: Float, m20: Float, m30: Float,
                                 m01: Float, m11: Float, m21: Float, m31: Float,
                                 m02: Float, m12: Float, m22: Float, m32: Float,
                                 m03: Float, m13: Float, m23: Float, m33: Float) -> simd_float4x4 {
        return simd_float4x4(SIMD4(m00, m01, m02, m03),
                             SIMD4(m10, m11, m12, m13),
                             SIMD4(m20, m21, m22, m23),
                             SIMD4(m30, m31, m32, m33))
    }
    

}
