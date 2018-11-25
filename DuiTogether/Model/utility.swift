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

