//
//  day8.swift
//  AOC-2025
//
//  Created by Rachael Worthington on 12/8/25.
//

import Foundation
import Spatial

func day8() {
    let input = readInput(forDay: 8)
    
    var relayBoxes: [Vector3D] = []
    let boxInput = input.split(separator: "\n")
    for box in boxInput {
        let boxCoord = box.split(separator: ",")
        relayBoxes.append(Vector3D(x: Double(boxCoord[0])!, y: Double(boxCoord[1])!, z: Double(boxCoord[2])!))
    }
    
// part1(relayBoxes: relayBoxes)
    part2(relayBoxes: relayBoxes)
}

func part1(relayBoxes: [Vector3D]) {
    // figure out all the relative distances:
    // X is the index of the first box, y is the index o the 2nd, the value is the distance between them.
    var distances: [Double: (Int, Int)] = [:]
    
    for y in 0..<relayBoxes.count {
        for x in y+1..<relayBoxes.count {
            let result = pythag(relay1: relayBoxes[x], relay2:relayBoxes[y])
            if result != 0 {
                distances[result] = (x, y)
            }
        }
    }
//    print(distances)
    
    let sortedDistances: [Double] = distances.keys.sorted().map { ele in
        Double(ele)
    }
    
    var networks: [Set<Int>] = []
    for x in 0..<1000 {
        let distance = sortedDistances[x]
        let relays = distances[distance]
        let relay1 = relays!.0 // this is an integer index in the OG relayBoxes array
        let relay2 = relays!.1
        var relay1Network: Set<Int> = Set() // more indexes this time in the networks arrays
        var relay2Network: Set<Int> = Set()
        
        for network in networks {
            if network.contains(relay1) {
                relay1Network = network
            }
            if network.contains(relay2) {
                relay2Network = network
            }
            if !relay1Network.isEmpty && !relay2Network.isEmpty {
                break
            }
        }
        
        // we now make them kiss
        if let relay1Index = networks.firstIndex(of: relay1Network) {
            networks.remove(at: relay1Index)
        } else {
            relay1Network = Set(arrayLiteral: relay1)
        }
        
        if let relay2Index = networks.firstIndex(of: relay2Network) {
            networks.remove(at: relay2Index)
        } else {
            relay2Network = Set(arrayLiteral: relay2)
        }
        
        let newNetwork = relay1Network.union(relay2Network)
        networks.append(newNetwork)
    }
    
    let sortedNetworksBySize = networks.sorted { net1, net2 in
        net1.count > net2.count 
    }

    let result = sortedNetworksBySize[0].count * sortedNetworksBySize[1].count * sortedNetworksBySize[2].count
    print("result: \(result)")
}

func part2(relayBoxes: [Vector3D]) {
    // figure out all the relative distances:
    // X is the index of the first box, y is the index o the 2nd, the value is the distance between them.
    var distances: [Double: (Int, Int)] = [:]
    
    for y in 0..<relayBoxes.count {
        for x in y+1..<relayBoxes.count {
            let result = pythag(relay1: relayBoxes[x], relay2:relayBoxes[y])
            if result != 0 {
                distances[result] = (x, y)
            }
        }
    }
//    print(distances)
    
    let sortedDistances: [Double] = distances.keys.sorted().map { ele in
        Double(ele)
    }
    
    var networks: [Set<Int>] = []
    // for this we need to make sure we've pre-populated our networks
    for index in 0..<relayBoxes.count {
        networks.append(Set(arrayLiteral: index))
    }
    
    for x in 0..<relayBoxes.count*relayBoxes.count {
        let distance = sortedDistances[x]
        let relays = distances[distance]
        let relay1 = relays!.0 // this is an integer index in the OG relayBoxes array
        let relay2 = relays!.1
        var relay1Network: Set<Int> = Set() // more indexes this time in the networks arrays
        var relay2Network: Set<Int> = Set()
        
        for network in networks {
            if network.contains(relay1) {
                relay1Network = network
            }
            if network.contains(relay2) {
                relay2Network = network
            }
            if !relay1Network.isEmpty && !relay2Network.isEmpty {
                break
            }
        }
        
        if relay1Network == relay2Network {
            // they are already together, it's fine.
            continue
        }
        // we now make them kiss
        if let relay1Index = networks.firstIndex(of: relay1Network) {
            networks.remove(at: relay1Index)
        } else {
            relay1Network = Set(arrayLiteral: relay1)
        }
        
        if let relay2Index = networks.firstIndex(of: relay2Network) {
            networks.remove(at: relay2Index)
        } else {
            relay2Network = Set(arrayLiteral: relay2)
        }
        
        let newNetwork = relay1Network.union(relay2Network)
        networks.append(newNetwork)
        
        print("networks: \(networks)")
        if networks.count == 1 {
            // we've found the connecting point!
            let relay1Loc = relayBoxes[relay1]
            let relay2Loc = relayBoxes[relay2]
            
            let result = relay1Loc.x * relay2Loc.x
            print(result)
            return
        } else {
            print("network count: \(networks.count)")
        }
    }
}

// 34291856 - too low

//sqrt( (x1-x2)^2 + (y1-y2)^2 + (z1-z2))
func pythag(relay1: Vector3D, relay2: Vector3D) -> Double {
    let term1 = (relay1.x - relay2.x) * (relay1.x - relay2.x)
    let term2 = (relay1.y - relay2.y) * (relay1.y - relay2.y) 
    let term3 = (relay1.z - relay2.z) * (relay1.z - relay2.z) 
    return sqrt(term1 + term2 + term3)
}
