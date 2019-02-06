//
//  DataModel.swift
//  DuiTogether
//
//  Created by Joey on 11/24/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import Foundation
import Firebase

enum VendingMachineError: Error {
    case outOfBounds
}

class GroupsModel {
    
    public static let shared = GroupsModel()
    
    private var plazaGroups: [LocalGroup] = []
    private var allGroups: [String:LocalGroup] = [:]
    
    init() {
        // if User is signed in.
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.uid
            let email = user.email
            let photoURL = user.photoURL
            // ...
            UserDataModel.shared.login(email: email!, uid: uid, url: photoURL?.absoluteString ?? "")
        }
    }
    
    // data fetching 1
    public func fetchPlazaData(completion: @escaping ((_ data: String) -> Void)) {
        
        let db = Firestore.firestore()
        let groupsRef = db.collection("groups")
        let query = groupsRef.whereField("visibility", isEqualTo: "")
        
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting user groups: \(err)")
            } else {
                // clear this first
                self.plazaGroups = []
                self.allGroups = [:]
                
                for document in querySnapshot!.documents {
                    // print("\(document.documentID) => \(document.data())")
                    let tempGid = document.documentID
                    print("Firebase: fetching data of group: \(tempGid) in userModel")

                    let data: NSDictionary = document.data() as NSDictionary
                    let thissize : Int = (data["users"] as! [String]).count
                    let newGroup = LocalGroup(
                        gid: tempGid,
                        mTask: data.value(forKey: "task") as! String,
                        mAmount: data.value(forKey: "amount") as! Int,
                        mUnit: data.value(forKey: "unit") as! String,
                        mCapacity: data.value(forKey: "capacity") as! Int,
                        mLength: data.value(forKey: "length") as! Int,
                        mRule: data.value(forKey: "rule") as! String,
                        mSize: thissize,
                        mColorCode: data.value(forKey: "colorCode") as! [Int],
                        mProgress: data.value(forKey: "progress") as! Int,
                        mName: data.value(forKey: "name") as! String,
                        creationDate: data.value(forKey: "creationDate") as! Date,
                        mVisibility: data.value(forKey: "visibility") as! String
                    )
                    // add uid to the group
                    let uidarr = data.value(forKey: "users") as! [String]
                    for thisuid in uidarr {
                        newGroup.addUid(uid: thisuid)
                    }
                    
                    self.plazaGroups.append(newGroup)
                    self.allGroups[tempGid] = newGroup;
                }
            }
            // completion
            completion("Completionhander: fetch data completion")
        }
    }
    // data fetching 2 - fetchCheckoff
    public func updateCheckoff(withGid gid: String, completion: @escaping ((_ data: String) -> Void)) {
        
        let db = Firestore.firestore()
        let groupsRef = db.collection("groups")
        let gRef = groupsRef.document(gid)
        let thisGroup = getGroupById(gid: gid)
//        whereField("users", arrayContains: UserDataModel.shared.getID())
        let checkoffsRef = gRef.collection("checkoffs").order(by: "creationdate", descending: true).limit(to: GroupsModel.shared.getGroupById(gid: gid).getSize()*2)
        
        checkoffsRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting checkoffs: \(err)")
            } else {
                thisGroup.mCheckoffList = [:]
                thisGroup.mCidList = []
                for document in querySnapshot!.documents {
                    // let data: Dictionary = document.data() as Dictionary
                    
                    let docRef = db.collection("checkoffs").document(document.documentID)
                    docRef.getDocument { (document, error) in
                        if let document2 = document, document2.exists {
                            
                            // DispatchQueue.main.async {
                                // Perform your async code here
                                let thisCid = document2.documentID
                                print("Firebase: fetch/updating data of checkoff: \(thisCid)")
                                
                                let data = document2.data()
                            
                                // print("Creation date rank \(data!["creationdate"] as! Date)")
                                let newCheckoff = localCheckoff(
                                    created: data!["creationdate"] as! Date,
                                    dayid: data!["dayid"] as! String,
                                    url: data!["imgurl"] as! String,
                                    comment: data!["comments"] as! String,
                                    verified: data!["isVerified"] as! Bool,
                                    uid: data!["uid"] as! String,
                                    username: data!["username"] as! String,
                                    uidlist: data!["verifierList"] as! [String]
                                )
                            
                                // 1 - add checkoff to the checkoflist on the group
                                self.getGroupById(gid: data!["gid"] as! String).addCheckoff(cid: thisCid, checkoff: newCheckoff)
                            // }
                        } else {
                            print("Document does not exist")
                        }
                        // sort checkoff list based on descending time
                        self.getGroupById(gid: gid).mCidList.sort {data1, data2 in
                            thisGroup.mCheckoffList[data1]!.getCreationDate() > thisGroup.mCheckoffList[data2]!.getCreationDate()
                        }
                        // completion
                        completion("Completionhander: fetch checkoffs")
                    }
                } // after for loop
            }
        }
    }
    
    // modifiers
    public func createGroup(
        gid: String,
        mTask: String,
        mAmount: Int,
        mUnit: String,
        mCapacity: Int,
        mLength: Int,
        mRule: String,
        mSize: Int,
        mColorCode: [Int],
        mProgress: Int,
        mName: String,
        creationDate: Date,
        uid: String, mVisibility: String)
    {
        let newGroup = LocalGroup(gid: gid, mTask: mTask, mAmount: mAmount, mUnit: mUnit, mCapacity: mCapacity, mLength: mLength, mRule: mRule, mSize: mSize, mColorCode: mColorCode, mProgress: mProgress, mName: mName, creationDate: creationDate, mVisibility: mVisibility)
        
        // data modifiers
        newGroup.addUid(uid: uid) // add owner to this group
        // groupModel.addGroup
        plazaGroups.append(newGroup) // add this group to the shared plaza group datamodel
        allGroups[gid] = newGroup;
        // userModel.addgid
        UserDataModel.shared.user?.AddGroup(gid: gid)
        
        print("special testing... id \(uid)")
        // firebase.users.user.addgid
        let db = Firestore.firestore()
        let washingtonRef = db.collection("users").document(uid)
            // Atomically add a new region to the "regions" array field.
        washingtonRef.updateData([
            "groups": FieldValue.arrayUnion([gid])
            
            ])
    }
    public func addGroupToAll(gid: String, group: LocalGroup) {
        allGroups[gid] = group
    }
    
    // getters
    public func getPlazaGroup(atIndex: Int) throws -> LocalGroup? {
        if(atIndex<0 || atIndex>plazaGroups.count-1) {
            print("getting group at \(atIndex)")
            throw VendingMachineError.outOfBounds
        } else {
//            print("returning group at: \(atIndex)")
            return plazaGroups[atIndex]
        }
    }
    public func getPlazaSize() -> Int {
        return plazaGroups.count
    }
    public func hasGroup(gid: String) -> Bool {
        if let _ = allGroups[gid] {
            return true;
        } else {
            return false;
        }
    }
    public func getGroupById(gid:String) -> LocalGroup {
//        if let result = allGroups[gid] {
//            return result;
//        } else {
//            print("ERROR: trying to getGroupById using non existing gid")
//            return nil
//        }
        return allGroups[gid]!
    }
    public func getAllGroupCount() -> Int {
        return allGroups.count;
    }
    
    // test helpers
    public func printAllGroups() {

    }
}
