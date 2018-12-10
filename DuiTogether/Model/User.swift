//
//  User.swift
//  DuiTogether
//
//  Created by Joey on 11/21/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import Foundation
import FirebaseFirestore

class localUser {

    // member variables
    let uid: String
    var mEmail: String = ""
    var avatarUrl: String = ""
    private var groups : [String] = []; // keep track of this user's groups so when a user loads a group, it checks isjoin, or load myTents page
    
    // init
    init(email: String, uid: String, url: String) {
        mEmail = email
        self.uid = uid
        avatarUrl = url
    }
    
    // getters
    public func GetUserEmail() -> String {
        return mEmail
    }
    public func GetGroupCount() -> Int {
        return groups.count
    }
    public func GetGroupByIndex(index: Int) -> LocalGroup? {
        if(index >= groups.count) {
            return nil
        } else {
            return GroupsModel.shared.getGroupById(gid: groups[index])
        }
    }
    public func GetUid() -> String {
        return uid
    }
    
    // modifiers
    public func AddGroup(gid: String) {
        groups.append(gid)
    }
    public func getTentsCount() -> Int {
        return groups.count
    }
    public func clearGroups() {
        groups = []
    }
    // NOT USING
    public func updateProgress() {
        print("ERROR: SHOULD NOT SHOW UP")
        for thisgid in groups {
            let daya:Date = GroupsModel.shared.getGroupById(gid: thisgid).getCreationDate()
            let dayb:Date = Date()
            let dayCount = countDays(dateA: daya, dateB: dayb)
            
            // local & firebase BIGTEST
            GroupsModel.shared.getGroupById(gid: thisgid).setProgress(dayCount, thisgid)
        }
    }
    
    // bool
    public func hasGroupByID(gid: String) -> Bool {
        if groups.contains(gid) {
            return true
        } else {
            return false
        }
    }
}

// NOT WORKING, not yet supported
class localDay {
    // time stamps
    let startDay: Int
    let endDay: Int
    
    var checkList: [localCheckoff] = []
    
    // init
    init(start: Int, userAmount: Int) {
        startDay = start;
        endDay = startDay + 1;
    }
}

