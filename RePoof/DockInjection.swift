//
//  DockInjection.swift
//  RePoof
//
//  Created by usagimaru on 2023/03/02.
//

import Cocoa
import EventTapper

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
	
	private var dockPref: DockPref?
	
	var tileRemoveTrigger: ((_ location: CGPoint, _ tileSize: Int) -> Void)?
		
	func start() {
		watchDockProcess()
		startEventTapping()
	}
	
	func watchDockProcess() {
		// Dockが再起動しても正しいPIDを把握できるようにタイマーで見張る
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
	
	private var mouseDownedLocation: CGPoint?
	private var mouseDowned: Bool = false
	private var mouseDragged: Bool = false
	
	private func resetMouseFlags() {
		self.mouseDownedLocation = nil
		self.mouseDowned = false
		self.mouseDragged = false
	}
	
	func startEventTapping() {
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
			
			// Dockのプロセスを判定できない条件がある？
			if self.dockPID != processID {
				return false
			}
			
			print("Dock: \(processID)")
			
			switch event.type {
				case .leftMouseDown:
					print("Dock: \(processID) mouse down")
					resetMouseFlags()
					self.mouseDownedLocation = event.unflippedLocation
					self.mouseDowned = true
					self.dockPref = DockPref.load()
					
				case .leftMouseDragged:
					if self.mouseDowned {
						self.mouseDragged = true
					}
					//print("Dock: \(processID) mouse dragged")
					
				case .leftMouseUp:
					print("Dock: \(processID) mouse up")
					if !self.mouseDragged {
						resetMouseFlags()
						return false
					}
					
					let location = event.unflippedLocation
					
					if let largeSize = self.dockPref?.largeSize,
					   let tileSize = self.dockPref?.tileSize,
					   let mouseDownedLocation = self.mouseDownedLocation {
						
						// Mouse Downがタイル上にない場合は無視
						// TODO: Dockウインドウの高さを正確に考慮する必要がある
						if mouseDownedLocation.y > CGFloat(tileSize) + 10 {
							return false
						}
						
						// タイルをDock外にドラッグした際の削除判定が有効になるY座標(threshold)を算出
						// `thresholdPoint = (largeSize * 2) + 38`
						let threshold = CGFloat(largeSize * 2 + 38)
						if threshold < location.y {
							print("ok: \(location.y) >= \(threshold)")
							self.tileRemoveTrigger?(location, largeSize)
						}
					}
					resetMouseFlags()
					
				case .keyDown:
					let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
					// Escapeを判定
					if keyCode == KeyCode.escape {
						resetMouseFlags()
					}
					print("Dock: \(processID) KeyCode: \(keyCode)")
					
				case _: ()
			}
			
			return false
		}
	}
}

struct KeyCode {
	// Key codes from Carbon HIToolbox/Events.h
	
	static let escape = CGKeyCode(0x35)
}
