//
//  day22.swift
//  AoC
//
//  Created by Rachael Worthington on 12/21/22.
//

import Foundation

func day22() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 22/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
        navigateBoard()
    } catch {
        print(error.localizedDescription)
    }
}

enum Space: Character {
    case floor = "."
    case wall = "#"
    case void = " "
}

enum Turn: Character {
    case clockwise = "R"
    case widdershins = "L"
}

//Facing is 0 for right (>), 1 for down (v), 2 for left (<), and 3 for up (^)
enum Facing: Int {
    case north = 3
    case east = 0
    case south = 1
    case west = 2
}

enum NavInstruction {
    case forward(Int) // distance
    case turn(Turn) // rotate
}

//       AB                so, A Face is x 50...99, y 0...49
//       C                     B Face is x 100...149, y 0...49
//      DE                     C face is x 50...99, y 50...99
//      F                      D face is x 0...49, y = 100...149
//                             E face is x 50...99, y = 100...149
//                             F face is x 0...49, y = 150...199

enum Face {
    case A
    case B
    case C
    case D
    case E
    case F

    static func face(at coord: Coord) -> Face {
        switch (coord.x, coord.y) {
        case (50...99, 0...49):
            return .A
        case (100...149, 0...49):
            return .B
        case (50...99, 50...99):
            return .C
        case (0...49, 100...149):
            return .D
        case (50...99, 100...149):
            return .E
        case (0...49, 150...199):
            return .F
        default:
            assertionFailure("no idea what face we're on? \(self)")
            return .A
        }
    }

    func xRange() -> ClosedRange<Int> {
        switch self {
        case .A:
            return 50...99
        case .B:
            return 100...149
        case .C:
            return 50...99
        case .D:
            return 0...49
        case .E:
            return 50...99
        case .F:
            return 0...49
        }
    }

