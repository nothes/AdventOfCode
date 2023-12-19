//
//  day14.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/19/23.
//

import Foundation

func day14() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day14/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        parsePlatform(with: text)
        // part 1
//        tiltUp()
//        calculateLoad()
        // part 2
        spinCycle()
        calculateLoad()
    } catch {
        print(error.localizedDescription)
    }
}

var platform: [[String]] = []

func parsePlatform(with input: String) {
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            var row: [String] = []
            for char in line {
                row.append(String(char))
            }
            platform.append(row)
        }
    }
}

func tiltUp() {
    let xMax = platform[0].count - 1
    let yMax = platform.count - 1

    // scan top -> bottom to find rocks. each time you find one, reposition it, then start scanning from the position you left off on?
    for x in 0...xMax {
        for y in 0...yMax {
            let space = platform[y][x]
            if space == "O" && y > 0 { // time to roll ;)
                if platform[y - 1][x] == "." { // if we can't roll then don't try.
                    var newY = y
                    while newY > 0 {
                        newY = newY - 1
                        let newSpace = platform[newY][x]
                        if newSpace != "." {
                            newY = newY + 1 // we couldn't roll, put it back up a roww
                            break
                        }
                    }

                    platform[y][x] = "."
                    platform[newY][x] = "O"
                }
            }
        }
    }
}

func tiltLeft() {
    let xMax = platform[0].count - 1
    let yMax = platform.count - 1

    // scan left -> right to find rocks. each time you find one, reposition it, then start scanning from the position you left off on?
    for y in 0...yMax {
        for x in 0...xMax {
            let space = platform[y][x]
            if space == "O" && x > 0 { // time to roll ;)
                if platform[y][x - 1] == "." { // if we can't roll then don't try.
                    var newX = x
                    while newX > 0 {
                        newX = newX - 1
                        let newSpace = platform[y][newX]
                        if newSpace != "." {
                            newX = newX + 1 // we couldn't roll, put it back up a roww
                            break
                        }
                    }

                    platform[y][x] = "."
                    platform[y][newX] = "O"
                }
            }
        }
    }
}

func tiltDown() {
    let xMax = platform[0].count - 1
    let yMax = platform.count - 1

    // scan bottom -> top to find rocks. each time you find one, reposition it, then start scanning from the position you left off on?
    for x in 0...xMax {
        var y = yMax
        while y >= 0 {
            let space = platform[y][x]
            if space == "O" && y < yMax { // time to roll ;)
                if platform[y + 1][x] == "." { // if we can't roll then don't try.
                    var newY = y
                    while newY < yMax {
                        newY = newY + 1
                        let newSpace = platform[newY][x]
                        if newSpace != "." {
                            newY = newY - 1 // we couldn't roll, put it back up a roww
                            break
                        }
                    }

                    platform[y][x] = "."
                    platform[newY][x] = "O"
                }
            }
            y = y - 1
        }
    }
}

func tiltRight() {
    let xMax = platform[0].count - 1
    let yMax = platform.count - 1

    // scan right -> left to find rocks. each time you find one, reposition it, then start scanning from the position you left off on?
    for y in 0...yMax {
        var x = xMax
        while x >= 0 {
            let space = platform[y][x]
            if space == "O" && x < xMax { // time to roll ;)
                if platform[y][x + 1] == "." { // if we can't roll then don't try.
                    var newX = x
                    while newX < xMax {
                        newX = newX + 1
                        let newSpace = platform[y][newX]
                        if newSpace != "." {
                            newX = newX - 1 // we couldn't roll, put it back up a roww
                            break
                        }
                    }

                    platform[y][x] = "."
                    platform[y][newX] = "O"
                }
            }
            x = x - 1
        }
    }
}

var seenPlatforms: [[[String]]] = []

func spinCycle() { // i'm worried this won't brute-force well... yup. gotta detect cycles in the spin state & then cut out the middle-man.
    let cycles = 1000000000
    var cycle = 1
    var remainder = 0
    while cycle <= cycles {
        tiltUp()
//            print("up")
//            printPlatform()
        tiltLeft()
//            print("left")
//            printPlatform()
        tiltDown()
//            print("down")
//            printPlatform()
        tiltRight()
//            print("right")
//            printPlatform()
        if let lastSeen = seenPlatforms.firstIndex(of: platform) {
//            print("we're in a loop! cycle = \(cycle), lastSeen = \(lastSeen)")
//            printPlatform()
            // we found a cycle so we can skip all the cycles before the end! huzzah!
            let cycleLength = cycle - (lastSeen + 1) // 0 vs 1 index
            let remainingCycles = cycles - cycle
             remainder = remainingCycles.remainderReportingOverflow(dividingBy: cycleLength).partialValue
            break
        } else {
            seenPlatforms.append(platform)
            cycle = cycle + 1
        }
    }

    for _ in 1...remainder {
        tiltUp()
//            print("up")
//            printPlatform()
        tiltLeft()
//            print("left")
//            printPlatform()
        tiltDown()
//            print("down")
//            printPlatform()
        tiltRight()
//            print("right")
//            printPlatform()
    }
}

func printPlatform() {
    for row in 0..<platform.count {
        print(platform[row])
    }
}

func calculateLoad() {
    let xMax = platform[0].count - 1
    let yMax = platform.count - 1

//    The amount of load caused by a single rounded rock (O) is equal to the number of rows from the rock to the south edge of the platform, including the row the rock is on. (Cube-shaped rocks (#) don't contribute to load.) So, the amount of load caused by each rock in each row is as follows:
    var totalLoad = 0
    var y = yMax
    while y >= 0 {
        for x in 0...xMax {
            let load = yMax - y + 1 // the 1 is because the bottom-most row is worth 1, not 0
            let space = platform[y][x]
            if space == "O" {
                totalLoad = totalLoad + load
            }
        }
        y = y - 1
    }
    print("total load = \(totalLoad)")
    // 102505 is Too Low
}

