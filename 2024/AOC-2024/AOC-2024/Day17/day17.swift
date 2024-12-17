//
//  day17.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/16/24.
//

import Foundation

func day17() {
    let input = readInput(forDay: 17)

    let lines = input.split(separator: "\n")
    var regA: Int = 0
    var regB: Int = 0
    var regC: Int = 0
    var program: [Int] = []
    var outputBuffer: [Int] = []
    var programString = ""
    //    it starts at 0, pointing at the first 3-bit number in the program. Except for jump instructions, the instruction pointer increases by 2 after each instruction is processed (to move past the instruction's opcode and its operand). If the computer tries to read an opcode past the end of the program, it instead halts.
    var instructionPointer = 0

    for line in lines {
        if line.hasPrefix("Register A: ") {
            regA = Int(line.trimmingPrefix("Register A: "))!
        } else if line.hasPrefix("Register B: ") {
            regB = Int(line.trimmingPrefix("Register B: "))!
        } else if line.hasPrefix("Register C: ") {
            regC = Int(line.trimmingPrefix("Register C: "))!
        } else if line.hasPrefix("Program: ") {
            programString = String(line.trimmingPrefix("Program: "))
            program = programString.split(separator: ",").map { Int($0)! }
        }
    }
    let origRegB = regB
    let origRegC = regC
    // part 1
 //   print(executeProgram(program: program, outputCap: -1))

    //part 2
    var outputString = ""
    var possibleRegA = 0
    while outputString != programString {
        // reset
        possibleRegA += 1 // last oen didn't work, NEXT
        if (possibleRegA % 1000000 == 0) {
            print("regA = \(possibleRegA)")
        }
        regA = possibleRegA
        regB = origRegB
        regC = origRegC
        instructionPointer = 0
        // retry
        outputString = executeProgram(program: program, outputCap: program.count)
       // print("<\(outputString)>\n")
    }
    print("successful regA = \(possibleRegA)")

//    The value of a literal operand is the operand itself. For example, the value of the literal operand 7 is the number 7. The value of a combo operand can be found as follows
//    Combo operands 0 through 3 represent literal values 0 through 3.
//    Combo operand 4 represents the value of register A.
//    Combo operand 5 represents the value of register B.
//    Combo operand 6 represents the value of register C.
//    Combo operand 7 is reserved and will not appear in valid programs.


//    The adv instruction (opcode 0) performs division. The numerator is the value in the A register. The denominator is found by raising 2 to the power of the instruction's combo operand. (So, an operand of 2 would divide A by 4 (2^2); an operand of 5 would divide A by 2^B.) The result of the division operation is truncated to an integer and then written to the A register.
    func adv(comboOp: Int) {
        regA = Int(Double(regA) / pow(2.0, Double(comboOp)))
    }
//    The bxl instruction (opcode 1) calculates the bitwise XOR of register B and the instruction's literal operand, then stores the result in register B.
    func bxl(litOp: Int) {
        regB = regB ^ litOp
    }
//    The bst instruction (opcode 2) calculates the value of its combo operand modulo 8 (thereby keeping only its lowest 3 bits), then writes that value to the B register.
    func bst(comboOp: Int) {
        regB = comboOp % 8
    }
//    The jnz instruction (opcode 3) does nothing if the A register is 0. However, if the A register is not zero, it jumps by setting the instruction pointer to the value of its literal operand; if this instruction jumps, the instruction pointer is not increased by 2 after this instruction.
    func jnz(litOp: Int) {
        if regA == 0 {
            instructionPointer += 2
            return
        } else {
            instructionPointer = litOp // DO NOT INCREASE BY 2 HERE. WE MAY DO A -2 TO ADJUST FOR IT...
        }
    }

//    The bxc instruction (opcode 4) calculates the bitwise XOR of register B and register C, then stores the result in register B. (For legacy reasons, this instruction reads an operand but ignores it.)
    func bxc(_: Int) {
        regB = regB ^ regC
    }
//    The out instruction (opcode 5) calculates the value of its combo operand modulo 8, then outputs that value. (If a program outputs multiple values, they are separated by commas.)
    func out(comboOp: Int) {
        outputBuffer.append(comboOp % 8)
    }
//    The bdv instruction (opcode 6) works exactly like the adv instruction except that the result is stored in the B register. (The numerator is still read from the A register.)
    func bdv(comboOp: Int) {
        regB = Int(Double(regA) / pow(2.0, Double(comboOp)))
    }
//    The cdv instruction (opcode 7) works exactly like the adv instruction except that the result is stored in the C register. (The numerator is still read from the A register.)
    func cdv(comboOp: Int) {
        regC = Int(Double(regA) / pow(2.0, Double(comboOp)))
    }

    func comboOperand(input: Int) -> Int {
        switch input {
        case 0, 1, 2, 3:
            return input
        case 4:
            return regA
        case 5:
            return regB
        case 6:
            return regC
        case 7:
            assertionFailure("I was promised no 7's!")
        default:
            assertionFailure("unexpected input \(input)")
        }
        return -1
    }

    func executeProgram(program: [Int], outputCap: Int) -> String {
        outputBuffer = []
        while instructionPointer < program.count {
            if outputCap != -1 {
                if outputBuffer.count > outputCap {
                    return ""
                }
            }
            let tempOutput = outputBuffer.reduce("", { partialResult, next in
                return partialResult.appending("\(next),")
            })
            if !programString.hasPrefix(tempOutput) {
                return ""
            }
            let instruction = program[instructionPointer]
            let input = program[instructionPointer + 1]
            switch instruction {
            case 0:
                adv(comboOp: comboOperand(input: input))
                instructionPointer+=2
            case 1:
                bxl(litOp: input)
                instructionPointer+=2
            case 2:
                bst(comboOp: comboOperand(input: input))
                instructionPointer+=2
            case 3:
                jnz(litOp: input)
            case 4:
                bxc(0) // input ignored
                instructionPointer+=2
            case 5:
                out(comboOp: comboOperand(input: input))
                instructionPointer+=2
            case 6:
                bdv(comboOp: comboOperand(input: input))
                instructionPointer+=2
            case 7:
                cdv(comboOp: comboOperand(input: input))
                instructionPointer+=2
            default:
                break
            }
        }

        var outputStr = outputBuffer.reduce("", { partialResult, next in
            return partialResult.appending("\(next),")
        })
        outputStr.removeLast()
        return outputStr
    }
}
