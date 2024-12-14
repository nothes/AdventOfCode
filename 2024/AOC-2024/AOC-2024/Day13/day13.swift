//
//  day13.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/12/24.
//

import Foundation
import RegexBuilder
import Accelerate

func day13() {
    let buttonAString = "Button A: "
    let buttonBString = "Button B: "
    let prizeString = "Prize: "
    let input = readInput(forDay: 13)

    let buttonPattern = Regex {
        ChoiceOf {
            One(buttonAString)
            One(buttonBString)
        }
        One("X+")
        Capture {
            OneOrMore {
                .digit
            }
        }
        One(", Y+")
        Capture {
            OneOrMore {
                .digit
            }
        }
    }

    let prizePattern = Regex {
        One(prizeString)
        One("X=")
        Capture {
            OneOrMore {
                .digit
            }
        }
        One(", Y=")
        Capture {
            OneOrMore {
                .digit
            }
        }
    }

    var machines:[ClawMachine] = []
    let machineStrings = input.split(separator: "\n\n")
    for machine in machineStrings {
        var buttonA = FloatCoord(x: -1, y: -1)
        var buttonB = FloatCoord(x: -1, y: -1)
        var prize = FloatCoord(x: -1, y: -1)
        for string in machine.split(separator: "\n") {

            if string.hasPrefix(buttonAString) {
                let matches = string.matches(of: buttonPattern)
                assert(matches.count == 1)
                if let match = matches.first {
                    buttonA = FloatCoord(x: Float(match.1)!, y: Float(match.2)!)
                }
            } else if string.hasPrefix(buttonBString) {
                let matches = string.matches(of: buttonPattern)
                assert(matches.count == 1)
                if let match = matches.first {
                    buttonB = FloatCoord(x: Float(match.1)!, y: Float(match.2)!)
                }
            } else if string.hasPrefix(prizeString) {
                let matches = string.matches(of: prizePattern)
                assert(matches.count == 1)
                if let match = matches.first {
                    prize = FloatCoord(x: Float(match.1)!, y: Float(match.2)!)
                }
            } else {
                assertionFailure("what is this input? \(string)")
            }
        }
        machines.append(ClawMachine(buttonA: buttonA, buttonB: buttonB, prize: prize, costA: 3, costB: 1))
    }

    print(machines)
    var total = 0

    for machine in machines {
        if let tokens = machine.tokensToWin() {
            total += tokens
        }
      //  print("\(String(describing: machine.tokensToWin())) to get prize at \(machine.prize)")
    }

    print("total tokens: \(total)")
    struct ClawMachine: CustomDebugStringConvertible {
        var debugDescription: String {
            "a: \(buttonA) b: \(buttonB) prize: \(prize)"
        }

        let buttonA: FloatCoord
        let buttonB: FloatCoord
        let prize: FloatCoord
        let costA: Float
        let costB: Float

        let pressLimit = 100 // no more than 100 presses per button!

        func tokensToWin() -> Int? { // nil is unwinnable
                                     // we cannot win if buttonA.x * aPresses + buttonB.x * bPresses != prize.x
                                     // AND buttonA.y * aPresses + buttonB.y * bPresses != prize.y
                                     // OR if aPresses > pressLimit OR if bPresses > pressLimit

            // this is a system of linear equations
            // buttonA.x * aPresses + buttonB.x * bPresses = prize.x
            // buttonA.y * aPresses + buttonB.y * bPresses = prize.y
            // aPresses <= pressLimit
            // bPresses <= pressLimit

            //            var aPresses = 0
            //            var bPresses = 0

            // column major format

            let aValues: [Float] = [buttonA.x, buttonA.y,
                                    buttonB.x, buttonB.y]

            /// The _b_ in _Ax = b_.
            let bValues: [Float] = [prize.x, prize.y]

            /// Call `nonsymmetric_general` to compute the _x_ in _Ax = b_.
            let x = nonsymmetric_general(a: aValues,
                                         dimension: 2,
                                         b: bValues,
                                         rightHandSideCount: 1)

          //  print("\nx vals: x = ", x)
            if let x {
                print("a presses: \(x[0])")
                print("b presses: \(x[1])")
                if x[0].remainder(dividingBy: 1.0) != 0 || x[1].remainder(dividingBy: 1.0) != 0 {
                    return nil
                }
                return Int(x[0]*costA + x[1] * costB)
            } else {
                return nil
            }
            /// Calculate _b_ using the computed _x_.
            //                if let x = x {
            //                    let b = matrixVectorMultiply(matrix: aValues,
            //                                                 dimension: (m: 2, n: 2),
            //                                                 vector: x)
            //
            //                    /// Prints _b_ in _Ax = b_ using the computed _x_: `~[70, 160, 250]`.
            //                    print("\nnonsymmetric_general: b =", b)
            //                }

        }
    }

}

func nonsymmetric_general(a: [Float],
                          dimension: Int,
                          b: [Float],
                          rightHandSideCount: Int) -> [Float]? {

    var info: __LAPACK_int = 0

    /// Create a mutable copy of the right hand side matrix _b_ that the function returns as the solution matrix _x_.
    var x = b

    /// Create a mutable copy of `a` to pass to the LAPACK routine. The routine overwrites `mutableA`
    /// with the factors `L` and `U` from the factorization `A = P * L * U`.
    var mutableA = a

    var ipiv = [__LAPACK_int](repeating: 0, count: dimension)

    /// Call `sgesv_` to compute the solution.
    withUnsafePointer(to: __LAPACK_int(dimension)) { n in
        withUnsafePointer(to: __LAPACK_int(rightHandSideCount)) { nrhs in
            
            sgesv_(n,
                   nrhs,
                   &mutableA,
                   n,
                   &ipiv,
                   &x,
                   n,
                   &info)
        }
    }

    if info != 0 {
        NSLog("nonsymmetric_general error \(info)")
        return nil
    }
    return x
}

func matrixVectorMultiply(matrix: [Float],
                          dimension: (m: Int, n: Int),
                          vector: [Float]) -> [Float] {

    let result = [Float](unsafeUninitializedCapacity: dimension.m) {
        buffer, initializedCount in

        cblas_sgemv(CblasColMajor, CblasNoTrans,
                    __LAPACK_int(dimension.m),
                    __LAPACK_int(dimension.n),
                    1, matrix, __LAPACK_int(dimension.m),
                    vector, 1, 0,
                    buffer.baseAddress, 1)

        initializedCount = dimension.m
    }

    return result
}

