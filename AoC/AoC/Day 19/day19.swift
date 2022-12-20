//
//  day19.swift
//  AoC
//
//  Created by Rachael Worthington on 12/18/22.
//

import Foundation

func day19() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 19/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
        compareBlueprints()
    } catch {
        print(error.localizedDescription)
    }
}

fileprivate func parseInput(_ text: String) {
    text.enumerateLines(invoking: { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            // Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
            var chunks = line.split(separator: " ")
            _ = chunks.removeFirst()
            let id: Int = Int(chunks.removeFirst().filter { char in
                char != ":"
            })!
            chunks.removeFirst(4) //Each ore robot costs
            let oreRobotCost = Cost(ore: Int(chunks.removeFirst())!, clay: 0, obsidion: 0)
            // assuming ore bots will never cost clay
            assert(chunks.removeFirst() == "ore.") // without the period, it will need more costs and this will have to be tweaked.
            chunks.removeFirst(4) // Each clay robot costs
            let clayRobotCost = Cost(ore: Int(chunks.removeFirst())!, clay: 0, obsidion: 0)
            //assuming clay bot will never cost clay
            assert(chunks.removeFirst() == "ore.") // without the period, it will need more costs and this will have to be tweaked.
            chunks.removeFirst(4) // each obsidion robot costs
            let oOreCost = Int(chunks.removeFirst())!
            var oClayCost: Int = 0
            if chunks.removeFirst() == "ore" { // no period
                chunks.removeFirst() // and
                oClayCost = Int(chunks.removeFirst())!
                assert(chunks.removeFirst() == "clay.")
            }
            let obsidianRobotCost = Cost(ore: oOreCost, clay: oClayCost, obsidion: 0)
            chunks.removeFirst(4) // Each geode robot costs
            let gOreCost = Int(chunks.removeFirst())!
            var gObsidCost: Int = 0
            if chunks.removeFirst() == "ore" { // no period
                chunks.removeFirst(1) // and
                gObsidCost = Int(chunks.removeFirst())!
                assert(chunks.removeFirst() == "obsidian.")
            }
            let geodeRobotCost = Cost(ore: gOreCost, clay:0, obsidion:gObsidCost)

            let blueprint = Blueprint(id: id, oreRobotCost: oreRobotCost, clayRobotCost: clayRobotCost, obsidionRobotCost: obsidianRobotCost, geodeRobotCost: geodeRobotCost)
            blueprints.append(blueprint)
        }
    })

    print(blueprints)
}

var blueprints: [Blueprint] = []

struct Cost: CustomStringConvertible {
    var ore: Int
    var clay: Int
    var obsidion: Int

    var description: String {
        var str = ""
        if ore != 0 {
            str.append("\(ore) ore ")
        }
        if clay != 0 {
            str.append("\(clay) clay")
        }
        if obsidion != 0 {
            str.append("\(obsidion) obsidion")
        }
        return str
    }

    func canAfford(with resources: Resources) -> Bool {
        if resources.ore >= ore && resources.clay >= clay && resources.obsidion >= obsidion {
            return true
        }
        return false
    }
}

struct Blueprint: CustomStringConvertible {
    var id: Int
    var oreRobotCost: Cost
    var clayRobotCost: Cost
    var obsidionRobotCost: Cost
    var geodeRobotCost: Cost

    var description: String {
        return "Blueprint \(id) oreBot: \(oreRobotCost) clayBot: \(clayRobotCost) obsiBot: \(obsidionRobotCost) geodeBot: \(geodeRobotCost)"
    }
}

struct Resources {
    var ore: Int
    var clay: Int
    var obsidion: Int
    var geodes: Int

    var oreBots: Int
    var clayBots: Int
    var obsidianBots: Int
    var geodeBots: Int

    var time: Int

    init(ore: Int, clay: Int, obsidion: Int, geodes: Int, oreBots: Int, clayBots: Int, obsidianBots: Int, geodeBots: Int, time: Int) {
        self.ore = ore
        self.clay = clay
        self.obsidion = obsidion
        self.geodes = geodes
        self.oreBots = oreBots
        self.clayBots = clayBots
        self.obsidianBots = obsidianBots
        self.geodeBots = geodeBots
        self.time = time
    }

    init() {
        self.ore = 0
        self.clay = 0
        self.obsidion = 0
        self.geodes = 0
        self.oreBots = 1
        self.clayBots = 0
        self.obsidianBots = 0
        self.geodeBots = 0
        self.time = TIME_TO_HARVEST

    }

    // 1. build orebot
    // 2. build claybot
    // 3. build obsibot
    // 4. build geobot
    func buildOrebot(from blueprint: Blueprint) -> Resources? {
        let cost = blueprint.oreRobotCost
        if cost.canAfford(with: self) { // since we've confirmed we had the resources, lets figure them out backwards so the new robot isn't built & being used at once.
            var result = Resources(ore: ore - cost.ore, clay: clay - cost.clay, obsidion: obsidion - cost.obsidion, geodes: geodes, oreBots: oreBots, clayBots: clayBots, obsidianBots: obsidianBots, geodeBots: geodeBots, time: time)
            result = result.collectResources()
            result = result.addOrebot()
            return result
        }
        return nil
    }

    func addOrebot() -> Resources {
        return Resources(ore: ore, clay: clay, obsidion: obsidion, geodes: geodes, oreBots: oreBots + 1, clayBots: clayBots, obsidianBots: obsidianBots, geodeBots: geodeBots, time: time)
    }

