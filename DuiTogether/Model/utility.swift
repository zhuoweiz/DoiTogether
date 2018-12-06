//
//  utility.swift
//  DuiTogether
//
//  Created by Joey on 11/23/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import Foundation

struct Uitility {
    
    public static let shared = Uitility()
    
    init() {
        
    }
    
    enum VendingMachineError: Error {
        case outOfBounds
        case invalidSelection
        case insufficientFunds(coinsNeeded: Int)
        case outOfStock
    }

}

public func Tformater() -> String {
    let formatter = DateFormatter()
    // initially set the format based on your datepicker date / server String
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    let myString = formatter.string(from: Date()) // string purpose I add here
    // convert your string to date
    let yourDate = formatter.date(from: myString)
    //then again set the date format whhich type of output you need
    formatter.dateFormat = "dd-MM-yyyy"
    // again convert your date to string
    let myStringafd = formatter.string(from: yourDate!)
    return myStringafd
}

public func countDays(dateA : Date, dateB: Date) -> Int {
    let diffInDays = Calendar.current.dateComponents([.day], from: dateA, to: dateB).day
    // TODO update progress in the future
    return diffInDays ?? -1
}
