//
//  day10.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/9/24.
//

import Foundation

func day10() {
    let input = readInput(forDay: 10)

    var map: [[Int]] = []
    var trailheads: [Coord] = []
    var vistas: [Coord] = []

    let lines = input.split(separator:"\n")
    let maxX: Int = lines[0].count - 1
    let maxY: Int = lines.count - 1
    for y in 0..<lines.count {
    let line = lines[y]
        var row: [Int] = []
        var xIndex = line.startIndex
        for x in 0..<lines[0].count {
            let char = String(line[xIndex])
            row.append(Int(char)!)
            xIndex = line.index(after: xIndex)

            if char == "0" {
                trailheads.append(Coord(x: x, y: y))
            } else if char == "9" {
                vistas.append(Coord(x: x, y: y))
            }
        }
        map.append(row)
    }


    var visitedVistas: Set<Coord> = Set()

    func traverseTrails(currPosition: Coord) { // return the total score
        let x = currPosition.x
        let y = currPosition.y
        let currAlt = map[y][x]
        if currAlt == 9 {
            visitedVistas.insert(currPosition)
            return
        }
        // check all 4 directions
        //up
        if y > 0 {
            let upAlt = map[y-1][x]
            if upAlt == currAlt + 1 {
                traverseTrails(currPosition: Coord(x: x, y: y-1))
            }
        }
        //down
        if y < maxY {
            let downAlt = map[y+1][x]
            if downAlt == currAlt + 1 {
                traverseTrails(currPosition: Coord(x: x, y: y+1))
            }
        }
        //left
        if x > 0 {
            let leftAlt = map[y][x-1]
            if leftAlt == currAlt + 1 {
               traverseTrails(currPosition: Coord(x: x-1, y: y))
            }
        }
        //right
        if x < maxX {
            let rightAlt = map[y][x+1]
            if rightAlt == currAlt + 1 {
                traverseTrails(currPosition: Coord(x: x+1, y: y))
            }
        }
    }


    func scoreTrailhead(currPosition: Coord) -> Int { // return the total score
        let x = currPosition.x
        let y = currPosition.y
        let currAlt = map[y][x]
        if currAlt == 9 {
            return 1
        }
        // check all 4 directions
        var upPath = 0
        var downPath = 0
        var leftPath = 0
        var rightPath = 0
        //up
        if y > 0 {
            let upAlt = map[y-1][x]
            if upAlt == currAlt + 1 {
                upPath += scoreTrailhead(currPosition: Coord(x: x, y: y-1))
            }
        }
        //down
        if y < maxY {
            let downAlt = map[y+1][x]
            if downAlt == currAlt + 1 {
                downPath += scoreTrailhead(currPosition: Coord(x: x, y: y+1))
            }
        }
        //left
        if x > 0 {
            let leftAlt = map[y][x-1]
            if leftAlt == currAlt + 1 {
               leftPath += scoreTrailhead(currPosition: Coord(x: x-1, y: y))
            }
        }
        //right
        if x < maxX {
            let rightAlt = map[y][x+1]
            if rightAlt == currAlt + 1 {
                rightPath += scoreTrailhead(currPosition: Coord(x: x+1, y: y))
            }
        }

        return upPath + downPath + leftPath + rightPath
    }

    // part 1 - find all the different 9's you can reach from 0's by moving through all the numbers.
    var trailScore = 0
    for trailhead in trailheads {
        traverseTrails(currPosition: trailhead)
        trailScore += visitedVistas.count
        visitedVistas.removeAll()
    }

    print("total trail score = \(trailScore)")

    // part 2 - find all the paths to 9's you can reach from 0's by moving through all the numbers.
    var trailheadScore = 0
    for trailhead in trailheads {
        let rating = scoreTrailhead(currPosition: trailhead)
        trailheadScore += rating
    }
    print("total trailhead scores: \(trailheadScore)")

}
