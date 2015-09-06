//
//  AppDelegate.swift
//  LMZGaugeView
//
//  Created by Dmitriy Zakharkin on 9/4/15.
//  Copyright (c) 2015 ZDima. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!

	@IBOutlet weak var ctrl: LMZGaugeView!

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}
}

