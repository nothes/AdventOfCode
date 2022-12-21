//
//  day20.swift
//  AoC
//
//  Created by Rachael Worthington on 12/19/22.
//

import Foundation

func day20() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 20/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        // do something interesting
        mixFile()
        calculateCoords()
    } catch {
        print(error.localizedDescription)
    }
}

var mixableData: [Data] = []

fileprivate func parseInput(_ text: String) {
    var count = 0
    text.enumerateLines(invoking: { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            let datum = Data(value: Int(line)!, originalIndex: count)
            mixableData.append(datum)
            count += 1
        }
    })

    print("data count = \(mixableData.count)")
}

class Data: Equatable, CustomStringConvertible {
    var value: Int
    var originalIndex: Int
    var mixed: Int

    init(value: Int, originalIndex: Int) {
        self.value = value
        self.originalIndex = originalIndex
        self.mixed = 0
    }

    static func == (lhs: Data, rhs: Data) -> Bool {
        return lhs.value == rhs.value && lhs.originalIndex == rhs.originalIndex
    }

    var description: String {
        return "[\(originalIndex)]: \(value)"
    }

}

func mixFile() {
    let orderedData = Array(mixableData)
    let dataCount = orderedData.count
    for index in 0 ..< dataCount {
        let mixValue = orderedData[index]
        guard let currentIndex = mixableData.firstIndex(of: mixValue) else { return }
        var targetIndex = (currentIndex + mixValue.value) % dataCount
        if targetIndex < 0 {
            targetIndex = dataCount + targetIndex
        }
        move(data: mixValue, from: currentIndex, to: targetIndex)
    }
}

func move(data: Data, from oldIndex: Int, to newIndex: Int) {
//    print("list before: \(mixableData)")
    assert(newIndex >= 0)
    assert(newIndex < mixableData.count)
    mixableData.remove(at: oldIndex)
    mixableData.insert(data, at: newIndex)
    data.mixed += 1
//    print("list after: \(mixableData)")
}

func calculateCoords() {
  //  Then, the grove coordinates can be found by looking at the 1000th, 2000th, and 3000th numbers after the value 0, wrapping around the list as necessary. In the above example, the 1000th number after 0 is 4, the 2000th is -3, and the 3000th is 2; adding these together produces 3.
    let dataCount = mixableData.count

    for value in mixableData {
        assert(value.mixed == 1)
    }

    guard let zeroIndex = mixableData.firstIndex (where: { data in
        data.value == 0
    }) else { return }
    print("zeroIndex: \(zeroIndex)")
    let oneThouIndex = (1000 + zeroIndex) % dataCount
    let twoThouIndex = (2000 + zeroIndex) % dataCount
    let threeThouIndex = (3000 + zeroIndex) % dataCount

    print("index1 = \(oneThouIndex) = \(mixableData[oneThouIndex].value)")
    print("index2 = \(twoThouIndex) = \(mixableData[twoThouIndex].value)")
    print("index3 = \(threeThouIndex) = \(mixableData[threeThouIndex].value)")
    let finalValue = mixableData[oneThouIndex].value + mixableData[twoThouIndex].value + mixableData[threeThouIndex].value

    print(finalValue)
}

// part 1: 2607 - too low missed "after the value 0"
// part 1: -13097 -- shouldn't have tried, it's negative!
// part 1: 9604 too low
// part 1: 15072 incorrect. (tried offsetting all my indexes by -1)
// part 1: -11200 - new simplified algorithm, still comes up wrong, but hope springs eternal.
