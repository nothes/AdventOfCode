//
//  day14.swift
//  AoC
//
//  Created by Rachael Worthington on 12/13/22.
//

import Foundation

func day14() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 14/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
    } catch {
        print(error.localizedDescription)
    }
}

fileprivate func parseInput(_ text: String) {

}
