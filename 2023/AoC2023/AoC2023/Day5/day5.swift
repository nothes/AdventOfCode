//
//  day5.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/4/23.
//

import Foundation
import RegexBuilder

func day5() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day5/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        // part 1
        //parseAlmanac(with: text)
        //findLowestLocation()

        // part 2
        parseAlmanacPt2(with: text)
        findLowestLocation()

    } catch {
        print(error.localizedDescription)
    }
}

struct MaterialMap {
    let source: Int
    let destination: Int
    let length: Int

    func destination(for value: Int) -> Int? {
        let relevantRange = source..<source + length
        guard relevantRange.contains(value) else {
            return nil
        }

        let offset = value - source
        return destination + offset
    }

    func sourceRange() -> Range<Int> {
        return source..<source+length
    }
}

struct Almanac {
    // part 1
    let seeds: [Int]
    let seedToSoil: [MaterialMap]
    let soilToFert: [MaterialMap]
    let fertToWater: [MaterialMap]
    let waterToLight: [MaterialMap]
    let lightToTemp: [MaterialMap]
    let tempToHumidity: [MaterialMap]
    let humidityToLoc: [MaterialMap]

    func location(for seed: Int) -> Int {
        var soil = seed
        for map in seedToSoil {
            if let newSoil = map.destination(for: seed) {
                soil = newSoil
            }
        }

        var fert = soil
        for map in soilToFert {
            if let newFert = map.destination(for: soil) {
                fert = newFert
            }
        }

        var water = fert
        for map in fertToWater {
            if let newWater = map.destination(for: fert) {
                water = newWater
            }
        }

        var light = water
        for map in waterToLight {
            if let newLight = map.destination(for: water) {
                light = newLight
            }
        }

        var temp = light
        for map in lightToTemp {
            if let newTemp = map.destination(for: light) {
                temp = newTemp
            }
        }

        var humidity = temp
        for map in tempToHumidity {
            if let newHumidity = map.destination(for: temp) {
                humidity = newHumidity
            }
        }

        var loc = humidity
        for map in humidityToLoc {
            if let newLoc = map.destination(for: humidity) {
                loc = newLoc
            }
        }
        return loc
    }

    func lowestLocation() -> Int {
        var locs: [Int] = []
        for seed in seeds {
            locs.append(location(for: seed))
        }
        locs.sort()
        return locs.first ?? -1
    }
}

struct Almanac2 {
    // part 1
    let seeds: [Range<Int>]
    let seedToSoil: [MaterialMap]
    let soilToFert: [MaterialMap]
    let fertToWater: [MaterialMap]
    let waterToLight: [MaterialMap]
    let lightToTemp: [MaterialMap]
    let tempToHumidity: [MaterialMap]
    let humidityToLoc: [MaterialMap]

    func location(for seed: Int) -> Int {
        var soil = seed
        for map in seedToSoil {
            if let newSoil = map.destination(for: seed) {
                soil = newSoil
            }
        }

        var fert = soil
        for map in soilToFert {
            if let newFert = map.destination(for: soil) {
                fert = newFert
            }
        }

        var water = fert
        for map in fertToWater {
            if let newWater = map.destination(for: fert) {
                water = newWater
            }
        }

        var light = water
        for map in waterToLight {
            if let newLight = map.destination(for: water) {
                light = newLight
            }
        }

        var temp = light
        for map in lightToTemp {
            if let newTemp = map.destination(for: light) {
                temp = newTemp
            }
        }

        var humidity = temp
        for map in tempToHumidity {
            if let newHumidity = map.destination(for: temp) {
                humidity = newHumidity
            }
        }

        var loc = humidity
        for map in humidityToLoc {
            if let newLoc = map.destination(for: humidity) {
                loc = newLoc
            }
        }
        return loc
    }

    func lowestLocation() -> Int {
        //ok, i have ranges of seeds, all in rows. for each range, see what range of the next products we have is?
        let seedRanges = seeds
        let relevantSoilRanges: [Range<Int>] = []
        for map in seedToSoil {
            for seedRange in seedRanges {
                if map.sourceRange().overlaps(seedRange) {
                    
                }

            }

        }
        return -1
    }
}


let mapHeader = Regex {
    OneOrMore(.word)
    "-"
    OneOrMore(.word)
    "-"
    OneOrMore(.word)
    OneOrMore(.whitespace)
    "map:"
}

var almanac: Almanac? = nil
var almanac2: Almanac2? = nil

func parseAlmanac(with input: String) {
    var readingMap = false
    var readMaps: [[MaterialMap]] = []
    var seeds: [Int] = []
    var currentMaps: [MaterialMap] = []

    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            if line.prefixMatch(of: /seeds:/) != nil {
                let seedLine = line.trimmingPrefix(/seeds:/)
                seeds = seedLine.split(separator: /\s+/).map { seedStr in
                    Int(seedStr)!
                }

            } else if readingMap {
                let values = line.split(separator: /\s+/).map{ val in
                    Int(val)!
                }
                currentMaps.append(MaterialMap(source: values[1], destination: values[0], length: values[2]))

            } else if line.prefixMatch(of: mapHeader) != nil {
                readingMap = true
                print("reading \(line)")
            }
        } else {
            readingMap = false
            if currentMaps.isEmpty == false {
                readMaps.append(currentMaps)
                currentMaps = []
            }
        }
    }
    // don't forget the last map we read!
    readMaps.append(currentMaps)

    assert(readMaps.count == 7)
    
    almanac = Almanac(seeds: seeds, seedToSoil: readMaps[0], soilToFert: readMaps[1], fertToWater: readMaps[2], waterToLight: readMaps[3], lightToTemp: readMaps[4], tempToHumidity: readMaps[5], humidityToLoc: readMaps[6])
}

func parseAlmanacPt2(with input: String) {
    var readingMap = false
    var readMaps: [[MaterialMap]] = []
    var seeds: [Range<Int>] = []
    var currentMaps: [MaterialMap] = []

    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            if line.prefixMatch(of: /seeds:/) != nil {
                let seedLine = line.trimmingPrefix(/seeds:/)
                let values = seedLine.split(separator: /\s+/).map { seedStr in
                    Int(seedStr)!
                }

                var location = -1
                var length = -1

                for value in values {
                    if location == -1 {
                        location = value
                    } else if length == -1 {
                        length = value
                    }

                    if location != -1 && length != -1 {
                        seeds.append(location..<location+length)
                        location = -1
                        length = -1
                    }
                }

            } else if readingMap {
                let values = line.split(separator: /\s+/).map{ val in
                    Int(val)!
                }
                currentMaps.append(MaterialMap(source: values[1], destination: values[0], length: values[2]))

            } else if line.prefixMatch(of: mapHeader) != nil {
                readingMap = true
                print("reading \(line)")
            }
        } else {
            readingMap = false
            if currentMaps.isEmpty == false {
                readMaps.append(currentMaps)
                currentMaps = []
            }
        }
    }
    // don't forget the last map we read!
    readMaps.append(currentMaps)

    assert(readMaps.count == 7)

    almanac2 = Almanac2(seeds: seeds, seedToSoil: readMaps[0], soilToFert: readMaps[1], fertToWater: readMaps[2], waterToLight: readMaps[3], lightToTemp: readMaps[4], tempToHumidity: readMaps[5], humidityToLoc: readMaps[6])
}

func findLowestLocation() {
    print(almanac?.lowestLocation() ?? -1)
}