    func yRange() -> ClosedRange<Int> {
        switch self {
        case .A:
            return 0...49
        case .B:
            return 0...49
        case .C:
            return 50...99
        case .D:
            return 100...149
        case .E:
            return 100...149
        case .F:
            return 150...199
        }
    }
}
fileprivate var part2 = true
extension Coord {
    func wrapCoord2(travelling direction: Facing) -> (Coord?, Facing) {// nil coord means cannot move there
        var nextLocale = self
        var nextFacing = direction
        if part2 {
            // step one: which face are we on?
            let currentFace = Face.face(at: self)
            // depending on which way we are moving, we need to update our facing, as well as our coordinate.
            let xOffset = x - currentFace.xRange().lowerBound
            let yOffset = y - currentFace.yRange().lowerBound
            var nextFace: Face
            switch(currentFace, direction) {
            case (.A, .west): // WA -> WD flips 180
                nextFace = .D
                nextFacing = .east
                nextLocale = Coord(x:nextFace.xRange().lowerBound, y: nextFace.yRange().upperBound - yOffset)
            case (.A, .north):
                // NA -> EE
                nextFacing = .east
                nextFace = .F
                nextLocale = Coord(x: nextFace.xRange().lowerBound, y: nextFace.yRange().lowerBound + xOffset)
            case (.B, .north):
                // NB -> NF
                nextFacing = .north
                nextFace = .F
                nextLocale = Coord(x: nextFace.xRange().lowerBound + xOffset, y: nextFace.yRange().upperBound)
            case (.B, .east):
                // EB -> WE
                nextFacing = .west
                nextFace = .E
                nextLocale = Coord(x: nextFace.xRange().upperBound , y: nextFace.yRange().upperBound - yOffset)
            case (.B, .south):
                // SB -> WC
                nextFacing = .west
                nextFace = .C
                nextLocale = Coord(x: nextFace.xRange().upperBound, y: nextFace.yRange().lowerBound + xOffset)
            case (.C, .west):
                // WC -> SD
                nextFace = .D
                nextFacing = .south
                nextLocale = Coord(x: nextFace.xRange().lowerBound + yOffset, y: nextFace.yRange().lowerBound)
            case (.C, .east):
                // EC -> NB
                nextFace = .B
                nextFacing = .north
                nextLocale = Coord(x: nextFace.xRange().lowerBound + yOffset, y: nextFace.yRange().upperBound)
            case (.D, .north):
                // ND -> EC
                nextFacing = .east
                nextFace = .C
                nextLocale = Coord(x: nextFace.xRange().lowerBound, y: nextFace.yRange().lowerBound + xOffset)
            case (.D, .west):
                // WD -> EA
                nextFacing = .east
                nextFace = .A
                nextLocale = Coord(x: nextFace.xRange().lowerBound, y: nextFace.yRange().upperBound - yOffset)
            case (.E, .east):
                // EE -> WB
                nextFacing = .west
                nextFace = .B
                nextLocale = Coord(x: nextFace.xRange().upperBound, y: nextFace.yRange().upperBound - yOffset)
            case (.E, .south):
                // SE -> WF
                nextFacing = .west
                nextFace = .F
                nextLocale = Coord(x: nextFace.xRange().upperBound, y: nextFace.yRange().lowerBound + xOffset)
            case (.F, .east):
                // EF -> NE
                nextFacing = .north
                nextFace = .E
                nextLocale = Coord(x: nextFace.xRange().lowerBound + yOffset, y: nextFace.yRange().upperBound)
            case (.F, .south):
                // SF -> SB
                nextFacing = .south
                nextFace = .B
                nextLocale = Coord(x: nextFace.xRange().lowerBound + xOffset, y: nextFace.yRange().lowerBound)
            case (.F, .west):
                // WF -> SA
                nextFacing = .south
                nextFace = .A
                nextLocale = Coord(x: nextFace.xRange().lowerBound + yOffset, y: nextFace.yRange().lowerBound)
            default:
                assertionFailure("we shouldn't be here wrapping around an edge that is already defined on our map. :(")
            }
        }

        let nextSpace = gameBoard[nextLocale]
        if nextSpace == .wall {
            return (nil, direction)
        }
        assert(nextSpace == .floor)
        return (nextLocale, nextFacing)

    }

    func wrapCoord(travelling direction: Facing) -> Coord? {// nil means cannot move there
        var nextLocale = self
        switch direction {
        case .north: // moving negative in Y
            nextLocale = Coord(x: x, y: largestY)
            while gameBoard[nextLocale] == nil || gameBoard[nextLocale] == .void {
                nextLocale =  Coord(x: x, y: nextLocale.y - 1)
            }

        case .east: // moving positive in X
            nextLocale = Coord(x: 0, y: y)
            while gameBoard[nextLocale] == nil || gameBoard[nextLocale] == .void {
                nextLocale =  Coord(x: nextLocale.x + 1, y: y)
            }
        case .south: // moving positive in Y
            nextLocale = Coord(x: x, y: 0)
            while gameBoard[nextLocale] == nil || gameBoard[nextLocale] == .void {
                nextLocale =  Coord(x: x, y: nextLocale.y + 1)
            }
        case .west: // moving negative in X
            nextLocale = Coord(x: largestX, y: y)
            while gameBoard[nextLocale] == nil || gameBoard[nextLocale] == .void {
                nextLocale =  Coord(x: nextLocale.x - 1, y: y)
            }
        }
        let nextSpace = gameBoard[nextLocale]
        if nextSpace == .wall {
            return nil
        }
        assert(nextSpace == .floor)
        return nextLocale
    }
}

var gameBoard: Dictionary<Coord, Space> = Dictionary()
var largestX = 0
var largestY = 0
var smallestX = 0
var smallestY = 0
var startSquare: Coord? = nil

