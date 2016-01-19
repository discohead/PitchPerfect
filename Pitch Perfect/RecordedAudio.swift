//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Jared McFarland on 1/18/16.
//  Copyright © 2016 Jared McFarland. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    var filePathUrl: NSURL!
    var title: String!
    
    init(withFilePathURL url: NSURL, andTitle fileName: String) {
        filePathUrl = url
        title = fileName
    }
    
}