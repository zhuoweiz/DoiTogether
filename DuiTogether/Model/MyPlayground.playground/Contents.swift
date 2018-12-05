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
