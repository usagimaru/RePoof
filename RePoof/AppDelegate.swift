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
		// "LSUIElement = 1" と同じ効果
		//NSApplication.shared.setActivationPolicy(.accessory)
		
		checkAccessibilityAccess()
		self.dockInjection.tileRemoveTrigger = { location, tileSize in
			// TODO: タイルのウインドウが取れるならそのframeを使った方が正確
			NSAnimationEffect.poof.show(centeredAt: location, size: NSSize(width: tileSize, height: tileSize))
		}
	}
	
	private func checkAccessibilityAccess() {
		// Sandboxが有効だとシステムアラートが表示されない
		AccessibilityAuthorization.askAccessibilityAccessIfNeeded()
		AccessibilityAuthorization.pollAccessibilityAccessTrusted { [self] in
			self.dockInjection.start()
		}
	}

}

