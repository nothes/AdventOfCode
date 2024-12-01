//
//  main.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/1/24.
//

import Foundation

day1()

func readInput(forDay day: Int) -> String {
    let path = "/Users/rachael/Documents/AoC-remote/2024/AOC-2024/AOC-2024/Day\(day)/input.txt"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        return text
    } catch {
        print(error.localizedDescription)
    }
    return ""
}
