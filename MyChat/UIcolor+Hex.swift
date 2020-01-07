//
//  UIcolor-Extension.swift
//  MyChat
//
//  Created by Xijie Lin on 1/6/20.
//  Copyright © 2020 com.cn. All rights reserved.
//

import UIKit
import Foundation
extension UIColor {
    
    
    class func colorWithHexString(color : String) -> UIColor{
    
       return self.colorWithHexString(color: color, alpha: 1.0)
    
    
    }
    // hexadecimal to color
    class func colorWithHexString(color : String , alpha : CGFloat) -> UIColor{
        // delete the space in the string
        var  cString = color
        
        // String should be 6 or 8 characters
        if cString.lengthOfBytes(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) < 6{
            return UIColor.clear
        }
        // if string starts with "0x", then start reading at index 2
        if cString.hasPrefix("0x") {
            cString = (cString as NSString).substring(from: 2)
        }
        // if string starts with "#", then start reading at index 1
        if cString.hasPrefix("#") {
            cString = (cString as NSString).substring(from: 1)
        }
        if cString.lengthOfBytes(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) !=  6{
            return UIColor.clear
        }
        
        
        // Separate into r, g, b substrings
        var range : NSRange = NSRange(location: 0, length: 2)
        //r
        let rString = (cString as NSString).substring(with: range)
        //g
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        //b
        range.location = 4
        let bString = (cString as NSString).substring(with: range)

        let r  = hexTodec(num: rString)
        let g  = hexTodec(num: gString)
        let b  = hexTodec(num: bString)
        return UIColor.init(red:  CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
         //UIColor(colorLiteralRed: Float(r) / 255.0, green: Float(g) / 255.0, blue: Float(b) / 255.0, alpha: Float(alpha))
}

    // MARK: - hexadecimal to decimal
    class func hexTodec(num:String) -> Int {
        let str = num.uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 start from 48
            if i >= 65 {                 // A-Z start from 65, but default value is 10, so subtract 55 from it
                sum -= 7
            }
        }
        return sum
    }
}

