//
//  day7.swift
//  AOC-2025
//
//  Created by Rachael Worthington on 12/6/25.
//

import Foundation

func day7() {
    let input = readInput(forDay: 7)
    
    let lines = input.split(separator: "\n", omittingEmptySubsequences: false)
    var problems: [[String]] = []
    var charGrid: [[String]] = []
    var startCoord: (Int, Int) = (0, 0)
    var x = 0
    var y = 0
    // lets just put it into a 2d grid of digits so we can navigate it to parse non-linearly.
    for line in lines {
        guard line.isEmpty == false else { continue }
        var splitLine: [String] = []
        for char in line {
            let symbol = String(char)
            splitLine.append(symbol)
            if symbol == "S" {
                startCoord = (x, y)
            }
                x += 1
        }
        y += 1
        x = 0
        charGrid.append(splitLine)
    }

//    part1(grid: charGrid, startPosition: startCoord)
    part2(grid: charGrid, startPosition: startCoord)
}

func part1(grid: [[String]], startPosition: (Int, Int)) {
    // always increasing in the Y direction.
    var splitCount = 0
    var currentLasers = Set(arrayLiteral: startPosition.0)
    var currY = startPosition.1
    let maxY = grid.count - 1
    let maxX = grid[0].count - 1
    while currY < maxY {
        var newLasers: Set<Int> = Set()
        for currX in currentLasers {
            if grid[currY + 1][currX] == "^" {
                splitCount += 1
                if currX > 0 {
                    newLasers.insert(currX - 1)
                }
                if currX < maxX {
                    newLasers.insert(currX + 1)
                }
            } else {
                newLasers.insert(currX)
            }
        }
        currentLasers = newLasers 
        currY += 1
    }
    
    print(splitCount)
}

func part2(grid: [[String]], startPosition: (Int, Int)) {
    // always increasing in the Y direction.
    var currentLasers = [startPosition.0:1]//Set(arrayLiteral: startPosition.0)
    var currY = startPosition.1
    let maxY = grid.count - 1
    let maxX = grid[0].count - 1
    while currY < maxY {
        print("starting currentLasers: \(currentLasers)")
        var newLasers: Dictionary<Int, Int> = [:]
        for (currX, count) in currentLasers {
            if grid[currY + 1][currX] == "^" {
                print("splitting at x = \(currX), with \(count) realities")
                if currX > 0 {
                    print("adding \(count) at x = \(currX-1) to the already present \(/*(currentLasers[currX-1] ?? 0) +*/ (newLasers[currX-1] ?? 0))")
                    newLasers[currX - 1] = /*(currentLasers[currX-1] ?? 0) +*/ (newLasers[currX-1] ?? 0) + count // this is tracking how many realities are at this position right now.
                }
                if currX < maxX {
                    print("adding \(count) at x = \(currX+1) to the already present \(/*(currentLasers[currX+1] ?? 0) +*/ (newLasers[currX+1] ?? 0))")
                    newLasers[currX + 1] = /*(currentLasers[currX+1] ?? 0) + */(newLasers[currX+1] ?? 0) + count
                }
            } else {
                print("continuing \(count) downwards at x = \(currX)")
                newLasers[currX] = (newLasers[currX] ?? 0) + count 
            }
        }
        currentLasers = newLasers 
        currY += 1
    }
    
    var total = 0
    for value in currentLasers.values {
        total += value
    }
    print(total)
}
