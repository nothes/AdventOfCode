//
//  day15.swift
//  AoC
//
//  Created by Rachael Worthington on 12/14/22.
//

import Foundation

func day15() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 15/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
//        checkTheResult()
        checkTheResult2()
    } catch {
        print(error.localizedDescription)
    }
}

fileprivate var map: Map?

fileprivate func parseInput(_ text: String) {
    var minX: Int = 0
    var maxX: Int = 0
    var minY: Int = 0
    var maxY: Int = 0
    var data: [(beacon: Coord, sensor: Coord)] = []
    text.enumerateLines(invoking: { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            let splitLine = line.split(separator: " ")
            var sensorXStr = String(splitLine[2])
            sensorXStr.removeFirst(2) // x=
            sensorXStr.removeLast() // ,
            let sensorX = Int(sensorXStr)!
            var sensorYStr = String(splitLine[3])
            sensorYStr.removeFirst(2) // y=
            sensorYStr.removeLast() // :
            let sensorY = Int(sensorYStr)!
            var beaconXStr = splitLine[8]
            beaconXStr.removeFirst(2) // x=
            beaconXStr.removeLast() //,
            let beaconX = Int(beaconXStr)!
            var beaconYStr = splitLine[9]
            beaconYStr.removeFirst(2) //y=
            let beaconY = Int(beaconYStr)!
            let sensorPos = Coord(x: sensorX, y: sensorY)
            let beaconPos = Coord(x: beaconX, y: beaconY)
            data.append((beacon: beaconPos, sensor: sensorPos))
            let distance = abs(beaconX - sensorX) + abs(beaconY - sensorY)
            if sensorX-distance < minX {
                minX = sensorX-distance
            }
            if sensorY-distance < minY {
                minY = sensorY-distance
            }
            if beaconX < minX {
                minX = beaconX
            }
            if beaconY < minY {
                minY = beaconY
            }
            if sensorX+distance > maxX {
                maxX = sensorX+distance
            }
            if sensorY+distance > maxY {
                maxY = sensorY+distance
            }
            if beaconX > maxX {
                maxX = beaconX
            }
            if beaconY > maxY {
                maxY = beaconY
            }
        }
    })

    map = Map(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
    guard let map = map else { print("our map didn't init right.");return }
    for (beacon, sensor) in data {
        map.read(beacon: beacon, sensor: sensor)
    }
}

enum ScanResult {
    case empty
    case beacon
    case sensor
    case unknown
}

struct Sensor {
    var location: Coord
    var distance: Int
    var beacon: Coord
}

class Map {
    var sensors: [Sensor]
    let minX: Int
    let minY: Int
    let maxX: Int
    let maxY: Int

