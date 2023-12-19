//
//  day10.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/9/23.
//

import Foundation

func day10() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day10/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        parseTubes(with: text)
        // part 1
        measureTubeDistance()
//        // part 2
//        findPreviousSequences()

    } catch {
        print(error.localizedDescription)
    }
}

var startPosition: (row: Int, column: Int) = (-1, -1) // (row, column)
var tubes: [[Tube]] = []

enum Tube: String {
    case vert = "|"
    case horiz = "-"
    case Lcorner = "L"
    case Jcorner = "J"
    case Fcorner = "F"
    case SevenCorner = "7"
    case empty = "."
    case start = "S"

    func exitDirection(entering enterDir: Direction) -> Direction {
        switch self {
        case .vert:
            if enterDir == .up {
                return .up
            } else if enterDir == .down {
                return .down
            } else {
                return .wall
            }
        case .horiz:
            if enterDir == .left {
                return .left
            } else if enterDir == .right {
                return .right
            } else {
                return .wall
            }
        case .Lcorner:
            if enterDir == .down {
                return .right
            } else if enterDir == .left {
                return .up
            } else {
                return .wall
            }
        case .Jcorner:
            if enterDir == .down {
                return .left
            } else if enterDir == .right {
                return .up
            } else {
                return .wall
            }
        case .Fcorner:
            if enterDir == .up {
                return .right
            } else if enterDir == .left {
                return .down
            } else {
                return .wall
            }
        case .SevenCorner: //'7'
            if enterDir == .right {
                return .down
            } else if enterDir == .up {
                return .left
            } else {
                return .wall
            }
        case .empty:
            return .wall
        case .start:
            return .wall
        }
    }
}

func position(for coord: (row: Int, column: Int), in direction: Direction) -> (Int, Int) { //lazy no error checking for this.
    switch direction {
    case .up:
        return (coord.row - 1, coord.column)
    case .down:
        return (coord.row + 1, coord.column)
    case .left:
        return (coord.row, coord.column - 1)
    case .right:
        return (coord.row, coord.column + 1)
    case .wall:
        return coord
    }
}

func parseTubes(with input: String) {
    var rowCount = 0
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            var row: [Tube] = []
            var column = 0
            for char in line {
                row.append(Tube(rawValue: String(char))!)
                if char == "S" {
                    startPosition = (rowCount, column)
                }
                column = column + 1
            }
            tubes.append(row)
            rowCount = rowCount + 1
            column = 0
        }
    }
}

enum Direction: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .up:
            return "up"
        case .down:
            return "down"
        case .left:
            return "left"
        case .right:
            return "right"
        case .wall:
            return "wall"
        }
    }

    case up
    case down
    case left
    case right
    case wall // error state, you're trying to walk through a wall, yo.
}

func measureTubeDistance() {
    let mapRows = tubes.count
    let mapColumns = tubes[0].count

    var distance = 0
    var direction: Direction = .wall // entry direction
    var currentPosition = startPosition
    //we know that we have a Start position, with 2 ways into it. so lets find one.
    //start checking up

    // Up
    if startPosition.row > 0 && tubes[startPosition.row-1][startPosition.column] == .vert {
        //we're in the tube, enter from bottom, exit through top
        direction = .up
        currentPosition = position(for: startPosition, in: .up)
    } else if startPosition.row > 0 && tubes[startPosition.row-1][startPosition.column] == .Fcorner {
        //we're in the tube, enter from bottom, exit through right
        direction = .up
        currentPosition = position(for: startPosition, in: .up)
    } else if startPosition.row > 0 && tubes[startPosition.row-1][startPosition.column] == .SevenCorner { // '7'
        //we're in the tube, enter from bottom, exit through left
        direction = .up
        currentPosition = position(for: startPosition, in: .up)
    } // Down
    else if startPosition.row < mapRows - 1 && tubes[startPosition.row + 1][startPosition.column] == .vert {
        // enter through top, exit through bottom
        direction = .down
        currentPosition = position(for: startPosition, in: .down)
    } else if startPosition.row < mapRows - 1 && tubes[startPosition.row + 1][startPosition.column] == .Lcorner {
        // enter through top, exit through right
        direction = .down
        currentPosition = position(for: startPosition, in: .down)
    } else if startPosition.row < mapRows - 1 && tubes[startPosition.row + 1][startPosition.column] == .Jcorner {
        // enter through top, exit through bottom
        direction = .down
        currentPosition = position(for: startPosition, in: .down)
    } // Left
    else if startPosition.column > 0 && tubes[startPosition.row][startPosition.column - 1] == .horiz {
        direction = .left
        currentPosition = position(for: startPosition, in: .left)
    } else if startPosition.column > 0 && tubes[startPosition.row][startPosition.column - 1] == .Lcorner {
        direction = .left
        currentPosition = position(for: startPosition, in: .left)
    } else if startPosition.column > 0 && tubes[startPosition.row][startPosition.column - 1] == .Fcorner {
        direction = .left
        currentPosition = position(for: startPosition, in: .left)
    } // Right
    else if startPosition.column < mapColumns - 1 && tubes[startPosition.row][startPosition.column + 1] == .horiz {
        direction = .right
        currentPosition = position(for: startPosition, in: .right)
    } else if startPosition.column < mapColumns - 1 && tubes[startPosition.row][startPosition.column + 1] == .Jcorner {
        direction = .right
        currentPosition = position(for: startPosition, in: .right)
    } else if startPosition.column < mapColumns - 1 && tubes[startPosition.row][startPosition.column + 1] == .SevenCorner {
        direction = .right
        currentPosition = position(for: startPosition, in: .right)
    }
    distance = 1 // first step.

    // I know have a direction to go, and know which way I will exit it.
    while tubes[currentPosition.row][currentPosition.column] != .start {
        print("currently in \(tubes[currentPosition.row][currentPosition.column]), going \(direction)")
        switch tubes[currentPosition.row][currentPosition.column] {
        case .vert:
            switch direction {
            case .up:
                direction = .up
            case .down:
                direction = .down
            default:
                assertionFailure("ow, a wall")
            }
        case .horiz:
            switch direction {
            case .left:
                direction = .left
            case .right:
                direction = .right
            default:
                assertionFailure("ow, a wall")
            }
        case .Lcorner:
            switch direction {
            case .left:
                direction = .up
            case .down:
                direction = .right
            default:
                assertionFailure("ow, a wall")
            }
        case .Jcorner:
            switch direction {
            case .down:
                direction = .left
            case .right:
                direction = .up
            default:
                assertionFailure("ow, a wall")
            }
        case .Fcorner:
            switch direction {
            case .left:
                direction = .down
            case .up:
                direction = .right
            default:
                assertionFailure("ow, a wall")
            }
        case .SevenCorner: // '7'
            switch direction {
            case .right:
                direction = .down
            case .up:
                direction = .left
            default:
                assertionFailure("ow, a wall")
            }
        case .empty:
            assertionFailure("ow, a wall")
        case .start:
            assertionFailure("i went past my stop condition")
        }
        currentPosition = position(for: currentPosition, in: direction)
        distance = distance + 1
    }

    print("full tube distance = \(distance), midpoint = \(distance / 2)")
}
