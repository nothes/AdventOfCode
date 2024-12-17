//
//  day16.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/15/24.
//

import Foundation
import GameKit

func day16() {
    let input = readInput(forDay: 16)
    var map: [[String]] = []
    let lines = input.split(separator: "\n")
    for line in lines {
        var row: [String] = []
        for char in line {
            let str = String(char)
            row.append(str)
        }
        map.append(row)
    }

 //   render2dArray(map)

    var startPosition: MapNode? = nil
    var endPosition: MapNode? = nil

    var walls: [GKGridGraphNode] = []
//    var spaces: Set<Coord> = []
    var graph: GKGridGraph = GKGridGraph(fromGridStartingAt: vector_int2(x: 0, y: 0), width: Int32(map[0].count), height: Int32(map.count), diagonalsAllowed: false, nodeClass: MapNode.self)

    for y in 0..<map.count {
        for x in 0..<map[0].count {
            if let node = graph.node(atGridPosition: vector_int2(x: Int32(x), y: Int32(y))) as? MapNode {
                node.symbol = map[y][x]

                switch map[y][x] {
                case "S":
                    startPosition = node
                    //    spaces.insert(Coord(x: x, y: y))
                case "E":
                    endPosition = node
                    //   spaces.insert(Coord(x: x, y: y))
                case "#":
                    walls.append(node)
                case ".":
                    let _ = 0
                    //spaces.insert(Coord(x: x, y: y))
                default:
                    assertionFailure("extra map symbol: \(map[y][x])")
                }
            }
        }
    }

    graph.remove(walls)



    // Part 1
    guard let startPosition else {
        print("no start position found!")
        return
    }
    guard let endPosition else {
        print("no end position found!")
        return
    }

    if let solution = graph.findPath(from: startPosition, to: endPosition) as? [MapNode] {
        print("score? \(scoreRoute(solution))")
    }

    // 11421 - too low (what)


    func scoreRoute(_ route: [MapNode]) -> Int {
        var currPosition = Position(location: startPosition.gridPosition, facing: .East)
        var totalScore = 0
        for move in route {
            let directionMoved: Direction
            let currLocation = currPosition.location
            if currLocation.x == move.gridPosition.x {
                if currLocation.y < move.gridPosition.y {
                    directionMoved = .South
                } else {
                    directionMoved = .North
                }
            } else {
                if currLocation.x < move.gridPosition.x {
                    directionMoved = .East
                } else {
                    directionMoved = .West
                }
            }
            switch currPosition.facing {
            case .North:
                switch directionMoved {
                case .North:
                    // no OP! no turning needed
                    let _ = 0
                case .East, .West: // turn once
                    totalScore += 1000
                case .South: // turn twice
                    totalScore += 2000
                default:
                    assertionFailure("no diagonals!")
                }
            case .East:
                switch directionMoved {
                case .East:
                    // no OP! no turning needed
                    let _ = 0
                case .North, .South: // turn once
                    totalScore += 1000
                case .West: // turn twice
                    totalScore += 2000
                default:
                    assertionFailure("no diagonals!")
                }
            case .South:
                switch directionMoved {
                case .South:
                    // no OP! no turning needed
                    let _ = 0
                case .East, .West: // turn once
                    totalScore += 1000
                case .North: // turn twice
                    totalScore += 2000
                default:
                    assertionFailure("no diagonals!")
                }
            case .West:
                switch directionMoved {
                case .West:
                    // no OP! no turning needed
                    let _ = 0
                case .North, .South: // turn once
                    totalScore += 1000
                case .East: // turn twice
                    totalScore += 2000
                default:
                    assertionFailure("no diagonals!")
                }
            default:
                assertionFailure("no diagonals!")
            }
            // movement cost
            totalScore += 1
        }

        return totalScore
    }

    class MapNode: GKGridGraphNode {
        var symbol: String = ""

        override func cost(to node: GKGraphNode) -> Float {
            // HERE'S THE PROBLEM... you can't set this up because it varies based on what the character's facing is at the time, and I can't adjust hte costs on the fly while the solver is solvering.
            return super .cost(to: node)
        }
    }

    struct Position {
        let location: vector_int2
        let facing: Direction
    }
}
