//
//  day7.swift
//  AoC
//
//  Created by Rachael Worthington on 12/6/22.
//

import Foundation


func day7() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 7/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
    } catch {
        print(error.localizedDescription)
    }
}

fileprivate func parseInput(_ text: String) {
    
}

