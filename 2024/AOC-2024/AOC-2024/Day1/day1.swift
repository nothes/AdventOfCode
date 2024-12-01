

func day1()
{
    let input = readInput(forDay: 1)

    let tempData = input.split(separator: "\n")
    var list1: [Int] = []
    var list2: [Int] = []
    var sum = 0
   // var data: [(Int, Int, Int)] = [] // start, end, difference
    for pair in tempData {
        let start = pair.split(separator: "   ") // this is dumb.
        list1.append(Int(start[0]) ?? 0)
        list2.append(Int(start[1]) ?? 0)
    }
    list1.sort()
    list2.sort()
    for index in 0..<list1.count {
        sum = sum + abs(list1[index] - list2[index])
    }
    print("part 1: \(sum)")

    // Calculate a total similarity score by adding up each number in the left list after multiplying it by the number of times that number appears in the right list
    sum = 0

    for id in list1 {
        sum = sum + id * numCount(id)
    }

    print("part 2: \(sum)")
    
    func numCount(_ input: Int) -> Int {
        return list2.count { search in
            search == input
        }
    }
}
