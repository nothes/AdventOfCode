//
//  day8.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/7/23.
//

import Foundation
import RegexBuilder

func day8() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day8/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        parseMap(with: text)
        //part 1
    //   traverseDesert()
        // part 2
        traverseSpookyDesert()

    } catch {
        print(error.localizedDescription)
    }
}

var map: [String: (String, String)] = [:] // key is node, value is left/right node, tuple
var instructions: [String] = []
var startingNodes: [String] = []
// AAA = (BBB, CCC)
let node = Regex {
    TryCapture {
        OneOrMore(.word)
    } transform: {
        String($0)
    }
    " = ("
    TryCapture {
        OneOrMore(.word)
    } transform: {
        String($0)
    }
    ", "
    TryCapture {
        OneOrMore(.word)
    } transform: {
        String($0)
    }
    ")"
}

func parseMap(with input: String) {
    var readTurns = false
    input.enumerateLines { line, stop in
        if !readTurns {
            // first line is left/right dirs.
            for char in line {
                instructions.append(String(char))
            }
            readTurns = true
        }

        if line.isEmpty == false { // stop forgetting this.
            if let match = line.firstMatch(of: node) {
                map[match.1] = (match.2, match.3)
                if (match.1.hasSuffix("A")) {
                    startingNodes.append(match.1)
                }
            }
        }
    }
}

func traverseDesert() {
    print("my horse has no name")
    var currentNode = "AAA"
    var instructionCount = 0
    var steps = 0
    while currentNode != "ZZZ" {
        if instructionCount == instructions.count {
            instructionCount = 0
        }

        steps = steps + 1
        if let potentialTurns = map[currentNode] {
            if instructions[instructionCount]  == "R" {
                currentNode = potentialTurns.1
            } else {
                currentNode = potentialTurns.0
            }
            instructionCount = instructionCount + 1
        }
    }

    print(steps)
}

func allAtZ(currNodes: [String]) -> Bool {
    for node in currNodes {
        if !node.hasSuffix("Z") {
            return false
        }
    }
    return true
}

func traverseSpookyDesert()
{
    print("my horses have no name")
    var instructionCount = 0
    var solutions: [Int] = []

    for startingNode in startingNodes {
        var currentNode = startingNode
        var steps = 0

        while !currentNode.hasSuffix("Z") {
            steps = steps + 1
            if instructionCount == instructions.count {
                instructionCount = 0
            }

            if let potentialTurns = map[currentNode] {
                if instructions[instructionCount]  == "R" {
                    currentNode = potentialTurns.1
                } else {
                    currentNode = potentialTurns.0
                }
            }
            instructionCount = instructionCount + 1
        }
        print("ending node \(currentNode), steps: \(steps)")
        solutions.append(steps)
    }
    print(solutions)
}
// applied https://www.calculatorsoup.com/calculators/math/lcm.php
//14449445933179
