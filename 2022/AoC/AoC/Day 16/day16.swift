//
//  day16.swift
//  AoC
//
//  Created by Rachael Worthington on 12/15/22.
//

import Foundation
import GameKit

func day16() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 16/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
        simulateValves()
    } catch {
        print(error.localizedDescription)
    }
}

var startValve: Valve? = nil
var graph: GKGraph? = nil
fileprivate func parseInput(_ text: String) {
    var valvePile: Dictionary<String, Valve> = Dictionary()
    text.enumerateLines(invoking: { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            let valveInfo = line.split(separator: " ")
            // Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
            //   0    1  2   3    4      5        6    7   8     9...
            let name = String(valveInfo[1]).trimmingCharacters(in: CharacterSet(charactersIn: ","))
            var rateStr = String(valveInfo[4])
            rateStr.removeAll { char in
                char.isNumber == false
            }
            let flow = Int(rateStr)!
            var nearbyStr = ""
            for i in 9..<valveInfo.count {
                nearbyStr.append("\(valveInfo[i]) ")
            }
            let newValve = Valve(name: name, flowRate: flow, nearbyString: nearbyStr)
            valvePile[name] = newValve
        }
    })

    for valve in valvePile.values {
        if valve.nearbyString.isEmpty == false {
            let nearbyValveNames = valve.nearbyString.split(separator: " ")
            var nearbyValves: [Valve] = []
            for valveName in nearbyValveNames {
                let cleanName = String(valveName).trimmingCharacters(in: CharacterSet(charactersIn: ","))
                nearbyValves.append(valvePile[String(cleanName)]!)
            }
            valve.addConnections(to: nearbyValves, bidirectional: true)
        }
        if valve.name == "AA" {
            startValve = valve
        }
    }

    graph = GKGraph(Array(valvePile.values))
}

class Valve: GKGraphNode, Comparable {
    static func < (lhs: Valve, rhs: Valve) -> Bool {
        return lhs.flowRate < rhs.flowRate
    }

    static func == (lhs: Valve, rhs: Valve) -> Bool {
        return lhs.name == rhs.name && lhs.flowRate == rhs.flowRate
    }

    var name: String
    var flowRate: Int
    var isOpen: Bool // true = open
    var nearbyString: String

    init(name: String, flowRate: Int, isOpen: Bool = false, nearbyValves: [Valve] = [], nearbyString: String = "") {
        self.name = name
        self.flowRate = flowRate
        self.isOpen = isOpen
        self.nearbyString = nearbyString
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var description: String {
        return "Valve \(name): \(flowRate) -> \(nearbyString)"
    }

    override func cost(to node: GKGraphNode) -> Float {
        return 1.0
    }
}

// need the most pressure released.
// * opening a valve takes 1 min
// * moving between valves takes 1 min
// * start at AA

func simulateValves() {
    guard let graph = graph else { return }
    let TIME_TO_LIVE = 30 // minutes
    var location = startValve!
  //  var priorLocations: [Valve] = [] // a stack to work back up?
    var releasedPressure = 0
    var openValves: [Valve] = []
    var closedValves: [Valve] = graph.nodes as! [Valve]
    closedValves = closedValves.filter { valve in
        valve.flowRate != 0
    }

    func updatePressureValue() -> Int {
        var pressureThisMin = 0
        for valve in openValves {
            pressureThisMin += valve.flowRate
        }
        releasedPressure += pressureThisMin
        return pressureThisMin
    }

    func generatePotentialReleaseList() -> [(valve: Valve, path: [Valve])] {
        var results: [(valve: Valve, path: [Valve])] = []
        for valve in closedValves {
            let valve = valve
            let path: [Valve] = graph.findPath(from: location, to: valve) as! [Valve]
            results.append((valve: valve, path: path))
        }
        return results
    }

    var doneOpening = false
    var time = 0
    while time <= TIME_TO_LIVE {
        if !doneOpening {
            var options = generatePotentialReleaseList()
            options.sort { (arg0, arg1) in
                let (valve2, path2) = arg1
                let (valve1, path1) = arg0
                return (time - path1.count - 1) * valve1.flowRate < (time - path2.count - 1) * valve2.flowRate
            }
            options = options.filter { (valve: Valve, path: [Valve]) in
                return path.count > time // we can get there before the race is over
            }
            if options.isEmpty {
                //done!
                doneOpening = true
                print("done early, stop looping except flow rate calcs.")
                continue
            }
            //next destination is the best node in that sorted list
            let option = options[0]
            for _ in 0..<option.path.count {
                print("Moving to \(option.valve)")
                time += 1
                let newFlow = updatePressureValue()
                print("minute \(time) :: opened: \(openValves), flow released = \(newFlow)")
                if time == TIME_TO_LIVE {
                    print("total pressure released: \(releasedPressure)")
                    return
                }
            }
            location = option.valve
            // open valve
            time += 1
            closedValves.removeAll { valve in
                valve == option.valve
            }
            openValves.append(option.valve)
            // check if done early
            if closedValves.isEmpty {
                doneOpening = true // just figure out the rest of our flow.
            }
        } else {
            let newFlow = updatePressureValue()
            print("minute \(time) :: opened: \(openValves), flow released = \(newFlow)")
            time += 1
        }
    }




    // currently i have a tree of valves, where each leg costs 1 time, and the value of any node is time * flowRate. what path maximizes flow rate?
    print("total pressure released: \(releasedPressure)")
}

