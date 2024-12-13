//
//  day12.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/11/24.
//

import Foundation

func day12() {
    let input = readInput(forDay: 12)

    var map: [[String]] = [] // might not be useful at all.
    var plantsPresent: Set<String> = Set() // not sure if useful, yet...
    var plots: [Plot] = []
    var coordsOfPlants: [String: [Coord]] = [:]

    let lines = input.split(separator:"\n")
    let maxX: Int = lines[0].count
    let maxY: Int = lines.count
    for y in 0..<lines.count {
        let line = lines[y]
        var xIndex = line.startIndex
        var row:[String] = []
        for x in 0..<lines[0].count {
            let char = String(line[xIndex])
            row.append(char)
            plantsPresent.insert(char)
            var newCoordList: [Coord] = coordsOfPlants[char] ?? []
            newCoordList.append(Coord(x: x, y: y))
            coordsOfPlants[char] = newCoordList
            xIndex = line.index(after: xIndex)
        }
        map.append(row)
    }

  //  print("map: \(map)")
    var alreadyChecked: [Coord] = []
    // sort into plots

    for x in 0..<maxX {
        for y in 0..<maxY {
            let start = Coord(x: x, y: y)
            let crop = map[y][x]
            if !alreadyChecked.contains(start) {
                let coordsOfPlot = recursiveFindPlot(ofType: crop, startingCoord: start)
                if !coordsOfPlot.isEmpty {
                    let plot = Plot(crop: crop, coords: Set(coordsOfPlot), map: map)
                //    print("plot: \(plot)")
                    plots.append(plot)
                }
            }
        }
    }

  //  print("plots \(plots.count) = \(plots)")
    // Due to "modern" business practices, the price of fence required for a region is found by multiplying that region's area by its perimeter. The total price of fencing all regions on a map is found by adding together the price of fence for every region on the map.

    // part 1:
    var total = 0
//    for plot in plots {
////        print("plot \(plot.crop): area: \(plot.area) perimeter: \(plot.perimeter)")
////        print("cost: \(plot.price)")
//        total += plot.price
//    }

    print("total price: \(total)")

    // part 2:
    total = 0
    for plot in plots {
        total += plot.discountPrice
    }

    print("discounted price: \(total)")


    func recursiveFindPlot(ofType type: String, startingCoord: Coord) -> [Coord] {
        if alreadyChecked.contains(startingCoord) || map[startingCoord.y][startingCoord.x] != type {
            return []
        }

        var plotCoords = [startingCoord]
        alreadyChecked.append(startingCoord)

        // check left
        if (0..<maxX).contains(startingCoord.x - 1) {
            let leftCoord = Coord(x: startingCoord.x - 1, y: startingCoord.y)
            if map[leftCoord.y][leftCoord.x] == type {
                plotCoords.append(contentsOf: recursiveFindPlot(ofType: type, startingCoord: leftCoord))
            }
        }

        // check right
        if (0..<maxX).contains(startingCoord.x + 1) {
            let rightCoord = Coord(x: startingCoord.x + 1, y: startingCoord.y)
            if map[rightCoord.y][rightCoord.x] == type {
                plotCoords.append(contentsOf: recursiveFindPlot(ofType: type, startingCoord: rightCoord))
            }
        }

        // check up
        if (0..<maxY).contains(startingCoord.y - 1) {
            let upCoord = Coord(x: startingCoord.x, y: startingCoord.y - 1)
            if map[upCoord.y][upCoord.x] == type {
                plotCoords.append(contentsOf: recursiveFindPlot(ofType: type, startingCoord: upCoord))
            }
        }

        // check down
        if (0..<maxY).contains(startingCoord.y + 1) {
            let downCoord = Coord(x: startingCoord.x, y: startingCoord.y + 1)
            if map[downCoord.y][downCoord.x] == type {
                plotCoords.append(contentsOf: recursiveFindPlot(ofType: type, startingCoord: downCoord))
            }
        }
        return plotCoords
    }

    class Plot: CustomDebugStringConvertible {
        var debugDescription: String {
            "crop: \(crop) \(coords)"
        }

        var crop: String = ""
        var coords: Set<Coord> = []
        let map: [[String]]

        init(crop: String, coords: Set<Coord> = [], map: [[String]]) {
            self.crop = crop
            self.coords = coords
            self.map = map
        }

        var price: Int {
            return perimeter * area
        }

        var area: Int {
            return coords.count
        }

        var perimeter: Int {
            var perimCount = 0
            let maxX = map.count
            let maxY = map[0].count
            for coord in coords {

                // left
                if (0..<maxX).contains(coord.x - 1) {
                    let leftCoord = Coord(x: coord.x - 1, y: coord.y)
                    if map[leftCoord.y][leftCoord.x] != crop {
                        perimCount += 1
                    }
                } else {
                    perimCount += 1
                }

                // right
                if (0..<maxX).contains(coord.x + 1) {
                    let rightCoord = Coord(x: coord.x + 1, y: coord.y)
                    if map[rightCoord.y][rightCoord.x] != crop {
                        perimCount += 1
                    }
                } else {
                    perimCount += 1
                }

                // up
                if (0..<maxY).contains(coord.y - 1) {
                    let upCoord = Coord(x: coord.x, y: coord.y - 1)
                    if map[upCoord.y][upCoord.x] != crop {
                        perimCount += 1
                    }
                } else {
                    perimCount += 1
                }

                // down
                if (0..<maxY).contains(coord.y + 1) {
                    let rightCoord = Coord(x: coord.x, y: coord.y + 1)
                    if map[rightCoord.y][rightCoord.x] != crop {
                        perimCount += 1
                    }
                } else {
                    perimCount += 1
                }
            }
            return perimCount
        }

        var edges: Int {
            var corners = 0
            let maxX = map.count
            let maxY = map[0].count
            for coord in coords {
                var leftEdge = false
                var rightEdge = false
                var upEdge = false
                var downEdge = false


                // left
                if (0..<maxX).contains(coord.x - 1) {
                    let leftCoord = Coord(x: coord.x - 1, y: coord.y)
                    if map[leftCoord.y][leftCoord.x] != crop {
                        leftEdge = true
                    }
                } else {
                    leftEdge = true
                }

                // right
                if (0..<maxX).contains(coord.x + 1) {
                    let rightCoord = Coord(x: coord.x + 1, y: coord.y)
                    if map[rightCoord.y][rightCoord.x] != crop {
                        rightEdge = true
                    }
                } else {
                    rightEdge = true
                }

                // up
                if (0..<maxY).contains(coord.y - 1) {
                    let upCoord = Coord(x: coord.x, y: coord.y - 1)
                    if map[upCoord.y][upCoord.x] != crop {
                        upEdge = true
                    }
                } else {
                    upEdge = true
                }

                // down
                if (0..<maxY).contains(coord.y + 1) {
                    let rightCoord = Coord(x: coord.x, y: coord.y + 1)
                    if map[rightCoord.y][rightCoord.x] != crop {
                        downEdge = true
                    }
                } else {
                    downEdge = true
                }

                // convex edges
                if upEdge && leftEdge {
                    corners += 1
                }

                if upEdge && rightEdge {
                    corners += 1
                }

                if downEdge && leftEdge {
                    corners += 1
                }

                if downEdge && rightEdge {
                    corners += 1
                }


                // convex edges
                if !upEdge && !leftEdge {
                    // check up-left
                    if (0..<maxY).contains(coord.y - 1) && (0..<maxX).contains(coord.x - 1) {
                        let leftUpCoord = Coord(x:coord.x - 1, y: coord.y - 1)
                        if map[leftUpCoord.y][leftUpCoord.x] != crop {
                            corners += 1
                        }
                    }
                }

                if !upEdge && !rightEdge {
                    // check up-right
                    if (0..<maxY).contains(coord.y - 1) && (0..<maxX).contains(coord.x + 1) {
                        let leftUpCoord = Coord(x:coord.x + 1, y: coord.y - 1)
                        if map[leftUpCoord.y][leftUpCoord.x] != crop {
                            corners += 1
                        }
                    }
                }

                if !downEdge && !leftEdge {
                    // check down-left
                    if (0..<maxY).contains(coord.y + 1) && (0..<maxX).contains(coord.x - 1) {
                        let leftUpCoord = Coord(x:coord.x - 1, y: coord.y + 1)
                        if map[leftUpCoord.y][leftUpCoord.x] != crop {
                            corners += 1
                        }
                    }
                }

                if !downEdge && !rightEdge {
                    // check down-right
                    if (0..<maxY).contains(coord.y + 1) && (0..<maxX).contains(coord.x + 1) {
                        let leftUpCoord = Coord(x:coord.x + 1, y: coord.y + 1)
                        if map[leftUpCoord.y][leftUpCoord.x] != crop {
                            corners += 1
                        }
                    }
                }


            }
            return corners
        }


        var discountPrice: Int {
            return area * edges
        }
    }
}
