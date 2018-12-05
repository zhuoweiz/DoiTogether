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
    
    public func fetchPlazaData(completion: @escaping ((_ data: String) -> Void)) {
        // clear this first
        plazaGroups = []
        allGroups = [:]
        
        let db = Firestore.firestore()
        db.collection("groups").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // print("\(document.documentID) => \(document.data())")
                    let tempGid = document.documentID
                    print("Firebase: fetching data of group: \(tempGid)")

                    let data: NSDictionary = document.data() as NSDictionary
                    
                    let newGroup = LocalGroup(
                        gid: tempGid,
                        mTask: data.value(forKey: "task") as! String,
                        mAmount: data.value(forKey: "amount") as! Int,
                        mUnit: data.value(forKey: "unit") as! String,
                        mCapacity: data.value(forKey: "capacity") as! Int,
                        mLength: data.value(forKey: "length") as! Int,
                        mRule: data.value(forKey: "rule") as! String,
                        mSize: data.value(forKey: "size") as! Int,
                        mColorCode: data.value(forKey: "colorCode") as! [Int],
                        mProgress: data.value(forKey: "progress") as! Int,
                        mName: data.value(forKey: "name") as! String,
                        creationDate: data.value(forKey: "creationDate") as! NSDate
                    )
                    self.plazaGroups.append(newGroup)
                    self.allGroups[tempGid] = newGroup;
                }
            }
            // completion
            completion("fetch data completion")
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
        creationDate: NSDate,
        uid: String)
    {
        let newGroup = LocalGroup(gid: gid, mTask: mTask, mAmount: mAmount, mUnit: mUnit, mCapacity: mCapacity, mLength: mLength, mRule: mRule, mSize: mSize, mColorCode: mColorCode, mProgress: mProgress, mName: mName, creationDate: creationDate)
        
        // data modifiers
        newGroup.addUid(uid: uid) // add owner to this group
        // groupModel.addGroup
        plazaGroups.append(newGroup) // add this group to the shared plaza group datamodel
        allGroups[gid] = newGroup;
        // userModel.addgid
        UserDataModel.shared.user?.AddGroup(gid: gid)
        
        // firebase.users.user.addgid
        let db = Firestore.firestore()
        let washingtonRef = db.collection("users").document(uid)
            // Atomically add a new region to the "regions" array field.
        washingtonRef.updateData([
            "groups": FieldValue.arrayUnion([gid])
            ])
    }
    public func addGroup(gid: String, group: LocalGroup) {
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
        return allGroups[gid]!;
    }
    public func getAllGroupCount() -> Int {
        return allGroups.count;
    }
    
    // test helpers
    public func printAllGroups() {

    }
}
