//
//  day21.swift
//  AoC
//
//  Created by Rachael Worthington on 12/20/22.
//

import Foundation

func day21() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 21/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
        solveRiddle()
    } catch {
        print(error.localizedDescription)
    }
}

fileprivate var part2 = true
fileprivate class Monkey {
    let name: String
    var value: Int?
    var dependancies: [Monkey] // in order
    var operation: (Int, Int) -> Int
    var dependentString: [String]
    var dependedOnBy: [Monkey]
    var leftValDependsOnHuman: Bool
    var rightValDependsOnHuman: Bool
    var leftOppositeOperation: (Int, Int) -> Int // solve for left value
    var rightOppositeOperation: (Int, Int) -> Int // solve for right value

    init(name: String, value: Int?, dependentString: [String] = [], operation: @escaping (Int, Int) -> Int, leftOppositeOperation: @escaping (Int, Int) -> Int, rightOppositeOperation: @escaping (Int, Int) -> Int) {
        self.name = name
        self.value = value
        self.dependancies = []
        self.dependentString = dependentString
        self.operation = operation
        self.dependedOnBy = []
        self.leftValDependsOnHuman = false
        self.rightValDependsOnHuman = false
        self.leftOppositeOperation = leftOppositeOperation
        self.rightOppositeOperation = rightOppositeOperation
    }

    func finalValue() -> Int {
        if part2 {
            if name == "root" {
                if dependancies[0].finalValue() == dependancies[1].finalValue() {
                    print("root monkey says true")
                } else {
                    print("root monkey says false")
                }
            }
        }
        if let value {
            return value
        } else {
            return operation(dependancies[0].finalValue(), dependancies[1].finalValue())
        }
    }

    func spreadHumanCooties() { // should only be directly called on the human monkey
        for monkey in dependedOnBy {
            if monkey.dependancies[0].name == name {
                monkey.leftValDependsOnHuman = true
                monkey.spreadHumanCooties()
            } else if monkey.dependancies[1].name == name {
                monkey.rightValDependsOnHuman = true
                monkey.spreadHumanCooties()
            }
        }
    }

    func reverseValue(with value:Int) {
        if name == "humn" {
            print("yell \(value)")
            return
        }
      //  print("my name is \(name), my result needs to be \(value)")
        assert(leftValDependsOnHuman || rightValDependsOnHuman)
        if leftValDependsOnHuman {
            // a op b = c

//            operation = { a, b in
//                a + b
//            }
//            leftOppositeOperation = { b, equ in // solving for old a,
//                equ - b
//            }
//            rightOppositeOperation = { a, equ in // solving for old b
//                equ - a
//            }
            var newValue: Int
            if name == "root" {
                newValue = value
            } else {
                newValue = leftOppositeOperation(dependancies[1].finalValue(), value)
            }
         //   print("I have left human cooties, and am passing \(newValue) on to \(dependancies[0].name)")
            dependancies[0].reverseValue(with: newValue)
        } else {
            var newValue: Int
            if name == "root" {
                newValue = value
            } else {
                newValue = rightOppositeOperation(dependancies[0].finalValue(), value)
            }

        //    print("I have right human cooties, and am passing \(newValue) on to \(dependancies[1].name)")
            return dependancies[1].reverseValue(with: newValue)
        }
    }
}

fileprivate var monkeys: [Monkey] = []
fileprivate var rootMonkey: Monkey? = nil
fileprivate var human: Monkey? = nil

fileprivate func parseInput(_ text: String) {
    var localMonkeys: Dictionary<String, Monkey> = Dictionary()
    text.enumerateLines(invoking: { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            let facts = line.split(separator: " ")
            let name = String(facts[0].trimmingCharacters(in: CharacterSet(charactersIn: (":"))))
            var value: Int? = nil
            var dependents: [String] = []
            var operation: (Int, Int) -> Int = { _,_ in return 0 }
            var leftOppositeOperation: (Int, Int) -> Int  = { _,_ in return 0 }
            var rightOppositeOperation: (Int, Int) -> Int  = { _,_ in return 0 }
            if facts[1].first!.isNumber {
                value = Int(facts[1])!
            } else {
                assert(facts.count == 4)
                dependents.append(String(facts[1]))
                dependents.append(String(facts[2]))
                dependents.append(String(facts[3]))

                switch(facts[2]) {
                case "+":
                    operation = { a, b in
                        a + b
                    }
                    leftOppositeOperation = { b, equ in // solving for old a,
                        equ - b
                    }
                    rightOppositeOperation = { a, equ in // solving for old b
                        equ - a
                    }
                case "-":
                    operation = { a, b in
                        a - b
                    }
                    leftOppositeOperation = { b, equ in
                        equ + b
                    }
                    rightOppositeOperation = { a, equ in
                        a - equ
                    }
                case "/":
                    operation = { a, b in
                        a / b
                    }
                    leftOppositeOperation = { b, equ in
                        equ * b
                    }
                    rightOppositeOperation = { a, equ in
                        a / equ
                    }
                case "*":
                    operation = { a, b in
                        a * b
                    }
                    leftOppositeOperation = { b, equ in
                         equ / b
                    }
                    rightOppositeOperation = { a, equ in
                        equ / a // i know this is right.
                    }
                default:
                    assertionFailure("what kind of math is this?")
                }
            }
            let newMonkey = Monkey(name: name, value: value, dependentString: dependents, operation: operation, leftOppositeOperation: leftOppositeOperation, rightOppositeOperation: rightOppositeOperation)
            monkeys.append(newMonkey)
            localMonkeys[name] = newMonkey
            if name == "root" {
                rootMonkey = newMonkey
            }
            if name == "humn" {
                human = newMonkey
            }
        }
    })

    for monkey in monkeys {
        for dependent in monkey.dependentString {
            if let depMonkey = localMonkeys[dependent] {
                monkey.dependancies.append(depMonkey)
                depMonkey.dependedOnBy.append(monkey)
            }
        }
    }
}

func solveRiddle() {
    guard let rootMonkey else { return }
    guard let human else { return }
    if !part2 {
        print(rootMonkey.finalValue())
    } else {
        human.spreadHumanCooties()
        var goalValue: Int
        if rootMonkey.rightValDependsOnHuman {
            goalValue = rootMonkey.dependancies[0].finalValue()
        } else {
            goalValue = rootMonkey.dependancies[1].finalValue()
        }
        //print(goalValue)
        let humanValue = rootMonkey.reverseValue(with: goalValue)
        print(humanValue)
    }
}
