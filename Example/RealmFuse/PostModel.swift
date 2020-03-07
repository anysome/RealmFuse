//
//  PostModel.swift
//  RealmFuse_Example
//
//  Created by Layman on 2020/3/7.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift
import RealmFuse

class PostModel: Object {
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var title = ""
    @objc dynamic var content = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension PostModel: Fuseable {
    
    var fuseProperties: [FuseProperty] {
        return [
            FuseProperty(name: "title", weight: 0.34),
            FuseProperty(name: "content", weight: 0.66)
        ]
    }
}
