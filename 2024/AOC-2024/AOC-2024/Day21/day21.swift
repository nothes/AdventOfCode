//
//  day21.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/24/24.
//

import Foundation

// final keypad
//+---+---+---+
//| 7 | 8 | 9 |
//+---+---+---+
//| 4 | 5 | 6 |
//+---+---+---+
//| 1 | 2 | 3 |
//+---+---+---+
//    | 0 | A |
//    +---+---+

// everyone else's keypads
//    +---+---+
//    | ^ | A |
//+---+---+---+
//| < | v | > |
//+---+---+---+

func day21() {
    let input = readInput(forDay: 21)

    let finalKeyPresses = input.split(separator: "\n")

    // always start at A
    // NEVER go over the blank where there's no button

    let numericKeypad: [[Int]] = [[7, 8, 9], [4, 5, 6], [1, 2, 3], [-1, 0, 10]] // -1 is DO NOT GO, 10 == A, or "enter"
    let directionalKeypad: [[Direction]] = [[.NorthWest, .North, .NorthEast], [.West, .South, .East]] // NW is ERROR, NE is Enter

    let numericCoords: [Int:Coord] = [0: Coord(x: 1, y: 3), 1: Coord(x: 0, y: 2), 2: Coord(x: 1, y: 2), 3: Coord(x: 2, y: 2), 4: Coord(x: 0, y: 1), 5: Coord(x: 1, y: 1), 6: Coord(x: 2, y: 1), 7: Coord(x: 0, y: 0), 8: Coord(x: 1, y: 0), 9: Coord(x: 2, y: 0), 10:Coord(x: 2, y: 3)]
    let directionalCoords: [Direction:Coord] = [.North: Coord(x: 1, y: 0), .West: Coord(x: 0, y: 1), .East: Coord(x: 2, y: 1), .South: Coord(x: 1, y: 1), .NorthEast: Coord(x: 2, y: 0)]


    // build up a dict of optimal moves:
    var optimalMoves: [Pair:[Direction]] = [:]
    // level 1 - arrows to get numeric keypad pushed.

    func optimalPath(from: (Int, Coord), to: (Int, Coord)) -> [Direction] {
        print("from \(from.0) to \(to.0)")
        if from.1 == to.1 {
            return []
        }
        let pair = Pair(start: from.1, end: to.1)

        if let answer = optimalMoves[pair] {
            return answer
        }
        let digitForCoord: String
        if to.0 == 10 {
            digitForCoord = "A"
        } else {
            digitForCoord = String(to.0)
        }
        let firstOrderPresses = numericViaDirectional(digitForCoord)

        // find all the combos of these directions:
        var possibleSecondOrders: [[Direction]] = permute(items: firstOrderPresses[0..<firstOrderPresses.count-1]) // leave off the damn enter key, that can't be mixed in!!
        possibleSecondOrders = possibleSecondOrders.map { element in
            var newElements = element
            newElements.append(.NorthEast)
            return newElements
        }

        print("secondOrderOptions: \(possibleSecondOrders)")
        var shortestThird: [Direction] = []
        for order in possibleSecondOrders {
            // for each possible way to input these keys,
            let secondOrderPresses = directionalViaDirectional(order)
            let AIndexRanges = secondOrderPresses.indices { dir in
                dir == .NorthEast
            }
            var AIndexes: [Int] = []

            var iterator = AIndexRanges.ranges.makeIterator()
            var indexRange = iterator.next()
            while let range = indexRange {
                AIndexes.append(range.lowerBound)
                indexRange = iterator.next()
            }

            var possibleThirdOrders: [[Direction]] = permute(items: secondOrderPresses[0..<secondOrderPresses.count-1]) // leave off the damn enter key, that can't be mixed in!!
            possibleThirdOrders = possibleThirdOrders.map { element in
                var newElements = element
                newElements.append(.NorthEast)
                return newElements
            }
            possibleThirdOrders.removeAll { possibility in
                for index in AIndexes {
                    if possibility[index] != .NorthEast {
                        return true
                    }
                }
                return false
            }
            print("ThirdOrderOptions: \(possibleThirdOrders)")

            for order in possibleThirdOrders {
                if shortestThird.isEmpty {
                    shortestThird = order
                } else {
                    if shortestThird.count > order.count {
                        shortestThird = order
                    }
                }
            }
        }

        // save the shortest one
        optimalMoves[pair] = shortestThird
        return directionalViaDirectional(shortestThird)
    }



    // thank you, Rob Napier!!!
    // Takes any collection of T and returns an array of permutations
    func permute<C: Collection>(items: C) -> [[C.Iterator.Element]] {
        var scratch = Array(items) // This is a scratch space for Heap's algorithm
        var result: [[C.Iterator.Element]] = [] // This will accumulate our result

        // Heap's algorithm
        func heap(_ n: Int) {
            if n == 0 {
                return
            }
            if n == 1 {
                result.append(scratch)
                return
            }

            for i in 0..<n-1 {
                heap(n-1)
                let j = (n%2 == 1) ? 0 : i
                scratch.swapAt(j, n-1)
            }
            heap(n-1)
        }

        // Let's get started
        heap(scratch.count)

        // And return the result we built up
        return result
    }

    func numericViaDirectional(_ finalKeyPresses: String) -> [Direction] {
        var currentPosition = numericCoords[10]!// A on the numeric keypad - since the last button press is always A, we'll always START there for the next code.
        var keypresses: [Direction] = []
        for char in finalKeyPresses {
            // find the key we're going to:
            var stringChar = String(char)
            if stringChar == "A" {
                stringChar = "10"
            }
            if let destCoord = numericCoords[Int(stringChar)!] {
                // on numeric keypads, always prefer UP or RIGHT first, to avoid the BAD SQUARE
                let northMove = currentPosition.y - destCoord.y
                if northMove > 0 { // move up first
                    keypresses.append(contentsOf: Array(repeating: .North, count: northMove))
                    currentPosition = currentPosition.coordWith(yVal: currentPosition.y - northMove)
                }
                let eastMove = destCoord.x - currentPosition.x
                if eastMove > 0 {
                    keypresses.append(contentsOf: Array(repeating: .East, count: eastMove))
                    currentPosition = currentPosition.coordWith(xVal: currentPosition.x + eastMove)
                }
                let southMove = destCoord.y - currentPosition.y
                if southMove > 0 {
                    keypresses.append(contentsOf: Array(repeating: .South, count: southMove))
                    currentPosition = currentPosition.coordWith(yVal: currentPosition.y + southMove)
                }
                let westMove = currentPosition.x - destCoord.x
                if westMove > 0 {
                    keypresses.append(contentsOf: Array(repeating: .West, count: westMove))
                    currentPosition = currentPosition.coordWith(xVal: currentPosition.x - westMove)
                }
                assert(destCoord == currentPosition)
                keypresses.append(.NorthEast)
            }
        }
        return keypresses
    }

    // level 2 and beyond
    func directionalViaDirectional(_ finalKeyPresses: [Direction]) -> [Direction] {
        // on directional keypads, always prefer RIGHT or DOWN first
        var currentPosition = directionalCoords[.NorthEast]! // A on the directional keypad - since the last button press is always A, we'll always START there for the next code.
        var keypresses: [Direction] = []
        for dir in finalKeyPresses {
            if let destCoord = directionalCoords[dir] {
                let northMove = currentPosition.y - destCoord.y
                let eastMove = destCoord.x - currentPosition.x
                if eastMove > 0 {
                    keypresses.append(contentsOf: Array(repeating: .East, count: eastMove))
                    currentPosition = currentPosition.coordWith(xVal: currentPosition.x + eastMove)
                }
                if northMove > 0 {
                    keypresses.append(contentsOf: Array(repeating: .North, count: northMove))
                    currentPosition = currentPosition.coordWith(yVal: currentPosition.y - northMove)
                }
                let southMove = destCoord.y - currentPosition.y
                if southMove > 0 {
                    keypresses.append(contentsOf: Array(repeating: .South, count: southMove))
                    currentPosition = currentPosition.coordWith(yVal: currentPosition.y + southMove)
                }
                let westMove = currentPosition.x - destCoord.x
                if westMove > 0 {
                    keypresses.append(contentsOf: Array(repeating: .West, count: westMove))
                    currentPosition = currentPosition.coordWith(xVal: currentPosition.x - westMove)
                }
                assert(destCoord == currentPosition)
                keypresses.append(.NorthEast)
            }
        }

        return keypresses
    }



    // part 1
    var totalComplexity = 0
    for code in finalKeyPresses {
        var solution: [Direction] = []
        var currentPosition = (10, numericCoords[10]!) // aka A
        for char in code {
            var stringChar = String(char)
            if stringChar == "A" {
                stringChar = "10"
            }
            let destCoord = numericCoords[Int(stringChar)!]
            if let destCoord {
                solution.append(contentsOf: optimalPath(from: currentPosition, to: (Int(stringChar)!, destCoord)))
                currentPosition = (Int(stringChar)!, destCoord)
            } else {
                assertionFailure()
            }
        }
        var localComplexity = Int(code.dropLast())! * solution.count
        print("\(code) complexity  = \(Int(code.dropLast())!) * \(solution.count)")
        totalComplexity += localComplexity
    }
    print(totalComplexity)


//    var solutionLv1: [String: [Direction]] = [:]
//    // first level of abstraction
//    for code in finalKeyPresses {
//        solutionLv1[String(code)] = numericViaDirectional(String(code))
//    }
//
//    var solutionLv2: [String: [Direction]] = [:]
//    for (origkeypresses, abstraction) in solutionLv1 {
//        solutionLv2[origkeypresses] = directionalViaDirectional(abstraction)
//    }
//
//    var solutionLv3: [String: [Direction]] = [:]
//    for (origkeypresses, abstraction) in solutionLv2 {
//        solutionLv3[origkeypresses] = directionalViaDirectional(abstraction)
//    }
//
//    var finalComplexity = 0
//    for key in solutionLv3.keys {
//        if let result = solutionLv3[key], let initialNum = Int(key.dropLast()) {
//            let complexity = initialNum * result.count
//            finalComplexity += complexity
//        } else {
//            assertionFailure()
//        }
//    }

}

struct Pair: Hashable {
    let start: Coord
    let end: Coord
}
