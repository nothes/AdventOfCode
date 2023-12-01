//
//  day18.swift
//  AoC
//
//  Created by Rachael Worthington on 12/17/22.
//

import Foundation

func day18() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 18/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
        print(shape.surfaceArea())
    } catch {
        print(error.localizedDescription)
    }
}

var shape: Shape = Shape()
fileprivate func parseInput(_ text: String) {
    text.enumerateLines(invoking: { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            let position = line.split(separator: ",")
            shape.add(coord: ThreeDCoord(x: Int(position[0])!, y: Int(position[1])!, z: Int(position[2])!))
        }
    })
}

struct ThreeDCoord: CustomStringConvertible, Equatable, Hashable {
    var x: Int
    var y: Int
    var z: Int

    var description: String {
        return "(\(x), \(y), \(z))"
    }

    init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    static func == (lhs: ThreeDCoord, rhs: ThreeDCoord) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    func adjacentCoords() -> [ThreeDCoord] {
        var adjacentCoords: [ThreeDCoord] = []
        adjacentCoords.append(ThreeDCoord(x: self.x - 1, y: self.y, z: self.z))
        adjacentCoords.append(ThreeDCoord(x: self.x + 1, y: self.y, z: self.z))
        adjacentCoords.append(ThreeDCoord(x: self.x, y: self.y + 1, z: self.z))
        adjacentCoords.append(ThreeDCoord(x: self.x, y: self.y - 1, z: self.z))
        adjacentCoords.append(ThreeDCoord(x: self.x, y: self.y, z: self.z + 1))
        adjacentCoords.append(ThreeDCoord(x: self.x, y: self.y, z: self.z - 1))
        return adjacentCoords
    }

}

enum Dimension {
    case x
    case y
    case z
}

class Surface: CustomStringConvertible, Equatable {
    var coord: ThreeDCoord
    var dimension: Dimension

    init(coord: ThreeDCoord, dimension: Dimension, lowSide: Bool) {
        self.coord = coord
        self.dimension = dimension
        if lowSide == false {
            switch (dimension) {
            case .x:
                self.coord = ThreeDCoord(x: coord.x + 1, y: coord.y, z: coord.z)
            case .y:
                self.coord = ThreeDCoord(x: coord.x, y: coord.y + 1, z: coord.z)
            case .z:
                self.coord = ThreeDCoord(x: coord.x, y: coord.y, z: coord.z + 1)
            }
        }
    }

    var description: String {
        return "\(coord): low side of \(dimension)"
    }

    static func == (lhs: Surface, rhs: Surface) -> Bool {
        return lhs.coord == rhs.coord && lhs.dimension == rhs.dimension
    }

    static func removeTouching(surfaces: [Surface], from coord: ThreeDCoord) -> [Surface] {
        let coordSurfaces: [Surface] = Surface.surfacesFor(coord: coord)
        var newSurfaces = Array(surfaces) // copy of our current outer surfaces of our shape.
        for surface in coordSurfaces { // for each surface on my new shape
            if newSurfaces.contains(surface) {
                if let index = newSurfaces.firstIndex(of: surface) {
                    newSurfaces.remove(at: index)
                }
            } else {
                newSurfaces.append(surface)
            }
        }
        return newSurfaces
    }

    static func surfacesFor(coord: ThreeDCoord) -> [Surface] {
        var surfaces: [Surface] = []
        surfaces.append(Surface(coord: coord, dimension: .x, lowSide: true))
        surfaces.append(Surface(coord: coord, dimension: .x, lowSide: false))
        surfaces.append(Surface(coord: coord, dimension: .y, lowSide: true))
        surfaces.append(Surface(coord: coord, dimension: .y, lowSide: false))
        surfaces.append(Surface(coord: coord, dimension: .z, lowSide: true))
        surfaces.append(Surface(coord: coord, dimension: .z, lowSide: false))

        return surfaces
    }
}

class Shape {
    private var outerSurfaces: [Surface]
    private var filledSpace: [ThreeDCoord]
    private var knownAirPockets: [ThreeDCoord]
    private let part2 = true

    var xRange: ClosedRange<Int>
    var yRange: ClosedRange<Int>
    var zRange: ClosedRange<Int>

    init() {
        xRange = 0...0
        yRange = 0...0
        zRange = 0...0
        self.outerSurfaces = []
        self.filledSpace = []
        self.knownAirPockets = []
    }

    func add(coord: ThreeDCoord) {
        if filledSpace.isEmpty {
            xRange = coord.x...coord.x
            yRange = coord.y...coord.y
            zRange = coord.z...coord.z
        } else {
            xRange = min(coord.x, xRange.lowerBound)...max(coord.x, xRange.upperBound)
            yRange = min(coord.y, yRange.lowerBound)...max(coord.y, yRange.upperBound)
            zRange = min(coord.z, zRange.lowerBound)...max(coord.z, zRange.upperBound)
        }

        filledSpace.append(coord)
        if !part2 {
            if outerSurfaces.isEmpty {
                outerSurfaces.append(contentsOf: Surface.surfacesFor(coord: coord))
            } else {
                outerSurfaces = Surface.removeTouching(surfaces: outerSurfaces, from: coord)
            }
        }
    }

    func surfaceArea() -> Int {
        if !part2 {
            return outerSurfaces.count
        }

        // lets do a search from an outer corner in all 3 directions, counting up all the surfaces we touch
        // begin at the smallest point.
        let xRan = (self.xRange.lowerBound - 1)...(self.xRange.upperBound + 1)
        let yRan = (self.yRange.lowerBound - 1)...(self.yRange.upperBound + 1)
        let zRan = (self.zRange.lowerBound - 1)...(self.zRange.upperBound + 1)
        var visitedPoints: Set<ThreeDCoord> = Set()
        // move forward in all possible directions, and if you encounter a solid space, add the connecting surface to your count.
        let startSearchPoint = ThreeDCoord(x: xRan.lowerBound, y: yRan.lowerBound, z: zRan.lowerBound)
        var surfaceCount = 0

         recursiveEdgeSearch(searchCoord: startSearchPoint)

        return surfaceCount

        func recursiveEdgeSearch(searchCoord: ThreeDCoord) {
            visitedPoints.insert(searchCoord)
            for coord in searchCoord.adjacentCoords() {
                if !xRan.contains(coord.x) || !yRan.contains(coord.y) || !zRan.contains(coord.z) {
                    //this is outside our search area, ignore it.
                    continue
                }
                if visitedPoints.contains(coord) {
                    // we've already looked at this point, stop it.
                    continue
                }
                if filledSpace.contains(coord) {
                    // this is an edge!
                    surfaceCount += 1
                } else {
                    recursiveEdgeSearch(searchCoord: coord)
                }
            }
        }
    }
}

// pt 2 fails:
// 3430 - Too High
