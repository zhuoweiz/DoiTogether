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
    private var creationDate: NSDate
    
    private var mName : String
    private var mTask : String = ""
    private var mAmount : Int = 0
    private var mUnit: String = "Amount"
    private var mLength : Int = 30 // Days
    private var mRule : String = "No rule specified"
    
    private var mCapacity : Int = 20
    private var mSize : Int = 0
    
    private var mUserList: [localUser] = []
    private var mUidList: [String] = []
    private var mDays: [localDay] = []
    
    private var mProgress = 0
    var mColorCode: [Int]
    
    // helper members
    var mTaskComplex: String
    
    // init, msize is 1 if create new group, is what it is if get data
    init(gid: String, mTask: String, mAmount: Int, mUnit: String, mCapacity: Int, mLength: Int, mRule: String, mSize: Int, mColorCode: [Int], mProgress: Int, mName: String, creationDate: NSDate) {
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
        
        // TODO: create all the day objects PROBLEMATIC
        for _ in 1...mLength {
            let temp = localDay(start: 0, userAmount: mSize)
            self.mDays.append(temp)
        }
    }
    
    // Modifiers, combine both local data & db query
    // TODO: not used for now
    public func addUser(user: localUser) {
        // local change
        mUserList.append(user)
        mSize += 1
        
        // db change
    }
    public func addUid(uid: String) {
        mUidList.append(uid)
        mSize += 1
    }
    
    // getters
    public func getTask() -> String {
        return mTask
    }
    public func getAmountUnitPerDay() -> String {
        return "\(mAmount) \(mUnit)/Day"
    }
    public func getSize() -> Int {
        return mSize
    }
    public func getName() -> String {
        return mName
    }
    public func getColor() -> [Double] {
        var result : [Double] = []
        for i in 0...5 {
            result.append(Double(mColorCode[i]))
        }
        return result
    }
}
