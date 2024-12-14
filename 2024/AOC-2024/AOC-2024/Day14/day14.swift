//
//  day14.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/13/24.
//

import Foundation
import RegexBuilder
import AppKit

func day14() {
    let input = readInput(forDay: 14)
    let boardDimensions = Coord(x: 101, y: 103)
//    let boardDimensions = Coord(x: 11, y: 7)

    let robotPattern = Regex {
        One("p=") // Position - must be positive
        Capture { // x
            OneOrMore(.digit)
        }
        One(",")
        Capture { // y
            OneOrMore(.digit)
        }
        One(" v=") // velocity - can be negative
        Capture { // x
            Optionally("-")
            OneOrMore(.digit)
        }
        One(",")
        Capture { // y
            Optionally("-")
            OneOrMore(.digit)
        }
    }

    var robots: [Robot] = []
    for line in input.split(separator: "\n") {
        if let result = line.firstMatch(of: robotPattern) {
            robots.append(Robot(position: Coord(x: Int(result.1)!, y: Int(result.2)!), velocity: Coord(x: Int(result.3)!, y: Int(result.4)!), boardSize: boardDimensions))
        }
    }

    // part 1
    // where are they in 100 seconds?
//    for robot in robots {
//        print("robot starting at \(robot.position), after 100 secs: \(robot.move(100).position)")
//    }
//    let movedBots = robots.map { robot in
//        robot.move(100)
//    }
//    print("and the safety factor = \(safetyFactor(for: movedBots))")

    // part 2
    var ttbBig = 0.0
    var ttbSmall = 0.0
    var ltrBig = 0.0
    var ltrSmall = 0.0
    var count = 0
    for i in 1...200000 {
        let newBots = robots.map { robot in
            robot.move(i)
        }
       // print("SECOND: \(i), ttb = \(ratioOfTopToBottom(for: newBots)), ltr = \(ratioOfLeftToRight(for: newBots))")
        let ttb = ratioOfTopToBottom(for: newBots)
        if ttbBig == 0 || ttb > ttbBig {
            ttbBig = ttb
        }

        if ttbSmall == 0 || ttb < ttbSmall {
            ttbSmall = ttb
        }

        let ltr = ratioOfLeftToRight(for: newBots)
        if ltrBig == 0 || ltr > ltrBig {
            ltrBig = ltr
        }
        if ltrSmall == 0 || ltr < ltrSmall {
            ltrSmall = ltr
        }
        if ttb > 3.41 {///*ttb < 0.85 &&*/ (0.9950...1.0050).contains(ltr) {
            count += 1
            print("SECOND \(i)")
            renderBoard(for: newBots)
        }
    }
    print("biggest ttb: \(ttbBig)")
    print("smallest ttb: \(ttbSmall)")
    print("biggest ltr: \(ltrBig)")
    print("smallest ltr: \(ltrSmall)")
    print("hitCount = \(count)")
    struct Robot {
        let position: Coord
        let velocity: Coord
        let boardSize: Coord

        func move(_ seconds: Int) -> Robot {
            let x = position.x + (velocity.x * seconds)
            var xRemainder = Double(x).truncatingRemainder(dividingBy: Double(boardSize.x))
            assert(xRemainder.rounded() == xRemainder)
            if xRemainder < 0 {
                xRemainder = Double(boardSize.x) + xRemainder
            }
            assert((0..<boardSize.x).contains(Int(xRemainder)))

            let y = position.y + velocity.y * seconds
            var yRemainder = Double(y).truncatingRemainder(dividingBy: Double(boardSize.y))
            assert(yRemainder.rounded() == yRemainder)
            if yRemainder < 0 {
                yRemainder = Double(boardSize.y) + yRemainder
            }
            assert((0..<boardSize.y).contains(Int(yRemainder)))

            return Robot(position: Coord(x: Int(xRemainder), y: Int(yRemainder)), velocity: velocity, boardSize: boardSize)
        }
    }

    func ratioOfTopToBottom(for bots: [Robot]) -> Double {
        let boardSize = bots[0].boardSize
        let centerY = Int(Double(boardSize.y / 2).rounded(.down))

        let topHalf = bots.filter { testBot in
            testBot.position.y < centerY
        }
        let bottomHalf = bots.filter { testBot in
            testBot.position.y > centerY
        }
        return Double(topHalf.count) / Double(bottomHalf.count)
    }

    func ratioOfLeftToRight(for bots: [Robot]) -> Double {
        let boardSize = bots[0].boardSize
        let centerX = Int(Double(boardSize.x / 2).rounded(.down))

        let leftHalf = bots.filter { testBot in
            testBot.position.x < centerX
        }
        let rightHalf = bots.filter { testBot in
            testBot.position.x > centerX
        }

        return Double(leftHalf.count) / Double(rightHalf.count)
    }


    func safetyFactor(for bots: [Robot]) -> Int {
        // To determine the safest area, count the number of robots in each quadrant after 100 seconds. Robots that are exactly in the middle (horizontally or vertically) don't count as being in any quadrant

        let boardSize = bots[0].boardSize
        let centerX = Int(Double(boardSize.x / 2).rounded(.down))
        let centerY = Int(Double(boardSize.y / 2).rounded(.down))

        // upper left
        let quadrant1Bots = bots.filter { testBot in
            testBot.position.x < centerX && testBot.position.y < centerY
        }
        // upper right
        let quadrant2Bots = bots.filter { testBot in
            testBot.position.x > centerX && testBot.position.y < centerY
        }
        // lower left
        let quadrant3Bots = bots.filter { testBot in
            testBot.position.x < centerX && testBot.position.y > centerY
        }
        // lower right
        let quadrant4Bots = bots.filter { testBot in
            testBot.position.x > centerX && testBot.position.y > centerY
        }

        return quadrant1Bots.count * quadrant2Bots.count * quadrant3Bots.count * quadrant4Bots.count
    }

    func renderBoard(for  bots: [Robot]) {
        let boardSize = bots[0].boardSize

        var positions: [Coord:Int] = [:]
        for bot in bots {
            if let _ = positions.index(forKey: bot.position) {
                positions[bot.position]! += 1
            } else {
                positions[bot.position] = 1
            }
        }

        for y in 0..<boardSize.y {
            var rowString = ""
            for x in 0..<boardSize.x {
                if let botCount = positions[Coord(x: x, y: y)] {
                    rowString.append(String(botCount))
                } else {
                    rowString.append(".")
                }
            }
            print(rowString)
        }
    }
}
