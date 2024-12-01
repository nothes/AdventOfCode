//
//  day18.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/19/23.
//

import Foundation

func day18() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day18/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        generateLake(with: text)
        // part 1

        // part 2

    } catch {
        print(error.localizedDescription)
    }
}

var lake: [[String]] = []

func generateLake(with input: String) {
    var trench: [(x: Int, y: Int)] = []
    var currentPosition = (x: 0, y: 0)
    trench.append(currentPosition)
    var minX = 0
    var maxX = 0
    var minY = 0
    var maxY = 0

    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            let components = line.split(separator: /\s+/)
            let direction: Direction
            switch components[0] {
            case "R":
                direction = .right
            case "L":
                direction = .left
            case "U":
                direction = .up
            case "D":
                direction = .down
            default:
                direction = .wall
                assertionFailure("a magical 5th direction has been found")
            }

            for _ in 1...Int(components[1])! {
                switch direction {
                case .up:
                    currentPosition.y = currentPosition.y - 1
                case .down:
                    currentPosition.y = currentPosition.y + 1
                case .left:
                    currentPosition.x = currentPosition.x - 1
                case .right:
                    currentPosition.x = currentPosition.x + 1
                default:
                    assertionFailure("a magical 5th direction has been found")
                }

                if currentPosition.x > maxX {
                    maxX = currentPosition.x
                } else if currentPosition.x < minX {
                    minX = currentPosition.x
                }

                if currentPosition.y > maxY {
                    maxY = currentPosition.y
                } else if currentPosition.y < minY {
                    minY = currentPosition.y
                }

                trench.append(currentPosition)
            }
        }
    }

    for _ in minY...maxY {
        var row: [String] = []
        for _ in minX...maxX {
            row.append(".")
        }
        lake.append(row)
    }

    // draw our trench in a 0-based coord system
    let xOffset = 0 - minX
    let yOffset = 0 - minY
    for trenchCoord in trench {
        let x = xOffset + trenchCoord.x
        let y = yOffset + trenchCoord.y
        lake[y][x] = "#"
    }

//    printLake()

//    print("*********")
    // hollow out the center
    var hashCount = 0
    for y in 0..<lake.count {
        var fill = false
        var lastSpace = "."
        for x in 0..<lake[0].count {
            var space = lake[y][x]
            if space == "#" {
                hashCount = hashCount + 1
            }

            if space == "#" && lastSpace != "#" && !fill || space == "." && lastSpace != "." && fill {
                fill = !fill
            }

            if space == "." && fill {
                lake[y][x] = "#"
                hashCount = hashCount + 1
                space = "#"
            }

            lastSpace = space
        }
    }
//    printLake()

    print("area = \(hashCount)")
    // 78208 is Too High
    // 4696 is Too Low
    // 7061 is Too Low
}

func printLake() {
    for row in 0..<lake.count {
        print(lake[row])
    }
}
