//
//  LMZGaugeView.swift
//  LMZGaugeView
//
//  Created by Dmitriy Zakharkin on 9/4/15.
//  Copyright (c) 2015 ZDima. All rights reserved.
//

import Foundation
import Cocoa

@objc
public protocol LMGaugeViewDelegate {
	/// Return ring stroke color from the specified value.
	optional  func gaugeView(gaugeView: LMZGaugeView, ringStokeColorForValue: CGFloat) -> NSColor?;
}

public class LMZGaugeView : NSView {
	/// Current value.
	public var doubleValue: Double = 0 {
		didSet {
			if oldValue != doubleValue {
				var value = max( self.minValue, doubleValue)
				doubleValue = min( self.maxValue, value)
			}
			if oldValue != doubleValue {
				if let formatter = self.unitFormatter {
					self.valueLabel.stringValue = formatter.stringForObjectValue(self.doubleValue)!
				} else {
					self.valueLabel.stringValue = NSString(format:"%0.f", locale:nil, self.doubleValue) as String
				}
				if self.delegate != nil,
					let valuecolor = self.delegate!.gaugeView?(self, ringStokeColorForValue: CGFloat(self.doubleValue)) {
							self.ringColor = valuecolor
				} else  {
					self.ringColor = kDefaultRingColor
				}
				self.invalidateMath = true
				self.valueChanged = true
				self.needsDisplay = true
			}
		}
	}
	override public func value() -> AnyObject? {
		return NSNumber(double: doubleValue)
	}
	override public func setValue(value: AnyObject?) {
		doubleValue = doubleFromAnyObject(value)
	}
	/// Minimum value.
	@IBInspectable var minValue: Double = 0 {
		didSet {
			if oldValue != minValue {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// Maximum value.
	@IBInspectable var maxValue: Double = 100 {
		didSet {
			if oldValue != maxValue {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// Limit value.
	@IBInspectable var limitValue: Double = 50 {
		didSet {
			if oldValue != limitValue {
				if let formatter = self.unitFormatter {
					self.limitLabel.stringValue = "Limit \(formatter.stringForObjectValue(self.limitValue)!)"
				} else {
					self.limitLabel.stringValue = NSString(format:"Limit %0.f", locale:nil, self.limitValue) as String
				}
			}
		}
	}
	/// The number of divisions.
	@IBInspectable var numOfDivisions: Int = 10 {
		didSet {
			if oldValue != numOfDivisions {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The number of subdivisions.
	@IBInspectable var numOfSubDivisions: Int = 1 {
		didSet {
			if oldValue != numOfSubDivisions {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The thickness of the ring.
	@IBInspectable var ringThickness: CGFloat = 15 {
		didSet {
			if oldValue != ringThickness {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The background color of the ring.
	@IBInspectable var ringBackgroundColor: NSColor = NSColor(white: 0.9, alpha: 1.0) {
		didSet {
			if oldValue != ringBackgroundColor {
				self.needsDisplay = true
			}
		}
	}
	/// The divisions radius.
	@IBInspectable var divisionsRadius: CGFloat = 1.25 {
		didSet {
			if oldValue != divisionsRadius {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The divisions color.
	@IBInspectable var divisionsColor: NSColor = NSColor(white: 0.5, alpha: 1.0) {
		didSet {
			if oldValue != divisionsColor {
				self.needsDisplay = true
			}
		}
	}
	/// The padding between ring and divisions.
	@IBInspectable var divisionsPadding: CGFloat = 12 {
		didSet {
			if oldValue != divisionsPadding {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The subdivisions radius.
	@IBInspectable var subDivisionsRadius: CGFloat = 0.75 {
		didSet {
			if oldValue != subDivisionsRadius {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The subdivisions color.
	@IBInspectable var subDivisionsColor: NSColor = NSColor(white: 0.5, alpha: 0.5) {
		didSet {
			if oldValue != subDivisionsColor {
				self.needsDisplay = true
			}
		}
	}
	/// A boolean indicates whether to show limit dot.
	@IBInspectable var showLimitDot: Bool = true {
		didSet {
			if oldValue != showLimitDot {
				self.needsDisplay = true
			}
		}
	}
	/// The radius of limit dot.
	@IBInspectable var limitDotRadius: CGFloat = 2 {
		didSet {
			if oldValue != limitDotRadius {
				self.needsDisplay = true
			}
		}
	}
	/// The color of limit dot.
	@IBInspectable var limitDotColor: NSColor = NSColor.redColor() {
		didSet {
			if oldValue != limitDotColor {
				self.needsDisplay = true
			}
		}
	}
	/// Font of value label.
	@IBInspectable var valueFont: NSFont? = NSFont(name: "HelveticaNeue-CondensedBold", size: 19) {
		didSet {
			if oldValue != valueFont {
				self.valueLabel.font = valueFont
			}
		}
	}
	/// Font of limit value label.
	@IBInspectable var limitValueFont: NSFont? = NSFont(name: "HelveticaNeue-Condensed", size: 17) {
		didSet {
			if oldValue != limitValueFont {
				self.limitLabel.font = limitValueFont
			}
		}
	}
	/// Text color of value label.
	@IBInspectable var valueTextColor: NSColor = NSColor(white: 0.1, alpha: 1.0) {
		didSet {
			if oldValue != valueTextColor {
				if !self.useGaugeColor {
					valueLabel.textColor = valueTextColor
				}
			}
		}
	}
	/// Use gauge color to show the value
	@IBInspectable var useGaugeColor: Bool = true{
		didSet {
			if useGaugeColor {
				valueLabel.textColor = self.ringColor
			} else {
				valueLabel.textColor = valueTextColor
			}
		}
	}
	/// The unit of measurement.
	@IBOutlet var unitFormatter: NSFormatter? {
		didSet {
			if oldValue != unitFormatter {
				if let formatter = self.unitFormatter {
					self.valueLabel.stringValue = formatter.stringForObjectValue(self.doubleValue)!
					self.limitLabel.stringValue = "Limit \(formatter.stringForObjectValue(self.limitValue)!)"
				} else {
					self.valueLabel.stringValue = NSString(format:"%0.f", locale:nil, self.doubleValue) as String
					self.limitLabel.stringValue = NSString(format:"Limit %0.f", locale:nil, self.limitValue) as String
				}
			}
		}
	}

	/// The receiver of all gauge view delegate callbacks.
	@IBOutlet var delegate: LMGaugeViewDelegate? {
		didSet {
			if self.delegate != nil,
				let valuecolor = self.delegate!.gaugeView?(self, ringStokeColorForValue: CGFloat(self.doubleValue)) {
					self.ringColor = valuecolor
			} else  {
				self.ringColor = kDefaultRingColor
			}
		}
	}

	func getValueColor() -> NSColor {
		if useGaugeColor {
			return self.ringColor
		} else {
			return self.valueTextColor
		}
	}

	let kDefaultRingColor = NSColor(red: 76.0/255, green: 217.0/255, blue: 100.0/255, alpha: 1.0)
	var startAngle: Double = 0
	var endAngle: Double = M_PI
	var divisionUnitAngle: Double = 1
	var divisionUnitValue: Double = 1
	var invalidateMath: Bool = true
	var valueChanged: Bool = true
	var ringColor: NSColor = NSColor(red: 76.0/255, green: 217.0/255, blue: 100.0/255, alpha: 1.0) {
		didSet {
			if oldValue != ringColor {
				self.progressLayer.fillColor = ringColor.CGColor
				self.progressLayer.strokeColor = ringColor.CGColor
				if useGaugeColor {
					self.valueLabel.textColor = ringColor
				}
			}
		}
	}
	lazy var progressLayer: CAShapeLayer! = {
		self.wantsLayer = true

		let player = CAShapeLayer()
		player.lineCap = kCALineJoinBevel
		self.layer!.addSublayer(player)
		return player
	}()
	lazy var valueLabel: NSTextField! = {
		let label = NSTextField()
		label.bezeled = false
		label.drawsBackground = false
		label.editable = false
		label.selectable = false
		label.alignment = NSTextAlignment.CenterTextAlignment
		if let formatter = self.unitFormatter {
			label.stringValue = formatter.stringForObjectValue(self.doubleValue)!
		} else {
			label.stringValue = NSString(format:"%0.f", locale:nil, self.doubleValue) as String
		}
		label.font = self.valueFont;
		label.textColor = self.getValueColor()
		self.addSubview(label)
		return label
	}()
	lazy var limitLabel: NSTextField! = {
		let label = NSTextField()
		label.bezeled = false
		label.drawsBackground = false
		label.editable = false
		label.selectable = false
		label.alignment = NSTextAlignment.CenterTextAlignment
		if let formatter = self.unitFormatter {
			label.stringValue = "Limit \(formatter.stringForObjectValue(self.limitValue)!)"
		} else {
			label.stringValue = NSString(format:"Limit %0.f", locale:nil, self.limitValue) as String
		}
		label.font = self.limitValueFont;
		label.textColor = self.valueTextColor;
		self.addSubview(label)
		return label
	}()

	func doubleFromAnyObject( any:AnyObject? ) -> Double {
		if let theValue: AnyObject = any {
			if let dValue = theValue as? Double {
				return dValue
			} else if let fValue = theValue as? CGFloat {
				return Double(fValue)
			} else if let iValue = theValue as? Int {
				return Double(iValue)
			} else if let nmValue = theValue as? NSNumber {
				return nmValue.doubleValue
			}
		}
		return 0.0
	}

	func angleFromValue( value: Double) -> CGFloat {
		let level = (value - minValue)
		let angle = level * divisionUnitAngle / divisionUnitValue  + startAngle
		return CGFloat(angle)
	}

	func drawDotAtContext(context: CGContextRef, center: CGPoint, radius: CGFloat, fillColor: CGColorRef ) {
		CGContextBeginPath(context)
		CGContextAddArc(context, center.x, center.y, radius, 0, CGFloat(M_PI*2), 0)
		CGContextSetFillColorWithColor(context, fillColor);
		CGContextFillPath(context);
	}

	var center: CGPoint = CGPoint(x: 0, y: 0)
	var ringRadius: CGFloat = 0
	var dotRadius: CGFloat = 0
	var divisionCenter: [CGPoint] = []
	var subdivisionCenter: [CGPoint] = []
	var progressFrame: CGRect = CGRectZero
	var progressBounds: CGRect = CGRectZero

	override public func resizeSubviewsWithOldSize(oldSize: NSSize) {
		super.resizeSubviewsWithOldSize(oldSize)
		prepareMath()
	}

	func prepareMath() {

		self.invalidateMath = false

		divisionUnitValue = (maxValue - minValue)/Double(numOfDivisions)
		divisionUnitAngle = (M_PI * 2 - fabs(endAngle - startAngle))/Double(numOfDivisions)

		center = CGPoint(x: CGRectGetWidth(bounds)/2, y: 0)
		ringRadius = (min(CGRectGetWidth(bounds)/2, CGRectGetHeight(bounds)) - ringThickness/2)
		dotRadius = ringRadius - ringThickness/2 - divisionsPadding - divisionsRadius/2

		let fx: CGFloat = center.x - ringRadius - ringThickness/2
		let fy: CGFloat = 0
		let fh: CGFloat = (ringRadius + ringThickness/2)
		let fw: CGFloat = fh * 2
		progressFrame = CGRect(x:fx, y:fy , width:fw, height:fh)
		progressBounds = CGRect(x:0, y:fh, width:fw, height:fh)

		CATransaction.setDisableActions(true)

		if progressLayer.frame != progressFrame || progressLayer.bounds != progressBounds {
			valueChanged = true
			progressLayer.frame = progressFrame
			progressLayer.bounds = progressBounds
		}

		if valueChanged {
			valueChanged = false
			let smoothedPath = NSBezierPath()

			let a1 = 180-(startAngle).toDegree
			let a2 = 180-((endAngle - startAngle) * doubleValue / self.maxValue).toDegree
			let w = CGRectGetWidth(progressLayer.bounds)/2
			smoothedPath.appendBezierPathWithArcWithCenter(CGPoint(x:w,y:w), radius: w, startAngle: a1, endAngle: a2, clockwise:true)
			smoothedPath.appendBezierPathWithArcWithCenter(CGPoint(x:w,y:w), radius: w-ringThickness, startAngle: a2, endAngle: a1, clockwise:false)

			progressLayer.path = BezierPath(smoothedPath)
		}

		CATransaction.setDisableActions(false)

		divisionCenter = []
		subdivisionCenter = []

		for i in 0...self.numOfDivisions {
			if i != numOfDivisions && numOfSubDivisions>1 {
				for j in 0..<numOfSubDivisions {
					// Subdivisions
					let value: Double = divisionUnitValue * Double(i) + (divisionUnitValue * Double(j)) / Double(numOfSubDivisions)
					let angle = angleFromValue(value)
					let dotCenter = CGPoint(x: dotRadius * CGFloat(cos(angle)) + center.x, y:dotRadius * CGFloat(sin(angle)) + center.y)
					subdivisionCenter.append(dotCenter)
				}
			}

			// Divisions
			let value = Double(i) * divisionUnitValue
			let angle = angleFromValue(value)
			let dotCenter = CGPoint(x:dotRadius * CGFloat(cos(angle)) + center.x, y:dotRadius * CGFloat(sin(angle)) + center.y)
			divisionCenter.append(dotCenter)
		}

		var lblFrame = CGRect(origin: CGPointZero, size: valueLabel.intrinsicContentSize)
		lblFrame.origin.y = (progressLayer.frame.height-lblFrame.height)/2
		lblFrame.size.width = self.frame.width
		self.valueLabel.frame = lblFrame

		let origin = CGPoint(x:valueLabel.frame.origin.x, y: valueLabel.frame.origin.y-limitLabel.intrinsicContentSize.height)
		let size = CGSize(width: CGRectGetWidth(self.valueLabel.frame), height:limitLabel.intrinsicContentSize.height)
		self.limitLabel.frame = CGRect(origin: origin, size: size)
	}

	override public func drawRect(dirtyRect: NSRect) {
		if invalidateMath {
			prepareMath()
		}
		let context: CGContext = NSGraphicsContext.currentContext()!.CGContext

		// Draw the ring progress background
		CGContextSetLineWidth(context, ringThickness);
		CGContextBeginPath(context);
		CGContextAddArc(context, center.x, center.y, CGFloat(ringRadius), CGFloat(startAngle), CGFloat(endAngle), 0);
		CGContextSetStrokeColorWithColor(context, ringBackgroundColor.CGColor);
		CGContextStrokePath(context);

		// Draw divisions and subdivisions
		for center in divisionCenter {
			drawDotAtContext(context, center: center, radius: divisionsRadius, fillColor: divisionsColor.CGColor)
		}
		for center in subdivisionCenter {
			drawDotAtContext(context, center: center, radius: subDivisionsRadius, fillColor: subDivisionsColor.CGColor)
		}

		// Draw the limit dot
		if showLimitDot {
			let angle = angleFromValue(limitValue)
			let dotCenter = CGPoint(x:center.x - dotRadius * CGFloat(cos(angle)), y: dotRadius * CGFloat(sin(angle)) + center.y)
			drawDotAtContext(context, center: dotCenter, radius: limitDotRadius, fillColor: limitDotColor.CGColor)
		}
	}
}

extension Int {
	var toRadians : CGFloat {
		return CGFloat(self) * CGFloat(M_PI) / 180.0
	}
	var toDegree: CGFloat {
		return CGFloat(self)*180.0/CGFloat(M_PI)
	}
}

extension Double {
	var toRadians : CGFloat {
		return CGFloat(self) * CGFloat(M_PI) / 180.0
	}
	var toDegree: CGFloat {
		return CGFloat(self)*180.0/CGFloat(M_PI)
	}
}

func BezierPath(bezier: NSBezierPath) -> CGPath {
	var path: CGMutablePath = CGPathCreateMutable()
	var points: [NSPoint] = [NSPoint(),NSPoint(),NSPoint()]
	var didClosePath: Bool = false

	for idx in 0..<bezier.elementCount {
		let elementType = bezier.elementAtIndex(idx, associatedPoints: &points)
		switch(elementType)
		{
		case .MoveToBezierPathElement:
			CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
		case .CurveToBezierPathElement:
			CGPathAddCurveToPoint(path, nil, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y)
		case .LineToBezierPathElement:
			CGPathAddLineToPoint(path, nil, points[0].x, points[0].y)
		case .ClosePathBezierPathElement:
			CGPathCloseSubpath(path)
			didClosePath = true
		}
	}
	if didClosePath == false {
		CGPathCloseSubpath(path)
	}
	return CGPathCreateCopy(path)
}
