//
//  day11.swift
//  AoC
//
//  Created by Rachael Worthington on 12/10/22.
//

import Foundation

func day11() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 11/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        monkeyRoutine()
    } catch {
        print(error.localizedDescription)
    }
}

//class Monkey {
//    var monkeyID: Int
//    var heldItems: [Int] = []
//    var operation: (_ old: Int) -> Int = { old in print("no operation provided"); return 0 }
//    var test: (_ worry: Int) -> Bool = { worry in print("no test provided"); return true }
//    var trueDest: Int = 0
//    var falseDest: Int = 0
//    var inspectionCount: Int = 0
//
//    init(monkeyID: Int) {
//        if monkeyID == -1 {
//            print("our monkey ID got wronged.")
//        }
//        self.monkeyID = monkeyID
//    }
//
//    func analyzeAndFling() {
//        for itemToUpdate in heldItems {
//            inspectionCount += 1
//            var item = itemToUpdate
//            // run operation on item
//            item = operation(item)
//            // booooring
//            item = Int(item / 3)
//            // check test
//            if test(item) {
//                monkeyCrew[trueDest].catchItem(item: item)
//            } else {
//                monkeyCrew[falseDest].catchItem(item: item)
//            }
//        }
//        heldItems = []
//    }
//
//    func catchItem(item: Int) {
//        heldItems.append(item)
//    }
//}

struct BigStressItem {
    let number: Int
    let multiplicationFactor: Int
    let remainder: Int

    init(number: Int, multiplicationFactor: Int, remainder: Int) {
        assert(number != 0)
        self.number = number
        self.multiplicationFactor = multiplicationFactor
        self.remainder = remainder
    }

    static func +(oldLeft: BigStressItem, right: Int) -> BigStressItem {
        var left = oldLeft.rebalance()

        if right.isMultiple(of: left.multiplicationFactor) {
            return BigStressItem(number: left.number + right/left.multiplicationFactor, multiplicationFactor: left.multiplicationFactor, remainder: left.remainder)
        }

        return BigStressItem(number: left.number, multiplicationFactor: left.multiplicationFactor, remainder: left.remainder + right)
    }

    static func +(oldLeft: BigStressItem, oldRight: BigStressItem) -> BigStressItem {
        var right = oldRight.rebalance()
        var left = oldLeft.rebalance()

        // need to find a new multiplication factor.
        let newFactor = gcd(right.multiplicationFactor, left.multiplicationFactor)

        if newFactor == 1 {
            assert(right.multiplicationFactor == 1)
            return BigStressItem(number: left.number, multiplicationFactor: left.multiplicationFactor, remainder: right.number + left.remainder)
        }
        //reorg our new BigInt to use our new factor
        let newLeft = BigStressItem(number: left.number * (left.multiplicationFactor / newFactor), multiplicationFactor: newFactor, remainder: left.remainder)
        right = BigStressItem(number: right.number * (right.multiplicationFactor / newFactor), multiplicationFactor: newFactor, remainder: right.remainder)
        return BigStressItem(number: newLeft.number + right.number, multiplicationFactor: newFactor, remainder: left.remainder + right.remainder)
    }

    static func -(left: BigStressItem, right: Int) -> BigStressItem {
        return left + (right * -1)
    }

    static func -(left: BigStressItem, right: BigStressItem) -> BigStressItem {
        return left + (right * -1)
    }

    static func *(left: BigStressItem, right: Int) -> BigStressItem {
        return BigStressItem(number: left.number, multiplicationFactor: left.multiplicationFactor * right, remainder: left.remainder * right)
    }

    static func *(oldLeft: BigStressItem, oldRight: BigStressItem) -> BigStressItem {
        var right = oldRight.rebalance()
        var left = oldLeft.rebalance()

        let newFactor = gcd(left.multiplicationFactor, right.multiplicationFactor)
        left = BigStressItem(number: left.number * (left.multiplicationFactor / newFactor), multiplicationFactor: newFactor, remainder: left.remainder).rebalance()
        right = BigStressItem(number: right.number * (right.multiplicationFactor / newFactor), multiplicationFactor: newFactor, remainder: right.remainder).rebalance()
       // (ax+y) * (bx+z) = abxx + axb + bxy + yz
        // x(abx + ab + yz/x)
        // x(ab(x+1)) + yz
        let newNumber = (left.number * right.number) * (newFactor + 1) + (left.remainder * right.remainder / newFactor)
        let newRemainder = ((left.remainder * right.remainder) % newFactor)
        return BigStressItem(number: newNumber, multiplicationFactor: newFactor, remainder: newRemainder)
    }

