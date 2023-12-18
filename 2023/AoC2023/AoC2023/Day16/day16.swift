//
//  day16.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/17/23.
//

import Foundation

func day16() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day16/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        parseMirrorRoom(with: text)
        // part 1
        //countEnergizedRooms(startingAt: (0,0, .right))
        // part 2
        bestBeamStartingCoord()
    } catch {
        print(error.localizedDescription)
    }
}

var room: [[Space]] = []

func parseMirrorRoom(with input: String) {
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            var row: [Space] = []
            for char in line {
                switch char {
                case ".":
                    row.append(Space())
                case "\\":
                    row.append(RoomMirror(forward: false))
                case "/":
                    row.append(RoomMirror(forward: true))
                case "|":
                    row.append(Splitter(horizontal: false))
                case "-":
                    row.append(Splitter(horizontal: true))
                default:
                    assertionFailure("bad input")
                }
            }
            room.append(row)
        }
    }
}

func countEnergizedRooms(startingAt beam: (Int, Int, Direction)) -> Int {
    // note beam enters from upper left corner travelling right.
    //traverseRooms
    followBeam(beam) // light starts in the upper left, travelling right

    var energized = 0
    for row in room {
        for space in row {
            if space.count > 0 {
                energized = energized + 1
            }
        }
    }
  //  print("energized: \(energized)")
    return energized
}

func bestBeamStartingCoord() {
    let yMax = room.count - 1
    let xMax = room[0].count - 1

    var results: [(x: Int, y: Int, dir: Direction, energ:Int)] = []
    //left edge
    print("Left Edge: ")
    for y in 0...yMax {
        let result = countEnergizedRooms(startingAt: (0, y, .right))
        print("going from (0, \(y)), right = \(result)")
        results.append((0, y, .right, result))
        resetRoom()
    }
    print("Right Edge: ")
    //right
    for y in 0...yMax {
        let result = countEnergizedRooms(startingAt: (xMax, y, .left))
        print("going from (\(xMax), \(y)), left = \(result)")
        results.append((xMax, y, .left, result))
        resetRoom()
    }
    print("Top Edge: ")
    //top
    for x in 0...xMax {
        let result = countEnergizedRooms(startingAt: (x, 0, .down))
        print("going from (\(x), \(0)), down = \(result)")
        results.append((x, 0, .down, result))
        resetRoom()
    }
    print("Bottom Edge: ")
    //bottom
    for x in 0...xMax {
        let result = countEnergizedRooms(startingAt: (x, yMax, .up))
        print("going from (\(x), \(yMax)), up = \(result)")
        results.append((x, yMax, .up, result))
        resetRoom()
    }

    //sort
    results.sort { result1, result2 in
        return result1.energ > result2.energ
    }

    print(results[0])
}

func coord(from startCoord: (x: Int, y: Int), in dir: Direction) -> (x: Int, y: Int) {
    switch dir {
    case .up:
        return (startCoord.x, startCoord.y - 1)
    case .down:
        return (startCoord.x, startCoord.y + 1)
    case .left:
        return (startCoord.x - 1, startCoord.y)
    case .right:
        return (startCoord.x + 1, startCoord.y)
    default:
        return (0,0)
    }
}

func followBeam(_ beam: (x: Int, y: Int, dir: Direction)) { //recursive beam-tracing
    if beam.x < 0 || beam.x == room[0].count || beam.y < 0 || beam.y == room.count {
        return
    }
    let currentSpace = room[beam.y][beam.x]
    if currentSpace.enteredFromDirs.contains(beam.dir) { return } // loop
    currentSpace.count = currentSpace.count + 1
    currentSpace.enteredFromDirs.insert(beam.dir)

    let newDir = currentSpace.outputDirections(for: beam.dir)
    for dir in newDir {
        let nextSpace = coord(from: (beam.x, beam.y), in: dir)
       followBeam((x: nextSpace.x, y: nextSpace.y, dir: dir))
    }
}

func resetRoom() {
    let yMax = room.count - 1
    let xMax = room[0].count - 1

    for x in 0...xMax {
        for y in 0...yMax {
            room[y][x].count = 0
            room[y][x].enteredFromDirs = Set()
        }
    }
}

class Space: CustomDebugStringConvertible {
    var count: Int = 0 // times the beam enters
    var enteredFromDirs: Set<Direction> = Set()

    func outputDirections(for inputDirection: Direction) -> [Direction] {
        return [inputDirection] // spaces without mirrors or splitters continue onwards.
    }

    var debugDescription: String {
        "count: \(count)"
    }
}

class RoomMirror: Space {
    let forward: Bool // forward slash: /, backslash: \

    init(forward: Bool) {
        self.forward = forward
    }

    override func outputDirections(for inputDirection: Direction) -> [Direction] {
        switch inputDirection {
        case .up:
            if forward {
                return [.right]
            } else {
                return [.left]
            }
        case .down:
            if forward {
                return [.left]
            } else {
                return [.right]
            }
        case .left:
            if forward { // /
                return [.down]
            } else {
                return [.up]
            }
        case .right:
            if forward {
                return [.up]
            } else {
                return [.down]
            }
        case .wall:
            return [.wall]
        }
    }

    override var debugDescription: String {
        "mirror " + (forward ? "(/)" : "(\\)") + super.debugDescription
    }

}

class Splitter: Space {
    let horizontal: Bool

    init(horizontal: Bool) {
        self.horizontal = horizontal
    }

    override func outputDirections(for inputDirection: Direction) -> [Direction] {
        switch inputDirection {
        case .up:
            if horizontal {
                return [.left, .right]
            } else {
                return [.up]
            }
        case .down:
            if horizontal {
                return [.left, .right]
            } else {
                return [.down]
            }
        case .left:
            if horizontal {
                return [.left]
            } else {
                return [.up, .down]
            }
        case .right:
            if horizontal {
                return [.right]
            } else {
                return [.up, .down]
            }
        case .wall:
            return [.wall]
        }
    }

    override var debugDescription: String {
        "splitter " + (horizontal ? "(-)" : "(|)") + super.debugDescription
    }

}
