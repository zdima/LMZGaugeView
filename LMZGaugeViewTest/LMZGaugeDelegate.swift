//
//  LMZGaugeDelegate.swift
//  LMZGaugeView
//
//  Created by Dmitriy Zakharkin on 9/5/15.
//  Copyright (c) 2015 ZDima. All rights reserved.
//

import Foundation
import Cocoa

@objc
class LMZGaugeDelegate : NSObject, LMGaugeViewDelegate
{
	func gaugeView(gaugeView: LMZGaugeView, ringStokeColorForValue: CGFloat) -> NSColor? {

		var power: Double = 0
		var greenPower = gaugeView.minValue+(gaugeView.limitValue - gaugeView.minValue)*0.75
		if gaugeView.doubleValue > greenPower {
			power = min((gaugeView.doubleValue-greenPower) / (gaugeView.limitValue - greenPower), 1.0)
		}

		let H = 0.4 * (1.0-power) // Hue (note 0.4 = Green, see huge chart below)
		let S = 0.9 // Saturation
		let B = 0.9 // Brightness

		return NSColor(deviceHue: CGFloat(H), saturation: CGFloat(S), brightness: CGFloat(B), alpha: 1.0)
	}
}
