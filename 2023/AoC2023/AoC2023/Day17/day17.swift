//
//  day17.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/18/23.
//

import Foundation

func day17() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day17/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        parseNeighorhood(with: text)
        // part 1
        findWarmestPath()
        // part 2

    } catch {
        print(error.localizedDescription)
    }
}

var neighborhood: [[Int]] = []

func parseNeighorhood(with input: String) {
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            var row: [Int] = []
            for char in line {
                row.append(Int(String(char))!)
            }
            neighborhood.append(row)
        }
    }
}

var results: [CurrentState] = []
var leastMaxHeatLoss = 0

func findWarmestPath() {
    let yMax = neighborhood.count - 1
    let xMax = neighborhood[0].count - 1
    // first lets get a path that is by doing 3 right, 3 down, till we get to the end.
    var testHeatLoss = 0
    var position: (x: Int, y: Int) = (0,0)
    var rightMove = 0
    var downMove = 0
    while position != (xMax, yMax) {
//        print("position = \(position), lose \(neighborhood[position.y][position.x]), heat loss = \(testHeatLoss)")
        // we just need an initial heat-loss number to cut out absurd routes. so lets go right 3, down 3, till we get to the end.
        if rightMove < 3 && position.x < xMax {
            // move right
            position.x = position.x + 1
            testHeatLoss = testHeatLoss + neighborhood[position.y][position.x]
            rightMove = rightMove + 1
        } else if downMove < 3 && position.y < yMax {
            // move down
            position.y = position.y + 1
            testHeatLoss = testHeatLoss + neighborhood[position.y][position.x]
            downMove = downMove + 1
        }

        if downMove == 3 || position.y == yMax {
            rightMove = 0
            downMove = 0
        }
    }

    results.append(CurrentState(straightMoves: 0, enteredDir: .wall, heatLoss: testHeatLoss, position: (xMax, yMax), visitedSpaces: []))
    leastMaxHeatLoss = testHeatLoss
    print("first heat-loss value = \(leastMaxHeatLoss)")

    // basic recursive flood
    // gotta do the first move ourselves to avoid losing heat to the first square.
    let startingState1 = CurrentState(straightMoves: 1, enteredDir: .right, heatLoss: 0, position: (1, 0), visitedSpaces: [])
    let startingState2 = CurrentState(straightMoves: 1, enteredDir: .down, heatLoss: 0, position: (1, 0), visitedSpaces: [])
    recursiveNavigation(startingState1)
    recursiveNavigation(startingState2)

    results.sort { state1, state2 in
        return state1.heatLoss < state2.heatLoss
    }
    print(results.first!)
}

func recursiveNavigation(_ state: CurrentState) {
    let yMax = neighborhood.count - 1
    let xMax = neighborhood[0].count - 1
    let heatLoss = neighborhood[state.position.y][state.position.x]
    let totalHeatLoss = state.heatLoss + heatLoss

    if totalHeatLoss >= leastMaxHeatLoss {
        return //we've finished 1 path, and this one is worse than it.
    }
    // we're moving into the point in the state object
    if state.position == (xMax, yMax) {
        print("finished a path! heatLoss = \(totalHeatLoss)")
        //we've arrived, record our result, and exit.
        results.append(CurrentState(straightMoves: 0, enteredDir: .wall, heatLoss: totalHeatLoss, position: state.position, visitedSpaces: state.visitedSpaces))
        if leastMaxHeatLoss == 0 {
            leastMaxHeatLoss = totalHeatLoss
        } else {
            if totalHeatLoss < leastMaxHeatLoss {
                leastMaxHeatLoss = totalHeatLoss
            }
        }

        return
    }

    //potential next directions:
    var nextDirs: Set<Direction> = Set([.left, .up, .down, .right])
    nextDirs.remove(state.enteredDir.oppositeDir()) // can't go backwards.
    // can't go off the map
    if state.position.x == 0 {
        nextDirs.remove(.left)
    } else if state.position.x == xMax {
        nextDirs.remove(.right)
    }
    if state.position.y == 0 {
        nextDirs.remove(.up)
    } else if state.position.y == yMax {
        nextDirs.remove(.down)
    }
    // can't move forward more than 3 spaces
    if state.straightMoves == 3 {
        nextDirs.remove(state.enteredDir)
    }

    if nextDirs.isEmpty {
        return
    }
    var visitedCoords: [(x: Int, y: Int)] = state.visitedSpaces
    visitedCoords.append((state.position.x, state.position.y))

    for exitDir in nextDirs {
        let nextCoord = coord(from: state.position, in: exitDir)
        if visitedCoords.contains(where: { (x: Int, y: Int) in
            return x == nextCoord.x && y == nextCoord.y
        }) {
            //we're in a loop, just stop.
            return
        }

        var straightMoves = state.straightMoves
        if exitDir == state.enteredDir {
            straightMoves = straightMoves + 1
        }
        assert(straightMoves <= 3)
        recursiveNavigation(CurrentState(straightMoves: straightMoves, enteredDir: exitDir, heatLoss: totalHeatLoss, position: nextCoord, visitedSpaces: visitedCoords))
    }
}

struct CurrentState: CustomDebugStringConvertible {
    let straightMoves: Int
    let enteredDir: Direction
    let heatLoss: Int
    let position: (x: Int, y: Int)
    let visitedSpaces: [(x: Int, y: Int)]

    var debugDescription: String {
        return "position: (\(position.x), \(position.y)), heatLoss: \(heatLoss)"
    }

}

extension Direction {
    func oppositeDir() -> Direction {
        switch self {
        case .up:
            return .down
        case .down:
            return .up
        case .left:
            return .right
        case .right:
            return .left
        case .wall:
            return .wall
        }
    }
}
