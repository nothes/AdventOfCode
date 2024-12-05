//
//  day5.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/4/24.
//

import Foundation
import RegexBuilder

func day5() {
    let input = readInput(forDay: 5)
    let temp = input.split(separator:"\n\n")

    let rulePattern = Regex {
        Capture {
            OneOrMore {
                .digit
            }
        }
        One("|")
        Capture {
            OneOrMore {
                .digit
            }
        }
        One(.newlineSequence)
    }
    let matches = temp[0].matches(of: rulePattern)
    var rules: [(Int, Int)] = []
    var ruleSet: Set<Int> = Set()
    for match in matches {
        rules.append((Int(match.1)!, Int(match.2)!))
        ruleSet.insert(Int(match.1)!)
        ruleSet.insert(Int(match.2)!)
    }
    var printJobs: [[Int]] = []
    for line in temp[1].split(separator: "\n") {
        let lineArray = line.split(separator: ",").map { str in
            return Int(str)!
        }
        printJobs.append(lineArray)
    }

    // part 1
    var centerTotal = 0
    var partTwoJobs: [[Int]] = []
    for printJob in printJobs {
        // figure out the ones that don't violate the rules of .0 before .1
        if obeysRules(printJob) {
            let count = printJob.count
            // find the center #:
            assert(!count.isMultiple(of: 2)) // if we have an even number, what the hell is the center?!
            let centerIndex = Int(floor(Double(count) / 2.0))
            centerTotal = centerTotal + printJob[centerIndex]
        } else {
            partTwoJobs.append(printJob)
        }
    }

    print("total of center page #s: \(centerTotal)")

    func obeysRules(_ job: [Int]) -> Bool {
        for rule in rules {
            let beforeIndex = job.firstIndex(of: rule.0)
            let afterIndex = job.firstIndex(of: rule.1)

            guard let beforeIndex, let afterIndex else { continue } // if both parts of the rule aren't present, it doesn't matter.
            guard beforeIndex < afterIndex else { return false }

        }

        return true
    }

    // part 2
    var fixedCenterTotal = 0
    for printJob in partTwoJobs { // these need _fixed_
        var newJob: [Int] = []

       // var insertIndex = newJob.startIndex
        for page in printJob {
            if ruleSet.contains(page) == false { // it's not got any ordering reqs
                //whack that SOB on the end!
                newJob.append(page)
            } else {
                let relevantRules = rules.filter { rule in
                    rule.0 == page || rule.1 == page
                }

                var beforePages: Set<Int> = Set()
                var afterPages: Set<Int> = Set()
                for rule in relevantRules {
                    if rule.0 == page {
                        afterPages.insert(rule.1)
                    } else if rule.1 == page {
                        beforePages.insert(rule.0)
                    }
                }

                if newJob.isEmpty {
                    newJob.append(page)
                } else {
                    var insertionIndex = newJob.startIndex
                    // iterate the current array to figure out where to place the new page
                    for beforePage in beforePages {
                        if let beforeIndex = newJob.firstIndex(of: beforePage) {
                            if beforeIndex >= insertionIndex {
                                insertionIndex = beforeIndex.advanced(by: 1)
                            }
                        }
                    }
                    //                if newJob.isEmpty || biggestBeforeIndex == newJob.startIndex {
                    newJob.insert(page, at: insertionIndex)
                    //                } else {
                    //                    newJob.insert(page, at: biggestBeforeIndex.advanced(by: 1))
                    //                }
                }
            }
        }
      //  print("newJob = \(newJob)")
        let count = newJob.count
        // find the center #:
        assert(!count.isMultiple(of: 2)) // if we have an even number, what the hell is the center?!
        let centerIndex = Int(floor(Double(count) / 2.0))
        fixedCenterTotal = fixedCenterTotal + newJob[centerIndex]
    }
    print("fixed jobs center totals: \(fixedCenterTotal)")
}
