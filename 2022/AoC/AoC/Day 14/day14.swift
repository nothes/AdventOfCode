//
//  day14.swift
//  AoC
//
//  Created by Rachael Worthington on 12/13/22.
//

import Foundation

func day14() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 14/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
        pullTheLever()
    } catch {
        print(error.localizedDescription)
    }
}

enum Material {
    case air
    case stone
    case sand
}

extension Coord {
    func coordBelow() -> Coord {
        return Coord(x: x, y: y + 1)
    }

    func coordDownLeft() -> Coord {
        return Coord(x: x - 1, y: y + 1)
    }

    func coordDownRight() -> Coord {
        return Coord(x: x + 1, y: y + 1)
    }
}

class Room {
    var walls: Set<Coord>
    var sand: Set<Coord>
    private var lowestWall: Int
    private var floor: Int
    private var part1: Bool = true

    init(walls: [[Coord]] = [], sand: Set<Coord> = Set()) {
        part1 = false
        self.sand = sand
        self.sand.insert(Coord(x: 500, y: 0)) // sand starts here.
        self.walls = Set()
        self.lowestWall = 0 // this is the upper limit to our map, so any wall should hopefully appear underneath here, or
        self.floor = 0
        processWalls(walls)
    }

    func processWalls(_ walls: [[Coord]]) {
        for wall in walls {
            let pointCount = wall.count // how many points define the wall
            assert(pointCount >= 2) // can't have a line w/o 2 points.

            for i in 0 ..< pointCount - 1 {
                let point1 = wall[i]
                let point2 = wall[i+1]

                let range: ClosedRange<Int>

                // is this an x-aligned wall
                if point1.y == point2.y {
                    if point1.x < point2.x {
                        range = point1.x ... point2.x
                    } else {
                        range = point2.x ... point1.x
                    }
                    for x in range {
                        if lowestWall < point1.y {
                            lowestWall = point1.y
                        }
                        self.walls.insert(Coord(x: x, y: point1.y))
                    }
                } else if point1.x == point2.x {
                    if point1.y < point2.y {
                        range = point1.y ... point2.y
                    } else {
                        range = point2.y ... point1.y
                    }
                    for y in range {
                        self.walls.insert(Coord(x: point1.x, y: y))
                        if lowestWall < y {
                            lowestWall = y
                        }
                    }
                } else {
                    assertionFailure("no diagonal walls allowed!")
                }
            }
        }
        floor = lowestWall + 2
    }

    func material(at point: Coord) -> Material {
        if part1 == false && point.y >= floor {
            return .stone
        }

        if walls.contains(point) {
            return .stone
        } else if sand.contains(point) {
            return.sand
        } else {
            return.air
        }
    }

    func dropSand() -> Bool {
        var position = Coord(x: 500, y: 0)
        while true {
          //  A unit of sand always falls down one step if possible. If the tile immediately below is blocked (by rock or sand), the unit of sand attempts to instead move diagonally one step down and to the left. If that tile is blocked, the unit of sand attempts to instead move diagonally one step down and to the right. Sand keeps moving as long as it is able to do so, at each step trying to move down, then down-left, then down-right. If all three possible destinations are blocked, the unit of sand comes to rest and no longer moves, at which point the next unit of sand is created back at the source.

            // attempt to go down
            if self.material(at: position.coordBelow()) == .air {
                position = position.coordBelow()
            } else if self.material(at: position.coordDownLeft()) == .air {
                position = position.coordDownLeft()
            } else if self.material(at: position.coordDownRight()) == .air {
                position = position.coordDownRight()
            } else {
                // final sand position, we're done.
                self.sand.insert(position)
                if !part1 {
                    // we've by necessity been through this once. if the sand didn't move, we've filled up the entire space we can.
                    if position == Coord(x: 500, y: 0) {
                        return false
                    }
                }
                return true
            }

            if part1 {
                if position.y > lowestWall {
                    // we've fallen into infinity
                    return false
                }
            }
        }
    }
}

var walls: [[Coord]] = []
var room: Room = Room()
func pullTheLever() {
    var count = 0
    while room.dropSand() {
        count += 1
    }
    print("count = \(count)")
    
}

fileprivate func parseInput(_ text: String) {
    text.enumerateLines(invoking: { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            var wall: [Coord] = []
            var coords = line.split(separator: " ")
            coords.removeAll { substr in
                substr == "->"
            }
            for coord in coords {
                let values = coord.split(separator: ",")
                wall.append(Coord(x: Int(values[0])!, y: Int(values[1])!))
            }
            walls.append(wall)
        }
    })
    room.processWalls(walls)
}
