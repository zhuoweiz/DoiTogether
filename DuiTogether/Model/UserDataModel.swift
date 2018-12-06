//
//  UserDataModel.swift
//  DuiTogether
//
//  Created by Joey on 11/25/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import Foundation
import Firebase

class UserDataModel {
    
    public var user : localUser? = nil;
    private var otherUsers : [localUser] = []; // keep track of other userData, for show otheruser page, modify if load a new user page

    public static let shared = UserDataModel()
    
    init() {
    }

    public func login(email: String, uid: String, url: String) {
        user = localUser(email: email, uid: uid, url: url);
        // preload data when log in
        fetchUserTentData(uid: uid) { (data) in
            // TODO if figure out how to change vc from another file
        }
    }
    
    
    public func logout() {
        
        deleteLocalUser()
    }
    
    public func deleteLocalUser() {
        if let _ = user {
            self.user = nil;
            print("User logged out");
        } else {
            print("ERROR: cant delete nil user");
        }
    }
    
    public func fetchUserTentData(uid: String ,completion: @escaping ((_ data: String) -> Void)) {
        // query all data under user db
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        
        // Load groups to with the id array, do it seperately with the plaza (plaza too large, u dont want to load all), so call all groups from the user.
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                // query for thisUser's all groupIDs success
                
                let data = document.data()
                let temp: [String] = data!["groups"] as! [String]
                
                // attempt to add groupID to this user & add Group if needed
                self.user?.clearGroups()
                for thisGid in temp {
                    // check if localModel has the group info in this
                    if GroupsModel.shared.hasGroup(gid: thisGid) {
                    } else {
                        let docRef = db.collection("groups").document(thisGid)
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                
                                let data: Dictionary! = document.data()
                                let thisGid: String = document.documentID
                                let thissize : Int = (data["users"] as! [String]).count
                                
                                // add the new group to groupmodel
                                let newGroup = LocalGroup(
                                    gid: thisGid,
                                    mTask: data["task"] as! String,
                                    mAmount: data["amount"] as! Int,
                                    mUnit: data["unit"] as! String,
                                    mCapacity: data["capacity"] as! Int,
                                    mLength: data["length"] as! Int,
                                    mRule: data["rule"] as! String,
                                    mSize: thissize,
                                    mColorCode: data["colorCode"] as! [Int],
                                    mProgress: data["progress"] as! Int,
                                    mName: data["name"] as! String,
                                    creationDate: data["creationDate"] as! Date
                                )
                                // add uid to this group
                                let uidarr = data["users"] as! [String]
                                for thisuid in uidarr {
                                    newGroup.addUid(uid: thisuid)
                                }
                                
                                GroupsModel.shared.addGroup(gid: thisGid, group: newGroup)
                            } else {
                                print("ERROR: Document does not exist for adding gid to login init user")
                            }
                        }
                    }
                    
                    print("temptest...fill a new gid to thisuser")
                    self.user?.AddGroup(gid: thisGid) // add gid to this user
                }
                
                // completion
                completion("fetch data completion")
                
            } else {
                print("ERROR: Document does not exist")
            }
        }
        
        
    }
    
    // getters
    public func getTentsCount() -> Int {
        return user?.getTentsCount() ?? 0
    }
    public func getGroupAt(index: Int) -> LocalGroup? {
        return user!.GetGroupByIndex(index: index) ?? nil
    }
    
    // bool
    public func hasGroupByID(gid: String) -> Bool {
        if let user = user {
            if(user.hasGroupByID(gid: gid)) {
                return true
            } else {
                return false
            }
        } else {
            print("ERROR check hasGroupByID when not logged in")
            return false;
        }
    }
    
    // modifiers, 只更改线上
    public func updateProgress() {
        print("temptesting progress... inside updateProgress in userdatamodel")
        if let user = self.user {
            user.updateProgress()
        }
    }
}
