//
//  day4.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/3/23.
//

import Foundation

func day4() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day4/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        // do something interesting
        parseInput(with: text)
        
    } catch {
        print(error.localizedDescription)
    }
}

func parseInput(with input: String) {
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
        }
    }
}
