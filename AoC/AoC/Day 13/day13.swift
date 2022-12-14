//
//  day13.swift
//  AoC
//
//  Created by Rachael Worthington on 12/12/22.
//

import Foundation

func day13() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 13/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
        compare()
    } catch {
        print(error.localizedDescription)
    }
}

class List: CustomStringConvertible {
    //Packet data consists of lists and integers. Each list starts with [, ends with ], and contains zero or more comma-separated values (either integers or other lists). Each packet is always a list and appears on its own line.
    var contents: [List] = []
    var parentList: List?

    init(contents: [List] = [], parentList: List? = nil) {
        self.contents = contents
        self.parentList = parentList
    }

    var description: String {
        return "\(contents)"
    }
}

class Node: List {
    var value: Int = 0
    init(value: Int, parentList: List? = nil) {
        self.value = value
        super.init(parentList: parentList)
    }

    override var contents: [List] {
        get {
            print("YOU'RE A NODE, YOU HAVE NO CONTENTS")
            return []
        }
        set {
            print("YOU'RE A NODE, YOU HAVE NO CONTENTS")
        }
    }

    override var description: String {
        return "\(value)"
    }
}

var listPairs: [(List, List)] = []
fileprivate func parseInput(_ text: String) {
    var listPair: [List] = []
    var list: List? = nil
    var listBeingRead: List? = nil
    text.enumerateLines(invoking: { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            var consumableLine = line
            while consumableLine.isEmpty == false {
                let nextChar = consumableLine.removeFirst()
                if nextChar == "[" { // new list.
                    if list == nil {
                        list = List()
                        listBeingRead = list
                    } else {
                        guard listBeingRead != nil else { print("how do i not have a list to update?"); return }
                        let newList = List(parentList: listBeingRead)
                        listBeingRead?.contents.append(newList)
                        listBeingRead = newList
                    }
                } else if nextChar.isNumber {
                    // add it to my currentlist as a node.
                    var valueStr = String(nextChar)
                    while let first = consumableLine.first, first.isNumber {
                        let nextChar = consumableLine.removeFirst()
                        assert(nextChar != "," && nextChar != "]")
                        valueStr.append(nextChar)
                    }
                    if let value = Int(valueStr), let listBeingRead {
                        listBeingRead.contents.append(Node(value: value, parentList: listBeingRead))
                    }
                } else if nextChar == "," {
                    // garbage char, ignore.
                } else if nextChar == "]" {
                    // list is over, pop the one we're editing up by 1.
                    listBeingRead = listBeingRead?.parentList
                }
            }
        }
        if line.isEmpty {
            return
        }
        if let justRead = list, listPair.isEmpty {
            listPair.append(justRead)
            list = nil
            listBeingRead = nil
        } else if let justRead = list {
            assert(listPair.count == 1) // we didn't fail to insert it, right?
            listPair.append(justRead)
            listPairs.append((listPair[0], listPair[1]))

            // cleanup
            list = nil
            listBeingRead = nil
            listPair = []
        } else {
            assertionFailure("if we got here something is wrong.")
        }
    })
}

func compare() {
    var correctOrderList: [Int] = []
    for i in 0..<listPairs.count {
        let listPair = listPairs[i]
        print("*****comparing list \(i+1): \(listPair.0) vs \(listPair.1)")
        let correct = compareLists(leftList: listPair.0, rightList: listPair.1, depth: 0)
        if correct {
            correctOrderList.append(i+1)
            print("list pair index: \(i + 1) is correct.")//1-indexed list, because rude.
        }
    }
    let answer = correctOrderList.reduce(0) { partialResult, index in
        return partialResult + index
    }
    print("correctLists: \(correctOrderList)")
    print("problem answer = \(answer)")
}

func compareLists(leftList: List, rightList: List, depth: Int) -> Bool {
   // print("checking \(leftList) vs \(rightList); depth = \(depth)")
    var leftListContents = Array(leftList.contents)
    var rightListContents = Array(rightList.contents)
    while true {
        if leftListContents.isEmpty && rightListContents.isEmpty {
            if depth != 0 {
                print("both sublists empty at once")
            } else {
                print("both list empty at once")
            }
            return true // we checked everything in that list; it was equal,
        } else if leftListContents.isEmpty  {
            print("Left side ran out of items.")
            return true // we checked everything we could, but ran out of items in 1 list early. allowed.
        } else if rightListContents.isEmpty {
            print("Right side ran out of items.")
            return false // right ran out first. SHAAAMEEE
        }

        let left = leftListContents.removeFirst()
        let right = rightListContents.removeFirst()

        print("checking \(left) vs \(right); depth = \(depth)")

        if let left = left as? Node, let right = right as? Node {
            //If both values are integers, the lower integer should come first. If the left integer is lower than the right integer, the inputs are in the right order. If the left integer is higher than the right integer, the inputs are not in the right order. Otherwise, the inputs are the same integer; continue checking the next part of the input.

            print("both nodes: left is \(left), right is \(right)")
            if left.value < right.value {
                if depth == 0 {
                    print("we're done here. Well Ordered.")
                }
                return true
                // otherwise keep checking.
            } else if left.value > right.value {
                print("we're done here. INcorrectly Ordered.")
                return false
            } else {
                print("check next value.")
            }
        } else if let left = left as? Node {
            //If exactly one value is an integer, convert the integer to a list which contains that integer as its only value, then retry the comparison. For example, if comparing [0,0,0] and 2, convert the right value to [2] (a list containing 2); the result is then found by instead comparing [0,0,0] and [2].
            let result = compareLists(leftList: List(contents: [Node(value: left.value)]), rightList: right, depth: depth + 1)
                return result
        } else if let right = right as? Node {
            let result = compareLists(leftList: left, rightList: List(contents: [Node(value: right.value)]), depth: depth + 1)
                return result
        } else {
            //If both values are lists, compare the first value of each list, then the second value, and so on. If the left list runs out of items first, the inputs are in the right order. If the right list runs out of items first, the inputs are not in the right order. If the lists are the same length and no comparison makes a decision about the order, continue checking the next part of the input.
            let result = compareLists(leftList: left, rightList: right, depth: depth + 1)
                print("sublists are well ordered? \(result)")
            if result == false {
                return result
            } else {
                print("keep looking")
            }
        }
    }
}
