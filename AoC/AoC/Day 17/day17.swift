//
//  day17.swift
//  AoC
//
//  Created by Rachael Worthington on 12/16/22.
//

import Foundation

func day17() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 17/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
        simulateFallingRocks()
    } catch {
        print(error.localizedDescription)
    }
}

var wind: [Movement] = []
fileprivate func parseInput(_ text: String) {
    text.enumerateLines(invoking: { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            for windChar in line {
                if windChar == "<" {
                    wind.append(.left)
                } else {
                    wind.append(.right)
                }
            }
        }
    })
}

//The tall, vertical chamber is exactly seven units wide. Each rock appears so that its left edge is two units away from the left wall and its bottom edge is three units above the highest rock in the room (or the floor, if there isn't one).
let CHAMBER_WIDTH = 7
// After a rock appears, it alternates between being pushed by a jet of hot gas one unit (in the direction indicated by the next symbol in the jet pattern) and then falling one unit down.
// If any movement would cause any part of the rock to move into the walls, floor, or a stopped rock, the movement instead does not occur. If a downward movement would have caused a falling rock to move into the floor or an already-fallen rock, the falling rock stops where it is (having landed on something) and a new rock immediately begins falling.

//let ROCKS_DROPPED = 2022
let ROCKS_DROPPED = 1000000000000
enum Rock {
    case plus
    case horiz
    case verti
    case ell // backwards, long as tall
    case square

    static func rockOrder() -> [Rock] {
        return [.horiz, .plus, .ell, .verti, .square]
    }

    func height() -> Int {
        switch(self) {
        case .plus:
            return 3
        case .horiz:
            return 1
        case .verti:
            return 4
        case .ell:
            return 3
        case .square:
            return 2
        }
    }

    func width() -> Int {
        switch self {
        case .plus:
            return 3
        case .horiz:
            return 4
        case .verti:
            return 1
        case .ell:
            return 3
        case .square:
            return 2
        }
    }

    func occupiedCoords() -> Set<Coord> {
        // assuming it's sitting at (0,0)
        var shapeSet: Set<Coord> = Set()
        switch self {
        case .plus:
            shapeSet.insert(Coord(x: 0, y: 1))
            shapeSet.insert(Coord(x: 1, y: 0))
            shapeSet.insert(Coord(x: 1, y: 1))
            shapeSet.insert(Coord(x: 1, y: 2))
            shapeSet.insert(Coord(x: 2, y: 1))
        case .verti:
            shapeSet.insert(Coord(x: 0, y: 0))
            shapeSet.insert(Coord(x: 0, y: 1))
            shapeSet.insert(Coord(x: 0, y: 2))
            shapeSet.insert(Coord(x: 0, y: 3))
        case .horiz:
            shapeSet.insert(Coord(x: 0, y: 0))
            shapeSet.insert(Coord(x: 1, y: 0))
            shapeSet.insert(Coord(x: 2, y: 0))
            shapeSet.insert(Coord(x: 3, y: 0))
        case .ell:
            shapeSet.insert(Coord(x: 0, y: 0))
            shapeSet.insert(Coord(x: 1, y: 0)) //     x
            shapeSet.insert(Coord(x: 2, y: 0)) //     x
            shapeSet.insert(Coord(x: 2, y: 1)) // x x x
            shapeSet.insert(Coord(x: 2, y: 2))
        case .square:
            shapeSet.insert(Coord(x: 0, y: 0))
            shapeSet.insert(Coord(x: 0, y: 1))
            shapeSet.insert(Coord(x: 1, y: 0))
            shapeSet.insert(Coord(x: 1, y: 1))
        }
        return shapeSet
    }
}

extension Coord {
    static func offset(coords: Set<Coord>, by offset: Coord) -> Set<Coord> {
        var results: Set<Coord> = Set()
        for coord in coords {
            results.insert(Coord(x: coord.x + offset.x, y: coord.y + offset.y))
        }
        return results
    }

    func offset(by offset: Coord) -> Coord {
        return Coord(x: self.x + offset.x, y: self.y + offset.y)
    }
}

enum Movement {
    case left
    case right
    case down
}

