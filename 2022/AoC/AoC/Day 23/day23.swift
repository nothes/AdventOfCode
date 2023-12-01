//
//  day23.swift
//  AoC
//
//  Created by Rachael Worthington on 12/22/22.
//

import Foundation

func day23() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 23/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
        simulateElvenInsanity()
    } catch {
        print(error.localizedDescription)
    }
}

var elves: Dictionary<Coord, Elf> = Dictionary()
fileprivate func parseInput(_ text: String) {
    var y = 0
    text.enumerateLines(invoking: { line, stop in
        var x = 0
        if line.isEmpty == false { // stop forgetting this.
            for char in line {
                switch char {
                case "#":
                    elves[Coord(x: x, y: y)] = Elf(position: Coord(x: x, y: y))
                default:
                    if char != "." {
                        assertionFailure("bad input")
                    }
                }
                x += 1
            }
            y += 1
        }
    })
}

enum Direction {
    case north
    case northEast
    case east
    case southEast
    case south
    case southWest
    case west
    case northWest
    case none

    static var all: [Direction] {
        return [.north, .northEast, .east, .southEast, .south, .southWest, .west, .northWest]
    }
}

// 0,0 is the upper left of the provided map, x is positive to the right, y is positive downwards. but coordinate space can go into the negative quadrants
extension Coord {
    var north: Coord {
        return Coord(x: x, y: y-1)
    }

    var northEast: Coord {
        return Coord(x: x+1, y: y-1)
    }

    var east: Coord {
        return Coord(x: x+1, y: y)
    }

    var southEast: Coord {
        return Coord(x: x+1, y: y+1)
    }

    var south: Coord {
        return Coord(x: x, y: y+1)
    }

    var southWest: Coord {
        return Coord(x: x-1, y: y+1)
    }

    var west: Coord {
        return Coord(x: x-1, y: y)
    }

    var northWest: Coord {
        return Coord(x: x-1, y: y-1)
    }

    func coord(in direction: Direction) -> Coord {
        switch direction {
        case .north:
            return north
        case .northEast:
            return northEast
        case .east:
            return east
        case .southEast:
            return southEast
        case .south:
            return south
        case .southWest:
            return southWest
        case .west:
            return west
        case .northWest:
            return northWest
        default:
            assertionFailure("what made up direction is this?")
            return self
        }
    }
}

var startingProposedMove: Direction = .north

class Elf: Equatable, Hashable {
    static func == (lhs: Elf, rhs: Elf) -> Bool {
        return lhs.position == rhs.position
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(position)
    }

    var position: Coord

    init(position: Coord) {
        self.position = position
    }
    
    var proposedMove: Coord? {
        var moveOrder: [Direction] = []
        switch startingProposedMove {
        case .north:
            moveOrder = [.north, .south, .west, .east]
        case .south:
            moveOrder = [.south, .west, .east, .north]
        case .west:
            moveOrder = [.west, .east, .north, .south]
        case .east:
            moveOrder = [.east, .north, .south, .west]
        default:
            assertionFailure("shouldn't consider diagonals")
        }
        for dir in moveOrder {
            if canMove(dir) {
                return position.coord(in: dir)
            }
        }
        return nil
    }

    func canMove(_ direction: Direction) -> Bool {
        switch direction {
        case .north:
            //If there is no Elf in the N, NE, or NW adjacent positions, the Elf proposes moving north one step.
            if elves[position.north] == nil && elves[position.northEast] == nil && elves[position.northWest] == nil {
                return true
            }
            return false
        case .south:
            //If there is no Elf in the S, SE, or SW adjacent positions, the Elf proposes moving south one step.
            if elves[position.south] == nil && elves[position.southEast] == nil && elves[position.southWest] == nil {
                return true
            }
        case .east:
            //If there is no Elf in the E, NE, or SE adjacent positions, the Elf proposes moving east one step.
            if elves[position.east] == nil && elves[position.southEast] == nil && elves[position.northEast] == nil {
                return true
            }
        case .west:
            //If there is no Elf in the W, NW, or SW adjacent positions, the Elf proposes moving west one step.
            if elves[position.west] == nil && elves[position.northWest] == nil && elves[position.southWest] == nil {
                return true
            }
        default:
            assertionFailure("cannot propose moving diagonally")
        }
        return false
    }

    // return true if no elf in that direction
    func checkForElves(in direction: Direction) -> Bool {
        switch direction {
        case .north:
            return elves[position.north] == nil
        case .northEast:
            return elves[position.northEast] == nil
        case .east:
            return elves[position.east] == nil
        case .southEast:
            return elves[position.southEast] == nil
        case .south:
            return elves[position.south] == nil
        case .southWest:
            return elves[position.southWest] == nil
        case .west:
            return elves[position.west] == nil
        case .northWest:
            return elves[position.northWest] == nil
        case .none:
            return true
        }
    }

    // return true if no elves in any direction
    func checkForElves() -> Bool {
        for direction in Direction.all {
            if checkForElves(in: direction) == false {
                return false
            }
        }
        return true
    }
}

//After each Elf has had a chance to propose a move, the second half of the round can begin. Simultaneously, each Elf moves to their proposed destination tile if they were the only Elf to propose moving to that position. If two or more Elves propose moving to the same position, none of those Elves move.
//
//Finally, at the end of the round, the first direction the Elves considered is moved to the end of the list of directions. For example, during the second round, the Elves would try proposing a move to the south first, then west, then east, then north. On the third round, the Elves would first consider west, then east, then north, then south.
//

func simulateElvenInsanity() {
    for loop in 1...1000000 {
        print("loop \(loop)")
        var activeElves = Set(elves.values)
        for (_, elf) in elves {
            //am I in a good spot?
            if elf.checkForElves() {
                //print("elf at \(elf.position) doesn't have to move")
                activeElves.remove(elf)
            }
        }

        if activeElves.isEmpty {
            print ("we're done! at the beginning of round \(loop)")
            break
        }

        var proposedMoves: Dictionary<Coord, Elf> = Dictionary()
        //print("moving \(startingProposedMove) first")
        for elf in activeElves {
            if let move = elf.proposedMove {
                if proposedMoves[move] == nil {
                    proposedMoves[move] = elf
                } else {
                    proposedMoves.removeValue(forKey: move)
                }
            } else {
                // can't move, so don't track a proposed move there.
                // do i need to remove from active Elves?
            }
        }

        // everyone MOVE!
        for (moveTo, elf) in proposedMoves {
            elves.removeValue(forKey: elf.position)
            elf.position = moveTo
            elves[moveTo] = elf
        }

       // print("elves are at \(elves.keys)")

        switch startingProposedMove { //[.north, .south, .west, .east]
        case .north:
            startingProposedMove = .south
        case .south:
            startingProposedMove = .west
        case .west:
            startingProposedMove = .east
        case .east:
            startingProposedMove = .north
        default:
            assertionFailure("wat")
        }
    }

    let testElf = elves.keys.first!
    var xRange: ClosedRange<Int> = testElf.x...testElf.x
    var yRange: ClosedRange<Int> = testElf.y...testElf.y
    // figure out the total area
    for coord in elves.keys {
        print("considering elf at \(coord)")
        xRange = min(xRange.lowerBound, coord.x)...max(xRange.upperBound, coord.x)
        yRange = min(yRange.lowerBound, coord.y)...max(yRange.upperBound, coord.y)
        print("xRange = \(xRange)")
        print("yRange = \(yRange)")
    }
    let area = (((xRange.upperBound + 1) - xRange.lowerBound) * ((yRange.upperBound + 1) - yRange.lowerBound)) - elves.count
    print("elves are spread over \(area)")
}
