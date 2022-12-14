//
//  day12.swift
//  AoC
//
//  Created by Rachael Worthington on 12/11/22.
//

import Foundation

func day12() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 12/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
        //calculateRoutes()
        calculateLaziestRoutes()
    } catch {
        print(error.localizedDescription)
    }
}

var map: Dictionary<Coord, Int> = Dictionary() // coords go positive to the right and down, int is the altitude. start is 0
var startPoint: Coord = Coord(x: 0, y: 0)
var endPoint: Coord = Coord(x: 0, y: 0)
var lowestPoints: [Coord] = []

fileprivate func parseInput(_ text: String) {
    var x = 0
    var y = 0
    text.enumerateLines(invoking: { line, stop in
     //   print("parsing line" + line)
        if line.isEmpty == false { // stop forgetting this.
            var lineToNom = line
            while lineToNom.isEmpty == false {
                let altChar = lineToNom.removeFirst()
                var altitude = 0
                if altChar.isLowercase {
                    altitude = Int(altChar.asciiValue!) // a = 97
                    altitude -= 96 // align so that a = 1
                    if altChar == "a" {
                        lowestPoints.append(Coord(x: x, y: y))
                    }
                } else if altChar == "S" {
                    altitude = Int(("a".first?.asciiValue)!)
                    altitude -= 96 // align so that a = 1
                    startPoint = Coord(x: x, y: y)
                    lowestPoints.append(startPoint)
                } else if altChar == "E" {
                    altitude = Int(("z".first?.asciiValue)!)
                    altitude -= 96 // align so that a = 1
                    endPoint = Coord(x: x, y: y)
                }
                //record the next point
                let coord = Coord(x: x, y: y)
                map[coord] = altitude
                // increment the x position
                x += 1
            }
            x = 0
            // increment the y pos
            y += 1

        }
    })
}

class TreeNode {
    let coord: Coord
    let parentNode: TreeNode?
    var children: [TreeNode]
    var depth: Int

    init(coord: Coord, parentNode: TreeNode? = nil, children: [TreeNode] = [], depth: Int = 0) {
        self.coord = coord
        self.parentNode = parentNode
        self.children = children
        self.depth = depth
    }

    var altitude: Int {
        return map[coord]!
    }

    var description: String {
        return "\(coord) \(altitude)"
    }

}

var rootNode = TreeNode(coord: startPoint)
var leaves: [TreeNode] = [rootNode]
var visitedCoords: Set<Coord> = Set()

func calculateRoutes() {
    visitedCoords.insert(rootNode.coord)
    solveRoute(from: [rootNode.coord])
}

func calculateLaziestRoutes() {
    visitedCoords = Set(lowestPoints)
    for point in lowestPoints {
        let newNode = TreeNode(coord: point, parentNode: nil, children: [], depth: 0)
        leaves.append(newNode)
    }
    solveRoute(from: lowestPoints)
}

func solveRoute(from currentLeaves: [Coord]) {
    print("solving")
    var localLeaves = Array(leaves)

    while true {
        //get all our leaves
        leaves = []

        for leaf in localLeaves {
            print("** checking coord \(leaf.coord)")
            // are we there yet?
            if leaf.coord == endPoint {
                print("we are here at \(leaf.coord), after \(leaf.depth)!!")
                return
            }
            // no? ok, take your next moves
            var possibleMoves: [Coord] = []
            let leafCoord = leaf.coord
            // the 4 moves we can make are as follows:
            possibleMoves.append(Coord(x: leafCoord.x-1, y: leafCoord.y))
            possibleMoves.append(Coord(x: leafCoord.x+1, y: leafCoord.y))
            possibleMoves.append(Coord(x: leafCoord.x, y: leafCoord.y-1))
            possibleMoves.append(Coord(x: leafCoord.x, y: leafCoord.y+1))

            let currentAlt = leaf.altitude
            for move in possibleMoves {
                let alt = map[move]
                if let alt = alt, (alt - currentAlt) <= 1 && visitedCoords.contains(move) == false { // maybe our next move would take us off the map, or in a circle. that's not valid.
                  //  print("making a new node with coord \(move)")
                    let newNode = TreeNode(coord: move, parentNode: leaf, children: [], depth: leaf.depth + 1)
                    leaf.children.append(newNode)
                    leaves.append(newNode)
                    visitedCoords.insert(move)
                }
            }
        }
        assert(leaves.count > 0)
        localLeaves = Array(leaves)
        print("new leaf count = \(leaves.count)")
    }
}
