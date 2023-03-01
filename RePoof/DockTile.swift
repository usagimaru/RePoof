//
//  DockTile.swift
//  RePoof
//
//  Created by usagimaru on 2023/03/02.
//

import Cocoa

typealias PlistDictType = Dictionary<String, Any>

struct DockTiles {
	
	private static let dockPreferences = "~/Library/Preferences/com.apple.dock.plist"
	
	var persistentApps = [DockTile]()
	var recentApps = [DockTile]()
	var persistentOthers = [DockTile]()
	
	private func dockTiles(from dockPrefDictionary: PlistDictType, key: String) -> [DockTile] {
		let dicts = dockPrefDictionary[key] as? [PlistDictType] ?? []
		
		return dicts.reduce(into: [DockTile?]()) { partialResult, dict in
			let tile = DockTile(with: dict)
			partialResult.append(tile)
		}.compactMap { $0 }
	}
	
	static func loadDockPref() -> DockTiles? {
		let plistPath = Self.dockPreferences.expandingTildeInPath()
		if let plist = NSDictionary(contentsOfFile: plistPath) as? PlistDictType {
			return DockTiles(with: plist)
		}
		return nil
	}
	
	init?(with dockPrefDictionary: PlistDictType) {
//		print("--- Apps ---")
		self.persistentApps = dockTiles(from: dockPrefDictionary, key: "persistent-apps")
//		print("--- Recents ---")
		self.recentApps = dockTiles(from: dockPrefDictionary, key: "recent-apps")
//		print("--- Others ---")
		self.persistentOthers = dockTiles(from: dockPrefDictionary, key: "persistent-others")
	}
	
}

struct DockTile {
	
	enum TileType: String {
		case file = "file-tile"
		case smartfolder = "smartfolder-tile"
		case directory = "directory-tile"
		case url = "url-tile"
		case spacer = "spacer-tile"
		case smallspacer = "small-spacer-tile"
		case unknown = "(unknown)"
	}
	
	var GUID: Int?
	var tileType: TileType
	var tileData: DockTileData?
	
	init?(with tileItemDictionary: PlistDictType) {
		self.GUID = tileItemDictionary["GUID"] as? Int
		
		if let type = tileItemDictionary["tile-type"] as? String {
			let tileType = TileType(rawValue: type) ?? .unknown
			self.tileType = tileType
		}
		else {
			return nil
		}
		
		if let tileData = tileItemDictionary["tile-data"] as? PlistDictType,
		   let tileData = DockTileData(with: tileData) {
			self.tileData = tileData
		}
	}
	
}

struct DockTileData {
	
	var fileType: Int?
	var fileLabel: String?
	var bundleIdentifier: String?
	var book: Data?
	var parentModDate: Date?
	var fileModDate: Date?
	var fileData: DockTileFileData?
	
	init?(with tileDataDictionary: PlistDictType) {
		self.fileType = tileDataDictionary["file-type"] as? Int
		self.fileLabel = tileDataDictionary["file-label"] as? String
		self.bundleIdentifier = tileDataDictionary["bundle-identifier"] as? String
		self.book = tileDataDictionary["book"] as? Data
		
		if let parentModDate = tileDataDictionary["parent-mod-date"] as? TimeInterval {
			self.parentModDate = Date(timeIntervalSince1970: parentModDate)
		}
		
		if let fileModDate = tileDataDictionary["file-mod-date"] as? TimeInterval {
			self.parentModDate = Date(timeIntervalSince1970: fileModDate)
		}
		
		if let fileDataDict = tileDataDictionary["file-data"] as? PlistDictType,
		   let fileData = DockTileFileData(with: fileDataDict) {
			self.fileData = fileData
		}
	}
	
}

struct DockTileFileData {
	
	var fileURL: URL?
	
	init?(with tileFileDataDictionary: PlistDictType) {
		if let URLString = tileFileDataDictionary["_CFURLString"] as? String,
		   let URL = URL(string: URLString) {
			self.fileURL = URL
		}
		else {
			return nil
		}
	}
	
}
