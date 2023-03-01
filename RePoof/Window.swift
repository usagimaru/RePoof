//
//  Window.swift
//  RePoof
//
//  Created by usagimaru on 2023/03/02.
//

import Cocoa

class Window: NSWindow {
	
	override var canBecomeKey: Bool {
		true
	}
	
	override var canBecomeMain: Bool {
		true
	}
	
	override func performKeyEquivalent(with event: NSEvent) -> Bool {
		// keyDownでbeepを鳴らさないための処理
		// https://stackoverflow.com/questions/8869462/prevent-not-allowed-beep-after-keystroke-in-nsview
		true
	}

}
