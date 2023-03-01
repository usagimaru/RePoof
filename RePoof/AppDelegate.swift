//
//  AppDelegate.swift
//  RePoof
//
//  Created by usagimaru on 2023/03/02.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	
	private var dockInjection = DockInjection()


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		checkAccessibilityAccess()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}
	
	
	// MARK: -
	
	private func checkAccessibilityAccess() {
		// Sandboxが有効だとシステムアラートが表示されない
		AccessibilityAuthorization.askAccessibilityAccessIfNeeded()
		AccessibilityAuthorization.pollAccessibilityAccessTrusted { [self] in
			self.dockInjection.start()
		}
	}


}

