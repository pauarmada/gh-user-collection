//
//  ColorExtensions.swift
//  GhUserCollection
//
//  Created by Paulus Armada on 2024/09/07.
//

import SwiftUI

struct HexColor {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    
    init?(hex: String) {
        var trimmedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if trimmedHex.hasPrefix("#") {
            trimmedHex.remove(at: trimmedHex.startIndex)
        }

        guard trimmedHex.count == 6 || trimmedHex.count == 8 else {
            return nil
        }

        var argb: UInt64 = 0
        Scanner(string: trimmedHex).scanHexInt64(&argb)
        
        red = CGFloat((argb & 0xFF0000) >> 16) / 255.0
        green = CGFloat((argb & 0xFF00) >> 8) / 255.0
        blue =  CGFloat(argb & 0xFF) / 255.0
        alpha = trimmedHex.count > 6 ? CGFloat((argb & 0xFF000000) >> 24) / 255.0 : 1.0
    }
    
    func asColor() -> Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension Color {
    static func from(hex: String) -> Color? {
        HexColor(hex: hex)?.asColor()
    }
}
