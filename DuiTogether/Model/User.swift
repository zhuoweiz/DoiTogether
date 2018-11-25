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
    var mEmail: String = ""
    var avatarUrl: String = ""
    var mGroups = [LocalGroup]()
    
    init(email: String) {
        mEmail = email
    }
    public func GetUserEmail() -> String {
        return mEmail
    }
    public func AddGroup(group: LocalGroup) {
        mGroups.append(group)
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