var instructions: [NavInstruction] = []
fileprivate func parseInput(_ text: String) {
    var readingBoard = true
    var y = 0
    var foundStartSquare = false
    text.enumerateLines(invoking: { line, stop in
        // do not eliminate beginning spaces!
        // 0,0 is upper left corner. X -> pos, y -v positive.
        if line.isEmpty  { // stop forgetting this.
            readingBoard = false
        }

        if readingBoard {
            let coordEnum = line.enumerated()
            for (x, space) in coordEnum {
                let space = Space(rawValue: space)!
                let location = Coord(x: x, y: y)
                if !foundStartSquare && space == .floor {
                    startSquare = location
                    foundStartSquare = true
                }
                gameBoard[location] = space
                largestX = max(largestX, x)
            }
            y += 1
            largestY = y
        } else {
            // instructions should be 1 last line.
            var distanceBuffer: String = ""
            for char in line {
                if char.isNumber {
                    distanceBuffer.append(char)
                } else {
                    assert(!distanceBuffer.isEmpty)
                    instructions.append(NavInstruction.forward(Int(distanceBuffer)!))
                    instructions.append(NavInstruction.turn(Turn(rawValue: char)!))
                    distanceBuffer = ""
                }
            }
            if !distanceBuffer.isEmpty { // one last move
                instructions.append(NavInstruction.forward(Int(distanceBuffer)!))
            }
        }
    })
}


func navigateBoard() {
    // start at startsquare:
    guard let startSquare else { return }
    var position = startSquare
    var facing = Facing.east

    for instruction in instructions {
        print("** currently at \(position), facing \(facing)")
        switch instruction {
        case .turn(let turnDir):
            print("turning \(turnDir)")
            switch facing {
            case .north:
                facing = turnDir == .clockwise ? .east : .west
            case .east:
                facing = turnDir == .clockwise ? .south : .north
            case .south:
                facing = turnDir == .clockwise ? .west : .east
            case .west:
                facing = turnDir == .clockwise ? .north : .south
            }
        case .forward(let distance):
            print("walking \(distance)")
            var nextMove: Coord?
            for _ in 1...distance {
                switch facing {
                case .north:
                    nextMove = Coord(x: position.x, y: position.y - 1)
                case .east:
                    nextMove = Coord(x: position.x + 1, y: position.y)
                case .south:
                    nextMove = Coord(x: position.x, y: position.y + 1)
                case .west:
                    nextMove = Coord(x: position.x - 1, y: position.y)
                }

                var nextSpace = gameBoard[nextMove!]
                if nextSpace == nil {
                    // the void!
                    if !part2 {
                        nextMove = nextMove?.wrapCoord(travelling: facing)
                    } else {
                        let wrapResult = position.wrapCoord2(travelling: facing)
                        nextMove = wrapResult.0
                        facing = wrapResult.1
                    }
                    if let nextMove { // fall through and move normally
                        nextSpace = gameBoard[nextMove]
                    } else {
                        // we stopped. stop.
                        continue
                    }
                }
                if nextSpace == .wall {
                    // STOP.
                    continue
                } else if nextSpace == .void {
                    // wrap around to the bottom.
                    if !part2 {
                        nextMove = nextMove?.wrapCoord(travelling: facing)
                    } else {
                        let wrapResult = position.wrapCoord2(travelling: facing)
                        nextMove = wrapResult.0
                        facing = wrapResult.1
                    }
                    if nextMove == nil {
                        continue
                    } else {
                        position = nextMove!
                    }
                } else if nextSpace == .floor {
                    // just move forward
                    position = nextMove!
                }
            }
        }
        print("** finished move at \(position), facing \(facing)")
    }

    print("stopped at \(position), facing \(facing)")

    // answer is 1-based
    let finalRow = position.y + 1
    let finalColumn = position.x + 1
    print("final row: \(finalRow), finalColumn: \(finalColumn)")
    //The final password is the sum of 1000 times the row, 4 times the column, and the facing.
    let password = (1000 * finalRow) + (4 * finalColumn) + facing.rawValue
    print(password)
}

// part 2 185118 That's not the right answer; your answer is too high
// part 2 34239 That's not the right answer; your answer is too low.
