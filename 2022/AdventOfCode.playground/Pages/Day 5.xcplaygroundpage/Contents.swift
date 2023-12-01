//: [Previous](@previous)

import Foundation

if let path = Bundle.main.path(forResource: "input", ofType: "txt") {
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
    } catch {
        print(error.localizedDescription)
    }

} else {
    print("where my file?")
}

struct Move {
    var numOfCrates: Int // note multiple moves invert the stack
    var sourceColumn: Int
    var destColumn: Int
}

class Board {
    var stacks: [[String]] = []

//    [G]         [P]         [M]
//    [V]     [M] [W] [S]     [Q]
//    [N]     [N] [G] [H]     [T] [F]
//    [J]     [W] [V] [Q] [W] [F] [P]
//[C] [H]     [T] [T] [G] [B] [Z] [B]
//[S] [W] [S] [L] [F] [B] [P] [C] [H]
//[G] [M] [Q] [S] [Z] [T] [J] [D] [S]
//[B] [T] [M] [B] [J] [C] [T] [G] [N]
// 1   2   3   4   5   6   7   8   9
    init() { // stacks are listed bottom to top
        stacks.append(["B", "G", "S", "C"])
        stacks.append(["T", "M", "W", "H", "J", "N", "V", "G"])
        stacks.append(["M", "Q", "S"])
        stacks.append(["B", "S", "L", "T", "W", "N", "M"])
        stacks.append(["J", "Z", "F", "T", "V", "G", "W", "P"])
        stacks.append(["C", "T", "B", "G", "Q", "H", "S"])
        stacks.append(["T", "J", "P", "B", "W"])
        stacks.append(["G", "D", "C", "Z", "F", "T", "Q", "M"])
        stacks.append(["N", "S", "H", "B", "P", "F"])
    }

    func stack(_ index: Int) -> [String] {// 1-9
        return stacks[index - 1]
    }

    func add(crates: [String], toStack: Int) { // does invert inputs
        //part 1
//        let reversedCrates = crates.reversed()
//        stacks[toStack-1].append(contentsOf: reversedCrates)

        //part2
        stacks[toStack-1].append(contentsOf: crates)
    }

    func retrieve(_ count: Int, fromStack: Int) -> [String] { // does not return inverted crates.
        let removedCrates = Array(stacks[fromStack - 1].suffix(count))
        stacks[fromStack-1].removeLast(count)
        return removedCrates
    }

    func move(_ count: Int, fromStack: Int, toStack: Int) {
        let retrievedCrates = retrieve(count, fromStack: fromStack)
        add(crates: retrievedCrates, toStack: toStack)
    }

    func displayStacks() {
        var index = 1
        for stack in stacks {
            print("stack \(index): \(stack)")
            index += 1
        }
    }
}

func parseInput(_ text: String) {
    let moves = text.split(separator: "\n")
    let board = Board()
    for move in moves {
        // move 2 from 4 to 2
        let movePieces = move.split(separator: " ")
        // important info isin indexs 1 (count), 3 (from stack), 5 (toStack
        let move = Move(numOfCrates: Int(movePieces[1])!, sourceColumn: Int(movePieces[3])!, destColumn: Int(movePieces[5])!)
        board.move(move.numOfCrates, fromStack: move.sourceColumn, toStack: move.destColumn)
    }
    board.displayStacks()

    // pt 1: CFFHVVHNC
//    stack 1: ["M", "T", "F", "S", "C"]
//    stack 2: ["B", "P", "M", "L", "F"]
//    stack 3: ["B", "W", "T", "B", "F"]
//    stack 4: ["Z", "C", "Q", "P", "T", "H"]
//    stack 5: ["T", "S", "J", "G", "T", "G", "G", "H", "S", "B", "W", "Z", "M", "M", "D", "G", "V"]
//    stack 6: ["V"]
//    stack 7: ["J", "W", "N", "Q", "Q", "B", "P", "J", "H"]
//    stack 8: ["N", "T", "G", "N"]
//    stack 9: ["S", "W", "S", "C"]


    //pt 2: FSZWBPTBG
//    stack 1: ["G", "C", "M", "B", "F"]
//    stack 2: ["V", "M", "W", "Q", "S"]
//    stack 3: ["B", "T", "S", "C", "Z"]
//    stack 4: ["S", "B", "M", "D", "J", "W"]
//    stack 5: ["W", "Q", "F", "W", "N", "G", "F", "G", "N", "T", "G", "H", "T", "J", "P", "Q", "B"]
//    stack 6: ["P"]
//    stack 7: ["Z", "C", "T", "P", "S", "H", "J", "M", "T"]
//    stack 8: ["N", "T", "V", "B"]
//    stack 9: ["L", "S", "H", "G"]

}


//: [Next](@next)
