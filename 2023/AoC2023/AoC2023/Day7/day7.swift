//
//  day7.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/7/23.
//

import Foundation

func day7() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day7/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        //part 1
        parseHands(with: text)
        showTotalWinnings()

    } catch {
        print(error.localizedDescription)
    }
}

let PART_1 = false

enum Card: Int, Comparable {
    static func < (lhs: Card, rhs: Card) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    case ace = 14
    case king = 13
    case queen = 12
    case jack = 11
    case ten = 10
    case nine = 9
    case eight = 8
    case seven = 7
    case six = 6
    case five = 5
    case four = 4
    case three = 3
    case two = 2
    case wild = 1
    case none = 0

    static func card(from str: String) -> Card {
        switch str {
        case "A": return .ace
        case "K": return .king
        case "Q": return .queen
        case "J":
            if PART_1 {
                return .jack
            } else {
                return .wild
            }
        case "T": return .ten
        case "9": return .nine
        case "8": return .eight
        case "7": return .seven
        case "6": return .six
        case "5": return .five
        case "4": return .four
        case "3": return .three
        case "2": return .two
        default:
            assertionFailure("a new kind of card we don't know")
            return .none
        }
    }
}

enum Winner: Int, Comparable {
    static func < (lhs: Winner, rhs: Winner) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    case fiveOfAKind = 7
    case fourOfAKind = 6
    case fullHouse = 5
    case threeOfAKind = 4
    case twoPair = 3
    case onePair = 2
    case highCard = 1

    static func win(for hand: Hand) -> Winner {
        let sortedHand = hand.orderedCards()

        var frequencies: [Card: Int] = [:]
        for card in sortedHand {
            let count = frequencies[card] ?? 0
            frequencies[card] = count + 1
        }

        if frequencies.count == 1 {
            return .fiveOfAKind
        }

        if frequencies.count == 2 {
            if frequencies[sortedHand[0]] == 4 || frequencies[sortedHand[0]] == 1 {
                return .fourOfAKind
            } else {
                return .fullHouse
            }
        }

        // 3 kinds is either 2 pair, or 3 of a kind
        if frequencies.count == 3 {
            for (_, freq) in frequencies {
                if freq == 3 {
                    return .threeOfAKind
                }
            }
            return .twoPair
        }

        if frequencies.count == 4 {
            return .onePair
        }

        return .highCard
    }

    static func win2(for hand: Hand) -> Winner {
        let sortedHand = hand.orderedCards()

        if sortedHand.contains(.wild) == false { // non-wild-card hands are judged as before
            return win(for: hand)
        }

        var frequencies: [Card: Int] = [:]
        for card in sortedHand {
            let count = frequencies[card] ?? 0
            frequencies[card] = count + 1
        }

      //  print("CARDS: \(hand.cards), frequencies \(frequencies)")
        // we already established that wild cards are here,
        if frequencies.count == 1 || frequencies.count == 2 {
            return .fiveOfAKind
        }

        // 3 kinds is either 2 pair, or 3 of a kind
        if frequencies.count == 3 {
            let wildCount = frequencies[.wild]

            if wildCount == 3 {
                return .fourOfAKind
            }

            if wildCount == 2 {
                return .fourOfAKind
            }

            for (card, freq) in frequencies {
                if freq == 3 && card != .wild {
                    return .fourOfAKind
                }
            }
            return .fullHouse
        }

        if frequencies.count == 4 {
            return .threeOfAKind
        }

        return .onePair
    }
}

struct Hand: Comparable {
    let cards: [Card] // must be 5, must stay ordered.
    let bid: Int

    func orderedCards() -> [Card] {
        return cards.sorted { card1, card2 in
            card1 < card2
        }
    }

    static func == (lhs: Hand, rhs: Hand) -> Bool {
        return lhs.orderedCards() == rhs.orderedCards()
    }
    
    static func < (lhs: Hand, rhs: Hand) -> Bool {
        let leftWin: Winner
        let rightWin: Winner

        if PART_1 {
            leftWin = Winner.win(for: lhs)
            rightWin = Winner.win(for: rhs)
        } else {
            leftWin = Winner.win2(for: lhs)
            rightWin = Winner.win2(for: rhs)

        }

        if leftWin == rightWin {
            if lhs.cards[0] == rhs.cards[0] {
                if lhs.cards[1] == rhs.cards[1] {
                    if lhs.cards[2] == rhs.cards[2] {
                        if lhs.cards[3] == rhs.cards[3] {
                            if lhs.cards[4] == rhs.cards[4] {
                                return true // just pick one.
                            } else {
                                return lhs.cards[4] < rhs.cards[4]
                            }
                        } else {
                            return lhs.cards[3] < rhs.cards[3]
                        }
                    } else {
                        return lhs.cards[2] < rhs.cards[2]
                    }
                } else {
                    return lhs.cards[1] < rhs.cards[1]
                }
            } else {
                return lhs.cards[0] < rhs.cards[0]
            }
        } else {
            return leftWin < rightWin
        }
    }
}

struct Camel {
    let hands: [Hand]

    func calculateScore() -> Int {
        var score = 0
        let sortedHands = hands.sorted()
        var rank = 1
        for hand in sortedHands {
       //     print("Winner: \(Winner.win2(for: hand)) \(hand.cards) \t Bid: \(hand.bid) \t Rank: \(rank)")
            score = score + hand.bid * (rank)
            rank = rank + 1
        }

        return score
    }
}

var camelGame: Camel? = nil

func parseHands(with input: String) {
    var cards: [Card] = []
    var hands: [Hand] = []
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            let handStrings = line.split(separator: /\s+/)
            for char in handStrings[0] {
                cards.append(Card.card(from: String(char)))
            }
            let hand = Hand(cards: cards, bid: Int(handStrings[1]) ?? 0)
//            print("WIN: \(Winner.win2(for: hand))\tHAND: \(cards)\tBID: \(Int(handStrings[1]) ?? 0)")
            hands.append(hand)
            cards = []
        }
    }

    camelGame = Camel(hands: hands)
}

func showTotalWinnings() {
    if let game = camelGame {
        print(game.calculateScore())
    }
}
