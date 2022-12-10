//
//  day10.swift
//  AoC
//
//  Created by Rachael Worthington on 12/9/22.
//

import Foundation

func day10() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 10/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
      //  beAComputer()
        drawAScreen()
    } catch {
        print(error.localizedDescription)
    }
}

enum Instruction: String {
    case noop = "noop" // 1 cycle
    case addx = "addx" // 2 cycles
}

struct Command {
    let instruction: Instruction
    let count: Int

    func perform(xRegister: inout Int) -> Int { // consumed cycles
        switch(instruction) {
        case .noop:
            return 1
        case .addx:
            xRegister += count
            return 2
        }
    }

    //0 pixel: xReg value: 1 clock: 1 so pixels 0, 1, 2 are colored, draw 0.
    //1 pixel: xreg value: 1 clock: 2 so pixels 0-2 are colored, draw 1
    //2 pixel: xReg value: 15 clock: 3 so pix 14-16 are colored, do not draw 2

    func draw(pixel: inout Int, xRegister: inout Int, clock: inout Int) -> String {
        var returnString = ""
        switch(instruction) {
        case .noop:
            if pixel <= xRegister + 1 && pixel >= xRegister - 1 {
                returnString.append("#")
            } else {
                returnString.append(".")
            }
            pixel += 1
            clock += 1
        case .addx:
            // need to calculate 2 pixels
            if pixel <= xRegister + 1 && pixel >= xRegister - 1 {
                returnString.append("#")
            } else {
                returnString.append(".")
            }
            let newPixel = pixel + 1
            if newPixel <= xRegister + 1 && newPixel >= xRegister - 1 {
                returnString.append("#")
            } else {
                returnString.append(".")
            }
            xRegister += count
            pixel += 2
            clock += 2
        }
        return returnString
    }
}

var program: [Command] = []

fileprivate func parseInput(_ text: String) {
    text.enumerateLines(invoking: { line, stop in
        if line.isEmpty {
            return
        }
        if line.contains(" ") {
            let cmd = line.split(separator: " ")
            guard let inst = Instruction(rawValue: String(cmd[0])) else { print("what instruction is this? \(cmd[0])"); return }
            guard let count = Int(cmd[1]) else { print("what count is this? \(cmd[0])"); return }
            program.append(Command(instruction: inst, count: count))
        } else {
            guard let inst = Instruction(rawValue: String(line)) else { print("what instruction is this? \(line)"); return }
            program.append(Command(instruction: inst, count: 0))
        }
    })
}

func beAComputer() {
    var xRegister = 1
    var clock = 1
    let importantClockValues = [20, 60, 100, 140, 180, 220, 0] // the 0 is to make sure we stop accumulating anything.
    var nextImportantClock = 0
    var importantClock = importantClockValues[nextImportantClock]

    var signalStrAccumulator = 0

    for command in program {
//        print("BEFORE: clock is now \(clock), xReg = \(xRegister)")
        if clock == importantClock || (clock == importantClock - 1 && command.instruction == .addx) {
            let str = xRegister * importantClock
//            print("at importantClock \(clock), signal str: \(xRegister) * \(importantClock) = \(str)")
            signalStrAccumulator += str
            nextImportantClock += 1
            if nextImportantClock < importantClockValues.count {
                importantClock = importantClockValues[nextImportantClock]
            }
        }
//        print("instruction = \(command.instruction) \(command.count)")
        clock += command.perform(xRegister: &xRegister)
//        print("AFTER: clock is now \(clock), xReg = \(xRegister)")

    }

    print("final signal = \(signalStrAccumulator)")
}

func drawAScreen() {
    var xRegister = 1
    var clock = 1
    let importantClockValues = [40, 80, 120, 160, 200, 240] // the 0 is to make sure we stop accumulating anything.
    var pixel = 0
    var screenOutput: String = ""

    for command in program {
        //0 pixel: xReg value: 1 clock: 1 so pixels 0, 1, 2 are colored, draw 0.
        //1 pixel: xreg value: 1 clock: 2 so pixels 0-2 are colored, draw 1
        //2 pixel: xReg value: 15 clock: 3 so pix 14-16 are colored, do not draw 2
        // so on so forth.

        if pixel == 41 || pixel == 40 {
            pixel -= 40
        }
        screenOutput.append(command.draw(pixel: &pixel, xRegister: &xRegister, clock: &clock))
    }

    var rowCount = 5
    while rowCount >= 0 {
        let insertIndex = screenOutput.index(screenOutput.startIndex, offsetBy: importantClockValues[rowCount])
        screenOutput.insert("\n", at: insertIndex)
        rowCount -= 1
    }

    print(screenOutput)
 }