    init(minX: Int, maxX: Int, minY: Int, maxY: Int) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
        self.sensors = []
    }

    func read(beacon: Coord, sensor: Coord) {
        guard let map = map else { print("missing our map!"); return }
//        print("beacon: \(beacon), sensor: \(sensor)")
        let distance = abs(beacon.x - sensor.x) + abs(beacon.y - sensor.y)
        let sensor = Sensor(location: sensor, distance: distance, beacon: beacon)
        map.sensors.append(sensor)
    }

    func result(at coord: Coord) -> ScanResult {
        for sensor in sensors {
            if sensor.location == coord {
//                print("\(coord) has a sensor")
                return .sensor
            }
            if sensor.beacon == coord {
//                print("\(coord) has a beacon")
                return .beacon
            }
            let sensingDistance = sensor.distance
            let currentDistance = abs(sensor.location.x - coord.x) + abs(sensor.location.y - coord.y)
//            print("\(coord) is \(currentDistance) from \(sensor.location) power: \(sensingDistance)")
            if currentDistance <= sensingDistance { //
                return .empty
            }
        }
        return .unknown
    }

    func findDistressBeacon(minPos: Int, maxPos: Int) {
        var yRow: [[ClosedRange<Int>]] = Array(repeating: [minPos ... maxPos], count: maxPos - minPos + 1)
        // for each sensor, remove any coords that it knows about.
        for sensorInfo in sensors {
            let distance = sensorInfo.distance
            let sensor = sensorInfo.location

            let yRange = max(minPos, sensor.y - distance) ... min(maxPos, sensor.y + distance)
            for y in yRange {
                if y < sensor.y { // top of diamond
                    let remainingDist = distance - abs(sensor.y - y)
                    let xRange = sensor.x - remainingDist ... sensor.x + remainingDist
                    var newRanges: [ClosedRange<Int>] = []
                    for range in yRow[y] { // unknown areas
                        if xRange.overlaps(range) { // we can mark more areas known!
        //                  range:   |-----|
        //     possible xRange results:
        //                           |-----|            -- equal
        //                        |------|              -- sticks off to left
        //                              |------|        -- sticks off to right
        //                             |--|             -- contained within
        //                        |-------------|       -- contains
                            if range == xRange {
                                // junk the mofo, by not adding it to our new range array
                            }
                            if xRange.lowerBound <= range.lowerBound {
                                if xRange.upperBound == range.upperBound {
                                    // junk it
                                } else if xRange.upperBound < range.upperBound {
                                    let newRange = max(xRange.upperBound + 1, minPos) ... min(range.upperBound, maxPos)
                                    newRanges.append(newRange)
                                } else if xRange.upperBound > range.upperBound {
                                    //junk it
                                }
                            } else if xRange.lowerBound > range.lowerBound {
                                if xRange.upperBound == range.upperBound {
                                    let newRange = max(minPos, range.lowerBound) ... min(xRange.lowerBound - 1, maxPos)
                                    newRanges.append(newRange)
                                } else if xRange.upperBound < range.upperBound {
                                    // create 2 new ranges
                                    var newRange = max(minPos, range.lowerBound) ... min(maxPos, xRange.lowerBound - 1)
                                    newRanges.append(newRange)
                                    newRange = max(minPos, xRange.upperBound + 1) ... min(maxPos, range.upperBound)
                                    newRanges.append(newRange)
                                } else if xRange.upperBound > range.upperBound {
                                    let newRange = max(minPos, range.lowerBound) ... min(maxPos, xRange.lowerBound - 1)
                                    newRanges.append(newRange)
                                }
                            }
                        } else {
                            newRanges.append(range)
                        }
                        yRow[y] = newRanges
                    }
                } else if y == sensor.y { // center row
                                          //  print("setting \(currentCoord) to empty")
                    var newRanges: [ClosedRange<Int>] = []
                    for range in yRow[y] {
                        let xRange = sensor.x - distance ... sensor.x + distance
                        if xRange.overlaps(range) { // we can mark more areas known!
                                                    //                  range:   |-----|
                                                    //     possible xRange results:
                                                    //                           |-----|            -- equal
                                                    //                        |------|              -- sticks off to left
                                                    //                              |------|        -- sticks off to right
                                                    //                             |--|             -- contained within
                                                    //                        |-------------|       -- contains
                            if range == xRange {
                                // junk the mofo, by not adding it to our new range array
                            }
                            if xRange.lowerBound <= range.lowerBound {
                                if xRange.upperBound == range.upperBound {
                                    // junk it
                                } else if xRange.upperBound < range.upperBound {
                                    let newRange = max(minPos, xRange.upperBound + 1) ... min(maxPos, range.upperBound)
                                    newRanges.append(newRange)
                                } else if xRange.upperBound > range.upperBound {
                                    //junk it
                                }
                            } else if xRange.lowerBound > range.lowerBound {
                                if xRange.upperBound == range.upperBound {
                                    let newRange = max(minPos, range.lowerBound) ... min(maxPos, xRange.lowerBound - 1)
                                    newRanges.append(newRange)
                                } else if xRange.upperBound < range.upperBound {
                                    // create 2 new ranges
                                    var newRange = max(minPos, range.lowerBound) ... min(maxPos, xRange.lowerBound - 1)
                                    newRanges.append(newRange)
                                    newRange = max(minPos, xRange.upperBound + 1) ... min(maxPos, range.upperBound)
                                    newRanges.append(newRange)
                                } else if xRange.upperBound > range.upperBound {
                                    let newRange = max(minPos, range.lowerBound) ... min(maxPos, xRange.lowerBound - 1)
                                    newRanges.append(newRange)
                                }
                            }
                        } else {
                            newRanges.append(range)
                        }
                        yRow[y] = newRanges
                    }

                } else if y > sensor.y { //bottom of diamond
                    let remainingDist = distance - abs(sensor.y - y)
                    let xRange = sensor.x - remainingDist ... sensor.x + remainingDist
                    var newRanges: [ClosedRange<Int>] = []
                    for range in yRow[y] { // unknown areas
                        if xRange.overlaps(range) { // we can mark more areas known!
                                                    //                  range:   |-----|
                                                    //     possible xRange results:
                                                    //                           |-----|            -- equal
                                                    //                        |------|              -- sticks off to left
                                                    //                              |------|        -- sticks off to right
                                                    //                             |--|             -- contained within
                                                    //                        |-------------|       -- contains
                            if range == xRange {
                                // junk the mofo, by not adding it to our new range array
                            }
                            if xRange.lowerBound <= range.lowerBound {
                                if xRange.upperBound == range.upperBound {
                                    // junk it
                                } else if xRange.upperBound < range.upperBound {
                                    let newRange = max(minPos, xRange.upperBound + 1) ... min(maxPos, range.upperBound)
                                    newRanges.append(newRange)
                                } else if xRange.upperBound > range.upperBound {
                                    //junk it
                                }
                            } else if xRange.lowerBound > range.lowerBound {
                                if xRange.upperBound == range.upperBound {
                                    let newRange = max(minPos, range.lowerBound) ... min(maxPos, xRange.lowerBound - 1)
                                    newRanges.append(newRange)
                                } else if xRange.upperBound < range.upperBound {
                                    // create 2 new ranges
                                    var newRange = max(minPos, range.lowerBound) ... min(maxPos, xRange.lowerBound - 1)
                                    newRanges.append(newRange)
                                    newRange = max(minPos, xRange.upperBound + 1) ... min(maxPos, range.upperBound)
                                    newRanges.append(newRange)
                                } else if xRange.upperBound > range.upperBound {
                                    let newRange = max(minPos, range.lowerBound) ... min(maxPos, xRange.lowerBound - 1)
                                    newRanges.append(newRange)
                                }
                            }
                        } else {
                            newRanges.append(range)
                        }
                        yRow[y] = newRanges
                    }
                }
            }
        }
        let finalY = yRow.firstIndex { range in
            range.isEmpty == false
        }
        guard let finalY = finalY else {print(" no y coords found"); return }
        print("finalY = \(finalY)")
        let xRanges = yRow[finalY]

        let finalX = xRanges.first?.lowerBound

        guard let finalX = finalX else { print("no x coords found"); return }
        print("final coord: (\(finalX), \(finalY)")
        print("freq: \(Coord(x: finalX, y: finalY).tuningFrequency())")
    }
}

