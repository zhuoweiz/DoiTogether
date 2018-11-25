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
    private var myGroups: [LocalGroup] = []
    
    init() {
        
    }
    
    public func fetchData(completion: @escaping ((_ data: String) -> Void)) {
        let db = Firestore.firestore()
        db.collection("groups").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let data: NSDictionary = document.data() as NSDictionary
                    
                    let newGroup = LocalGroup(
                        gid: document.documentID,
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
                }
            }
            // completion
            completion("fetch data completion")
        }
    }
    
    // modifiers
    public func createGroup(gid: String, mTask: String, mAmount: Int, mUnit: String, mCapacity: Int, mLength: Int, mRule: String, mSize: Int, mColorCode: [Int], mProgress: Int, mName: String, creationDate: NSDate, uid: String) {
        let newGroup = LocalGroup(gid: gid, mTask: mTask, mAmount: mAmount, mUnit: mUnit, mCapacity: mCapacity, mLength: mLength, mRule: mRule, mSize: mSize, mColorCode: mColorCode, mProgress: mProgress, mName: mName, creationDate: creationDate)
        
        // TODO: add this group to owner user's sharedModel
        newGroup.addUid(uid: uid)
        
        // TODO: add owner to this group
        
        
        plazaGroups.append(newGroup)
    }
    
    // getters
    public func getGroup(atIndex: Int) throws -> LocalGroup? {
        
        if(atIndex<0 || atIndex>plazaGroups.count-1) {
            print("getting group at \(atIndex)")
            throw VendingMachineError.outOfBounds
//            return nil
        } else {
            print("returning group at: \(atIndex)")
            return plazaGroups[atIndex]
        }
    }
    public func getSize() -> Int {
        return plazaGroups.count
    }
}
