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
	@objc optional func gaugeViewRingColor(_ gaugeView: LMZGaugeView) -> NSColor?;
	@objc optional func gaugeViewLabel1Color(_ gaugeView: LMZGaugeView) -> NSColor?;
	@objc optional func gaugeViewLabel2Color(_ gaugeView: LMZGaugeView) -> NSColor?;
	@objc optional func gaugeViewLabel1String(_ gaugeView: LMZGaugeView) -> String?;
	@objc optional func gaugeViewLabel2String(_ gaugeView: LMZGaugeView) -> String?;
}

open class LMZGaugeView: NSView {
	/// Current value.
	open var doubleValue: Double = 0 {
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
	open func value() -> AnyObject? {
		return NSNumber(value: doubleValue as Double)
	}
	open func setValue(_ value: AnyObject?) {
		doubleValue = doubleFromAnyObject(value)
	}
	/// Minimum value.
	@IBInspectable open var minValue: Double = 0 {
		didSet {
			if oldValue != minValue {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// Maximum value.
	@IBInspectable open var maxValue: Double = 100 {
		didSet {
			if oldValue != maxValue {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// Limit value.
	@IBInspectable open var limitValue: Double = 50 {
		didSet {
			if oldValue != limitValue {
				self.label2.stringValue = self.stringForLabel2()
			}
		}
	}
	/// The number of divisions.
	@IBInspectable open var numOfDivisions: Int = 10 {
		didSet {
			if oldValue != numOfDivisions {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The number of subdivisions.
	@IBInspectable open var numOfSubDivisions: Int = 1 {
		didSet {
			if oldValue != numOfSubDivisions {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The thickness of the ring.
	@IBInspectable open var ringThickness: CGFloat = 15 {
		didSet {
			if oldValue != ringThickness {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The background color of the ring.
	@IBInspectable open var ringBackgroundColor: NSColor = NSColor(white: 0.9, alpha: 1.0) {
		didSet {
			if oldValue != ringBackgroundColor {
				self.needsDisplay = true
			}
		}
	}
	/// The divisions radius.
	@IBInspectable open var divisionsRadius: CGFloat = 1.25 {
		didSet {
			if oldValue != divisionsRadius {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The divisions color.
	@IBInspectable open var divisionsColor: NSColor = NSColor(white: 0.5, alpha: 1.0) {
		didSet {
			if oldValue != divisionsColor {
				self.needsDisplay = true
			}
		}
	}
	/// The padding between ring and divisions.
	@IBInspectable open var divisionsPadding: CGFloat = 12 {
		didSet {
			if oldValue != divisionsPadding {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The subdivisions radius.
	@IBInspectable open var subDivisionsRadius: CGFloat = 0.75 {
		didSet {
			if oldValue != subDivisionsRadius {
				self.invalidateMath = true
				self.needsDisplay = true
			}
		}
	}
	/// The subdivisions color.
	@IBInspectable open var subDivisionsColor: NSColor = NSColor(white: 0.5, alpha: 0.5) {
		didSet {
			if oldValue != subDivisionsColor {
				self.needsDisplay = true
			}
		}
	}
	/// A boolean indicates whether to show limit dot.
	@IBInspectable open var showLimitDot: Bool = true {
		didSet {
			if oldValue != showLimitDot {
				self.needsDisplay = true
			}
		}
	}
	/// The radius of limit dot.
	@IBInspectable open var limitDotRadius: CGFloat = 2 {
		didSet {
			if oldValue != limitDotRadius {
				self.needsDisplay = true
			}
		}
	}
	/// The color of limit dot.
	@IBInspectable open var limitDotColor: NSColor = NSColor.red {
		didSet {
			if oldValue != limitDotColor {
				self.needsDisplay = true
			}
		}
	}
	/// Font of value label.
	@IBInspectable open var valueFont: NSFont? = NSFont(name: "HelveticaNeue-CondensedBold", size: 19) {
		didSet {
			if oldValue != valueFont {
				self.label1.font = valueFont
			}
		}
	}
	/// Font of limit value label.
	@IBInspectable open var limitValueFont: NSFont? = NSFont(name: "HelveticaNeue-Condensed", size: 17) {
		didSet {
			if oldValue != limitValueFont {
				self.label2.font = limitValueFont
			}
		}
	}
	/// Text color of value label.
	@IBInspectable open var valueTextColor: NSColor = NSColor(white: 0.1, alpha: 1.0) {
		didSet {
			if oldValue != valueTextColor {
				if !self.useGaugeColor {
					label1.textColor = valueTextColor
				}
			}
		}
	}
	/// Use gauge color to show the value
	@IBInspectable open var useGaugeColor: Bool = true{
		didSet {
			if useGaugeColor {
				label1.textColor = self.currentRingColor
			} else {
				label1.textColor = valueTextColor
			}
		}
	}
	/// The unit of measurement.
	@IBOutlet open var unitFormatter: Formatter? {
		didSet {
			if oldValue != unitFormatter {
				self.label1.stringValue = self.stringForLabel1()
				self.label2.stringValue = self.stringForLabel2()
			}
		}
	}

	/// The receiver of all gauge view delegate callbacks.
	@IBOutlet open var delegate: LMZGaugeViewDelegate? {
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
		guard let returnValue = self.unitFormatter?.string(for: self.doubleValue) else {
			return NSString(format:"%0.f", locale:nil, self.doubleValue) as String
		}
		return returnValue
	}

	func stringForLabel2() -> String {
		if let valueString = self.delegate?.gaugeViewLabel2String?(self) {
			return valueString
		}
		guard let valueString = self.unitFormatter?.string(for: self.limitValue) else {
			return NSString(format:NSLocalizedString("Limit %0.f", comment: "") as NSString, locale:nil, self.limitValue) as String
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
				self.progressLayer.fillColor = currentRingColor.cgColor
				self.progressLayer.strokeColor = currentRingColor.cgColor
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
		label.isBezeled = false
		label.drawsBackground = false
		label.isEditable = false
		label.isSelectable = false
		label.alignment = .center
		label.stringValue = self.stringForLabel1()
		label.font = self.valueFont;
		label.textColor = self.getValueColor()
		self.addSubview(label)
		return label
	}()
	lazy var label2: NSTextField! = {
		let label = NSTextField()
		label.isBezeled = false
		label.drawsBackground = false
		label.isEditable = false
		label.isSelectable = false
		label.alignment = .center
		label.stringValue = self.stringForLabel2()
		label.font = self.limitValueFont;
		label.textColor = self.valueTextColor;
		self.addSubview(label)
		return label
	}()

	func doubleFromAnyObject(_ any: AnyObject? ) -> Double {
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

	func angleFromValue( _ value: Double) -> CGFloat {
		let level = (value - minValue)
		if divisionUnitValue != 0 {
			let angle = level * divisionUnitAngle / divisionUnitValue  + startAngle
			return CGFloat(angle)
		}
		return CGFloat(startAngle)
	}

	func drawDotAtContext(_ context: CGContext, center: CGPoint, radius: CGFloat, fillColor: CGColor ) {
        let path = CGMutablePath()
        path.addArc(center: center, radius: radius,
                    startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: false)
        context.addPath(path)
        context.setFillColor(fillColor);
		context.fillPath();
	}

	var center: CGPoint = CGPoint(x: 0, y: 0)
	var ringRadius: CGFloat = 0
	var dotRadius: CGFloat = 0
	var divisionCenter: [CGPoint] = []
	var subdivisionCenter: [CGPoint] = []
	var progressFrame: CGRect = CGRect.zero
	var progressBounds: CGRect = CGRect.zero

	override open func resizeSubviews(withOldSize oldSize: NSSize) {
		super.resizeSubviews(withOldSize: oldSize)
		prepareMath()
	}

	func prepareMath() {

		self.invalidateMath = false

		divisionUnitValue = (maxValue - minValue)/Double(numOfDivisions)
		divisionUnitAngle = (M_PI * 2 - fabs(endAngle - startAngle))/Double(numOfDivisions)

		center = CGPoint(x: bounds.width/2, y: 0)
		ringRadius = (min(bounds.width/2, bounds.height) - ringThickness/2)
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
            let a2 = (self.maxValue.isNaN || self.maxValue.isZero) ? 180 : 180-((endAngle - startAngle) * doubleValue / self.maxValue).toDegree
			let w = progressLayer.bounds.width/2
			smoothedPath.appendArc(withCenter: CGPoint(x:w,y:w), radius: w, startAngle: a1, endAngle: a2, clockwise:true)
			smoothedPath.appendArc(withCenter: CGPoint(x:w,y:w), radius: w-ringThickness, startAngle: a2, endAngle: a1, clockwise:false)

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

		var lblFrame = CGRect(origin: CGPoint.zero, size: label1.intrinsicContentSize)
		lblFrame.origin.y = (progressLayer.frame.height-lblFrame.height)/2
		lblFrame.size.width = self.frame.width
		self.label1.frame = lblFrame

		let origin = CGPoint(x:label1.frame.origin.x, y: label1.frame.origin.y-label2.intrinsicContentSize.height)
		let size = CGSize(width: self.label1.frame.width, height:label2.intrinsicContentSize.height)
		self.label2.frame = CGRect(origin: origin, size: size)
	}

	override open func draw(_ dirtyRect: NSRect) {
		if invalidateMath {
			prepareMath()
		}
		let context: CGContext = NSGraphicsContext.current()!.cgContext

		// Draw the ring progress background
		context.setLineWidth(ringThickness);
		context.beginPath();
        context.addArc(center: center, radius: CGFloat(ringRadius),
                        startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: false)
		context.setStrokeColor(ringBackgroundColor.cgColor);
		context.strokePath();

		// Draw divisions and subdivisions
		for center in divisionCenter {
			drawDotAtContext(context, center: center, radius: divisionsRadius, fillColor: divisionsColor.cgColor)
		}
		for center in subdivisionCenter {
			drawDotAtContext(context, center: center, radius: subDivisionsRadius, fillColor: subDivisionsColor.cgColor)
		}

		// Draw the limit dot
		if showLimitDot {
			let angle = angleFromValue(limitValue)
			let dotCenter = CGPoint(x:center.x - dotRadius * CGFloat(cos(angle)), y: dotRadius * CGFloat(sin(angle)) + center.y)
			drawDotAtContext(context, center: dotCenter, radius: limitDotRadius, fillColor: limitDotColor.cgColor)
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

func BezierPath(_ bezier: NSBezierPath) -> CGPath {
	let path: CGMutablePath = CGMutablePath()
	var points: [NSPoint] = [NSPoint(),NSPoint(),NSPoint()]
	var didClosePath: Bool = false

	for idx in 0..<bezier.elementCount {
		let elementType = bezier.element(at: idx, associatedPoints: &points)
		switch(elementType)
		{
		case .moveToBezierPathElement:
            path.move(to: points[0])
		case .curveToBezierPathElement:
            path.addCurve( to: points[2], control1: points[0], control2: points[1])
		case .lineToBezierPathElement:
            path.addLine(to: points[0])
		case .closePathBezierPathElement:
			path.closeSubpath()
			didClosePath = true
		}
	}
	if didClosePath == false {
		path.closeSubpath()
	}
	return path.copy()!
}
