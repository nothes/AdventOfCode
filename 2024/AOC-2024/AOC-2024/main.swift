//
//  main.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/1/24.
//

import Foundation

day17()

func readInput(forDay day: Int) -> String {
    let path = "/Users/rachael/Documents/AoC-remote/2024/AOC-2024/AOC-2024/Day\(day)/input.txt"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        return text
    } catch {
        print(error.localizedDescription)
    }
    return ""
}

enum Direction: CaseIterable {
    case North
    case NorthEast
    case East
    case SouthEast
    case South
    case SouthWest
    case West
    case NorthWest

    func turnLeft() -> Direction {
        // assume a 90 degree turn
        switch self {
        case .North:
            return .West
        case .NorthEast:
            return .NorthWest
        case .East:
            return .North
        case .SouthEast:
            return .NorthEast
        case .South:
            return .East
        case .SouthWest:
            return .SouthEast
        case .West:
            return .South
        case .NorthWest:
            return .SouthWest
        }
    }

    func turnRight() -> Direction {
        switch self {
        case .North:
            return .East
        case .NorthEast:
            return .SouthEast
        case .East:
            return .South
        case .SouthEast:
            return .SouthWest
        case .South:
            return .West
        case .SouthWest:
            return .NorthWest
        case .West:
            return .North
        case .NorthWest:
            return .NorthEast
        }
    }
}

struct Coord: Hashable, CustomDebugStringConvertible {
    var debugDescription: String {
        "(\(x), \(y))"
    }

    let x: Int
    let y: Int

    func coordWith(xVal: Int) -> Coord {
        return Coord(x: xVal, y: y)
    }

    func coordWith(yVal: Int) -> Coord {
        return Coord(x: x, y: yVal)
    }

    func north() -> Coord {
        return Coord(x: x, y: y - 1)
    }

    func south() -> Coord {
        return Coord(x: x, y: y+1)
    }

    func east() -> Coord {
        return Coord(x: x+1, y: y)
    }

    func west() -> Coord {
        return Coord(x: x-1, y: y)
    }
}

struct FloatCoord: Hashable, CustomDebugStringConvertible {
    var debugDescription: String {
        "(\(x), \(y))"
    }

    let x: Float
    let y: Float

    func coordWith(xVal: Float) -> FloatCoord {
        return FloatCoord(x: xVal, y: y)
    }

    func coordWith(yVal: Float) -> FloatCoord {
        return FloatCoord(x: x, y: yVal)
    }
}

struct Motion: Hashable {
    let position: Coord
    let facing: Direction
}

func render2dArray(_ map: [[Any]]) {
    for y in 0..<map.count {
        var rowString = ""
        for x in 0..<map[0].count {
            rowString.append(String(describing: map[y][x]))
        }
        print(rowString)
    }
}
