//
//  day6.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/5/24.
//

import Foundation

func day6() {
    let input = readInput(forDay: 6)

    var baseMap: [[String]] = []
    var startingPos: Coord = Coord(x: -1, y: -1)
    var guardPos: Coord = Coord(x: -1, y: -1) // dunno, yet
    var guardFacing: Direction = .North
    // parse the map!
    let lines = input.split(separator:"\n")

    for line in lines {
        var row: [String] = []
        for char in line {
            row.append(String(char))
        }
        baseMap.append(row)
    }

    // these are actually 1 greater, but the duck operator makes that fine.
    let maxY = baseMap.count
    let maxX = baseMap[0].count

    // origin is top left and increases right and downwards, so all coords should be positive
    for y in 0..<maxY {
        for x in 0..<maxX {
            if baseMap[y][x] == "^" { //assuming our guard will start facing North.
                startingPos = Coord(x: x, y: y)
                guardPos = startingPos
            }
        }
    }

    assert(guardPos.x != -1 && guardPos.y != -1)

    var guardPath: Set<Coord> = Set()
    guardPath.insert(guardPos)
    var loopTracking: Set<Motion> = Set()
    loopTracking.insert(Motion(position: guardPos, facing: guardFacing))
    // part 1
    func navigatePatrol(in map: [[String]]) -> Bool { // returns false if we loop and thus can never escape (for part 2)
        while true {
            //while the guard is still wandering the path...
            guard guardPos.x >= 0 && guardPos.x < maxX else { return true }
            guard guardPos.y >= 0 && guardPos.y < maxY else { return true }

            // walk forward unless you can't
            let nextSpotForward: Coord
            switch guardFacing {
            case .North:
                nextSpotForward = Coord(x: guardPos.x, y: guardPos.y-1)
            case .East:
                nextSpotForward = Coord(x: guardPos.x+1, y: guardPos.y)
            case .South:
                nextSpotForward = Coord(x: guardPos.x, y: guardPos.y+1)
            case .West:
                nextSpotForward = Coord(x: guardPos.x-1, y: guardPos.y)

            default:
                nextSpotForward = Coord(x: -1, y: -1)
                assertionFailure("guards don't move on diagonals")
            }
            if nextSpotForward.x >= 0 && nextSpotForward.x < maxX && nextSpotForward.y >= 0 && nextSpotForward.y < maxY { // next step would still be on the map
                let contains = map[nextSpotForward.y][nextSpotForward.x]
                switch contains {
                case ".", "^": // free space,move fwd.
                    guardPos = nextSpotForward
                    guardPath.insert(guardPos)
                    let newMotion = Motion(position: guardPos, facing: guardFacing)
                    if loopTracking.contains(newMotion) {
                        return false
                    } else {
                        loopTracking.insert(newMotion)
                    }
                case "#": // obstacle! update facing
                    guardFacing = guardFacing.turnRight()
                    let newMotion = Motion(position: guardPos, facing: guardFacing)
                    if loopTracking.contains(newMotion) {
                        return false
                    } else {
                        loopTracking.insert(newMotion)
                    }
                default:
                    assertionFailure("what is on our map other than us?")
                }
            } else { return true } // we done!
        }
    }

    let _ = navigatePatrol(in: baseMap)
    print("guard stepped in \(guardPath.count) spaces")
    let cannonicalGuardPath = guardPath

    // part 2
    // now we can tell WHEN we loop, lets make it happen.
//    var loopCount = 0
//    for y in 0..<maxY {
//        for x in 0..<maxX {
//            // reset out tracking
//            guardPos = startingPos
//            guardFacing = .North
//            loopTracking = Set()
//            
//            var newMap = baseMap
//            let currentItem = baseMap[y][x]
//            switch currentItem {
//            case ".":
//                newMap[y][x] = "#"
//                if !navigatePatrol(in: newMap) {
//                    loopCount = loopCount + 1
//                }
//            default:
//                continue
//            }
//        }
//    }
//    print("in \(loopCount) cases, the guard gets stuck in a loop")

    // part 2, part 2, the not-lazy way
    var loopCount = 0
    for coord in cannonicalGuardPath {
        // reset out tracking
        guardPos = startingPos
        guardFacing = .North
        loopTracking = Set()
        guardPath = Set() // this isn't actually important, but for the sake of tidiness

        var newMap = baseMap
        let currentItem = baseMap[coord.y][coord.x]
        switch currentItem {
        case ".":
            newMap[coord.y][coord.x] = "#"
            if !navigatePatrol(in: newMap) {
                loopCount = loopCount + 1
            }
        default:
            continue
        }
    }
    print("in \(loopCount) cases, the guard gets stuck in a loop")

}
