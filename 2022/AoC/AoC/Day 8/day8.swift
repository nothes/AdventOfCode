//
//  day8.swift
//  AoC
//
//  Created by Rachael Worthington on 12/7/22.
//

import Foundation

func day8() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 8/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        //findVisibleTrees()
        calculateScenicScores()
    } catch {
        print(error.localizedDescription)
    }
}

var forest: [[Int]] = [[0]]

fileprivate func parseInput(_ text: String) {
    // A tree is visible if all of the other trees between it and an edge of the grid are shorter than it. Only consider trees in the same row or column; that is, only look up, down, left, or right from any given tree.
    // how many trees are visible from outside the grid?

    let treeRows = text.split(separator: "\n")
    let rowCount = treeRows.count
    forest = Array(repeating: [], count: rowCount)
    let columnCount = treeRows[0].count
    for row in 0..<rowCount {
        forest[row] = Array(repeating: 0, count: columnCount)
    }

    for i in 0..<rowCount {
        var trees = treeRows[i]
        for j in 0..<trees.count {
            forest[i][j] = Int(String(trees.removeFirst()))! // if this isn't a digit, the input is invalid, plz crash.
        }
    }
}

fileprivate func findVisibleTrees() {
    var visibleTreeCount = 0
    let rowCount = forest.count
    let columnCount = forest[0].count
    for row in 0 ..< rowCount {
        for column in 0 ..< columnCount {
            let tree = forest[row][column]
            print("row = \(row), column = \(column), tree is \(tree)")
            if row == 0 || row == rowCount - 1 || column == 0 || column == columnCount - 1 {
                visibleTreeCount += 1
                print("edgeTree, visibleTrees = \(visibleTreeCount)")
            } else {
                // have to check 4 dirs, top, bottom, left, right, to see if all the trees in each dir are shorter. once any 1 dir is visible, you're done, NEXT
                var visible = true
                //top
                for i in 0 ..< row {
                    let comparisonTree = forest[i][column]
                    if visible == true && tree <= comparisonTree {
                        // visibility broken
                        print("TOP: can't see because of [\(i),\(column)] being \(comparisonTree)")
                        visible = false
                    } else if visible == true {
                        print("can see over [\(i),\(column)] being \(comparisonTree)")

                    }
                }
                if visible == true {
                    visibleTreeCount += 1
                }

                if visible == false {
                    //bottom
                    visible = true
                    for i in (row + 1) ..< rowCount {
                        let comparisonTree = forest[i][column]
                        if visible == true && tree <= comparisonTree {
                            // visibility broken
                            print("BOTTOM: can't see because of [\(i),\(column)] being \(comparisonTree)")
                            visible = false
                        } else if visible == true {
                            print("can see over [\(i),\(column)] being \(comparisonTree)")
                        }
                    }
                    if visible == true {
                        visibleTreeCount += 1
                    }
                    if visible == false {
                        //left
                        visible = true
                        for i in 0 ..< column {
                            let comparisonTree = forest[row][i]
                            if visible == true && tree <= comparisonTree {
                                // visibility broken
                                print("LEFT: can't see because of [\(row),\(i)] being \(comparisonTree)")
                                visible = false
                            } else if visible == true {
                                print("can see over [\(row),\(i)] being \(comparisonTree)")
                            }
                        }
                        if visible == true {
                            visibleTreeCount += 1
                        }

                        if visible == false {
                            //right
                            visible = true
                            for i in (column + 1) ..< columnCount {
                                let comparisonTree = forest[row][i]
                                if visible == true && tree <= comparisonTree {
                                    // visibility broken
                                    print("RIGHT: can't see because of [\(row),\(i)] being \(comparisonTree)")
                                    visible = false
                                } else if visible == true {
                                    print("can see over [\(row),\(i)] being \(comparisonTree)")
                                }
                            }

                            if visible == true {
                                visibleTreeCount += 1
                            }
                        }

                    }
                }
            }
        }
    }
    print("visible tree total: \(visibleTreeCount)")
}

func calculateScenicScores() {
    var highestScenicScore = 0

    var currentScenicScore = [0,0,0,0] // top bottom left right

    let rowCount = forest.count
    let columnCount = forest[0].count
    for row in 0 ..< rowCount {
        for column in 0 ..< columnCount {
            let tree = forest[row][column]
            currentScenicScore = [0,0,0,0]
            if row == 0 || row == rowCount - 1 || column == 0 || column == columnCount - 1 {
            } else {
                //top
                var checkRow = row - 1
                var visibleCount = 0
                var viewBlocked = false
                while checkRow >= 0 && !viewBlocked {
                    let comparisonTree = forest[checkRow][column]
                    if tree <= comparisonTree {
                        viewBlocked = true
                    }
                    visibleCount += 1
                    checkRow -= 1
                }
                currentScenicScore[0] = visibleCount

                // bottom
                checkRow = row + 1
                visibleCount = 0
                viewBlocked = false
                while checkRow < rowCount && !viewBlocked {
                    let comparisonTree = forest[checkRow][column]
                    if tree <= comparisonTree {
                        viewBlocked = true
                    }
                    visibleCount += 1
                    checkRow += 1
                }
                currentScenicScore[1] = visibleCount

                // left
                var checkColumn = column - 1
                visibleCount = 0
                viewBlocked = false
                while checkColumn >= 0 && viewBlocked == false {
                    let comparisonTree = forest[row][checkColumn]
                    if tree <= comparisonTree {
                        viewBlocked = true
                    }
                    visibleCount += 1
                    checkColumn -= 1
                }
                currentScenicScore[2] = visibleCount

                //right
                checkColumn = column + 1
                visibleCount = 0
                viewBlocked = false
                while checkColumn < columnCount && viewBlocked == false {
                    let comparisonTree = forest[row][checkColumn]
                    if tree <= comparisonTree {
                        viewBlocked = true
                    }
                    visibleCount += 1
                    checkColumn += 1
                }
                currentScenicScore[3] = visibleCount
            }

            let scenicScore = currentScenicScore.reduce(into: 1) { partialResult, score in
                partialResult *= score
            }
            if scenicScore > highestScenicScore {
                highestScenicScore = scenicScore
            }
        }
    }
    print("highest scenic score: \(highestScenicScore)")
}
