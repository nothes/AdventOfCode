//
//  day24.swift
//  AoC
//
//  Created by Rachael Worthington on 12/23/22.
//

import Foundation

func day24() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 24/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
        //rideTheStorm()
        rideTheStormThrice()
    } catch {
        print(error.localizedDescription)
    }
}

var board: Board = Board()
fileprivate func parseInput(_ text: String) {
    var storms: [Storm] = []
    var walls: [Coord] = []
    var startPosition: Coord = Coord(x: 0, y: 0)
    var endPosition: Coord = Coord(x: 0, y: 0)

    var x = 0
    var y = 0
    var notedEmptySpot:Coord = Coord(x: 0, y: 0)
    text.enumerateLines(invoking: { line, stop in
        x = 0
        if line.isEmpty == false { // stop forgetting this.
            for char in line {
                if char == "#" {
                    walls.append(Coord(x: x, y: y))
                } else if char != "." {
                    storms.append(Storm(terrain: Terrain(rawValue: char)!, location: Coord(x: x, y: y)))
                } else {
                    if y == 0 {
                        startPosition = Coord(x: x, y: y)
                    } else {
                        notedEmptySpot = Coord(x: x, y: y)
                    }
                }
                x += 1
            }
        }
        y += 1
    })
    endPosition = notedEmptySpot

    board.maxX = x - 1 // zero indexed.
    board.maxY = y - 1
    board.walls = walls
    board.storms = storms
    board.startPosition = startPosition
    board.endPosition = endPosition
}

enum Terrain: Character {
    case wall = "#"
    case westStorm = "<"
    case eastStorm = ">"
    case northStorm = "^"
    case southStorm = "v"

    func isStorm() -> Bool {
        switch self {
        case .wall:
            return false
        default:
            return true
        }
    }

    func isWall() -> Bool {
        switch self {
        case .wall:
            return true
        default:
            return false
        }
    }
}

class Storm: CustomStringConvertible {
    var terrain: Terrain
    var location: Coord
    var direction: Direction

    init(terrain: Terrain, location: Coord) {
        self.terrain = terrain
        self.location = location
        switch terrain {
        case .westStorm:
            self.direction = .west
        case .eastStorm:
            self.direction = .east
        case .northStorm:
            self.direction = .north
        case .southStorm:
            self.direction = .south
        default:
            assertionFailure("rogue storm direction")
            self.direction = .none
        }
    }

    var description: String {
        return "\(location) moving \(direction)"
    }
}

class Board {
    var walls: [Coord]
    var storms: [Storm]
    var startPosition: Coord
    var endPosition: Coord
    var maxX: Int = 0
    var maxY: Int = 0

    init() {
        self.walls = []
        self.storms = []
        self.startPosition = Coord(x: -1, y: -1)
        self.endPosition = Coord(x: -1, y: -1)
    }

    func updateStorms() {
        for storm in storms {
            var newLocation = storm.location
            switch storm.direction {
            case .west:
                 newLocation = storm.location.west
                if walls.contains(newLocation) { // we're crossing a wall, loop to the beginning
                    newLocation = Coord(x: board.maxX - 1 , y: storm.location.y)
                }
//                print("<<<west storm moving from \(storm.location) to \(newLocation)")
            case .east:
                newLocation = storm.location.east
               if walls.contains(newLocation) { // we're crossing a wall, loop to the beginning
                   newLocation = Coord(x: 1 , y: storm.location.y)
               }
//                print(">>>east storm moving from \(storm.location) to \(newLocation)")
            case .north:
                newLocation = storm.location.north
               if walls.contains(newLocation) { // we're crossing a wall, loop to the beginning
                   newLocation = Coord(x: storm.location.x , y: board.maxY - 1)
               }
//                print("^^^north storm moving from \(storm.location) to \(newLocation)")
          case .south:
                newLocation = storm.location.south
               if walls.contains(newLocation) { // we're crossing a wall, loop to the beginning
                   newLocation = Coord(x: storm.location.x , y: 1)
               }
//                print("vvvsouth storm moving from \(storm.location) to \(newLocation)")
            default:
                assertionFailure("not a storm, laaame.")
            }
            storm.location = newLocation
        }
    }

    func isWall(at coord: Coord) -> Bool {
        if coord == endPosition || coord == startPosition {
            return false
        }
        if (coord.x == 0 || coord.x == maxX || coord.y == 0 || coord.y == maxY ) {
            return true
        } else {
            return false
        }
    }
}

func rideTheStorm() {
    var positions:Set<Coord> = Set(arrayLiteral: board.startPosition)
    print("starting at: \(positions)")
    var time: Int = 0
    while true {
        time += 1
        var newPositions: Set<Coord> = Set()
        // first: move the storms (technically we all move at once, but we have to know where they are to figure out our options.
        board.updateStorms()
        // next: what options are there, for each potential path?
        for position in positions {
            //1. stay still
            if board.storms.filter({ storm in
                return storm.location == position
            }).isEmpty {
                newPositions.insert(position)
            }
            var potentialPosition = position.west
            // move any of the 4 directions:
            if board.storms.filter({ storm in
                return storm.location == potentialPosition
            }).isEmpty && !board.isWall(at: potentialPosition) {
                newPositions.insert(potentialPosition)
            }
            potentialPosition = position.east
            if board.storms.filter({ storm in
                return storm.location == potentialPosition
            }).isEmpty && !board.isWall(at: potentialPosition) {
                newPositions.insert(potentialPosition)
            }
            potentialPosition = position.north
            if board.storms.filter({ storm in
                return storm.location == potentialPosition
            }).isEmpty && !board.isWall(at: potentialPosition) {
                newPositions.insert(potentialPosition)
            }
            potentialPosition = position.south
            let filteredStorms = board.storms.filter({ storm in
                return storm.location == potentialPosition
            })

            if filteredStorms.isEmpty && !board.isWall(at: potentialPosition) {
                newPositions.insert(potentialPosition)
            }
        }
        newPositions = newPositions.filter { coord in
            return coord.x >= 0 && coord.y >= 0
        }

        newPositions = newPositions.filter { coord in
            return coord.x <= board.maxX && coord.y <= board.maxY
        }
        if newPositions.contains(board.endPosition) {
            print("arrived at end in \(time) minutes")
            return
        }

        positions = newPositions
        newPositions = Set()
       // print("*** after minute \(time), going to \(board.endPosition)")
       // print("positions: \(positions)")
    }
}

func rideTheStormThrice() {
    print("going from \(board.startPosition) to \(board.endPosition)")
    rideTheStorm()
    var firstEnd = board.endPosition
    board.endPosition = board.startPosition
    board.startPosition = firstEnd
    print("going from \(board.startPosition) to \(board.endPosition)")
    rideTheStorm()
    firstEnd = board.endPosition
    board.endPosition = board.startPosition
    board.startPosition = firstEnd
    print("going from \(board.startPosition) to \(board.endPosition)")
    rideTheStorm()
}
