
//  AJPCH.swift
//  MyChat
//
//  Created by Xijie Lin on 1/6/20.
//  Copyright © 2020 com.cn. All rights reserved.
//

import UIKit



public  let ScreenW =  UIScreen.main.bounds.size.width
public  let ScreenH = UIScreen.main.bounds.size.height

var iPhoneX : Bool = (UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0) || (UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0) || (UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 896.0)  ? true : false  //x  xsM  xr  's size
// the height of status bar
var statusBarH : CGFloat = iPhoneX == true  ? 44.00 : 20.00
// the height of navigation and status bar
var navStatusBarH : CGFloat = iPhoneX == true  ? 88.00 : 64.00
// the height of navigation bar
var navBarH : CGFloat = iPhoneX == true  ? 44.00 : 44.00
// the height of safe area
var bottomSafeH : CGFloat = iPhoneX == true ? 34.00 : 0.00

var GRAY_BACKGROUND_COLOR =  UIColor.colorWithHexString(color: "#F5F6FA")//灰底色





