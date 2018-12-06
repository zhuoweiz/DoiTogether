import UIKit

var str = "Hello, playground"



class test {
    var name:String
    
    init(_ name: String) {
        self.name = name;
    }
}

var kit : [test] = []

var a : test = test("bob");
var b : test = test("jeff");

kit.append(a)
kit.append(b)

a.name = "changed"

print(kit[0].name)

// TESTED: all objects are passed by reference

var dict : [Int:Int] = [1:2, 2:3]

// TESTED:
if let _ = dict[4] {
    
} else {
    print("not existing...")
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



