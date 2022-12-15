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
        checkTheResult()
    } catch {
        print(error.localizedDescription)
    }
}

var caves: CaveSystem?

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

    var map = Map(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
    caves = CaveSystem(map: map)
    for (beacon, sensor) in data {
        caves?.read(beacon: beacon, sensor: sensor)
    }
}

enum ScanResult {
    case empty
    case beacon
    case sensor
    case unknown
}

class Map {
    var map: [[ScanResult]]
    var xAdjustment: Int = 0
    var yAdjustment: Int = 0
    let minX: Int
    let minY: Int
    let maxX: Int
    let maxY: Int

    init(minX: Int, maxX: Int, minY: Int, maxY: Int) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
        let mapRow = Array(repeating: ScanResult.unknown, count: maxX - minX + 1) // because 0 indexing is hiiilarious.
        self.map = Array(repeating: mapRow, count: maxY - minY + 1)

        self.xAdjustment = 0 - minX
        self.yAdjustment = 0 - minY
    }

    func result(at coord: Coord) -> ScanResult {
        return map[coord.x + xAdjustment][coord.y + yAdjustment]
    }

    func setResult(at coord: Coord, to result: ScanResult) {
        map[coord.x + xAdjustment][coord.y + yAdjustment] = result
    }
}

class CaveSystem {
    var beacons: Set<Coord>
    var map: Map

    init(map: Map) {
        self.beacons = Set()
        self.map = map
    }

    func read(beacon: Coord, sensor: Coord) {
        print("beacon: \(beacon), sensor: \(sensor)")
        let distance = abs(beacon.x - sensor.x) + abs(beacon.y - sensor.y)
        beacons.insert(beacon)
        map.setResult(at: beacon, to: .beacon)
        map.setResult(at: sensor, to: .sensor)
        print("distance = \(distance)")
        assert(distance >= 1) // positive and the sensor isn't on the beacon.
        //let diameter = (distance * 2) + 1
        // a diamond around the sensor for <distance> coords is empty of beacons.
        //          *
        //         ***      // distance of 3
        //        *****     // diameter of 7
        //       ***S***
        //        *****
        //         ***
        //          *
        //
        // from minX -> maxX
        // from minY -v maxY
        // build it by rows, increasing
        let yRange = sensor.y - distance ... sensor.y + distance
        let rowWidth = (distance * 2) + 1
        for y in yRange {
            if y < sensor.y { // top of diamond
                let remainingDist = distance - abs(sensor.y - y)
                let xRange = sensor.x - remainingDist ... sensor.x + remainingDist
                for x in xRange {
                    let currentCoord = Coord(x: x, y: y)
                  //  print("setting \(currentCoord) to empty")
                    if map.result(at: currentCoord) == .unknown { // don't overwrite a beacon or sensor
                        map.setResult(at: currentCoord, to: .empty)
                    }
                }
            } else if y == sensor.y { // center row
                for x in sensor.x - distance ... sensor.x + distance {
                    let currentCoord = Coord(x: x, y: y)
                  //  print("setting \(currentCoord) to empty")
                    if map.result(at: currentCoord) == .unknown { // don't overwrite a beacon or sensor
                        map.setResult(at: currentCoord, to: .empty)
                    }
                }
            } else if y > sensor.y { //bottom of diamond
                let remainingDist = distance - abs(sensor.y - y)
                let xRange = sensor.x - remainingDist ... sensor.x + remainingDist
                for x in xRange {
                    let currentCoord = Coord(x: x, y: y)
                    print("setting \(currentCoord) to empty")
                    if map.result(at: currentCoord) == .unknown { // don't overwrite a beacon or sensor
                        map.setResult(at: currentCoord, to: .empty)
                    }
                }
            }
        }
    }
}

//let checkY = 10 // ans should be 26
let checkY = 2000000

func checkTheResult() {
    var clearedCount = 0
    guard let caves = caves else { print("the world doesn't exist"); return }
    let map = caves.map
    //var resultDrawing = ""
    for x in map.minX ... map.maxX {
        let result = map.result(at: Coord(x: x, y: checkY))
        if result == .empty {
            clearedCount += 1
        }
    }
    print("map[\(checkY)] has \(clearedCount) cleared spaces")
}

