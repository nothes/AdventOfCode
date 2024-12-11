//
//  day11.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/10/24.
//

import Foundation

func day11() {
    let input = readInput(forDay: 11)
    let stones = input.split(separator: " ").map { str in
        Int(String(str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)))!
    }

    func blink(stones: [Int]) -> [Int] {
        var newStones: [Int] = Array(repeating: -1, count: stones.count)
        var indexModifier = 0
        for i in 0..<stones.count {
            let stone = stones[i]

            //If the stone is engraved with the number 0, it is replaced by a stone engraved with the number 1.
            if stone == 0 {
                newStones[i+indexModifier] = 1
            } else if String(stone).count.isMultiple(of: 2) {
                //If the stone is engraved with a number that has an even number of digits, it is replaced by two stones. The left half of the digits are engraved on the new left stone, and the right half of the digits are engraved on the new right stone. (The new numbers don't keep extra leading zeroes: 1000 would become stones 10 and 0.)
                let stoneStr = String(stone)
                let splitIdx = stoneStr.count / 2
                // let range = stoneStr.index(stoneStr.startIndex, offsetBy: splitIdx)

                let leftStr = stoneStr.prefix(splitIdx)
                let rightStr = stoneStr.suffix(splitIdx)

                newStones[i+indexModifier] = Int(leftStr)!
                indexModifier += 1
                if i+indexModifier < newStones.count {
                    newStones[i+indexModifier] = Int(rightStr)!
                    newStones.append(-1) // this is to make room for the rest of the array as we work through our stones
                } else {
                    newStones.append(Int(rightStr)!)
                }
            } else {
                //If none of the other rules apply, the stone is replaced by a new stone; the old stone's number multiplied by 2024 is engraved on the new stone.
                newStones[i+indexModifier] = stone * 2024
            }
        }

        return newStones
    }

    // part 1
//        var mutatingStones = stones
//        for _ in 0..<25 {
//            mutatingStones = blink(stones: mutatingStones)
//        }
//        //Consider the arrangement of stones in front of you. How many stones will you have after blinking 25 times?
//        print("after 25 blinks, count = \(mutatingStones.count)")
//
    // part 2

    var mutatingStones = [3277]
    mutatingStones = blink(stones: mutatingStones)
    print("test 1 blink \(mutatingStones)")
    struct Stone: Hashable {
        let value: Int
        let blinks: Int
    }
    var resultCache: [Stone: Int] = [:] // for a combo of value & blinks to go, there are x steps
    func recursiveBlink(stone: Int, blinks: Int) -> Int {
        var newStones: [Int] = Array(repeating: -1, count: 1)
        var indexModifier = 0
        var total = 0
        if let result = resultCache[Stone(value: stone, blinks: blinks)] {
            total += result
        } else {
                let blinksToGo = blinks - 1
                if blinks == 0 {
                //    print("stone \(stone) blinks \(blinksToGo) = 1")
                    resultCache[Stone(value: stone, blinks: blinksToGo)] = 1
                    return 1
                }
                assert(blinksToGo >= 0)
                //If the stone is engraved with the number 0, it is replaced by a stone engraved with the number 1.
                if stone == 0 {
                    newStones[0+indexModifier] = 1
                } else if String(stone).count.isMultiple(of: 2) {
                    //If the stone is engraved with a number that has an even number of digits, it is replaced by two stones. The left half of the digits are engraved on the new left stone, and the right half of the digits are engraved on the new right stone. (The new numbers don't keep extra leading zeroes: 1000 would become stones 10 and 0.)
                    let stoneStr = String(stone)
                    let splitIdx = stoneStr.count / 2

                    let leftStr = stoneStr.prefix(splitIdx)
                    let rightStr = stoneStr.suffix(splitIdx)

                    newStones[0+indexModifier] = Int(leftStr)!
                    indexModifier += 1
                    if 0+indexModifier < newStones.count {
                        newStones[0+indexModifier] = Int(rightStr)!
                        //  newStones.append(-1) // this is to make room for the rest of the array as we work through our stones
                    } else {
                        newStones.append(Int(rightStr)!)
                    }
                } else {
                    //If none of the other rules apply, the stone is replaced by a new stone; the old stone's number multiplied by 2024 is engraved on the new stone.
                    newStones[0+indexModifier] = stone * 2024
                }
            for stone in newStones {
                let result = recursiveBlink(stone: stone, blinks: blinksToGo)
             //   print("stone \(stone) blinks \(blinksToGo) = \(result)")
                resultCache[Stone(value: stone, blinks: blinksToGo)] = result
                total += result
            }
        }
        return total
    }
    var count = 0

    for stone in stones {
        let results = recursiveBlink(stone: stone, blinks: 75)
        count += results
    }

    print("after 75 blinks, count = \(count)") // 25 = 194557
    // count = 1219422435403264 is too high
}

