//: [Previous](@previous)

import Foundation

var num = 4890

var digits: [String] = []

var multiplier = 1
var count = 0
var carryValue = 0

while num != 0 {
    var digit = num / multiplier
    var remainder = num % multiplier
    digits.append("")
    // should be 0-4
    // 0, 1, or 2 can just be used
    if remainder <= 2 {
        digits[count] = String(remainder)
    } else {
        // we'll need to use a negative number, which means we need to increase the numbers used in the higher digits...
        if remainder == 3 {
            // increase the nextdigit up
            digits[count] = "="
            carryValue = multiplier
        } else if remainder == 4 {
            digits[count] = "-"
            carryValue = multiplier
        }
    }
    num = digit + remainder * multiplier
    digit += 1
    multiplier *= 5
}


