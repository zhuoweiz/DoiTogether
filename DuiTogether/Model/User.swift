//
//  User.swift
//  DuiTogether
//
//  Created by Joey on 11/21/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import Foundation


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
    
    // bool
    public func hasGroupByID(gid: String) -> Bool {
        if groups.contains(gid) {
            return true
        } else {
            return false
        }
    }
}

class localDay {
    // time stamps
    let startDay: Int
    let endDay: Int
    
    var checkList: [localCheckIn] = []
    
    // init
    init(start: Int, userAmount: Int) {
        startDay = start;
        endDay = startDay + 1;
        
        for _ in 1...userAmount {
            let temp = localCheckIn()
            self.checkList.append(temp)
        }
    }
}

class localCheckIn {
    var isCheckedOff = false;
    var imgUrl: String = "no url";
    var description: String = "no description";
    var checkBook: [String:Bool] = [:] // array of uids with size of n (check self if add record)
    
    init() {
        
    }
    
    // Modifiers
    public func changeUrl(url: String) {
        imgUrl = url;
    }
    public func changeDesc(desc: String) {
        description = desc
    }
    public func check() {
        isCheckedOff = !isCheckedOff;
    }
}
