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
    private var mTask : String
    private var mAmount : Int
    private var mUnit: String = "Amount"
    private var mLength : Int // Days
    private var mRule : String = "No rule specified"
    
    private var mCapacity : Int = 10
    private var mSize : Int = 1
    
    private var mUidList: [String] = []
    private var mDays: [localDay] = []
    
    private var mProgress = 1
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
        return Float(mProgress/mLength)
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
}
