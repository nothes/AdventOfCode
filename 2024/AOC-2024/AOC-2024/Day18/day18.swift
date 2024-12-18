//
//  day18.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/17/24.
//

import Foundation
import GameKit

func day18() {
    let input = readInput(forDay: 18)
    let coords = input.split(separator: "\n")
    let drops: [Coord] = coords.map { coordStr in
        let xy = coordStr.split(separator: ",")
        return Coord(x: Int(xy[0])!, y: Int(xy[1])!)
    }

 //   print(drops)

    // map is 70x70, example is 6x6
//    As bytes fall into your memory space, they make that coordinate corrupted. Corrupted memory coordinates cannot be entered by you or The Historians, so you'll need to plan your route carefully. You also cannot leave the boundaries of the memory space; your only hope is to reach the exit.

    let graph = GKGridGraph(fromGridStartingAt: vector_int2(x: 0, y: 0), width: 71, height: 71, diagonalsAllowed: false)

    guard let startPosition: GKGridGraphNode = graph.node(atGridPosition: vector_int2(x: 0, y: 0)) else { assertionFailure("no start node?") ; return }
    guard let endPosition: GKGridGraphNode = graph.node(atGridPosition: vector_int2(x: Int32(70), y: Int32(70))) else { assertionFailure("no end node?") ; return }

    var fallenBlocks: [GKGridGraphNode] = []

    for drop in drops[0..<1024] {
        fallenBlocks.append(graph.node(atGridPosition: vector_int2(x: Int32(drop.x), y: Int32(drop.y)))!)
    }

    graph.remove(fallenBlocks)

    let path = graph.findPath(from: startPosition, to: endPosition) as! [GKGridGraphNode]
    print(path)
    print(path.count)
    var map: [[String]] = Array(repeating: Array(repeating: ".", count: 71), count: 71)

    for y in 0..<71 {
        for x in 0..<71 {
            if let node = graph.node(atGridPosition: vector_int2(x: Int32(x), y: Int32(y))) {
                if path.contains(node) {
                    map[y][x] = "O"
                } else {
                    map[y][x] = "."
                }
            } else {
                map[y][x] = "#"
            }
        }
    }
    //     render2dArray(map)

    // part 2
    for drop in drops[1025..<drops.count] {
        if let nextBlockedNode = graph.node(atGridPosition: vector_int2(x: Int32(drop.x), y: Int32(drop.y))) {
            graph.remove([nextBlockedNode])
            if graph.findPath(from: startPosition, to: endPosition).isEmpty {
                print("first blocking drop is \(drop)")
                break
            }
        }
    }
}

extension GKGridGraphNode {
    override open var debugDescription: String {
        return "(\(self.gridPosition.x), \(self.gridPosition.y))"
    }
}
