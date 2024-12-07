//
//  day7.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/6/24.
//

import Foundation

struct Equation {
    let solution: Int
    let inputs: [Int]
}

enum Operator: CaseIterable, CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .plus:
            return "+"
        case .times:
            return "*"
        case .concat:
            return "||"
        }
    }

    case plus
    case times
    case concat
}

func day7() {
    let input = readInput(forDay: 7)
    // total = x ? y where ? is either + or *
    // always evaluate L -> R, not in precidence order, no re-ordering

    var equations: [Equation] = []
    var greatestCount = 1 // largest # of inputs
    var operators: [Int:[[Operator]]] = [:] // number of inputs to array of operator combos
    let split0 = input.split(separator: "\n")

    for equation in split0 {
        let split1 = equation.split(separator: ": ")
        let split2 = split1[1].split(separator: " ").map { str in
            Int(str)!
        }
        equations.append(Equation(solution: Int(split1[0])!, inputs: split2))
        if split2.count > greatestCount {
            greatestCount = split2.count
        }
    }
    let part2 = true
    // combos are 2 ^ operator numbers
    // generate potential operator combinations:
    for i in 1..<greatestCount {
        var operatorOrders: [[Operator]] = []
        opGen(count: i, opList: [])
     //   var operatorOrder: [Operator] = []
        func opGen(count: Int, opList:[Operator]) {
            if count == 0 {
                operatorOrders.append(opList)
                return
            }
            var localList = opList
            localList.append(.plus)
            opGen(count: count - 1, opList: localList)
            localList = opList
            localList.append(.times)
            opGen(count: count - 1, opList: localList)
            if part2 {
                localList = opList
                localList.append(.concat)
                opGen(count: count - 1, opList: localList)
            }
        }
     //   print("operatorList: \(operatorOrders)")

        operators[i] = operatorOrders
    }



    // part 1
    //The engineers just need the total calibration result, which is the sum of the test values from just the equations that could possibly be true.
    var calibrationResult = 0
    for eq in equations {
        if testCorrectness(eq) {
            calibrationResult = calibrationResult + eq.solution
        }
    }

    print("calibrationResult = \(calibrationResult)")
    func testCorrectness(_ eq: Equation) -> Bool {
        var total = 0
//        // bounds check -
//        for input in eq.inputs {
//            total = total + input
//        }
//        if total > eq.solution {
//            return false
//        }
//        total = 1
//        for input in eq.inputs {
//            total = total * input
//        }
//
//        if total < eq.solution {
//            return false
//        }
//
        // combos...
        for operatorList in operators[eq.inputs.count-1]! {
            total = eq.inputs[0]
            for i in 0..<operatorList.count {
                switch operatorList[i] {
                case .plus:
                    total = total + eq.inputs[i+1]
                case .times:
                    total = total * eq.inputs[i+1]
                    // for part 2
                case .concat:
                    total = Int(String(total)+String(eq.inputs[i+1]))!

                }
                if total > eq.solution {
                    break
                }
            }
            if total == eq.solution {
                return true
            }
        }
        return false
    }

}