func simulateFallingRocks() {
    var rockCounter = 0
    let rockOrder = Rock.rockOrder()
    func nextRock() -> Rock {
        let nextRock = rockOrder[rockCounter]
        rockCounter += 1
        if rockCounter == rockOrder.count {
            rockCounter = 0
        }
        return nextRock
    }

    var windCounter = 0
    func nextWind() -> Movement {
        let nextWind = wind[windCounter]
        windCounter += 1
        if windCounter == wind.count {
            windCounter = 0
        }
        return nextWind
    }

    func attemptMove(rock: Rock, position: Coord, direction: Movement) -> Coord { // returns new position of the rock after the movement
        let motionCoord: Coord
        // direction specific error-checking is here.
        switch(direction) {
        case .left:
            if position.x < 1 {
                //no room to move left by 1, early out
                return position
            }
            motionCoord = Coord(x: -1, y: 0)
        case .right:
            if position.x + (rock.width() - 1) > 5 {
                // no room to move right, early out
                return position
            }
            motionCoord = Coord(x: 1, y: 0)
        case .down:
            if position.y == 0 {
                // we're on the floor
                return position
            }
            motionCoord = Coord(x: 0, y: -1)
        }

        let potentialOccupiedCoords = Coord.offset(coords: Coord.offset(coords: rock.occupiedCoords(), by: motionCoord), by: position)
        if occupiedSpace.intersection(potentialOccupiedCoords).isEmpty {
            return position.offset(by: motionCoord)
        } else { // that would overlap something already in that space.
            return position
        }
    }
//   | 0,4 1,4 2,4 3,4 4,4 5,4 6,4 |
//   | 0,3 1,3 2,3 3,3 4,3 5,3 6,3 |
//   | 0,2 1,2 2,2 3,2 4,2 5,2 6,2 |
//   | 0,1 1,1 2,1 3,1 4,1 5,1 6,1 |
//   | 0,0 1,0 2,0 3,0 4,0 5,0 6,0 |
//     --  --  --  --  --  --   --    // floor is -1

    // (0,0) is the lower left corner. X -> right Y -^ upwards.
    var occupiedSpace: Set<Coord> = Set() // floor spaces 0,0 = 6,0 are empty to start
    var highestOccupiedY = -1 // the floor.
    var highestYPoints: [Int] = Array(repeating: -1, count: 7)
    // drop a rock.
    for time in 1...ROCKS_DROPPED {
        if time % 10 == 0 {
            //print ("rock \(time)")
            // purge anything below the top point in each column
            // clean up my used set
            let lowestHighestY = highestYPoints.sorted()[0]
            occupiedSpace = occupiedSpace.filter { coord in
                coord.y >= lowestHighestY
            }
            if time % 10000 == 0 {
                print("rock number \(time)")
            }
        }
        let incomingRock = nextRock()
        var rockPos = Coord(x:2, y: highestOccupiedY + 4) // position of block's lower-left edge of the grid
//        print("new rock \(incomingRock) at position: \(rockPos)")
        var rockHasLanded = false
        while !rockHasLanded {
            // 1. apply wind
            switch nextWind() {
            case .left:
                // attempt to move the block left.
                rockPos = attemptMove(rock: incomingRock, position: rockPos, direction: .left)
//                print("pushed left, new position: \(rockPos)")
            case .right:
                // attempt to move right
                rockPos = attemptMove(rock: incomingRock, position: rockPos, direction: .right)
//                print("pushed right, new position: \(rockPos)")
            default:
                assertionFailure("wind cannot blow downwards. stop it.")
            }
            // 2. move down
            let newRockPos = attemptMove(rock: incomingRock, position: rockPos, direction: .down)
            if newRockPos == rockPos { // we cannot fall any farther
                rockHasLanded = true
//                print("landed at position: \(rockPos)")
                //update maxY's...
                let finalPositions = Coord.offset(coords: incomingRock.occupiedCoords(), by: rockPos)
                for x in rockPos.x ... rockPos.x + (incomingRock.width() - 1) {
                    var xposes = Array(finalPositions.filter { coord in
                        coord.x == x
                    })
                    if !xposes.isEmpty {
                        xposes.sort { coord1, coord2 in
                            coord1.y > coord2.y
                        }
                        highestYPoints[x] = max(highestYPoints[x], xposes[0].y)
                    }
                }
                occupiedSpace.formUnion(finalPositions)
                highestOccupiedY = max(rockPos.y + (incomingRock.height() - 1), highestOccupiedY)

            } else {
                rockPos = newRockPos
//                print("dropped down, new position: \(rockPos)")
            }
        }
    }
    print("highest point in the stack = \(highestOccupiedY + 1)") // since my coord are 0-based, gotta increase 1 to talk about height
}
