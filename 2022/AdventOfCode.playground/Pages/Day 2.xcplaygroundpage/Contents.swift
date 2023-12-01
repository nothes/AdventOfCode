//: [Previous](@previous)

import Foundation
import Cocoa

let win = 6
let tie = 3
let loss = 0

//The score for a single round is the score for the shape you selected (1 for Rock, 2 for Paper, and 3 for Scissors) plus the score for the outcome of the round (0 if you lost, 3 if the round was a draw, and 6 if you won)
enum Play {
    case rock
    case paper
    case scissors

    func playScore() -> Int {
        switch self {
        case .rock:
            return 1
        case .paper:
            return 2
        case .scissors:
            return 3
        }
    }

    func vs(otherPlay: Play) -> Int {
        switch (self, otherPlay) {
        case (.rock, .rock), (.paper, .paper), (.scissors, .scissors):
            return self.playScore() + tie
        case (.rock, .paper), (.paper, .scissors), (.scissors, .rock):
            return self.playScore() + loss
        case (.rock, .scissors), (.paper, .rock), (.scissors, .paper):
            return self.playScore() + win
        }
    }
}

var inputData: Array<(Play, Play)> = []

if let path = Bundle.main.path(forResource: "input", ofType: "txt") {
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        runTheCode()
    } catch {
        print(error.localizedDescription)
    }

} else {
    print("where my file?")
}

func parseInput(_ text: String) {
    let inputs = text.split(separator: "\n")
    for input in inputs {
        let plays = input.split(separator: " ")
        let theirPlay: Play
        switch plays[0] {
        case "A":
            theirPlay = .rock
        case "B":
            theirPlay = .paper
        case "C":
            theirPlay = .scissors
        default:
            theirPlay = .rock
            assertionFailure("wtf")
        }

        // part 1
        var myPlay: Play = .rock
//        switch plays[1] {
//        case "X":
//            myPlay = .rock
//        case "Y":
//            myPlay = .paper
//        case "Z":
//            myPlay = .scissors
//        default:
//            myPlay = .rock
//            assertionFailure("wtf")
//        }

        //part 2
        switch(plays[1]) {
        case "X": // lose
            if theirPlay == .rock {
                myPlay = .scissors
            } else if theirPlay == .paper {
                myPlay = .rock
            } else if theirPlay == .scissors {
                myPlay = .paper
            }
        case "Y": // draw
                myPlay = theirPlay
        case "Z": // win
            if theirPlay == .rock {
                myPlay = .paper
            } else if theirPlay == .paper {
                myPlay = .scissors
            } else if theirPlay == .scissors {
                myPlay = .rock
            }
        default:
            myPlay = .rock
            assertionFailure("wtf")
        }
        inputData.append((theirPlay, myPlay))
    }
    // column 1 A = Rock, B = Paper, C = Scissors
    // column 2  X for Rock, Y for Paper, and Z for Scissors
}

func runTheCode() {
    var score = 0
    for round in inputData {
        score += round.1.vs(otherPlay: round.0)
    }
    print(score)
}


//: [Next](@next)
