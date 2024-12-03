//
//  day2.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/1/24.
//

func day2() {
    let input = readInput(forDay: 2)

    // The levels are either all increasing or all decreasing.
    // Any two adjacent levels differ by at least one and at most three.
    let reports = input.split(separator: "\n")
    var safeCount = 0
    // pt 1
//    for report in reports {
//        let values = report.split(separator: " ")
//        var prevValue: Int = Int(values.first!)!
//        let increase = prevValue < Int(values[1])!
//        var safe = true
//        for index in 1..<values.count {
//            safe = true
//            let currValue: Int = Int(values[index])!
//            if increase {
//                if currValue - prevValue > 3 || currValue - prevValue < 1 {
//                    safe = false
//                    break // unsafe!
//                }
//            } else {
//                if prevValue - currValue > 3 || prevValue - currValue < 1 {
//                    safe = false
//                    break
//                }
//            }
//            prevValue = currValue
//        }
//        if safe {
//            safeCount += 1
//        }
//    }
//    print("total safe reports: \(safeCount)")

    // pt 2
    // same as above, but if a report fails, you can try to fix it by removing one of the offending levels & checking the next.
    for report in reports {
        print("evaluating \(report)")
        let values = report.split(separator: " ")
        var safe = true
        safe = evaluateReport(values: values)
        if safe {
            print("***series \(report) is safe")
            safeCount += 1
        } else {
            // I'm tired, we're brute-forcing this mofo.
            for index in 0..<values.count {
                var testData = values//Array(values[index..<index+1])
                testData.remove(at: index)
                if evaluateReport(values: testData) {
                    safeCount += 1
                    break;
                }
            }
        }
    }
    print("total safe reports: \(safeCount)") // 2
}

func evaluateReport(values: [Substring]) -> Bool {
    let increase = Int(values[0])! < Int(values[1])!
    var prevValue: Int = Int(values.first!)!

    for index in 1..<values.count {
        let currValue: Int = Int(values[index])!
        if increase {
            if currValue - prevValue > 3 || currValue - prevValue < 1 {
                return false
            }
        } else {
            if prevValue - currValue > 3 || prevValue - currValue < 1 {
                return false
            }
        }
        prevValue = currValue
    }
    return true
}
