//
//  LocalGroup.swift
//  DuiTogether
//
//  Created by Joey on 11/24/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import Foundation
import Firebase

class LocalGroup {
    // member var
    private var groupID: String
    private var creationDate: Date
    
    private var mName : String
    private var mTask : String
    private var mAmount : Int
    private var mUnit: String = "Amount"
    private var mLength : Int // Days
    private var mRule : String = "No rule specified"
    
    private var mCapacity : Int = 10
    private var mSize : Int = 0
    
    private var mUidList: [String] = []
    private var mDays: [localDay] = [] // not used yet
    
    // temp solution for the final, will improve for future release
    public var mCheckoffList: [localCheckoff] = []
    
    private var mProgress = 1
    var mColorCode: [Int]
    
    // helper members
    var mTaskComplex: String
    let db = Firestore.firestore()
    
    // init, msize is 1 if create new group, is what it is if get data
    init(gid: String, mTask: String, mAmount: Int, mUnit: String, mCapacity: Int, mLength: Int, mRule: String, mSize: Int, mColorCode: [Int], mProgress: Int, mName: String, creationDate: Date) {
        groupID = gid
        self.creationDate = creationDate
        
        self.mTask = mTask
        self.mAmount = mAmount
        self.mUnit = mUnit
        
        self.mCapacity = mCapacity
        self.mSize = mSize
        
        self.mLength = mLength
        self.mRule = mRule
        self.mName = mName
        self.mColorCode = mColorCode
        
        self.mProgress = mProgress
        
        mTaskComplex = "\(mTask) \(mAmount) \(mUnit)/Day"
        
        // update progress
        let daya:Date = creationDate
        let dayb:Date = Date()
        let dayCount = countDays(dateA: daya, dateB: dayb)
        self.setProgress(dayCount, groupID)
        
        // TODO: create all the day objects PROBLEMATIC
//        for _ in 1...mLength {
//            let temp = localDay(start: 0, userAmount: mSize)
//            self.mDays.append(temp)
//        }
    }
    
    // Modifiers, combine both local data & db query
    public func addUid(uid: String) {
        mUidList.append(uid)
        // mSize += 1
    }
    
    // getters
    public func getTask() -> String {
        return mTask
    }
    public func getAmountUnitPerDay() -> String {
        return "\(mAmount) \(mUnit)/Day"
    }
    public func getSize() -> Int {
        return mUidList.count
    }
    public func getCap() -> Int {
        return mCapacity
    }
    public func getName() -> String {
        return mName
    }
    public func getAmount() -> Int {
        return mAmount
    }
    public func getUnit() -> String {
        return mUnit
    }
    public func getColor() -> [Double] {
        var result : [Double] = []
        for i in 0...5 {
            result.append(Double(mColorCode[i]))
        }
        return result
    }
    public func getProgress() -> Float {
        return Float(mProgress)/Float(mLength)
    }
    public func getProgressInt() -> Int {
        return mProgress
    }
    public func getLength() -> Int {
        return mLength
    }
    public func getRuleText() -> String {
        return mRule
    }
    public func getgid() -> String {
        return groupID
    }
    public func getCreationDate() -> Date {
        return creationDate
    }
    public func getCheckoffAmount() -> Int {
        return mCheckoffList.count
    }
    public func getCheckoffLink(index: Int) -> String {
        return mCheckoffList[index].geturl()
    }
//    public func getCheckoffTitle(index: Int) -> String {
//
//    }
    public func getCheckoffTitle(index: Int, completion: @escaping ((_ data: String) -> Void)) {
        
        let thisuid = mCheckoffList[index].getUserID()
        // let comment = mCheckoffList[index].getComment()
        
        // firebase call get username and comment
        let docRef = db.collection("users").document(thisuid)
        // Force the SDK to fetch the document from the cache. Could also specify
        // FirestoreSource.server or FirestoreSource.default.
        docRef.getDocument(source: .cache) { (document, error) in
            if let document = document {
                let emailname = document.data()!["email"] as! String
                completion("\(emailname.prefix(5))")
            } else {
                print("Document does not exist in cache")
                completion("FAIL to get user email prefix 5 for checkoff table")
            }
        }
    }
    
    // modifiers
    // BIG TEST
    public func setProgress(_ newProgress: Int, _ thisGid: String) {
        mProgress = newProgress
        // firebase side here too
        // firebase
        let washingtonRef = db.collection("groups").document(thisGid)
        
        // Set the "capital" field of the city 'DC'
        washingtonRef.updateData([
            "progress": newProgress
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Progress successfully updated")
            }
        }
    }
    public func addCheckoff(checkoff: localCheckoff) {
        mCheckoffList.append(checkoff)
    }
}
