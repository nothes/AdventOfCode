//
//  day3.swift
//  AoC2023
//
//  Created by Rachael Worthington on 11/30/23.
//

import Foundation

func day3() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day3/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        // do something interesting
        doSomething(with: text)
    } catch {
        print(error.localizedDescription)
    }
}

func doSomething(with text: String) {


}