    static func /(left: BigStressItem, right: Int) -> BigStressItem {
        return left * (1 / right)
      //  return BigStressItem(number: left.number, multiplicationFactor: left.multiplicationFactor * 1 / right)
    }

    static func /(left: BigStressItem, right: BigStressItem) -> BigStressItem {
        let newFactor = gcd(left.multiplicationFactor, right.multiplicationFactor)
        let newLeft = BigStressItem(number: left.number * (left.multiplicationFactor / newFactor), multiplicationFactor: newFactor, remainder: left.remainder)
        let newRight = BigStressItem(number: right.number * (right.multiplicationFactor / newFactor), multiplicationFactor: newFactor, remainder: right.remainder)

       // (ax + y) / (bx + z) = a/b + ax/z + bx/y + y/z // where x is multiplcation factor, a and b are numbs, y and z are remaiders
        // refactor out x... a/b + x*a/z + x*b/y + y/z
        // x(a/z+b/y) + a/b+y/z

        return BigStressItem(number: (newLeft.number / newRight.remainder) + (newRight.number / newLeft.remainder), multiplicationFactor: newFactor, remainder: newLeft.number / newRight.number + newLeft.remainder/newRight.remainder) // this may be bad...
    }

    func isMultiple(of other: BigStressItem) -> Bool {
        // refactor self, and other guy to a gdc
        // short-ciruit for simple numbers
        if other.multiplicationFactor == 1 {
            return self.multiplicationFactor.isMultiple(of: other.number)
        }

        let newFactor = BigStressItem.gcd(multiplicationFactor, other.multiplicationFactor)
        let newSelf = BigStressItem(number: number * (multiplicationFactor / newFactor), multiplicationFactor: newFactor, remainder: remainder)
        let newOther = BigStressItem(number: other.number * (other.multiplicationFactor / newFactor), multiplicationFactor: newFactor, remainder: other.remainder)
        return newSelf.number.isMultiple(of: newOther.number)
    }

    private func rebalance() -> BigStressItem {
        // if there's an extreme imbalance between the number and the exponent, things approach crazy, so lets see if we can get closer to sane.

        if multiplicationFactor == 1 {
            return self
        }

        if multiplicationFactor > number {
            return BigStressItem(number: multiplicationFactor, multiplicationFactor: number, remainder: remainder).rebalance()
        }

        //factor out any number of remainders into the number
        if remainder > multiplicationFactor {
            let numIncrease = Int(remainder/multiplicationFactor)
            let newRemainder = remainder % multiplicationFactor

            return BigStressItem(number: number + numIncrease, multiplicationFactor: multiplicationFactor, remainder: newRemainder).rebalance()
        }

        if number % 10 == 0 && number / 10 > multiplicationFactor * 10 {
            return BigStressItem(number: number / 10, multiplicationFactor: multiplicationFactor * 10, remainder: remainder).rebalance()
        }
        if number % 9 == 0 && number / 9 > multiplicationFactor * 9 {
            return BigStressItem(number: number / 9, multiplicationFactor: multiplicationFactor * 9, remainder: remainder).rebalance()
        }

        if number % 3 == 0 && number / 3 > multiplicationFactor * 3 {
            return BigStressItem(number: number / 3, multiplicationFactor: multiplicationFactor * 3, remainder: remainder)
        }
        if number % 2 == 0 && number / 2 > multiplicationFactor * 2 {
            return BigStressItem(number: number / 2, multiplicationFactor: multiplicationFactor * 2, remainder: remainder)
        }

//        if multiplicationFactor+1 < number / 2 {
//            var i = number / 2
//            while i > multiplicationFactor + 1 {
//                if i > number {
//                    break
//                }
//                if i % number == 0 && i % multiplicationFactor == 0 {
//                    var remainder = remainder
//                    var numIncrease = 0
//                    if remainder % i == 0 {
//                        numIncrease = remainder / i
//                        remainder = 0
//                    }
//                    return BigStressItem(number: number / i + numIncrease, multiplicationFactor: multiplicationFactor * i, remainder: remainder)
//                }
//                i -= 1
//            }
//        }
        return self
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        let r = a % b
        if r != 0 {
          return gcd(b, r)
        } else {
          return b
        }
      }


}

