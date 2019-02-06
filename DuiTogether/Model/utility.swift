//
//  utility.swift
//  DuiTogether
//
//  Created by Joey on 11/23/18.
//  Copyright © 2018 Joey. All rights reserved.
//

import Foundation
import UIKit

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
    formatter.dateFormat = "MM-dd-yyyy"
    // again convert your date to string
    let myStringafd = formatter.string(from: yourDate!)
    return myStringafd
}

public func countDays(dateA : Date, dateB: Date) -> Int {
    let diffInDays = Calendar.current.dateComponents([.day], from: dateA, to: dateB).day
    // TODO update progress in the future
    return diffInDays ?? -1
}

// download image from url helper function
public func download(url: URL, image: UIImageView) {
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let d = data {
            DispatchQueue.main.async {
                image.image = UIImage(data: d)
            }
        }
        }.resume()
}

extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
