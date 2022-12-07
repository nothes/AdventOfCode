//
//  day6.swift
//  AoC
//
//  Created by Rachael Worthington on 12/6/22.
//

import Foundation
public struct day6 {
    public func day6() {
        let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 6/input"
        do {
            //   let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 6/input"
            let text = try String(contentsOfFile: path, encoding: .utf8)
            // parseInput(text)
            parseInput3(text)
        } catch {
            print(error.localizedDescription)
        }
    }


    // first swing. this will work, but be inefficient.
    //func parseInput(_ text: String) {
    ////    To be able to communicate with the Elves, the device needs to lock on to their signal. The signal is a series of seemingly-random characters that the device receives one at a time.
    //
    ////    To fix the communication system, you need to add a subroutine to the device that detects a start-of-packet marker in the datastream. In the protocol being used by the Elves, the start of a packet is indicated by a sequence of four characters that are **all different**.
    //    var startIndex = text.startIndex
    //    var endIndex = text.index(startIndex, offsetBy: 3, limitedBy: text.endIndex)
    //    guard endIndex != nil else { return } // no possible way to get a 4 letter code with less than 4 chars.
    //    var potentialStartPacket: String.SubSequence
    //
    //    while let end = endIndex {
    //        potentialStartPacket = text[startIndex...end]
    //        if isStartPacket(String(potentialStartPacket)) {
    //            print("start packet ends at index \(String(describing: endIndex))")
    //        } else {
    //            startIndex = text.index(startIndex, offsetBy: 1)
    //            endIndex = text.index(end, offsetBy: 1, limitedBy: text.endIndex)
    //        }
    //    }
    //    print("no start packet found.")
    //}

    private func parseInput(_ dataStream: String) {
        //    To be able to communicate with the Elves, the device needs to lock on to their signal. The signal is a series of seemingly-random characters that the device receives one at a time.

        //    To fix the communication system, you need to add a subroutine to the device that detects a start-of-packet marker in the datastream. In the protocol being used by the Elves, the start of a packet is indicated by a sequence of four characters that are **all different**.

        // set up my initial checks.
        var text = dataStream
        let index = text.startIndex
        var lazyCount = 0
        func newChar() -> Character { //updates the index after snagging the char
            let char = text.remove(at: index)
            // index = text.index(after: index)
            lazyCount += 1
            return char
        }
        var firstChar = newChar()
        var secChar = newChar()
        var thirdChar = newChar()
        var fourthChar = newChar()

        // things that can match: (bottom to top sice that's the most drastic change to least, eliminates things faster)
        // 1 - 2 new 1st is 2
        // 1 - 3 new 1st is 2
        // 1 - 4 new 1st is 2
        // 2 - 3 new 1st is 3
        // 2 - 4 new 1st is 3
        // 3 - 4 new 1st is 4
        while text.isEmpty == false { // this will run a few times more than necessary but a max of 3, meh.
                                      // time to start my search!
            print("comparing \(firstChar), \(secChar), \(thirdChar), and \(fourthChar)")
            if fourthChar == thirdChar {
                print("\(fourthChar) matches \(thirdChar)")
                // new first is fourth, read in 3 new ones.
                firstChar = fourthChar
                secChar = newChar()
                thirdChar = newChar()
                fourthChar = newChar()
                continue
            } else if fourthChar == secChar || thirdChar == secChar {
                // new first is third, read in 2 new ones.
                firstChar = thirdChar
                secChar = fourthChar
                thirdChar = newChar()
                fourthChar = newChar()
                continue
            } else if fourthChar == firstChar || thirdChar == firstChar || secChar == firstChar {
                // new first is second, read in 1 new one.
                firstChar = secChar
                secChar = thirdChar
                thirdChar = fourthChar
                fourthChar = newChar()
                continue
            } else {
                print("found new packet symbol. first char after is at index \(lazyCount)")
                return
            }
        }
        print("no start packet found")
    }