// something about lowest common denominators is relevant here, and I don't understand why.
class StressfulMonkey {
    var monkeyID: Int
    var heldItems: [BigStressItem] = []
    var operation: (_ old: BigStressItem) -> BigStressItem = { old in print("no operation provided"); return BigStressItem(number: 0, multiplicationFactor: 1, remainder: 0) }
    var test: (_ worry: BigStressItem) -> Bool = { worry in print("no test provided"); return true }
    var trueDest: Int = 0
    var falseDest: Int = 0
    var inspectionCount: Int = 0

    init(monkeyID: Int) {
        if monkeyID == -1 {
            print("our monkey ID got wronged.")
        }
        self.monkeyID = monkeyID
    }

    func analyzeAndFling() {
        for itemToUpdate in heldItems {
            inspectionCount += 1
            var item = itemToUpdate
            // run operation on item
            item = operation(item)
            // check test
            if test(item) {
                monkeyCrew[trueDest].catchItem(item: item)
            } else {
                monkeyCrew[falseDest].catchItem(item: item)
            }
        }
        heldItems = []
    }

    func catchItem(item: BigStressItem) {
        heldItems.append(item)
    }
}

//var monkeyCrew: [Monkey] = []
var monkeyCrew: [StressfulMonkey] = []

//fileprivate func parseInput(_ text: String) {
//    var currentMonkey: Monkey? = nil
//
//    text.enumerateLines(invoking: { txt, stop in
//        let line = txt.trimmingCharacters(in: .whitespaces)
//        if line.hasPrefix("Monkey") { // begining of monkey
//            if let currentMonkey { // clear out my previous monkey
//                monkeyCrew.append(currentMonkey)
//            }
//            var monkIDStr = String(line.split(separator: " ").last!)
//            monkIDStr.removeLast()
//            let monkeyID = Int(monkIDStr) ?? -1 //remove the colon
//            currentMonkey = Monkey(monkeyID: monkeyID)
//        } else if line.hasPrefix("Starting items:") {
//            let items = line.split(separator: " ")[2...]
//            currentMonkey!.heldItems = items.compactMap { itemStr in
//                return Int(itemStr.trimmingCharacters(in: CharacterSet(charactersIn: (","))))
//            }
//        } else if line.hasPrefix("Operation:") { // new = old <something something>
//            let opers = line.split(separator: " ")
//            let operand1 = String(opers[3])
//            let oper = opers[4]
//            let operand2 = opers[5]
//            var operValue: Int? = nil
//            assert(operand1 == "old")
//            if operand2 != "old" {
//                operValue = Int(operand2)!
//            }
//
//            currentMonkey?.operation = { (old: Int) -> Int in
//                let oper2: Int
//                if let operValue {
//                    oper2 = operValue
//                } else {
//                    oper2 = old
//                }
//                switch(oper) {
//                case "*":
//                    return old * oper2
//                case "/":
//                    return old / oper2
//                case "+":
//                    return old + oper2
//                case "-":
//                    return old - oper2
//                default:
//                    print("oh no, operator was \(oper)")
//                }
//                return 0
//            }
//        }  else if line.hasPrefix("Test:") { //"Test: divisible by 23"
//            let items = line.split(separator: " ")
//            if let divideValue = Int(items.last ?? "0") {
//                currentMonkey?.test = { (worry: Int) -> Bool in
//                    return worry.isMultiple(of: divideValue)
//                }
//            }
//        } else { // result line
//            if line.isEmpty == false {
//                let items = line.split(separator: " ")
//                if items[1] == "true:" {
//                    currentMonkey?.trueDest = Int(items.last ?? "-1") ?? -1
//                } else if items[1] == "false:" {
//                    currentMonkey?.falseDest = Int(items.last ?? "-1") ?? -1
//                } else {
//                    print("some other operation happened?")
//                }
//            }
//        }
//    })
//
//    // last monkey append
//    monkeyCrew.append(currentMonkey!)
//
//  //  print(monkeyCrew)
//}

