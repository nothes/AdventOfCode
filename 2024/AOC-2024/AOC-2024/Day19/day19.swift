//
//  day19.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/18/24.
//

import Foundation
import GameKit

func day19()  {
    let input = readInput(forDay: 19)

    let firstSplit = input.split(separator: "\n\n")
    var towelLibrary = firstSplit[0].split(separator: ", ").map { String($0) }
    towelLibrary.sort(by: { str1, str2 in
        str1.count > str2.count
    })
    let patternRequests = firstSplit[1].split(separator: "\n").map { String($0) }

   // print("towelLibrary contains: \(towelLibrary)")
    // part 1
    var success = 0
    for request in patternRequests {
        let graph = GKGraph()
        let rootNode = TowelNode(request: request, towel: "")
        graph.add([rootNode as GKGraphNode])
        buildTowelGraph(graph, rootNode: rootNode, with: request)
//        print(graph.nodes?.compactMap({ node in
//            if let towel = node as? TowelNode {
//                return "request: \(towel.request)"
//            }
//            return ""
//        }))
        print("finished with a graph with \(graph.nodes?.count ?? 0) nodes")
        let victory = graph.nodes?.contains(where: { node in
            let towelNode = node as! TowelNode
            if towelNode.request == "" {
                return true
            }
            return false
        })
        if victory ?? false {
            success += 1
        }
    }

    print("sucessful request count: \(success)")


    func buildTowelGraph(_ graph: GKGraph, rootNode: TowelNode, with request: String) {
        if request.isEmpty { // we built the whole thing
            return
        }
        let possibilities = towelLibrary.filter({ request.hasPrefix($0) })
        if possibilities.isEmpty {
            graph.remove([rootNode])
            return
        }
        var newNodes: [TowelNode] = []
        var done = false
        for possibility in possibilities {
            let newRequest = String(request.trimmingPrefix(possibility))
            if newRequest.isEmpty {
                done = true
            }
            newNodes.append(TowelNode(request: newRequest, towel: possibility))
        }
        graph.add(newNodes)
        rootNode.addConnections(to: newNodes, bidirectional: false)
        if !done {
            for newNode in newNodes {
                buildTowelGraph(graph, rootNode: newNode, with: newNode.request)
            }
        }
        if rootNode.connectedNodes.isEmpty { // only the connection to our
            graph.remove([rootNode])
        }
    }

}

class TowelNode: GKGraphNode {
    var request: String // the stripe pattern yet to find
    var towel: String // the portion i represent

    init(request: String, towel: String) {
        self.request = request
        self.towel = towel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
