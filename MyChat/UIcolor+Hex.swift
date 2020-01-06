//
//  UIcolor-Extension.swift
//  abc
//
//  Created by abc on 19/1/9.
//  Copyright © 2019年 abc. All rights reserved.
//

import UIKit
import Foundation
extension UIColor {
    
    
    class func colorWithHexString(color : String) -> UIColor{
    
       return self.colorWithHexString(color: color, alpha: 1.0)
    
    
    }
    //16进制颜色设置
    class func colorWithHexString(color : String , alpha : CGFloat) -> UIColor{
        //删除字符串中的空格
        var  cString = color
        
        // String should be 6 or 8 characters
        if cString.lengthOfBytes(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) < 6{
            return UIColor.clear
        }
        //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
        if cString.hasPrefix("0x") {
            cString = (cString as NSString).substring(from: 2)
        }
        //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
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

    // MARK: - 十六进制转十进制
    class func hexTodec(num:String) -> Int {
        let str = num.uppercased()//大写
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }
}

