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
public protocol LMZGaugeViewDelegate {
	/// Return ring stroke color from the specified value.
	optional func gaugeViewRingColor(gaugeView: LMZGaugeView) -> NSColor?;
	optional func gaugeViewLabel1Color(gaugeView: LMZGaugeView) -> NSColor?;
	optional func gaugeViewLabel2Color(gaugeView: LMZGaugeView) -> NSColor?;
	optional func gaugeViewLabel1String(gaugeView: LMZGaugeView) -> String?;
	optional func gaugeViewLabel2String(gaugeView: LMZGaugeView) -> String?;
}

public class LMZGaugeView: NSView {
	/// Current value.
	public var doubleValue: Double = 0 {
		didSet {
			if oldValue != doubleValue {
				let value = max( self.minValue, doubleValue)
				doubleValue = min( self.maxValue, value)
			}
			if oldValue != doubleValue {
				self.updateValueAndColor()
			}
		}
	}
	public func value() -> AnyObject? {
		return NSNumber(double: doubleValue)
	}
	public func setValue(value: AnyObject?) {
		doubleValue = doubleFromAnyObject(value)
	}
	/// Minimum value.
	@IBInspectable public var minValue: Double = 0 {
		didSet {
			if oldValue != minValue {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// Maximum value.
	@IBInspectable public var maxValue: Double = 100 {
		didSet {
			if oldValue != maxValue {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// Limit value.
	@IBInspectable public var limitValue: Double = 50 {
		didSet {
			if oldValue != limitValue {
				self.label2.stringValue = self.stringForLabel2()
			}
		}
	}
	/// The number of divisions.
	@IBInspectable public var numOfDivisions: Int = 10 {
		didSet {
			if oldValue != numOfDivisions {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The number of subdivisions.
	@IBInspectable public var numOfSubDivisions: Int = 1 {
		didSet {
			if oldValue != numOfSubDivisions {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The thickness of the ring.
	@IBInspectable public var ringThickness: CGFloat = 15 {
		didSet {
			if oldValue != ringThickness {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The background color of the ring.
	@IBInspectable public var ringBackgroundColor: NSColor = NSColor(white: 0.9, alpha: 1.0) {
		didSet {
			if oldValue != ringBackgroundColor {
				self.needsDisplay = true
			}
		}
	}
	/// The divisions radius.
	@IBInspectable public var divisionsRadius: CGFloat = 1.25 {
		didSet {
			if oldValue != divisionsRadius {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The divisions color.
	@IBInspectable public var divisionsColor: NSColor = NSColor(white: 0.5, alpha: 1.0) {
		didSet {
			if oldValue != divisionsColor {
				self.needsDisplay = true
			}
		}
	}
	/// The padding between ring and divisions.
	@IBInspectable public var divisionsPadding: CGFloat = 12 {
		didSet {
			if oldValue != divisionsPadding {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The subdivisions radius.
	@IBInspectable public var subDivisionsRadius: CGFloat = 0.75 {
		didSet {
			if oldValue != subDivisionsRadius {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The subdivisions color.
	@IBInspectable public var subDivisionsColor: NSColor = NSColor(white: 0.5, alpha: 0.5) {
		didSet {
			if oldValue != subDivisionsColor {
				self.needsDisplay = true
			}
		}
	}
	/// A boolean indicates whether to show limit dot.
	@IBInspectable public var showLimitDot: Bool = true {
		didSet {
			if oldValue != showLimitDot {
				self.needsDisplay = true
			}
		}
	}
	/// The radius of limit dot.
	@IBInspectable public var limitDotRadius: CGFloat = 2 {
		didSet {
			if oldValue != limitDotRadius {
				self.needsDisplay = true
			}
		}
	}
	/// The color of limit dot.
	@IBInspectable public var limitDotColor: NSColor = NSColor.redColor() {
		didSet {
			if oldValue != limitDotColor {
				self.needsDisplay = true
			}
		}
	}
	/// Font of value label.
	@IBInspectable public var valueFont: NSFont? = NSFont(name: "HelveticaNeue-CondensedBold", size: 19) {
		didSet {
			if oldValue != valueFont {
				self.label1.font = valueFont
			}
		}
	}
	/// Font of limit value label.
	@IBInspectable public var limitValueFont: NSFont? = NSFont(name: "HelveticaNeue-Condensed", size: 17) {
		didSet {
			if oldValue != limitValueFont {
				self.label2.font = limitValueFont
			}
		}
	}
	/// Text color of value label.
	@IBInspectable public var valueTextColor: NSColor = NSColor(white: 0.1, alpha: 1.0) {
		didSet {
			if oldValue != valueTextColor {
				if !self.useGaugeColor {
					label1.textColor = valueTextColor
				}
			}
		}
	}
	/// Use gauge color to show the value
	@IBInspectable public var useGaugeColor: Bool = true{
		didSet {
			if useGaugeColor {
				label1.textColor = self.currentRingColor
			} else {
				label1.textColor = valueTextColor
			}
		}
	}
	/// The unit of measurement.
	@IBOutlet public var unitFormatter: NSFormatter? {
		didSet {
			if oldValue != unitFormatter {
				self.label1.stringValue = self.stringForLabel1()
				self.label2.stringValue = self.stringForLabel2()
			}
		}
	}

	/// The receiver of all gauge view delegate callbacks.
	@IBOutlet public var delegate: LMZGaugeViewDelegate? {
		didSet {
			updateValueAndColor()
		}
	}

	func updateValueAndColor() {
		self.label1.stringValue = self.stringForLabel1()
		self.label2.stringValue = self.stringForLabel2()

		if let valuecolor = self.delegate?.gaugeViewRingColor?(self) {
				self.currentRingColor = valuecolor
		} else {
			self.currentRingColor = kDefaultRingColor
		}

		if let valuecolor = self.delegate?.gaugeViewLabel1Color?(self) {
				self.currentLabel1Color = valuecolor
		} else {
			if useGaugeColor {
				self.currentLabel1Color = self.currentRingColor
			} else {
				self.currentLabel1Color = kDefaultRingColor
			}
		}
		if let valuecolor = self.delegate?.gaugeViewLabel2Color?(self) {
				self.currentLabel2Color = valuecolor
		} else  {
			if useGaugeColor {
				self.currentLabel2Color = self.currentRingColor
			} else {
				self.currentLabel2Color = kDefaultRingColor
			}
		}

		self.invalidateMath = true
		self.valueChanged = true
		self.needsDisplay = true
	}

	func getValueColor() -> NSColor {
		if useGaugeColor {
			return self.currentRingColor
		} else {
			return self.valueTextColor
		}
	}

	func stringForLabel1() -> String {
		if let valueString = self.delegate?.gaugeViewLabel1String?(self) {
			return valueString
		}
		guard let returnValue = self.unitFormatter?.stringForObjectValue(self.doubleValue) else {
			return NSString(format:"%0.f", locale:nil, self.doubleValue) as String
		}
		return returnValue
	}

	func stringForLabel2() -> String {
		if let valueString = self.delegate?.gaugeViewLabel2String?(self) {
			return valueString
		}
		guard let valueString = self.unitFormatter?.stringForObjectValue(self.limitValue) else {
			return NSString(format:NSLocalizedString("Limit %0.f", comment: ""), locale:nil, self.limitValue) as String
		}
		return String(format: NSLocalizedString("Limit %@", comment: ""), valueString)
	}

	let kDefaultRingColor = NSColor(red: 76.0/255, green: 217.0/255, blue: 100.0/255, alpha: 1.0)
	var startAngle: Double = 0
	var endAngle: Double = M_PI
	var divisionUnitAngle: Double = 1
	var divisionUnitValue: Double = 1
	var invalidateMath: Bool = true
	var valueChanged: Bool = true
	var currentRingColor: NSColor = NSColor(red: 76.0/255, green: 217.0/255, blue: 100.0/255, alpha: 1.0) {
		didSet {
			if oldValue != currentRingColor {
				self.progressLayer.fillColor = currentRingColor.CGColor
				self.progressLayer.strokeColor = currentRingColor.CGColor
				if useGaugeColor {
					self.label1.textColor = currentRingColor
				}
			}
		}
	}
	var currentLabel1Color: NSColor = NSColor(red: 76.0/255, green: 217.0/255, blue: 100.0/255, alpha: 1.0) {
		didSet {
			if oldValue != currentLabel1Color {
				self.label1.textColor = currentLabel1Color
			}
		}
	}
	var currentLabel2Color: NSColor = NSColor(red: 76.0/255, green: 217.0/255, blue: 100.0/255, alpha: 1.0) {
		didSet {
			if oldValue != currentLabel1Color {
				self.label2.textColor = currentLabel1Color
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
	lazy var label1: NSTextField! = {
		let label = NSTextField()
		label.bezeled = false
		label.drawsBackground = false
		label.editable = false
		label.selectable = false
		label.alignment = .Center
		label.stringValue = self.stringForLabel1()
		label.font = self.valueFont;
		label.textColor = self.getValueColor()
		self.addSubview(label)
		return label
	}()
	lazy var label2: NSTextField! = {
		let label = NSTextField()
		label.bezeled = false
		label.drawsBackground = false
		label.editable = false
		label.selectable = false
		label.alignment = .Center
		label.stringValue = self.stringForLabel2()
		label.font = self.limitValueFont;
		label.textColor = self.valueTextColor;
		self.addSubview(label)
		return label
	}()

	func doubleFromAnyObject(any: AnyObject? ) -> Double {
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
		if divisionUnitValue != 0 {
			let angle = level * divisionUnitAngle / divisionUnitValue  + startAngle
			return CGFloat(angle)
		}
		return CGFloat(startAngle)
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

		var lblFrame = CGRect(origin: CGPointZero, size: label1.intrinsicContentSize)
		lblFrame.origin.y = (progressLayer.frame.height-lblFrame.height)/2
		lblFrame.size.width = self.frame.width
		self.label1.frame = lblFrame

		let origin = CGPoint(x:label1.frame.origin.x, y: label1.frame.origin.y-label2.intrinsicContentSize.height)
		let size = CGSize(width: CGRectGetWidth(self.label1.frame), height:label2.intrinsicContentSize.height)
		self.label2.frame = CGRect(origin: origin, size: size)
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
	var toRadians: CGFloat {
		return CGFloat(self) * CGFloat(M_PI) / 180.0
	}
	var toDegree: CGFloat {
		return CGFloat(self)*180.0/CGFloat(M_PI)
	}
}

extension Double {
	var toRadians: CGFloat {
		return CGFloat(self) * CGFloat(M_PI) / 180.0
	}
	var toDegree: CGFloat {
		return CGFloat(self)*180.0/CGFloat(M_PI)
	}
}

func BezierPath(bezier: NSBezierPath) -> CGPath {
	let path: CGMutablePath = CGPathCreateMutable()
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
	return CGPathCreateCopy(path)!
}
