//
//  LocalCheckoff.swift
//  DuiTogether
//
//  Created by Joey on 12/5/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import Foundation

class localCheckoff {
    var isVerified = false;
    var imgUrl: String = "no url";
    var description: String = "no description";
    var creationDate: Date
    
    var creatorID: String
    var checkBook: [String:Bool] = [:] // array of uids with size of n (check self if add record)
    var verifierList: [String] = []
    
    init(created cd: Date, url: String, comment: String, verified: Bool, uid: String, uidlist: [String]) {
        creationDate = cd
        imgUrl = url
        description = comment
        isVerified = verified
        
        creatorID = uid
        verifierList = uidlist
    }
    
    // Modifiers
    public func changeUrl(url: String) {
        imgUrl = url;
    }
    public func changeDesc(desc: String) {
        description = desc
    }
    
    // BIG TEST firebase & local
    public func check() {
        isVerified = !isVerified;
    }
    
    // getter
    public func getUserID() -> String {
        return creatorID
    }
    public func getComment() -> String {
        return description
    }
    public func geturl() -> String {
        return imgUrl
    }
}
