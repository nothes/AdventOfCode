//
//  day4.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/3/24.
//

import Foundation

func day4() {
    let input = readInput(forDay: 4)
    var puzzle: [[String]] = []

    let lines = input.split(separator:"\n")
    for line in lines {
        var puzzleLine: [String] = []
        for char in line {
            puzzleLine.append(String(char))
        }

        puzzle.append(puzzleLine)
    }

    //part 1
    // This word search allows words to be horizontal, vertical, diagonal, written backwards, or even overlapping other words.

    // find all the instances of the target.
    // forwards
    // backwards
    // vertically (top down)
    // vertically (bottom up)
    // diagonal (down-right)
    // diagonal (up-right)
    // diagonal (down-left)
    // diagonal (up-left)


    //OR we find all intsances of X and check if they have MAS in any of the dirs. that seems like it might be easier honestly.

    var allTheXs: [(x: Int, y: Int)] = []
    for x in 0..<puzzle.count {
//        print("line: \(puzzle[x])")
        for y in 0..<puzzle[0].count {
//            print("char (\(x),\(y)): \(puzzle[x][y])")
            if puzzle[x][y] == "X" {
                allTheXs.append((x,y))
            }
        }
    }

    var wordCount = 0
    for possWord in allTheXs {
        //check the directions
        wordCount = wordCount + wordsAt(pos: possWord)
    }

    print("total XMAS count: \(wordCount)")

    func wordsAt(pos: (x: Int, y: Int)) -> Int { // returns how many XMASes start from this X
        var count = 0
        let xPuzzleSize = puzzle.count
        let yPuzzleSize = puzzle[0].count
        for dir in Direction.allCases {
            switch dir {
            case .North:
                guard pos.y >= 3 else { continue } // run off the top of the puzzle
                guard puzzle[pos.x][pos.y-1] == "M" else { continue }
                guard puzzle[pos.x][pos.y-2] == "A" else { continue }
                guard puzzle[pos.x][pos.y-3] == "S" else { continue }
                count = count + 1
            case .NorthEast:
                guard pos.x < xPuzzleSize - 3 else { continue } // run off the right of the puzzle
                guard pos.y >= 3 else { continue } // run off the top of the puzzle
                guard puzzle[pos.x+1][pos.y-1] == "M" else { continue }
                guard puzzle[pos.x+2][pos.y-2] == "A" else { continue }
                guard puzzle[pos.x+3][pos.y-3] == "S" else { continue }
                count = count + 1
            case .East:
                guard pos.x < xPuzzleSize - 3 else { continue } // run off the right of the puzzle
                guard puzzle[pos.x+1][pos.y] == "M" else { continue }
                guard puzzle[pos.x+2][pos.y] == "A" else { continue }
                guard puzzle[pos.x+3][pos.y] == "S" else { continue }
                count = count + 1
            case .SouthEast:
                guard pos.x < xPuzzleSize - 3 else { continue } // run off the right of the puzzle
                guard pos.y < yPuzzleSize - 3 else { continue } // run off the bottom of the puzzle
                guard puzzle[pos.x+1][pos.y+1] == "M" else { continue }
                guard puzzle[pos.x+2][pos.y+2] == "A" else { continue }
                guard puzzle[pos.x+3][pos.y+3] == "S" else { continue }
                count = count + 1
            case .South:
                guard pos.y < yPuzzleSize - 3 else { continue } // run off the top of the puzzle
                guard puzzle[pos.x][pos.y+1] == "M" else { continue }
                guard puzzle[pos.x][pos.y+2] == "A" else { continue }
                guard puzzle[pos.x][pos.y+3] == "S" else { continue }
                count = count + 1
            case .SouthWest:
                guard pos.x >= 3 else { continue } // run off the left of the puzzle
                guard pos.y < yPuzzleSize - 3 else { continue } // run off the bottom of the puzzle
                guard puzzle[pos.x-1][pos.y+1] == "M" else { continue }
                guard puzzle[pos.x-2][pos.y+2] == "A" else { continue }
                guard puzzle[pos.x-3][pos.y+3] == "S" else { continue }
                count = count + 1
            case .West:
                guard pos.x >= 3 else { continue } // run off the left of the puzzle
                guard puzzle[pos.x-1][pos.y] == "M" else { continue }
                guard puzzle[pos.x-2][pos.y] == "A" else { continue }
                guard puzzle[pos.x-3][pos.y] == "S" else { continue }
                count = count + 1
            case .NorthWest:
                guard pos.x >= 3 else { continue } // run off the left of the puzzle
                guard pos.y >= 3 else { continue } // run off the top of the puzzle
                guard puzzle[pos.x-1][pos.y-1] == "M" else { continue }
                guard puzzle[pos.x-2][pos.y-2] == "A" else { continue }
                guard puzzle[pos.x-3][pos.y-3] == "S" else { continue }
                count = count + 1
            }
        }
        return count
    }

    // part 2 (don't find "XMAS" find M.M
    //                                .A.
    //                                S.S
    // in any orientation)

    // first find the A's:
    var allTheAs: [(x: Int, y: Int)] = []
    for x in 0..<puzzle.count {
        for y in 0..<puzzle[0].count {
            if puzzle[x][y] == "A" {
                allTheAs.append((x,y))
            }
        }
    }

    var xCount = 0
    for possX in allTheAs {
        //check the directions
        if xAt(pos: possX) {
            xCount = xCount + 1
        }
    }

    print("total X-MAS count: \(xCount)")

    func xAt(pos: (x: Int, y: Int)) -> Bool {
        let xPuzzleSize = puzzle.count
        let yPuzzleSize = puzzle[0].count

        guard pos.x > 0 && pos.x < xPuzzleSize - 1 else { return false } // is the A away from the x edges?
        guard pos.y > 0 && pos.y < yPuzzleSize - 1 else { return false } // y edges?

        // check the first corner
        let upperLeft = puzzle[pos.x-1][pos.y-1]
        let upperRight = puzzle[pos.x+1][pos.y-1]
        let lowerLeft = puzzle[pos.x-1][pos.y+1]
        let lowerRight = puzzle[pos.x+1][pos.y+1]

        if upperLeft == "M" {
            if lowerRight != "S" {
                return false
            }
        } else if upperLeft == "S" {
            if lowerRight != "M" {
                return false
            }
        } else {
            return false
        }

        if upperRight == "M" {
            if lowerLeft != "S" {
                return false
            }
        } else if upperRight == "S" {
            if lowerLeft != "M" {
                return false
            }
        } else {
            return false
        }

        return true
    }
}
