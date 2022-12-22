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

extension Coord {
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
                    print("moving negative in the y dimension")
                    nextMove = Coord(x: position.x, y: position.y - 1)
                case .east:
                    print("moving positive in the x dimension")
                    nextMove = Coord(x: position.x + 1, y: position.y)
                case .south:
                    print("moving positive in the y direction")
                    nextMove = Coord(x: position.x, y: position.y + 1)
                case .west:
                    print("moving negative in the x direction")
                    nextMove = Coord(x: position.x - 1, y: position.y)
                }

                var nextSpace = gameBoard[nextMove!]
                if nextSpace == nil {
                    // the void!
                    nextMove = nextMove?.wrapCoord(travelling: facing)
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
                    nextMove = nextMove?.wrapCoord(travelling: facing)
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