    // this approach should work, but because I can't actually inspect the indicies, it's being a bitch to debug.
    private func parseInput2(_ text: String) {
        var startIndex = text.startIndex
        var endIndex = text.index(startIndex, offsetBy: 14, limitedBy: text.endIndex)
        guard endIndex != nil else { return } // no possible way to get a 14 letter code with less than 14 chars.
        var potentialStartPacket: String.SubSequence

        if let end = endIndex {
            potentialStartPacket = text[startIndex..<end] // limited by will return an endIndex of nil, so we have to check it.
            var comparatorIndex = potentialStartPacket.index(before: potentialStartPacket.endIndex)
            var newFirstIndex:String.Index? = nil
            print("comparing chars in \(potentialStartPacket)")
            while comparatorIndex > potentialStartPacket.startIndex {
                var comparisonIndex = text.index(before: comparatorIndex)
                print("comparator: \(comparatorIndex), comparison: \(comparisonIndex)")
                while comparisonIndex >= potentialStartPacket.startIndex {
                    if potentialStartPacket[comparisonIndex] == potentialStartPacket[comparatorIndex] {
                        print("new first Index after \(potentialStartPacket[comparisonIndex]) == \(potentialStartPacket[comparatorIndex])")
                        newFirstIndex = potentialStartPacket.index(after:comparisonIndex)
                        break
                    } else {
                        if comparisonIndex == potentialStartPacket.startIndex {
                            break
                        }
                        comparisonIndex = potentialStartPacket.index(before: comparisonIndex)
                    }
                }
                comparatorIndex = potentialStartPacket.index(before: comparatorIndex)
            }

            //update my buffer (slide my Slice along the string)
            if let firstIdx = newFirstIndex, let newEndIndex = text.index(firstIdx, offsetBy: 13, limitedBy: text.endIndex) { // gotta update my buffer.
                potentialStartPacket = text[firstIdx...newEndIndex]
                print("updated packet: \(potentialStartPacket)")
                newFirstIndex = nil
                comparatorIndex = potentialStartPacket.index(before: potentialStartPacket.endIndex)
            } else {
                print("finished searching, content starts at \(potentialStartPacket.endIndex)")
                return
            }
        }
        print("no start packet found.")

    }

    private func parseInput3(_ text: String) {
        var startIndex: Int = 0
        var endIndex: Int = 13
        guard text.count >= 14 else { return } // no possible way to get a 14 letter code with less than 14 chars.
        var potentialStartPacket: [Character] = []

        var mutableText = text
        for _ in 0 ..< 14 {
            potentialStartPacket.append(mutableText.removeFirst())
        }

        var compare1 = 13 // start at the end of my string
        var compare2 = 12 // what am I comparing it to?
        var newFirstIndex: Int? = nil

        while mutableText.count >= 14 {
            print("\(startIndex) to \(endIndex) gives \(potentialStartPacket)")

            while compare1 >= 1 {
                print("compare1 = \(compare1)")
                while compare2 >= 0 {
                    print("compare2 = \(compare2)")
                    print("checking \(potentialStartPacket[compare1]) to \(potentialStartPacket[compare2])")
                    if potentialStartPacket[compare1] == potentialStartPacket[compare2] {
                        print("char at \(compare1) == char at \(compare2)")
                        newFirstIndex = compare2 + 1
                        break
                    } else {
                        compare2 -= 1
                    }
                }

                if newFirstIndex != nil {
                    break
                }
                print("decrementing comp1")
                compare1 -= 1
                compare2 = compare1 - 1
            }
            print("out of outer while")

            if let newFirstIndex = newFirstIndex {
                print("newFirstIndex = \(newFirstIndex)")
                // updated start & end indexes, and search array.
                let keepLast = 14 - newFirstIndex
                print("keep last \(keepLast) chars")
                for i in 0 ..< keepLast {
                    potentialStartPacket[i] = potentialStartPacket[14 - keepLast + i]
                }

                for j in keepLast ..< 14 {
                    if mutableText.isEmpty == false {
                        potentialStartPacket[j] = mutableText.removeFirst()
                    } else {
                        print("no unique sequence found.")
                        return
                    }
                }

                startIndex += newFirstIndex
                endIndex = startIndex + 13
                compare1 = 13
                compare2 = compare1 - 1
            } else {
                // we found a clean string!
                print("found 14 unique chars: \(potentialStartPacket). first index after that is \(endIndex + 1)")
                return
            }
            newFirstIndex = nil

        }
    }
}
