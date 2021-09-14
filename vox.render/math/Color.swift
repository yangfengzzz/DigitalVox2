//
//  Color.swift
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

import Foundation


/// Describes a color in the from of RGBA (in order: R, G, B, A).
class Color {
    /// The color component of the color, 0~1.
    public var elements: SIMD4<Float>

    /// The red component of the color, 0~1.
    public var r: Float {
        get {
            elements.x
        }
        set {
            elements.x = newValue
        }
    }
    /// The green component of the color, 0~1.
    public var g: Float {
        get {
            elements.y
        }
        set {
            elements.y = newValue
        }
    }
    /// The blue component of the color, 0~1.
    public var b: Float {
        get {
            elements.z
        }
        set {
            elements.z = newValue
        }
    }
    /// The alpha component of the color, 0~1.
    public var a: Float {
        get {
            elements.w
        }
        set {
            elements.w = newValue
        }
    }

    /// Constructor of Color.
    /// - Parameters:
    ///   - r: The red component of the color
    ///   - g: The green component of the color
    ///   - b: The blue component of the color
    ///   - a: The alpha component of the color
    init(_ r: Float = 1, _ g: Float = 1, _ b: Float = 1, _ a: Float = 1) {
        self.elements = [r, g, b, a]
    }
}

extension Color: IClone {
    typealias Object = Color

    func clone() -> Color {
        Color(r, g, b, a)
    }

    func cloneTo(target: Color) {
        target.elements = elements
    }
}

extension Color {
    /// Modify a value from the gamma space to the linear space.
    /// - Parameter value: The value in gamma space
    /// - Returns: The value in linear space
    static func gammaToLinearSpace(value: Float) -> Float {
        // https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_framebuffer_sRGB.txt
        // https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_texture_sRGB_decode.txt

        if (value <= 0.0) {
            return 0.0
        } else if (value <= 0.04045) {
            return value / 12.92
        } else if (value < 1.0) {
            return pow((value + 0.055) / 1.055, 2.4)
        } else {
            return pow(value, 2.4)
        }
    }

    /// Modify a value from the linear space to the gamma space.
    /// - Parameter value: The value in linear space
    /// - Returns: The value in gamma space
    static func linearToGammaSpace(value: Float) -> Float {
        // https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_framebuffer_sRGB.txt
        // https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_texture_sRGB_decode.txt

        if (value <= 0.0) {
            return 0.0
        } else if (value < 0.0031308) {
            return 12.92 * value
        } else if (value < 1.0) {
            return 1.055 * pow(value, 0.41666) - 0.055
        } else {
            return pow(value, 0.41666)
        }
    }

    /// Determines whether the specified colors are equals.
    /// - Parameters:
    ///   - left: The first color to compare
    ///   - right: The second color to compare
    /// - Returns: True if the specified colors are equals, false otherwise
    static func equals(left: Color, right: Color) -> Bool {
        MathUtil.equals(left.r, right.r) &&
        MathUtil.equals(left.g, right.g) &&
        MathUtil.equals(left.b, right.b) &&
        MathUtil.equals(left.a, right.a)
    }

    /// Determines the sum of two colors.
    /// - Parameters:
    ///   - left: The first color to add
    ///   - right: The second color to add
    ///   - out: The sum of two colors
    static func add(left: Color, right: Color, out: Color) {
        out.elements = left.elements + right.elements
    }

    /// Scale a color by the given value.
    /// - Parameters:
    ///   - left: The color to scale
    ///   - s: The amount by which to scale the color
    ///   - out: The scaled color
    static func scale(left: Color, s: Float, out: Color) {
        out.elements = left.elements * s
    }
}

extension Color {
    /// Set the value of this color.
    /// - Parameters:
    ///   - r: The red component of the color
    ///   - g: The green component of the color
    ///   - b: The blue component of the color
    ///   - a: The alpha component of the color
    /// - Returns: This color.
    func setValue(r: Float, g: Float, b: Float, a: Float) -> Color {
        elements = [r, g, b, a]
        return self
    }
    
    /// Determines the sum of this color and the specified color.
    /// - Parameter color: The specified color
    /// - Returns: This color
    func add(color: Color) -> Color {
        elements += color.elements

        return self
    }
    
    /// Scale this color by the given value.
    /// - Parameter s: The amount by which to scale the color
    /// - Returns: This color
    func scale(s: Float) -> Color {
        elements *= s

        return self
    }

    /// Modify components (r, g, b) of this color from gamma space to linear space.
    /// - Parameter out: The color in linear space
    /// - Returns: The color in linear space
    func toLinear(out: Color) -> Color {
        out.r = Color.gammaToLinearSpace(value: r)
        out.g = Color.gammaToLinearSpace(value: g)
        out.b = Color.gammaToLinearSpace(value: b)
        return out
    }

    /// Modify components (r, g, b) of this color from linear space to gamma space.
    /// - Parameter out: The color in gamma space
    /// - Returns: The color in gamma space
    func toGamma(out: Color) -> Color {
        out.r = Color.linearToGammaSpace(value: r)
        out.g = Color.linearToGammaSpace(value: g)
        out.b = Color.linearToGammaSpace(value: b)
        return out
    }
}
