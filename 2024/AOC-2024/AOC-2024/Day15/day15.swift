//
//  day15.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/14/24.
//

import Foundation

func day15() {
    let input = readInput(forDay: 15)
    let mapNdirections = input.split(separator: "\n\n")
    var map: [[String]] = []

    let mapLines = mapNdirections[0].split(separator: "\n")
    for line in mapLines {
        var row: [String] = []
        for char in line {
            row.append(String(char))
        }
        map.append(row)
    }

    let directions = String(mapNdirections[1])

    // gather some map info
    var botCoord: Coord = Coord(x: -1, y: -1)
    var boxPositions: Set<Coord> = []
    var wallPositions: Set<Coord> = []
    for y in 0..<map.count {
        for x in 0..<map[0].count {
            switch map[y][x] {
            case "@": // bot
                botCoord = Coord(x: x, y: y)
            case "O": // box
                boxPositions.insert(Coord(x: x, y: y))
            case "#": // wall
                wallPositions.insert(Coord(x: x, y: y))
            default: // space or walls just Are
                continue
            }
        }
    }

    // part1
//    performOperations(dirs: directions)
//    calculateGPS()

    // part 2
    var wideMap = generateWideMap(map: map)

    // collect new info
    botCoord = Coord(x: -1, y: -1)
    var bigBoxPositions: Set<Box> = []
    wallPositions = []
    for y in 0..<wideMap.count {
        for x in 0..<wideMap[0].count {
            switch wideMap[y][x] {
            case "@": // bot
                botCoord = Coord(x: x, y: y)
            case "[": // box
                bigBoxPositions.insert(Box(left: Coord(x: x, y: y), right: Coord(x: x+1, y: y)))
            case "#": // wall
                wallPositions.insert(Coord(x: x, y: y))
            default: // space or walls just Are
                continue
            }
        }
    }

//    render2dArray(wideMap)
    performOperationsPt2(dirs: directions)
    calculateGPS2()

    func performOperations(dirs: String) {
        for char in dirs {
            switch char {
            case "^":
                move(dir: .North)
            case "v":
                move(dir: .South)
            case "<":
                move(dir: .West)
            case ">":
                move(dir: .East)
            case "\n":
                let _ = 0 // no op
            default:
                assertionFailure("what other direction can you go my dude?")
            }
        }
    }

    func move(dir: Direction) {
        var xDelta = 0
        var yDelta = 0
        var stuckAgainstWall = false

        switch dir {
        case .North:
            yDelta = -1
        case .South:
            yDelta = 1
        case .East:
            xDelta = 1
        case .West:
            xDelta = -1
        default:
            assertionFailure("robots don't move diagonally")
        }

        var checkCoord = Coord(x: botCoord.x+xDelta, y: botCoord.y+yDelta)
        var boxesMoved: Set<Coord> = []
        
        while (0..<map.count).contains(checkCoord.y) && (0..<map[0].count).contains(checkCoord.x) {
            if wallPositions.contains(checkCoord) {
                stuckAgainstWall = true
                break
            } else if boxPositions.contains(checkCoord) {
                // we might be able to push the box, keep going, but keep track of how many boxes we need to be able to move...
                boxesMoved.insert(checkCoord)
            } else {
                // space! we can move, along with the boxes we're pushing
                break
            }
            checkCoord = checkCoord.coordWith(yVal: checkCoord.y+yDelta).coordWith(xVal: checkCoord.x+xDelta)
        }
        if stuckAgainstWall {
            return // nothing moves
        }
        // move all the boxes we're pushing upwards 1
        boxPositions.subtract(boxesMoved)
        for box in boxesMoved {
            boxPositions.insert(box.coordWith(yVal: box.y+yDelta).coordWith(xVal: box.x+xDelta))
        }
        // move the bot
        botCoord = botCoord.coordWith(yVal: botCoord.y+yDelta).coordWith(xVal: botCoord.x+xDelta)
    }

    func calculateGPS() {
        // The GPS coordinate of a box is equal to 100 times its distance from the top edge of the map plus its distance from the left edge of the map. (This process does not stop at wall tiles; measure all the way to the edges of the map.)

        // The lanternfish would like to know the sum of all boxes' GPS coordinates after the robot finishes moving. In the larger example, the sum of all boxes' GPS coordinates is 10092. In the smaller example, the sum is 2028.
        var total = 0
        for box in boxPositions {
            let boxGPS = 100 * box.y + box.x
            total += boxGPS
        }
        print("total GPS: \(total)")
    }

    // part 2
    func generateWideMap(map:[[String]]) -> [[String]] {
        var fatMap: [[String]] = []
        for y in 0..<map.count {
            var widerMapLine:[String] = []
            for x in 0..<map[0].count {
                switch map[y][x] {
                case "#":
                    widerMapLine.append("#")
                    widerMapLine.append("#")
                case "O":
                    widerMapLine.append("[")
                    widerMapLine.append("]")
                case ".":
                    widerMapLine.append(".")
                    widerMapLine.append(".")
                case "@":
                    widerMapLine.append("@")
                    widerMapLine.append(".")

                default:
                    let _ = 1
                }
            }
            fatMap.append(widerMapLine)
        }
        return fatMap
    }

    func performOperationsPt2(dirs: String) {
        for char in dirs {
            print("moving \(char)")
            switch char {
            case "^":
                move2(dir: .North)
            case "v":
                move2(dir: .South)
            case "<":
                move2(dir: .West)
            case ">":
                move2(dir: .East)
            case "\n":
                let _ = 0 // no op
            default:
                assertionFailure("what other direction can you go my dude?")
            }
            wideMap = updateMapWithResults(with: wideMap[0].count, yCount: wideMap.count)
//            render2dArray(wideMap)
        }
    }

    func move2(dir: Direction) {
        var xDelta = 0
        var yDelta = 0
        var stuckAgainstWall = false

        switch dir {
        case .North:
            yDelta = -1
        case .South:
            yDelta = 1
        case .East:
            xDelta = 1
        case .West:
            xDelta = -1
        default:
            assertionFailure("robots don't move diagonally")
        }

        if xDelta != 0 { // left-right motion works as before.
            var checkCoord = Coord(x: botCoord.x+xDelta, y: botCoord.y+yDelta)
            var boxesMoved: Set<Box> = []

            while (0..<wideMap.count).contains(checkCoord.y) && (0..<wideMap[0].count).contains(checkCoord.x) {
                if wallPositions.contains(checkCoord) {
                    stuckAgainstWall = true
                    break
                } else {
                    // we might be able to push the box, keep going, but keep track of how many boxes we need to be able to move...
                    let foundBox = bigBoxPositions.first { box in
                        box.left == checkCoord || box.right == checkCoord
                    }
                    if let foundBox {
                        boxesMoved.insert(foundBox)
                    } else {
                        // SPACE!
                        break
                    }
                }
                checkCoord = checkCoord.coordWith(yVal: checkCoord.y+yDelta).coordWith(xVal: checkCoord.x+xDelta)
            }
            if stuckAgainstWall {
                return // nothing moves
            }
            // move all the boxes we're pushing

            bigBoxPositions.subtract(boxesMoved)
            for box in boxesMoved {
                let newBox = Box(left: box.left.coordWith(xVal: box.left.x+xDelta), right: box.right.coordWith(xVal: box.right.x+xDelta))
                bigBoxPositions.insert(newBox)
            }
            // move the bot
            botCoord = botCoord.coordWith(yVal: botCoord.y+yDelta).coordWith(xVal: botCoord.x+xDelta)
            return
        } else { // up/down movement
            var checkCoord = Coord(x: botCoord.x+xDelta, y: botCoord.y+yDelta) // the actual column the bot is in
            var checkCoords: Set<Coord> = []
            checkCoords.insert(checkCoord) // which columns we're shifting upwards due to boxes
            var boxesMoved: Set<Box> = []

            while (0..<wideMap.count).contains(checkCoord.y) && (0..<wideMap[0].count).contains(checkCoord.x) {
                if !wallPositions.intersection(checkCoords).isEmpty {
                    stuckAgainstWall = true
                    break
                } else {
                    // check for boxes
                    let bigBoxCopy = bigBoxPositions
                    let boxesAboveOrBelow = bigBoxCopy.filter { box in
                        return checkCoords.contains(box.left)  || checkCoords.contains(box.right)
                    }

                    if boxesAboveOrBelow.isEmpty {
                        // we found our space!
                        break
                    } else {
                        boxesMoved.formUnion(boxesAboveOrBelow)
                        // update checkcoords
                        var newCheckCoords: Set<Coord> = []
                        for coord in checkCoords {
                            if !(wideMap[coord.y][coord.x] == ".") {
                                newCheckCoords.insert(coord.coordWith(yVal: coord.y + yDelta))
                            }
                        }
                        checkCoords = newCheckCoords
                        // and add new ones for any new boxes we're pushing along.
                        for box in boxesAboveOrBelow {
                            checkCoords.insert(box.left.coordWith(yVal: box.left.y+yDelta))
                            checkCoords.insert(box.right.coordWith(yVal: box.right.y+yDelta))
                        }
                    }
                }
                checkCoord = checkCoord.coordWith(yVal: checkCoord.y+yDelta).coordWith(xVal: checkCoord.x+xDelta)
               // checkCoords.insert(checkCoord)
            }
            if stuckAgainstWall {
                return // nothing moves
            }
            // move all the boxes we're pushing
            bigBoxPositions.subtract(boxesMoved)
            for box in boxesMoved {
                let newBox = Box(left: box.left.coordWith(yVal: box.left.y+yDelta), right: box.right.coordWith(yVal: box.right.y+yDelta))
                bigBoxPositions.insert(newBox)
            }
            // move the bot
            botCoord = botCoord.coordWith(yVal: botCoord.y+yDelta).coordWith(xVal: botCoord.x+xDelta)
        }
    }

    struct Box: Hashable {
        let left: Coord
        let right: Coord
        func moveLeft() -> Box {
            return Box(left: left.coordWith(xVal: left.x-1), right: right.coordWith(xVal: right.x-1))
        }
        func moveRight() -> Box {
            return Box(left: left.coordWith(xVal: left.x+1), right: right.coordWith(xVal: right.x+1))
        }
        func moveUp() -> Box {
            return Box(left: left.coordWith(yVal: left.y-1), right: right.coordWith(yVal: left.y-1))
        }
        func moveDown() -> Box {
            return Box(left: left.coordWith(yVal: left.y+1), right: right.coordWith(yVal: left.y+1))
        }
    }

    func calculateGPS2() {
        // The GPS coordinate of a box is equal to 100 times its distance from the top edge of the map plus its distance from the left edge of the map. (This process does not stop at wall tiles; measure all the way to the edges of the map.)

        // The lanternfish would like to know the sum of all boxes' GPS coordinates after the robot finishes moving. In the larger example, the sum of all boxes' GPS coordinates is 10092. In the smaller example, the sum is 2028.
        var total = 0
        for box in bigBoxPositions {
            let boxGPS = 100 * box.left.y + box.left.x
            total += boxGPS
        }
        print("total GPS: \(total)")
        // 1366988 is Too Low
    }

    func updateMapWithResults(with xCount: Int, yCount: Int) -> [[String]] {
        var updatedMap: [[String]] = []
        for y in 0..<yCount {
            var updatedRow: [String] = []
            for x in 0..<xCount {
                let checkCoord = Coord(x: x, y: y)
                if wallPositions.contains(checkCoord) {
                    updatedRow.append("#")
                } else if checkCoord == botCoord {
                    updatedRow.append("@")
                } else {
                    // box fun
                    let boxOverSpot = bigBoxPositions.first { box in
                        box.left == checkCoord || box.right == checkCoord
                    }
                    if let box = boxOverSpot {
                        if box.left == checkCoord {
                            updatedRow.append("[")
                        } else if box.right == checkCoord {
                            updatedRow.append("]")
                        } else {
                            assertionFailure("wat. box rendering is weird.")
                        }
                    } else {
                        updatedRow.append(".")
                    }
                }
            }
            updatedMap.append(updatedRow)
        }

        return updatedMap
    }
}


