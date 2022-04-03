//
//  CGFloat+Spacing.swift
//  Electrolux_Test
//
//  Created by koh kar heng on 31/03/2022.
//


import CoreGraphics

public extension CGFloat {
    private static var base:CGFloat {
        return 8
    }
    
    /// Return CGFloat value with value 8
    static let spacing_1: CGFloat = 1 * base
    /// Return CGFloat value with value 16
    static let spacing_2: CGFloat = 2 * base
    /// Return CGFloat value with value 24
    static let spacing_3: CGFloat = 3 * base
}

public extension CGFloat {
    static let scenePadding: CGFloat = spacing_1
}
