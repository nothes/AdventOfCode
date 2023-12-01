//: [Previous](@previous)

import Foundation

var greeting = "Hello, playground"


//The list of items for each rucksack is given as characters all on a single line. A given rucksack always has the same number of items in each of its two compartments, so the first half of the characters represent items in the first compartment, while the second half of the characters represent items in the second compartment
// Lowercase item types a through z have priorities 1 through 26.
// Uppercase item types A through Z have priorities 27 through 52.

var inputData: Array<(Set<String>, Int)> = []
var grandTotal = 0

if let path = Bundle.main.path(forResource: "input", ofType: "txt") {
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        // part A
        //        parseInput(text)
        //        print(inputData)
        //        print(grandTotal)

        // part B
        parseInput2(text)
        print(grandTotal)

    } catch {
        print(error.localizedDescription)
    }

} else {
    print("where my file?")
}

func parseInput(_ text: String) {
    let inputs = text.split(separator: "\n")

    for input in inputs {
        assert(input.count % 2 == 0)
        let partA = input[...Substring.Index(utf16Offset: (input.count / 2) - 1, in: input)]
        let partB = input[Substring.Index(utf16Offset: input.count / 2, in: input)...]

        var doubledUpItems: Set<String> = Set()
        for letter in partA {
            if partB.contains(letter) {
                doubledUpItems.insert(String(letter))
            }
        }

        if doubledUpItems.isEmpty {
            inputData.append(([], 0))
        }// else {
//            let priority = priority(doubledUpItems)
//            inputData.append((doubledUpItems, priority))
//            grandTotal += priority
//        }
    }
}

func priority(_ letter: String) -> Int {
    guard letter.isEmpty == false else { return 0 }
    var priorityTotal = 0
    let lowercaseLetterArray = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    let uppercaseLetterArray = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    //for letter in chars {
        switch letter {
        case "a"..."z":
            guard let index = lowercaseLetterArray.firstIndex(of: letter) else {print("wat."); return 0 }
            priorityTotal += Int(index) + 1
        case "A"..."Z":
            guard let index = uppercaseLetterArray.firstIndex(of: letter) else {print("wat."); return 0 }
            priorityTotal += Int(index) + 27
        default:
            priorityTotal += 0
        }
    //}
    return priorityTotal
}


struct ElfGroup {
    var elf1: String
    var elf2: String
    var elf3: String
}

func parseInput2(_ text: String) {
    let inputs = text.split(separator: "\n")

    print("total strings: \(inputs.count)")
    var index = 0
    while index < inputs.count {
        let str1 = String(inputs[index])
        let str2 = String(inputs[index+1])
        let str3 = String(inputs[index+2])
        let group = ElfGroup(elf1: str1, elf2: str2, elf3: str3)
        let badge = findBadge(group)
        print("priority: \(badge)")
        grandTotal += badge
        print("grandTotal = \(grandTotal)")
        index += 3
    }
}

func findBadge(_ elfGroup: ElfGroup) -> Int {

    // find the one item that all 3 strings share
    let setA = Set(Array(elfGroup.elf1))
    let setB = Set( Array(elfGroup.elf2))
    let setC = Set( Array(elfGroup.elf3))

    let intersectA = setA.intersection(setB)
    let badge = setC.intersection(intersectA).first?.description ?? ""

    print("badge = \(badge)")
    let priority = priority(badge)

    return priority

}

//: [Next](@next)