//let checkY = 10 // ans should be 26
let checkY = 2000000

func checkTheResult() {
    var clearedCount = 0
  //  var drawingString = ""
    guard let map = map else { print("the world doesn't exist"); return }
    for x in map.minX ... map.maxX {
        let result = map.result(at: Coord(x: x, y: checkY))
//        switch result {
//        case .sensor:
//            drawingString.append("S")
//        case .beacon:
//            drawingString.append("B")
//        case .empty:
//            drawingString.append("#")
//        case .unknown:
//            drawingString.append(".")
//        }

        if result == .empty {
            clearedCount += 1
        }
    }
 //   print(drawingString)
    // ..####B######################..
    print("map[\(checkY)] has \(clearedCount) cleared spaces")
}

let beaconMin = 0//x and y coordinates each no lower than 0 and no larger than 4000000.
let beaconMax = 4000000

extension Coord {
    func tuningFrequency() -> Int {
        //To isolate the distress beacon's signal, you need to determine its tuning frequency, which can be found by multiplying its x coordinate by 4000000 and then adding its y coordinate.
        return (x * 4000000) + y

    }
}

func checkTheResult2() {
    guard let map = map else { print("the world is corrupt!"); return }
    map.findDistressBeacon(minPos: beaconMin, maxPos: beaconMax)

    // brute force: bad idea.
//    for x in beaconMin ... beaconMax {
//        for y in beaconMin ... beaconMax {
//            let checkCoord = Coord(x: x, y: y)
//            if map.result(at: checkCoord) == .unknown {
//                print("distress beacon at \(checkCoord), with freq: \(checkCoord.tuningFrequency())")
//            }
//        }
//    }
}
