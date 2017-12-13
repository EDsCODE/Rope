//
//  Media.swift
//  Rope
//
//  Created by Eric Duong on 11/22/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import Foundation
import AVFoundation
import Firebase

class Media: NSObject {
    var senderName: String!
    var senderID: String!
    var mediaType: String!
    var image: Data?
    var videoURL: URL?
    var sentDate: Int!
    var url: URL!
    @objc dynamic var loadState: LoadState = .unloaded
    var key: String!
    
    func printdetail() {
        print(senderID)
        print(mediaType)
        print(sentDate)
        print(url)
        print(key)
    }
    
    func load(completion: @escaping (_ loaded: Bool) -> Void) {
        self.loadState = .loading
        let _url = Storage.storage().reference(forURL: url.absoluteString)
        _url.getData(maxSize: 1073741824, completion: {(data, error) in
            if let error = error {
                print("Error loading image from Media#load: \(error.localizedDescription)")
            } else if self.mediaType == "image" {
                
                self.image = data
                self.loadState = .loaded
                completion(true)
                
            } else if self.mediaType == "video" {
                
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let filePath = documentsURL.appendingPathComponent("\(UUID().uuidString).mp4")
                try! data?.write(to: filePath, options: Data.WritingOptions.atomic)
                self.videoURL = filePath
                completion(true)
                
            } else {
                print("Error: Invalid type from Media#load!")
            }
        })
    }
    
}

@objc public enum LoadState: Int {
    case unloaded = -1
    case loading = 0
    case loaded = 1
}