    func buildClaybot(from blueprint: Blueprint) -> Resources? {
        let cost = blueprint.clayRobotCost
        if cost.canAfford(with: self) {
            var result = Resources(ore: ore - cost.ore, clay: clay - cost.clay, obsidion: obsidion - cost.obsidion, geodes: geodes, oreBots: oreBots, clayBots: clayBots, obsidianBots: obsidianBots, geodeBots: geodeBots, time: time)
            result = result.collectResources()
            result = result.addClaybot()
            return result
        }
        return nil

    }

    func addClaybot() -> Resources {
        return Resources(ore: ore, clay: clay, obsidion: obsidion, geodes: geodes, oreBots: oreBots, clayBots: clayBots + 1, obsidianBots: obsidianBots, geodeBots: geodeBots, time: time)
    }


    func buildObsidibot(from blueprint: Blueprint) -> Resources? {
        let cost = blueprint.obsidionRobotCost
        if cost.canAfford(with: self) {
            var result = Resources(ore: ore - cost.ore, clay: clay - cost.clay, obsidion: obsidion - cost.obsidion, geodes: geodes, oreBots: oreBots, clayBots: clayBots, obsidianBots: obsidianBots, geodeBots: geodeBots, time: time)
            result = result.collectResources()
            result = result.addObsidibot()
            return result
        }
        return nil
    }

    func addObsidibot() -> Resources {
        return Resources(ore: ore, clay: clay, obsidion: obsidion, geodes: geodes, oreBots: oreBots, clayBots: clayBots, obsidianBots: obsidianBots + 1, geodeBots: geodeBots, time: time)
    }

    func buildGeodebot(from blueprint: Blueprint) -> Resources? {
        let cost = blueprint.geodeRobotCost
        if cost.canAfford(with: self) {
            var result = Resources(ore: ore - cost.ore, clay: clay - cost.clay, obsidion: obsidion - cost.obsidion, geodes: geodes, oreBots: oreBots, clayBots: clayBots, obsidianBots: obsidianBots, geodeBots: geodeBots, time: time)
            result = result.collectResources()
            result = result.addGeodebot()
            return result
        }
        return nil
    }

    func addGeodebot() -> Resources {
        return Resources(ore: ore, clay: clay, obsidion: obsidion, geodes: geodes, oreBots: oreBots, clayBots: clayBots, obsidianBots: obsidianBots, geodeBots: geodeBots + 1, time: time)
    }


    func buildNothing() -> Resources? {
        return collectResources()
    }

    // time cost taken here.
    func collectResources() -> Resources {
    //    print("collecting for time \(time)")
        return Resources(ore: ore + oreBots, clay: clay + clayBots, obsidion: obsidion + obsidianBots, geodes: geodes + geodeBots, oreBots: oreBots, clayBots: clayBots, obsidianBots: obsidianBots, geodeBots: geodeBots, time: time - 1)

    }
}

var TIME_TO_HARVEST = 24 // mins

func compareBlueprints() {
    var resultsDict: Dictionary<Int, Int> = Dictionary()//key: blueprintID, value = geodes harvested
  //  for bprint in blueprints {
    let bprint = blueprints[0]
        resultsDict[bprint.id] = simulate(blueprint: bprint)
        print("blueprint \(bprint.id) made \(String(describing: resultsDict[bprint.id]))")
  //  }

   // print("Final Results: \(resultsDict)")
}

// this has to figure out the best yield over 24 minutes, for each blueprint, per the follwing rules:
// 1. harvesting and building a bot takes 1 minute, consumes resources up front, presumably pays out at the end.
// 2. start with 1 ore robot.
// 3. start with 1 bot-building bot.

func simulate(blueprint: Blueprint) -> Int {
    print("Starting blueprint \(blueprint.id)")
    let resources = Resources()
    return recursiveMinuteCalculator(with: resources, and: blueprint)
}

func recursiveMinuteCalculator(with resources: Resources, and blueprint: Blueprint) -> Int {
    let currentTime = resources.time
//    print("after \(currentTime), opened \(resources.geodes), collected \(resources.ore)")
    if currentTime == 0 {
        return resources.geodes
    }
    var results: [Int] = []

    if let oreResources = resources.buildOrebot(from: blueprint) { //returns updated resources if successful
        assert(oreResources.time == currentTime - 1)
        results.append(recursiveMinuteCalculator(with: oreResources, and: blueprint))
    }
    if let clayResources = resources.buildClaybot(from: blueprint) {
        assert(clayResources.time == currentTime - 1)
        results.append(recursiveMinuteCalculator(with: clayResources, and: blueprint))
    }
//    if let obsidionResources = resources.buildObsidibot(from: blueprint) {
//        assert(obsidionResources.time == currentTime - 1)
//        results.append(recursiveMinuteCalculator(with: obsidionResources, and: blueprint))
//    }
//    if let geodeResources = resources.buildObsidibot(from: blueprint) {
//        assert(geodeResources.time == currentTime - 1)
//        results.append(recursiveMinuteCalculator(with: geodeResources, and: blueprint))
//    }
    if let waitResources = resources.buildNothing() {
        assert(waitResources.time == currentTime - 1)
       results.append(recursiveMinuteCalculator(with: waitResources, and: blueprint))
    }

    results.sort()
    return results.last ?? 0
}

// options:
// 1. build orebot
// 2. build claybot
// 3. build obsibot
// 4. build geobot
// 5. wait
