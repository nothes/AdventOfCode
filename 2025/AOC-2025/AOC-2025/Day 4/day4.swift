//
//  day4.swift
//  AOC-2025
//
//  Created by Rachael Worthington on 12/3/25.
//

import Foundation

func day4() {
    let input = readInput(forDay: 4)

    var room: [[String]] = [] // accessed room[y][x]

    let rows = input.split(separator: "\n")

    for row in rows {
        var roomRow: [String] = []
        for char in row {
            roomRow.append(String(char))
        }
        room.append(roomRow)
    }
    
//    part1(room: room)
    part2(startRoom: room)
}

func part1(room: [[String]]) {
    var total = 0
//    printRoom(room: room)
    let maxX = room[0].count - 1
    let maxY = room.count - 1
    for y in 0...maxY {
        for x in 0...maxX {
            let location = room[y][x]
            if location == "@" {
//                print("checking (\(x),\(y))")
                var surroundingCount = 0
                // check the 8 points surrounding it
                for j in max(0, y-1)...min(maxY, y+1) {
                    for i in max(0, x-1)...min(maxX, x+1) {
//                        print("x = \(i) y = \(j) contents = \(room[j][i])")
                        if room[j][i] == "@" {
                            surroundingCount += 1
//                            print("found roll at (\(i),\(j))")
                        }
                    }
                }
                // the problem reads " less than 4", but my algo counts my own roll, so this compensates for it
//                print("total surrounding rows (inc self): \(surroundingCount)")
                if surroundingCount <= 4 {
                    total += 1
                }
            }
        }
    }
    print("total movable rows: \(total)")
}

func part2(startRoom: [[String]]) {
    var room = startRoom
    var total = 0
    // we want something very similar to part 1, but we need to track which rolls we're _going_ to remove, and update the room at the end, so we can repeat it.
    var removeIndexes: [(Int, Int)] = []
    repeat {
        removeIndexes = [] // reset each go-round
        let maxX = room[0].count - 1
        let maxY = room.count - 1
        for y in 0...maxY {
            for x in 0...maxX {
                let location = room[y][x]
                if location == "@" {
                    var surroundingCount = 0
                    // check the 8 points surrounding it
                    for j in max(0, y-1)...min(maxY, y+1) {
                        for i in max(0, x-1)...min(maxX, x+1) {
                            if room[j][i] == "@" {
                                surroundingCount += 1
                            }
                        }
                    }
                    // the problem reads " less than 4", but my algo counts my own roll, so this compensates for it
                    if surroundingCount <= 4 {
                        removeIndexes.append((x, y))
                        total += 1
                    }
                }
            }
        }

        // now update the room
        for index in removeIndexes {
            room[index.1][index.0] = "."
        }

    } while !removeIndexes.isEmpty

    print("total = \(total)")
}

func printRoom(room: [[String]]) {
    let maxX = room[0].count
    let maxY = room.count
    for x in 0..<maxX {
        var tempStr: String = ""
        for y in 0..<maxY {
            tempStr.append(room[x][y])
        }
        print("\(tempStr)\n")
    }
}
