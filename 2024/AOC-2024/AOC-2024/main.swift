//
//  main.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/1/24.
//

import Foundation

day9()

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

struct Coord: Hashable {
    let x: Int
    let y: Int

    func coordWith(xVal: Int) -> Coord {
        return Coord(x: xVal, y: y)
    }

    func coordWith(yVal: Int) -> Coord {
        return Coord(x: x, y: yVal)
    }
}

struct Motion: Hashable {
    let position: Coord
    let facing: Direction
}
