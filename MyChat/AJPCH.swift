
//  AJPCH.swift
//
//
//  Created by abc on 19/11/27.
//  Copyright © 2019年 cn.www. All rights reserved.
//

import UIKit



public  let ScreenW =  UIScreen.main.bounds.size.width
public  let ScreenH = UIScreen.main.bounds.size.height

var iPhoneX : Bool = (UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0) || (UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0) || (UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 896.0)  ? true : false  //x  xsM  xr  的尺寸
//状态栏高度
var statusBarH : CGFloat = iPhoneX == true  ? 44.00 : 20.00
//导航栏加上状态栏高度
var navStatusBarH : CGFloat = iPhoneX == true  ? 88.00 : 64.00
//导航栏
var navBarH : CGFloat = iPhoneX == true  ? 44.00 : 44.00
//全面屏底部安全区高度
var bottomSafeH : CGFloat = iPhoneX == true ? 34.00 : 0.00

var GRAY_BACKGROUND_COLOR =  UIColor.colorWithHexString(color: "#F5F6FA")//灰底色





