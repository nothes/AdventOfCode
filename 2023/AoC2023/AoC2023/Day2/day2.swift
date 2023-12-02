//
//  day2.swift
//  AoC2023
//
//  Created by Rachael Worthington on 11/30/23.
//

import Foundation
import RegexBuilder

func day2() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day2/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        // do something interesting
        parseGames(with: text)
        part1()
        part2()
    } catch {
        print(error.localizedDescription)
    }
}

struct Game {
    let gameID: Int
    let redPulls: [Int] // sorted
    let bluePulls: [Int] // sorted
    let greenPulls: [Int] // sorted

    func impossibleGame() -> Bool {
        let impossibleRedCount = redPulls.contains(where: { count in
            count > 12
        })

        let impossibleBlueCount = bluePulls.contains { count in
            count > 14
        }

        let impossibleGreenCount = greenPulls.contains { count in
            count > 13
        }

        return impossibleRedCount || impossibleBlueCount || impossibleGreenCount
    }

    func power() -> Int { // The power of a set of cubes is equal to the numbers of red, green, and blue cubes multiplied together.
        return (redPulls.last ?? 1) * (bluePulls.last ?? 1) * (greenPulls.last ?? 1)
    }
}

var blockGames: [Game] = []
// Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
func parseGames(with input: String) {
    input.enumerateLines(invoking: { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            // split the header
            let firstSplits = line.split(separator: /:/)
            var gameTitleStr = String(firstSplits[0])
            gameTitleStr.removeFirst(5)
            let gameNumber: Int = Int(gameTitleStr) ?? 0
            let pulls = firstSplits[1].split(separator: /;/)

            var red: [Int] = []
            var blue: [Int] = []
            var green: [Int] = []

            let regex = Regex {
                Capture {
                    OneOrMore(.digit)
                }
                OneOrMore(.whitespace)
                Capture {
                    ChoiceOf {
                        "red"
                        "green"
                        "blue"
                    }
                }
            }


            for pull in pulls {
                let colors = pull.split(separator: ",")

                for color in colors {
                    if let match = color.firstMatch(of: regex) {
                        let resultCount = (Int(match.1) ?? 0)
                        if match.2 == "red" {
                            red.append(resultCount)
                        } else if match.2 == "blue" {
                            blue.append(resultCount)
                        } else {
                            green.append(resultCount)
                        }
                    }
                }
            }
            blockGames.append(Game(gameID: gameNumber, redPulls: red.sorted(), bluePulls: blue.sorted(), greenPulls: green.sorted()))
        }
    })
}

func part1()  {
    var solution = 0
    for game in blockGames {
        if !game.impossibleGame() {
            solution = solution + game.gameID
        }
    }

    print("part 1: \(solution)")
}

func part2() {
    var solution = 0
    for game in blockGames {
        solution = solution + game.power()
    }
    print("part 2: \(solution)")
}
