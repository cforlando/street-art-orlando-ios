//
//  FileUtils.swift
//  StreetArt
//
//  Created by Axel Rivera on 3/8/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation

func dLog(_ message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    // WARNING: Must add the following flag to Other Swift Flags in Build Settings "-D DEBUG"
    #if DEBUG
        let url = URL(fileURLWithPath: filename)
        print("[\(url.lastPathComponent):\(line)] \(function) - \(message)")
    #endif
}

func path(inDocumentDirectory fileName: String) -> String {
    var documentStr = String()

    let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    if !document.isEmpty {
        documentStr = URL(fileURLWithPath: document[0]).appendingPathComponent(fileName).path
    }

    return documentStr
}

func delete(pathInDocumentDirectory fileName: String) -> Bool {
    let filePath = path(inDocumentDirectory: fileName)
    do {
        try FileManager.default.removeItem(atPath: filePath)
        return true
    } catch {
        dLog("failed to delete path in documents directory: \(filePath)")
        return false
    }
}

func path(inTemporaryDirectory fileName: String) -> String {
    let tmpStr = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName).path
    return tmpStr
}

func delete(pathInTemporaryDirectory fileName: String) -> Bool {
    let filePath = path(inTemporaryDirectory: fileName)
    do {
        try FileManager.default.removeItem(atPath: filePath)
        return true
    } catch {
        dLog("failed to delete path in temporary directory: \(filePath)")
        return false
    }
}
