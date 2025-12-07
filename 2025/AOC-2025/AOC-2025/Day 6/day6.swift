//
//  day6.swift
//  AOC-2025
//
//  Created by Rachael Worthington on 12/5/25.
//

import Foundation

func day6() {
    let input = readInput(forDay: 6)


//    part1(input: input)
    part2(input: input)

}

func part1(input: String) {
    let lines = input.split(separator: "\n")
    var problems: [[String]] = []

    var lineCount = 0
    for line in lines {
        let inputs = String(line).split { char in
            char.isWhitespace
        }
        if problems.isEmpty { // first line establishes all the arrays we need.
            for _ in 0..<inputs.count {
                problems.append([])
            }
        }
        let problemCount = problems.count
        for i in 0..<problemCount {
            problems[i].append(String(inputs[i]))
        }
        lineCount += 1
    }

  //  solve(problems: problems)
}

func part2(input: String) {
    let lines = input.split(separator: "\n", omittingEmptySubsequences: false)
    var problems: [[String]] = []
    var charGrid: [[String]] = []
    // lets just put it into a 2d grid of digits so we can navigate it to parse non-linearly.
    for line in lines {
        guard line.isEmpty == false else { continue }
        var splitLine: [String] = []
        for char in line {
            splitLine.append(String(char))
        }
        charGrid.append(splitLine)
    }
    let lastX = charGrid[0].count - 1
    let lastY = charGrid.count - 1
    var x = lastX
    var problem: [String] = []
    var oper = ""
    while x >= 0 {
        var whitespaceColumn = true
        var value = ""
        for y in 0...lastY { // read down the column
            let currChar = charGrid[y][x]
            if currChar == " " {

            } else if currChar == "*" || currChar == "+" {
                oper = currChar
                whitespaceColumn = false
            } else {
                if !currChar.isEmpty {
                    value.append(currChar)
                    whitespaceColumn = false
                }
            }
        }
        if whitespaceColumn || x == 0 { // last line
            assert(!oper.isEmpty)
            if !value.isEmpty {
                problem.append(value)
            }
            problem.append(oper)
            problems.append(problem)
            problem = []
            oper = ""
        } else {
            if !value.isEmpty {
                problem.append(value)
            }
        }
        x -= 1
    }

    solve(problems: problems)
}

func solve(problems: [[String]]) {
    var total = 0
    for problem in problems {
        var solution = 0
        switch problem.last {
        case "*":
            solution = 1
            let multipliers = problem.dropLast()
            for val in multipliers {
                solution *= Int(val)!
            }
            total += solution
        case "+":
            solution = 0
            let adders = problem.dropLast()
            for val in adders {
                solution += Int(val)!
            }
            total += solution
        default:
            assertionFailure("unknown operator")
        }

    }
    print("Grand total = \(total)")
}
