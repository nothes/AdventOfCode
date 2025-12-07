//
//  main.swift
//  AOC-2025
//
//  Created by Rachael Worthington on 11/30/25.
//

import Foundation


day7()

func readInput(forDay day: Int) -> String {
    let path = "/Users/rachael/Documents/AoC-remote/2025/AOC-2025/AOC-2025/Day \(day)/input.txt"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        return text
    } catch {
        print(error.localizedDescription)
    }
    return ""
}
