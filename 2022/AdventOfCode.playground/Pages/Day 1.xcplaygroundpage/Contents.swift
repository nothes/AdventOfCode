//: [Previous](@previous)

import Foundation
import Cocoa

var calorieLog: Dictionary<Int, ([Int], Int)> = Dictionary()

if let path = Bundle.main.path(forResource: "input", ofType: "txt") {
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
    } catch {
        // Handle error here
    }

} else {
    print("where my file?")
}

func parseInput(_ text: String) {
    let inputs = text.split(separator: "\n", omittingEmptySubsequences: false)
    var biggestSnack: (elfIndex: Int, snackTotal: Int) = (0, 0)
    var secondBiggestSnack: (elfIndex: Int, snackTotal: Int) = (0, 0)
    var thirdBiggestSnack: (elfIndex: Int, snackTotal: Int) = (0, 0)
    var elfIndex = 0
    var snackList: [Int] = []
    for input in inputs {
        // NEXT ELF!
        if input.isEmpty {
            var snackTotal = 0
            snackList.reduce(into: snackTotal) { _, snackCals in
                snackTotal += snackCals
            }
            calorieLog[elfIndex] = (snackList, snackTotal)
            if snackTotal > biggestSnack.snackTotal {
                thirdBiggestSnack = secondBiggestSnack
                secondBiggestSnack = biggestSnack
                biggestSnack = (elfIndex, snackTotal)
            } else if snackTotal > secondBiggestSnack.snackTotal {
                thirdBiggestSnack = secondBiggestSnack
                secondBiggestSnack = (elfIndex, snackTotal)
            } else if snackTotal > thirdBiggestSnack.snackTotal {
                thirdBiggestSnack = (elfIndex, snackTotal)
            }
            elfIndex += 1
            snackList = []
            continue
        }

        if let snack = Int(input) {
            snackList.append(snack)
        } else {
            assertionFailure("not an int, but not empty")
        }
    }

    print(biggestSnack)
    print(secondBiggestSnack)
    print(thirdBiggestSnack)

    let grandTotal = biggestSnack.snackTotal + secondBiggestSnack.snackTotal + thirdBiggestSnack.snackTotal
    print(grandTotal)
}

func runTheCode() {

}

//: [Next](@next)
