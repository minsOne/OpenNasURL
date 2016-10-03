//
//  Extension.swift
//  OpenNasURL
//
//  Created by JungMin Ahn on 2015. 12. 5..
//  Copyright © 2015년 SmartStudy. All rights reserved.
//

import Foundation

func openFinder(url: String) {
    let task = NSTask()
    task.launchPath = "/usr/bin/open"
    task.arguments = [url + "\0"];
    print(task.launchPath, task.arguments)
    task.launch()
}

func loadURLList() -> [String] {
    guard let unArchivedData = NSUserDefaults.standardUserDefaults().objectForKey("urllist") else { return [] }
    return NSKeyedUnarchiver.unarchiveObjectWithData(unArchivedData as! NSData) as! [String]
}

extension String {
    var encodingSpace: String {
        get {
            return self
                .stringByReplacingOccurrencesOfString("\\ ", withString: " ")
                .stringByReplacingOccurrencesOfString(" ", withString: "\\ ")
        }
    }
    var encodedURL: String {
        get {
            return self.encodingSpace
                .stringByReplacingOccurrencesOfString("(", withString: "\\(")
                .stringByReplacingOccurrencesOfString(")", withString: "\\)")
                .stringByReplacingOccurrencesOfString("/", withString: "\\/")
                .stringByReplacingOccurrencesOfString("\\", withString: "\\".substringFromIndex(1))
        }
    }
}

extension CollectionType where Generator.Element == String {
    func saveURLList() {
        let archivedURList = NSKeyedArchiver.archivedDataWithRootObject(self as! [String])
        NSUserDefaults.standardUserDefaults().setObject(archivedURList, forKey: "urllist")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}