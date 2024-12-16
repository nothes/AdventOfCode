//
//  day16.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/15/24.
//

import Foundation

func day16() {
    let input = readInput(forDay: 16)
    var map: [[String]] = []
    let lines = input.split(separator: "\n")
    for line in lines {
        var row: [String] = []
        for char in line {
            let str = String(char)
            row.append(str)
        }
        map.append(row)
    }

    render2dArray(map)

    var startPosition: Coord = Coord(x: -1, y: -1)
    var endPosition: Coord = Coord(x: -1, y: -1)
    let currPosition: Motion // coord & facing

//    var walls: Set<Coord> = []
//    var spaces: Set<Coord> = []

    for y in 0..<map.count {
        for x in 0..<map[0].count {
            switch map[y][x] {
            case "S":
                startPosition = Coord(x: x, y: y)
            //    spaces.insert(Coord(x: x, y: y))
            case "E":
                endPosition = Coord(x: x, y: y)
             //   spaces.insert(Coord(x: x, y: y))
            case "#":
                let _ = 0
               // walls.insert(Coord(x: x, y: y))
            case ".":
                let _ = 0
                //spaces.insert(Coord(x: x, y: y))
            default:
                assertionFailure("extra map symbol: \(map[y][x])")
            }
        }
    }

    // Part 1

    var memoedResults: [Motion: Int] = [:]
    currPosition = Motion(position: startPosition, facing: .East)

    // The Reindeer start on the Start Tile (marked S) facing East and need to reach the End Tile (marked E). They can move forward one tile at a time (increasing their score by 1 point), but never into a wall (#). They can also rotate clockwise or counterclockwise 90 degrees at a time (increasing their score by 1000 points).

    let score = runMaze(from: currPosition, seen: [startPosition], scoreSoFar: 0, pathSoFar: [currPosition.position])
    print("final smallest score = \(score)")


    func runMaze(from currentPos: Motion, seen: Set<Coord>, scoreSoFar: Int, pathSoFar: [Coord]) -> Int { // lowest score from the choice of directions

        if currentPos.position == endPosition {
       //     print("at the end! score: \(scoreSoFar) path: \(pathSoFar)")
            return scoreSoFar // we're done!
        }

        if let result = memoedResults[currentPos] {
        //    print("found result: \(result) for \(currentPos)")
            return result
        }

        if pathSoFar.count > 10000 {
            print("long path, bailing")
            return -1
        }
        // check all 4 directions:
        let west = currentPos.position.west()
        let east = currentPos.position.east()
        let north = currentPos.position.north()
        let south = currentPos.position.south()
        var westScore = scoreSoFar
        var eastScore = scoreSoFar
        var northScore = scoreSoFar
        var southScore = scoreSoFar
        var newSeen: Set<Coord> = seen
        var newPos: Motion = currentPos
        var newPath = pathSoFar
        var scores: [Int] = []

        // West
        // handle facing change score increase
        let westPossible = /*walls.contains(west) == false*/map[west.y][west.x] != "#" && seen.contains(west) == false
        if westPossible {
            newSeen = seen
            let newPos = Motion(position: currentPos.position.west(), facing: .West)
            switch (currentPos.facing) {
            case .North:
                // turn left, step forward
                westScore += 1000 + 1
            case .South:
                // turn right, step forward
                westScore += 1000 + 1
            case .East:
                // turn twice, then step forward
                westScore += 1000 + 1000 + 1
            case .West:
                // step forward
                westScore += 1
            default:
                let _ = 0 // we don't move diagonally
            }

            newPath.append(west)
            newSeen.insert(west)
            westScore = runMaze(from: newPos, seen: newSeen, scoreSoFar: westScore, pathSoFar: newPath)
            if let memoedVal = memoedResults[newPos], westScore < memoedVal {
                memoedResults[newPos] = westScore
            }
            if westScore != -1 {
                scores.append(westScore)
            }
        }
        // East
        let eastPossible = /*walls.contains(east) == false*/map[east.y][east.x] != "#"  && seen.contains(east) == false
        if eastPossible {
            newSeen = seen
            newPos = Motion(position: currentPos.position.east(), facing: .East)

            switch (currentPos.facing) {
            case .North:
                // turn right, step forward
                eastScore += 1000 + 1
            case .South:
                // turn left, step forward
                eastScore += 1000 + 1
            case .East:
                //  step forward
                eastScore += 1
            case .West:
                // turn twice, step fwd
                eastScore += 1000 + 1000 + 1
            default:
                let _ = 0 // we don't move diagonally
            }

            newPath.append(east)
            newSeen.insert(east)
            eastScore = runMaze(from: newPos, seen: newSeen, scoreSoFar: eastScore, pathSoFar: newPath)
            if let memoedVal = memoedResults[newPos], westScore < memoedVal {
                memoedResults[newPos] = eastScore
            }
            if eastScore != -1 {
                scores.append(eastScore)
            }
        }
        // North
        let northPossible = /*walls.contains(north) == false*/map[north.y][north.x] != "#"  && seen.contains(north) == false
        if northPossible {
            newSeen = seen
            newPos = Motion(position: currentPos.position.north(), facing: .North)

            switch (currentPos.facing) {
            case .North:
                // step forward
                northScore += 1
            case .South:
                // turn twice, step forward
                northScore += 1000 + 1000 + 1
            case .East:
                //  turn left, step forward
                northScore += 1000 + 1
            case .West:
                // turn right, step fwd
                northScore += 1000 + 1
            default:
                let _ = 0 // we don't move diagonally
            }

            newPath.append(north)
            newSeen.insert(north)
            northScore = runMaze(from: newPos, seen: newSeen, scoreSoFar: northScore, pathSoFar: newPath)
            if let memoedVal = memoedResults[newPos], westScore < memoedVal {
                memoedResults[newPos] = northScore
            }
            if northScore != -1 {
                scores.append(northScore)
            }
        }

        // South
        let southPossible = /*walls.contains(south) == false*/ map[south.y][south.x] != "#"  && seen.contains(south) == false
        if southPossible {
            newSeen = seen
            newPos = Motion(position: currentPos.position.south(), facing: .South)

            switch (currentPos.facing) {
            case .North:
                // turn twice, step forward
                southScore += 1000 + 1000 + 1
            case .South:
                // turn twice, step forward
                southScore += 1
            case .East:
                //  turn right, step forward
                southScore += 1000 + 1
            case .West:
                // turn left, step fwd
                southScore += 1000 + 1
            default:
                let _ = 0 // we don't move diagonally
            }

            newPath.append(south)
            newSeen.insert(south)
            southScore = runMaze(from: newPos, seen: newSeen, scoreSoFar: southScore, pathSoFar: newPath)
            if let memoedVal = memoedResults[newPos], westScore < memoedVal {
                memoedResults[newPos] = southScore
            }
            if southScore != -1 {
                scores.append(southScore)
            }
        }

        scores.sort(by: <)
        if scores.isEmpty == false {
            return scores[0]
        } else {
            return -1 // dead end marker. no winning from this point!
        }
    }
}
