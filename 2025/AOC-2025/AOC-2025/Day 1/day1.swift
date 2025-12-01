//
//  day1.swift
//  AOC-2025
//
//  Created by Rachael Worthington on 11/30/25.
//

import Foundation

func day1()
{
    let input = readInput(forDay: 1)
    var currentDigit = 50
    var zeroCount = 0

    let actions = input.split(separator: "\n")
    for act in actions {
        var action = act
        let dir = action.removeFirst()
        let result = Int(action)!.quotientAndRemainder(dividingBy: 100)
        let movement = result.remainder
        let quotient = result.quotient
        zeroCount += quotient
        if dir == "L" {
            if currentDigit > movement {
                currentDigit = currentDigit - movement
            } else {
                let oldCurrDig = currentDigit
                currentDigit = 100 - (movement - currentDigit)
                if currentDigit == 100 {
                    currentDigit = 0
                }
                if oldCurrDig != 0 {
                    zeroCount += 1
                }
            }
        } else if dir == "R" {
            if currentDigit + movement <= 99 {
                currentDigit = currentDigit + movement
            } else {
                let oldCurrDig = currentDigit
                currentDigit = movement - (100 - currentDigit)
                if oldCurrDig != 0 {
                    zeroCount += 1
                }
            }
        }
    }

    print("zero total: \(zeroCount)")

}