fileprivate func parseInput(_ text: String) {
    var currentMonkey: StressfulMonkey? = nil

    text.enumerateLines(invoking: { txt, stop in
        let line = txt.trimmingCharacters(in: .whitespaces)
        if line.hasPrefix("Monkey") { // begining of monkey
            if let currentMonkey { // clear out my previous monkey
                monkeyCrew.append(currentMonkey)
            }
            var monkIDStr = String(line.split(separator: " ").last!)
            monkIDStr.removeLast()
            let monkeyID = Int(monkIDStr) ?? -1 //remove the colon
            currentMonkey = StressfulMonkey(monkeyID: monkeyID)
        } else if line.hasPrefix("Starting items:") {
            let items = line.split(separator: " ")[2...]
            currentMonkey!.heldItems = items.compactMap { itemStr in
                let num = Int(itemStr.trimmingCharacters(in: CharacterSet(charactersIn: (","))))
                return BigStressItem(number: num ?? 0,  multiplicationFactor: 1, remainder: 0)
            }
        } else if line.hasPrefix("Operation:") { // new = old <something something>
            let opers = line.split(separator: " ")
            let operand1 = String(opers[3])
            let oper = opers[4]
            let operand2 = opers[5]
            var operValue: Int? = nil
            assert(operand1 == "old")
            if operand2 != "old" {
                operValue = Int(operand2)!
            }

            currentMonkey?.operation = { (old: BigStressItem) -> BigStressItem in
                var oper2: BigStressItem? = nil
                var intOper2 = 0
                if let operValue {
                    intOper2 =  operValue
                } else {
                    oper2 = old
                }
                switch(oper) {
                case "*":
                    if let oper2 {
                        return old * oper2
                    } else {
                        return old * intOper2
                    }
                case "/":
                    if let oper2 {
                        return old / oper2
                    } else {
                        if intOper2 == 0 {
                            print("no int oper?")
                            intOper2 = 1
                        }
                        return old / intOper2
                    }
                case "+":
                    if let oper2 {
                        return old + oper2
                    } else {
                        return old + intOper2
                    }
                case "-":
                    if let oper2 {
                        return old - oper2
                    } else {
                        return old - intOper2
                    }
                default:
                    print("oh no, operator was \(oper)")
                }
                return BigStressItem(number: 0, multiplicationFactor: 1, remainder: 0)
            }
        }  else if line.hasPrefix("Test:") { //"Test: divisible by 23"
            let items = line.split(separator: " ")
            if let divideValue = Int(items.last ?? "0") {
                currentMonkey?.test = { (worry: BigStressItem) -> Bool in
                    return worry.isMultiple(of: BigStressItem(number: divideValue, multiplicationFactor: 1, remainder: 0))
                }
            }
        } else { // result line
            if line.isEmpty == false {
                let items = line.split(separator: " ")
                if items[1] == "true:" {
                    currentMonkey?.trueDest = Int(items.last ?? "-1") ?? -1
                } else if items[1] == "false:" {
                    currentMonkey?.falseDest = Int(items.last ?? "-1") ?? -1
                } else {
                    print("some other operation happened?")
                }
            }
        }
    })

    // last monkey append
    monkeyCrew.append(currentMonkey!)

  //  print(monkeyCrew)
}

let MONKEY_TIME = 10000

func monkeyRoutine() {
//    for monkey in monkeyCrew {
//        print("monkey \(monkey.monkeyID) holds: \(monkey.heldItems), inspection count = \(monkey.inspectionCount)")
//    }
    for i in 0 ..< MONKEY_TIME {
        print("round \(i)")
        monkeyRound()
//        for monkey in monkeyCrew {
//            print("monkey \(monkey.monkeyID) now holds: \(monkey.heldItems), inspection count = \(monkey.inspectionCount)")
//        }
//        print("******")
    }

    let monkeyinspects = monkeyCrew.map { monkey in
        return monkey.inspectionCount
    }
    for i in 0..<monkeyCrew.count {
        print("monkey \(monkeyCrew[i].monkeyID): \(monkeyinspects[i])")
    }
}

func monkeyRound() {
    for monkey in monkeyCrew {
        monkey.analyzeAndFling()
    }
}

//118674
