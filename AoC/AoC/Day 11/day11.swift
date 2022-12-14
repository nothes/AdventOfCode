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

fileprivate class Monkey {
    var monkeyID: Int
    var heldItems: [Int] = []
    var operation: (_ old: Int) -> Int = { old in print("no operation provided"); return 0 }
    var test: (_ worry: Int) -> Bool = { worry in print("no test provided"); return true }
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
            var item = itemToUpdate % maxWorry
            // run operation on item
            item = operation(item)
            // remove for pt 2
//            // booooring
//            item = Int(item / 3)
            // check test
            if test(item) {
                monkeyCrew[trueDest].catchItem(item: item)
            } else {
                monkeyCrew[falseDest].catchItem(item: item)
            }
        }
        heldItems = []
    }

    func catchItem(item: Int) {
        heldItems.append(item)
    }
}

fileprivate var monkeyCrew: [Monkey] = []
var maxWorry: Int = 0

fileprivate func parseInput(_ text: String) {
    var currentMonkey: Monkey? = nil
    var divideValues: [Int] = []

    text.enumerateLines(invoking: { txt, stop in
        let line = txt.trimmingCharacters(in: .whitespaces)
        if line.hasPrefix("Monkey") { // begining of monkey
            if let currentMonkey { // clear out my previous monkey
                monkeyCrew.append(currentMonkey)
            }
            var monkIDStr = String(line.split(separator: " ").last!)
            monkIDStr.removeLast()
            let monkeyID = Int(monkIDStr) ?? -1 //remove the colon
            currentMonkey = Monkey(monkeyID: monkeyID)
        } else if line.hasPrefix("Starting items:") {
            let items = line.split(separator: " ")[2...]
            currentMonkey!.heldItems = items.compactMap { itemStr in
                return Int(itemStr.trimmingCharacters(in: CharacterSet(charactersIn: (","))))
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

            currentMonkey?.operation = { (old: Int) -> Int in
                let oper2: Int
                if let operValue {
                    oper2 = operValue
                } else {
                    oper2 = old
                }
                switch(oper) {
                case "*":
                    return old * oper2
                case "/":
                    return old / oper2
                case "+":
                    return old + oper2
                case "-":
                    return old - oper2
                default:
                    print("oh no, operator was \(oper)")
                }
                return 0
            }
        }  else if line.hasPrefix("Test:") { //"Test: divisible by 23"
            let items = line.split(separator: " ")
            if let divideValue = Int(items.last ?? "0") {
                divideValues.append(divideValue)
                currentMonkey?.test = { (worry: Int) -> Bool in
                    return worry.isMultiple(of: divideValue)
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

    maxWorry = divideValues.reduce(1) { partialResult, divideCheck in
        return partialResult * divideCheck
    }

    // last monkey append
    monkeyCrew.append(currentMonkey!)

  //  print(monkeyCrew)
}

let MONKEY_TIME = 10000

func monkeyRoutine() {
    for i in 0 ..< MONKEY_TIME {
        print("round \(i)")
        monkeyRound()
    }

    let sortedCrew = monkeyCrew.sorted { monk1, monk2 in
        return monk1.inspectionCount < monk2.inspectionCount
    }

    let monkeyinspects = sortedCrew.map { monkey in
        return monkey.inspectionCount
    }


    for i in 0..<sortedCrew.count {
        print("monkey \(sortedCrew[i].monkeyID): \(monkeyinspects[i])")
    }
    print("monkey value = \(sortedCrew[7].inspectionCount * sortedCrew[6].inspectionCount)")
}

func monkeyRound() {
    for monkey in monkeyCrew {
        monkey.analyzeAndFling()
    }
}

//118674
