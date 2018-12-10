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
    var dayid: String
    
    var creatorID: String
    var creatorName: String
    var checkBook: [String:Bool] = [:] // array of uids with size of n (check self if add record)
    public var verifierList: [String] = []
    
    init(created cd: Date, dayid: String, url: String, comment: String, verified: Bool, uid: String, username: String, uidlist: [String]) {
        creationDate = cd
        self.dayid = dayid
        imgUrl = url
        description = comment
        isVerified = verified
        
        creatorName = username
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
    public func verifiedBy(uid: String) {
        if(!verifierList.contains(uid)) {
            verifierList.append(uid)
        }
    }

    // getter
    public func getCreatorID() -> String {
        return creatorID
    }
    public func getComment() -> String {
        return description
    }
    public func geturl() -> String {
        return imgUrl
    }
    public func getusername() -> String {
        return creatorName
    }
    public func getCreationDate() -> Date {
        return creationDate
    }
    public func getDayid() -> String {
        return dayid
    }
}
