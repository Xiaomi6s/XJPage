//
//  Helper.swift
//  XJPageView
//
//  Created by 任晓健 on 2017/2/22.
//  Copyright © 2017年 rxj. All rights reserved.
//

import Foundation
import UIKit

let scr_width = UIScreen.main.bounds.width
let scr_height = UIScreen.main.bounds.height

typealias offsetDidChangeClosures = (UIScrollView) -> Void

func setSystemFontSize(_ fontSize:CGFloat)-> UIFont {
    return UIFont.systemFont(ofSize: fontSize)
}
