//
//  day15.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/17/23.
//

import Foundation

func day15() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day15/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        parseInitSequence(with: text)
        // part 1
     //   generateHash()
        // part 2
        arrangeLenses()
        generateFocusingPower()
    } catch {
        print(error.localizedDescription)
    }
}

var startupSteps: [String] = []

func parseInitSequence(with input: String) {
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            startupSteps.append(contentsOf: line.split(separator: ",").compactMap { instruction in
                return String(instruction)
            })
        }
    }
}

func stringHash(_ string: String) -> Int {
    //Determine the ASCII code for the current character of the string.
    //Increase the current value by the ASCII code you just determined.
    //Set the current value to itself multiplied by 17.
    //Set the current value to the remainder of dividing itself by 256.
    var hashValue: Int = 0
    for char in string {
        let asciiValue = Int(char.asciiValue!)
        hashValue = hashValue + asciiValue
        hashValue = hashValue * 17
        hashValue = hashValue.remainderReportingOverflow(dividingBy: 256).partialValue
    }
  //  print("returning \(hashValue)")
    return hashValue
}

func generateHash() {
    var total = 0
    for step in startupSteps {
        total = total + stringHash(step)
    }
    print(total)
}

struct Lens {
    var label: String
    var focalLength: Int

    func focusingPower(forBox boxIndex: Int, inSlot slotIndex: Int) -> Int {
//        One plus the box number of the lens in question.
//        The slot number of the lens within the box: 1 for the first lens, 2 for the second lens, and so on.
//        The focal length of the lens.

        var power = 1 + boxIndex
        power = power * slotIndex
        power = power * focalLength
        return power
    }
}

var boxRig: [[Lens]] = Array(repeating: [], count: 256)

func arrangeLenses() {
    for step in startupSteps {
        if step.hasSuffix("-") {// removal command
            var label = step
            label.removeLast()
            let boxIndex = stringHash(label)
            let index = boxRig[boxIndex].firstIndex { lens in
                lens.label == label
            }
            if let index {
                boxRig[boxIndex].remove(at: index)
            }
        } else {
            if let equalIndex = step.lastIndex(of: "=") {
                let label = String(step.prefix(upTo: equalIndex))
                let focalLength = Int(step.suffix(from: step.index(after: equalIndex))) ?? 0
                let lens = Lens(label: label, focalLength: focalLength)
                let boxIndex = stringHash(label)
                if let index = boxRig[boxIndex].firstIndex(where: { lens in
                    lens.label == label
                }) {
                    boxRig[boxIndex][index] = lens
                } else {
                    boxRig[boxIndex].append(lens)
                }
            }
        }
    }
    print(boxRig)
}


func generateFocusingPower() {
    var totalPower = 0
    for boxCount in 0..<boxRig.count {
        let box = boxRig[boxCount]
        for slot in 0..<box.count {
            let lens = box[slot]
            totalPower = totalPower + lens.focusingPower(forBox: boxCount, inSlot: slot + 1) // slots  are 1-indexed
        }
    }
    print(totalPower)
}
