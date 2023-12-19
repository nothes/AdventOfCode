//
//  day13.swift
//  AoC2023
//
//  Created by Rachael Worthington on 12/15/23.
//

import Foundation

func day13() {
    let path = "/Users/rachael/Documents/AoC-remote/2023/AoC2023/AoC2023/Day13/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)

        parseTerrain(with: text)
        // part 1
        findReflections()
        // part 2
    } catch {
        print(error.localizedDescription)
    }
}

func parseTerrain(with input: String) {
    var ground: [[String]] = []
    var dupes: [(Int, Int)] = []
    input.enumerateLines { line, stop in
        if line.isEmpty == false { // stop forgetting this.
            var row: [String] = []
            var dupeRun: [(Int, Int)] = []
            for char in line {
                row.append(String(char))
            }
            if let dupe = ground.lastIndex(of: row) {
                dupeRun.append((dupe, ground.count))
            }
            // how do i tell when i have a new potential duplicate run? what if htey overlap?
            ground.append(row)
        } else {
            if !ground.isEmpty {
                terrains.append(Terrain(ground: ground, dupeRows: dupes))
            }
            ground = []
            dupes = []
        }
    }
    terrains.append(Terrain(ground: ground, dupeRows: dupes))
}

var terrains: [Terrain] = []

// CustomDebugStringConvertible
struct Terrain { // because a 3d array is too many d's.
    let ground: [[String]]
    let dupeRows: [(Int, Int)]

    func rotatedGround() -> Terrain {
        var dupes: [(Int, Int)] = []
        var newGround: [[String]] = []
        var newRow: [String] = []
        for i in 0..<columnCount() {
            for row in ground {
                newRow.append(row[i])
            }

            if let dupe = newGround.lastIndex(of: newRow) {
                dupes.append((dupe, newGround.count))
            }
            newGround.append(newRow)
            newRow = []
        }
        return Terrain(ground: newGround, dupeRows: dupes)
    }

    func rowCount() -> Int {
        return ground.count
    }

    func columnCount() -> Int {
        return ground[0].count
    }
}

func findReflections() {
    // reflections could be vertical betewen two columns, or horizontal between 2 rows.

    var topOfMirrorRows = 0
    var leftOfMirrorColumns = 0

    for ground in terrains {
        print("Next Ground!")
        // we already know if theres any duplicate rows
        if !ground.dupeRows.isEmpty {
            print("dupeRows = \(ground.dupeRows)")
            var distance = 1
            var isMirrored = true
            var reachedAnEdge = false
            let potentialReflectAfterRow = ground.dupeRows[0].0
            for row in ground.dupeRows {
                // the way we built this, it should be hte mirror pair and then rows outwards till we fall off
                if row.0 == 0 || row.1 == ground.rowCount() - 1 {
                    reachedAnEdge = true
                }

                if row.1 - row.0 == distance {
                    distance = distance + 2
                } else {
                    isMirrored = false
                    break
                }
            }
            if isMirrored && reachedAnEdge {
                assert(potentialReflectAfterRow < ground.rowCount())
                print("mirrored horizontally over \(potentialReflectAfterRow)")
                topOfMirrorRows = topOfMirrorRows + potentialReflectAfterRow + 1 // because 0-indexed
            }
        }

        // now flip it sideways & do it again.
        let rotatedGround = ground.rotatedGround()
        if !rotatedGround.dupeRows.isEmpty {
            print("dupeColumns = \(rotatedGround.dupeRows)")
            var distance = 1
            var isMirrored = true
            var reachedAnEdge = false
            let potentialReflectAfterRow = rotatedGround.dupeRows[0].0
            for row in rotatedGround.dupeRows {
                // the way we built this, it should be hte mirror pair and then rows outwards till we fall off
                if row.0 == 0 || row.1 == rotatedGround.rowCount() - 1 {
                    print("\treached an edge! \(row)")
                    reachedAnEdge = true
                }
                if row.1 - row.0 == distance {
                    distance = distance + 2
                } else {
                    print("\tturned out not to be a mirror")
                    isMirrored = false
                    break
                }
            }
            if isMirrored && reachedAnEdge {
                assert(potentialReflectAfterRow < rotatedGround.rowCount())
                print("mirrored vertically over \(potentialReflectAfterRow)")
                leftOfMirrorColumns = leftOfMirrorColumns + potentialReflectAfterRow + 1
            }
        }
    }

    //To summarize your pattern notes, add up the number of columns to the left of each vertical line of reflection; to that, also add 100 multiplied by the number of rows above each horizontal line of reflection. In the above example, the first pattern's vertical line has 5 columns to its left and the second pattern's horizontal line has 4 rows above it, a total of 405.

    let summary = leftOfMirrorColumns + (100 * topOfMirrorRows)
    print("summary = \(leftOfMirrorColumns) + (100 * \(topOfMirrorRows)) = \(summary)")
}
