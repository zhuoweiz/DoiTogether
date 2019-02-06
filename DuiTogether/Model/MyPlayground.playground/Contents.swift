import UIKit

var testArr = [Int]()
testArr.append(1)
testArr.append(2)
testArr.append(3)
testArr.append(4)
testArr.append(5)
for i in 0...testArr.count-1 {
    print(testArr[i]);
}


public func Tformater() -> String {
    let formatter = DateFormatter()
    // initially set the format based on your datepicker date / server String
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    let myString = formatter.string(from: Date()) // string purpose I add here
    print(myString)
    // convert your string to date
    let yourDate = formatter.date(from: myString)
    //then again set the date format whhich type of output you need
    formatter.dateFormat = "dd"
    let testStr = formatter.string(from: yourDate!)
    print("test1: \(testStr)")
    
    formatter.dateFormat = "MM"
    let testStr2 = formatter.string(from: yourDate!)
    print("test2: \(testStr2)")
    
    formatter.dateFormat = "dd-MM-yyyy"
    // again convert your date to string
    let myStringafd = formatter.string(from: yourDate!)
    return myStringafd
}
//
//public func CountProgress() {
//    let formatter = DateFormatter()
//    // initially set the format based on your datepicker date / server String
//    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//    let myString = formatter.string(from: Date()) // string purpose I add here
//
//    // convert your string to date
//    let yourDate = formatter.date(from: myString)
//    //then again set the date format whhich type of output you need
//    formatter.dateFormat = "dd"
//    //let day = formatter.string(from: yourDate!)
//    
//    formatter.dateFormat = "MM"
//    //let month = formatter.string(from: yourDate!)
//}
//
//print(Tformater())



