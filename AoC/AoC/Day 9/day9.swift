//
//  day9.swift
//  AoC
//
//  Created by Rachael Worthington on 12/8/22.
//

import Foundation

func day9() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 9/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
//        runRopeSim1()
        runRopeSim2()
    } catch {
        print(error.localizedDescription)
    }
}

enum RopeDir: String {
    case up = "U"
    case down = "D"
    case left = "L"
    case right = "R"
}

var commands: [(RopeDir, Int)] = []

fileprivate func parseInput(_ text: String) {
    let cmds = text.split(separator: "\n")
    for cmd in cmds {
        let cmdParts = cmd.split(separator: " ")
        if let dir = RopeDir(rawValue: String(cmdParts[0])), let dist = Int(cmdParts[1]) {
            commands.append((dir, dist))
        } else {
            print("bad directional input, either \(cmdParts[0]) is not a direction or \(cmdParts[1]) is not an int")
        }
    }
}

struct Coord {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    func move(_ dir: RopeDir) -> Coord {
        switch(dir) {
        case .up:
            return Coord(x: x, y: y + 1)
        case .down:
            return Coord(x: x, y: y - 1)
        case .left:
            return Coord(x: x - 1, y: y)
        case .right:
            return Coord(x: x + 1, y: y)
        }

    }
}

extension Coord: Hashable {
    static func == (lhs: Coord, rhs: Coord) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

func runRopeSim1() {
    var head: Coord = Coord(x: 0, y: 0)
    var tail: Coord = Coord(x: 0, y: 0)

    var tailPositions: Set<Coord> = Set()
    tailPositions.insert(tail)

    for (dir, count) in commands {
        var moveCount = count
        while moveCount > 0 {
            // move the head
            head = head.move(dir)
            // tail chases if necessary
            let xDelta = head.x - tail.x
            let yDelta = head.y - tail.y
            //     is the tail 2 spots away?
            if abs(xDelta) >= 2 || abs(yDelta) >= 2 {
                // If the head is ever two steps directly up, down, left, or right from the tail, the tail must also move one step in that direction so it remains close enough.
                if xDelta == 0 {
                    tail = tail.move(yDelta > 0 ? .up : .down)
                } else if yDelta == 0 {
                    tail = tail.move(xDelta > 0 ? .right : .left)
                } else {
                    // Otherwise, if the head and tail aren't touching and aren't in the same row or column, the tail always moves one step diagonally to keep up.
                    // in order for this to happen, our deltas will have to be 2,1 or 1,2
                    if xDelta == -2 {
                        // head delta is either (-2,-1), (-2,1),
                        tail = tail.move(.left)
                        tail = tail.move(yDelta > 0 ? .up: .down)
                    } else if xDelta == 2 {
                        tail = tail.move(.right)
                        tail = tail.move(yDelta > 0 ? .up: .down)
                        //(2, -1), (2, 1)
                    } else if yDelta == -2 {
                        tail = tail.move(.down)
                        tail = tail.move(xDelta > 0 ? .right: .left)
                        // (-1,-2), (1, -2)
                    } else if yDelta == 2 {
                        tail = tail.move(.up)
                        tail = tail.move(xDelta > 0 ? .right: .left)
                        // (-1,2), (1, 2)
                    } else {
                        print("****wtf movement should we do? xDelta = \(xDelta), yDelta = \(yDelta)")
                    }
                }
                tailPositions.insert(tail)
            }
            moveCount -= 1
        }
    }
    print("final tail positions: \(tailPositions)")
    print("final squares occupied: \(tailPositions.count)")
}

func runRopeSim2() {
//    var head: Coord = Coord(x: 0, y: 0)
//    var tail: Coord = Coord(x: 0, y: 0)
    var rope: [Coord] = Array(repeating: Coord(x:0, y:0), count: 10)

    var tailPositions: Set<Coord> = Set()
    tailPositions.insert(rope[9]) // rope[9] is the tail segment

    for (dir, count) in commands {
        var moveCount = count
        while moveCount > 0 {
            // move the head
            rope[0] = rope[0].move(dir)
            // head is the segment whose movement triggered this segment's movement
            for i in 1...9 {
                let head = rope[i - 1]
                let tail = rope[i]
            // tail chases if necessary
            let xDelta = head.x - tail.x
            let yDelta = head.y - tail.y
            //     is the tail 2 spots away?
                if abs(xDelta) >= 2 || abs(yDelta) >= 2 {
                    // If the head is ever two steps directly up, down, left, or right from the tail, the tail must also move one step in that direction so it remains close enough.
                    if xDelta == 0 {
                        rope[i] = rope[i].move(yDelta > 0 ? .up : .down)
                    } else if yDelta == 0 {
                        rope[i] = rope[i].move(xDelta > 0 ? .right : .left)
                    } else {
                        // Otherwise, if the head and tail aren't touching and aren't in the same row or column, the tail always moves one step diagonally to keep up.
                        // in order for this to happen, our deltas will have to be 2,1 or 1,2
                        if xDelta == -2 {
                            // head delta is either (-2,-1), (-2,1),
                            rope[i] = rope[i].move(.left)
                            rope[i] = rope[i].move(yDelta > 0 ? .up: .down)
                        } else if xDelta == 2 {
                            rope[i] = rope[i].move(.right)
                            rope[i] = rope[i].move(yDelta > 0 ? .up: .down)
                            //(2, -1), (2, 1)
                        } else if yDelta == -2 {
                            rope[i] = rope[i].move(.down)
                            rope[i] = rope[i].move(xDelta > 0 ? .right: .left)
                            // (-1,-2), (1, -2)
                        } else if yDelta == 2 {
                            rope[i] = rope[i].move(.up)
                            rope[i] = rope[i].move(xDelta > 0 ? .right: .left)
                            // (-1,2), (1, 2)
                        } else {
                            print("****wtf movement should we do? xDelta = \(xDelta), yDelta = \(yDelta)")
                        }
                    }
                }
                if (i == 9) {
                    print("new Tail position: \(rope[i])")
                    tailPositions.insert(rope[i])
                }
            }
            moveCount -= 1
        }
    }
    print("final tail positions: \(tailPositions)")
    print("final squares occupied: \(tailPositions.count)")
}
// the head (H) and tail (T) must always be touching (diagonally adjacent and even overlapping both count as touching).
