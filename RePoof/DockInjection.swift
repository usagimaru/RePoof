//
//  DockInjection.swift
//  RePoof
//
//  Created by usagimaru on 2023/03/02.
//

import Cocoa
import EventTapper

extension NSPasteboard.PasteboardType {
	
	static func finderNode() -> NSPasteboard.PasteboardType {
		NSPasteboard.PasteboardType(rawValue: "com.apple.finder.node")
	}
	
}

extension String {
	
	func expandingTildeInPath() -> String {
		return self.replacingOccurrences(of: "~", with: FileManager.default.homeDirectoryForCurrentUser.path)
	}
	
}

class DockInjection: EventTapperDelegate {
	
	private static let dockBundleIdentifier = "com.apple.dock"
	
	private var eventTapper = EventTapper()
	private weak var timer: Timer?
	private(set) var dockPID: pid_t?
	
	private var dockTiles: DockTiles?
		
	func start() {
		watchDockProcess()
		startEventTapping()
	}
	
	func watchDockProcess() {
		stopTimer()
		let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [self] timer in
			let dockPID = NSRunningApplication.runningApplications(withBundleIdentifier: Self.dockBundleIdentifier)
				.first?.processIdentifier
			self.dockPID = dockPID
		}
		self.timer = timer
		
		RunLoop.current.add(timer, forMode: .common)
	}
	
	private func stopTimer() {
		self.timer?.invalidate()
		self.timer = nil
	}
	
	func startEventTapping() {
		// https://github.com/briankendall/forceFullDesktopBar/blob/master/dockInjection/dockInjection.m
		
		self.eventTapper.tapWrapper?.disableTap()
		
		let eventTypes: [CGEventType] = [
			.leftMouseDown,
			.leftMouseUp,
			.leftMouseDragged,
			.keyDown,
			.keyUp,
			.flagsChanged,
		]
		self.eventTapper.delegate = self
		self.eventTapper.tap(for: eventTypes,
							 location: .cgAnnotatedSessionEventTap,
							 placement: .headInsertEventTap,
							 tapOption: .listenOnly) { [self] event, function in
			let processID = Int32(event.getIntegerValueField(.eventTargetUnixProcessID))
			if self.dockPID == processID {
				//print("Dock: \(processID)")
				
				switch event.type {
					case .leftMouseDown: ()
						//print("Dock: \(processID) mouse down")
						
						
					case .leftMouseDragged: ()
						//print("Dock: \(processID) mouse dragged")
						
					case .leftMouseUp: ()
						//print("Dock: \(processID) mouse up")
												
					case .keyDown:
						let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
						print("Dock: \(processID) KeyCode: \(keyCode)")
						
					case _: ()
				}
			}
			
			return false
		}
	}
}
