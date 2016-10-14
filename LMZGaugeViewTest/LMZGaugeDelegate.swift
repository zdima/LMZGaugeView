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
class LMZGaugeDelegate : NSObject, LMZGaugeViewDelegate
{
	func gaugeViewRingColor(_ gaugeView: LMZGaugeView) -> NSColor? {

		var power: Double = 0
		let greenPower = gaugeView.minValue+(gaugeView.limitValue - gaugeView.minValue)*0.75
		if gaugeView.doubleValue > greenPower {
			power = min((gaugeView.doubleValue-greenPower) / (gaugeView.limitValue - greenPower), 1.0)
		}

		let H = 0.4 * (1.0-power) // Hue (note 0.4 = Green, see huge chart below)
		let S = 0.9 // Saturation
		let B = 0.9 // Brightness

		return NSColor(deviceHue: CGFloat(H), saturation: CGFloat(S), brightness: CGFloat(B), alpha: 1.0)
	}

	func gaugeViewLabel1String(_ gaugeView: LMZGaugeView) -> String? {
		return NSString(format:"$%0.f", locale:nil, gaugeView.doubleValue) as String
	}
	func gaugeViewLabel2String(_ gaugeView: LMZGaugeView) -> String? {
		if gaugeView.doubleValue < gaugeView.limitValue*0.75 {
			return ""
		}
		if gaugeView.doubleValue < gaugeView.limitValue {
			return NSString(format:"$%0.f left", locale:nil, (gaugeView.limitValue-gaugeView.doubleValue)) as String
		}
		return NSString(format:"$%0.f over budget", locale:nil, (gaugeView.doubleValue - gaugeView.limitValue)) as String
	}
}
