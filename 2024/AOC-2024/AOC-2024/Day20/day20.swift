//
//  day20.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/20/24.
//

import Foundation
import GameKit

func day20() {
    let input = readInput(forDay: 20)
    
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
    
    let graph = GKGridGraph(fromGridStartingAt: vector_int2(x: 0, y: 0), width: Int32(map[0].count), height: Int32(map.count), diagonalsAllowed: false)
    render2dArray(map)
    var startLoc: GKGridGraphNode?
    var endLoc: GKGridGraphNode?
    
    //   var nodes: [GKGridGraphNode] = []
    var walls: [GKGridGraphNode] = []
    for y in 0..<map.count {
        for x in 0..<map[0].count {
            let str = map[y][x]
            switch str {
            case "S":
                startLoc = graph.node(atGridPosition: vector_int2(x: Int32(x), y: Int32(y)))
                //    nodes.append(startLoc!)
            case "E":
                endLoc = graph.node(atGridPosition: vector_int2(x: Int32(x), y: Int32(y)))
                //    nodes.append(endLoc!)
                //            case ".":
                //                nodes.append(GKGridGraphNode(gridPosition: vector_int2(x: Int32(x), y: Int32(y))))
            case "#":
                if let wall = graph.node(atGridPosition: vector_int2(x: Int32(x), y: Int32(y))) {
                    walls.append(wall)
                }
            default:
                let _ = 0 // no op
            }
        }
    }
    
    guard let startLoc else { assertionFailure("found no start location"); return }
    guard let endLoc else { assertionFailure("found no end location"); return }
    
    // removing the Start & End markers to make consulting the map easier since we've noted them elsewhere
    map[Int(startLoc.gridPosition.y)][Int(startLoc.gridPosition.x)] = "."
    map[Int(endLoc.gridPosition.y)][Int(endLoc.gridPosition.x)] = "."
    
    //    graph.add(nodes)
    //    graph.add(walls)
    //    for node in nodes {
    //        graph.connectToAdjacentNodes(node: node)
    //    }
    //
    graph.remove(walls)
    
    let basePath = graph.findPath(from: startLoc, to: endLoc) as! [GKGridGraphNode]
    let baseDistance = basePath.count - 1 // because it's got the start position in there.
    
    print("base distance = \(baseDistance)")
//    let filteredWalls = walls.filter { node in
//        let nodeXPos = node.gridPosition.x
//        let nodeYPos = node.gridPosition.y
//        // in order to be able to pass through the walls safely they need to be only 1 thick, so we can discard any wall that leads to the edge of the map or doesn't open up again in 1 move
//        if let down = graph.node(atGridPosition: vector_int2(x: nodeXPos, y: nodeYPos + 1)), let up = graph.node(atGridPosition: vector_int2(x: nodeXPos, y: nodeYPos - 1)), let left = graph.node(atGridPosition: vector_int2(x: nodeXPos - 1, y: nodeYPos)), let right = graph.node(atGridPosition: vector_int2(x: nodeXPos + 1, y: nodeYPos)) {
//            let upChar = map[Int(down.gridPosition.y)][Int(down.gridPosition.x)]
//            let downChar = map[Int(up.gridPosition.y)][Int(up.gridPosition.x)]
//            let leftChar = map[Int(left.gridPosition.y)][Int(left.gridPosition.x)]
//            let rightChar = map[Int(right.gridPosition.y)][Int(right.gridPosition.x)]
//            if (upChar != "." && downChar != ".") || (leftChar != "." && rightChar != ".") {
//                return false
//            }
//        }
//        return true
//    }
    
    // thisis hte brute force way, instead we should just make the path & "remove" the nodes between the cut-over, and re-count.
    // part 1, pass one - this works, but almost 7 mins to execute.
    //
    //    var answerCount = 0
    //    for wall in filteredWalls {
    //        // update the graph, see if the solution is better
    //        graph.add([wall])
    //        graph.connectToAdjacentNodes(node: wall)
    //        let cheatDistance = graph.findPath(from: startLoc, to: endLoc).count - 1
    //
    //        //print("removing wall at \(wall.gridPosition), path is \(cheatDistance.count - 1), for a delta of \(baseDistance - cheatDistance)")
    //
    //        if baseDistance - cheatDistance >= 100 {
    //            answerCount += 1
    //        }
    //        graph.remove([wall])
    //    }
    
    //    print(answerCount) //my answer was 1369
    
    // part 1 - much smarter!

    var answer = 0
    for node in walls {
        let nodeXPos = node.gridPosition.x
        let nodeYPos = node.gridPosition.y
        // in order to be able to pass through the walls safely they need to be only 1 thick, so we can discard any wall that leads to the edge of the map or doesn't open up again in 1 move
        let up = graph.node(atGridPosition: vector_int2(x: nodeXPos, y: nodeYPos - 1))
        let down = graph.node(atGridPosition: vector_int2(x: nodeXPos, y: nodeYPos + 1))
        let left = graph.node(atGridPosition: vector_int2(x: nodeXPos - 1, y: nodeYPos))
        let right = graph.node(atGridPosition: vector_int2(x: nodeXPos + 1, y: nodeYPos))
        var verticalPassthrough = false
        var horizontalPassthrough = false
        if let up, let down {
            let upChar = map[Int(down.gridPosition.y)][Int(down.gridPosition.x)]
            let downChar = map[Int(up.gridPosition.y)][Int(up.gridPosition.x)]
            if upChar == "." && downChar == "." {
                if let upIndex = basePath.firstIndex(of: up), let downIndex = basePath.firstIndex(of: down) {
                    let skipDistance = abs(downIndex - upIndex)
                    if skipDistance > 100 {
                        answer += 1
                    }
                }
            }
        }

        if let left, let right {
            let leftChar = map[Int(left.gridPosition.y)][Int(left.gridPosition.x)]
            let rightChar = map[Int(right.gridPosition.y)][Int(right.gridPosition.x)]
            if leftChar == "." && rightChar == "." {
                if let leftIndex = basePath.firstIndex(of: left), let rightIndex = basePath.firstIndex(of: right) {
                    let skipDistance = abs(leftIndex - rightIndex)
                    if skipDistance > 100 {
                        answer += 1
                    }
                }
            }

        }
    }

    print(answer)


    // for radar later - the error here was BAFFLINGLY wrong.
//    { node in
//        let nodeXPos = node.gridPosition.x
//        let nodeYPos = node.gridPosition.y
//        // in order to be able to pass through the walls safely they need to be only 1 thick, so we can discard any wall that leads to the edge of the map or doesn't open up again in 1 move
//        if let down = graph.node(atGridPosition: vector_int2(x: nodeXPos, y: nodeYPos + 1)), let up = graph.node(atGridPosition: vector_int2(x: nodeXPos, y: nodeYPos - 1)), let left = graph.node(atGridPosition: vector_int2(x: nodeXPos - 1, y: nodeYPos)), let right = graph.node(atGridPosition: vector_int2(x: nodeXPos + 1, y: nodeYPos)) {
//            if (map[down.y][down.x] != "." && map[up.y][up.x] != ".") || (map[left.y][left.x] != "." && map[right.y][right.x] != ".") {
//                return false
//            }
//        }
//        return true
//    }

}

struct Cheat {
    let start: Coord
    let end: Coord
}
