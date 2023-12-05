//
//  day4.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/3/23.
//

import Foundation
import RegexBuilder

func day4() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day4/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        // do something interesting
        parseScratchCards(with: text)
       // totalScore()
        totalCards()
    } catch {
        print(error.localizedDescription)
    }
}

struct ScratchCard: Hashable {
    let cardNumber: Int
    let winners: [Int]
    let numbers: [Int]

    func points() -> Int {
        var points = 0
        for winner in winners {
            if numbers.contains(winner) {
                if points == 0 {
                    points = 1
                } else {
                    points = points * 2
                }
            }
        }
        return points
    }

    func matches() -> Int {
        var matches = 0
        for winner in winners {
            if numbers.contains(winner) {
                matches = matches + 1
            }
        }
        return matches
    }
}

var scratchCards: [ScratchCard] = []
var countedScratchCards: [ScratchCard: Int] = [:]

//Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
let cardNumber = Regex {
    OneOrMore(.word)
    OneOrMore(.whitespace)
    TryCapture {
        OneOrMore(.digit)
    } transform: {
        Int($0)
    }
    ":"
    OneOrMore(.whitespace)
}

func parseScratchCards(with input: String) {
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            var cardID: Int
            var winners: [Int] = []
            var guesses: [Int] = []
            if let match = line.firstMatch(of: cardNumber) {
                cardID = match.1
            } else {
                cardID = 0
                print("did not find cardID of \(line)")
            }
            let numbers = line.trimmingPrefix(cardNumber)
            let numberSets = numbers.split(separator: /\|/)
            let luckyNumbers = numberSets[0].split(separator: /\s+/)
            let lottoNumbers = numberSets[1].split(separator: /\s+/)

            for str in luckyNumbers {
                winners.append(Int(str)!)
            }

            for str in lottoNumbers {
                guesses.append(Int(str)!)
            }
            // for part 1
//            scratchCards.append(ScratchCard(cardNumber: cardID, winners: winners, numbers: guesses))
            // for part 2
            countedScratchCards[ScratchCard(cardNumber: cardID, winners: winners, numbers: guesses)] = 1 // every card starts with 1 instance.
        }
    }
}

func totalScore() {
    var total = 0
    for card in scratchCards {
        total = total + card.points()
    }
    print(total)
}

func totalCards() {
    // get our cards, in ID order
    let cards = countedScratchCards.keys.sorted { card1, card2 in
        card1.cardNumber < card2.cardNumber
    }

    for card in cards {
        let matches = card.matches()
        if let cardsToProcess = countedScratchCards[card] {
//            print("processing card \(card.cardNumber) x \(cardsToProcess), \(matches) matches")
            for _ in 0..<cardsToProcess {
                for newCard in (card.cardNumber)..<min((card.cardNumber + matches), cards.count) { // this only works because there's no skipped ID's. otherwise we'd have to be smarter.
                    if let currentCardCount = countedScratchCards[cards[newCard]] {
                        countedScratchCards[cards[newCard]] = currentCardCount + 1
//                        print("adding to card \(cards[newCard].cardNumber) new count = \(currentCardCount + 1)")
                    } else {
                        assertionFailure()
                    }
                }
            }
        }
    }

    var cardTotal = 0
    for card in countedScratchCards.keys {
        cardTotal = cardTotal + (countedScratchCards[card] ?? 0)
    }
    print(cardTotal)
}

