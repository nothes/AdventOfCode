//
//  day9.swift
//  AOC-2024
//
//  Created by Rachael Worthington on 12/8/24.
//

import Foundation

struct File: CustomDebugStringConvertible {
    var debugDescription: String {
        if let id {
            return "id:\(id): \(size)"
        } else {
            return "\(size) free"
        }
    }

    let id: Int? // nil ID indicates free space
    let size: Int

    var isFreeSpace: Bool {
        return id == nil
    }

    func fileByRemovingBlock(count: Int = 1) -> File? {
        if size > count {
            return File(id: id, size: size - count)
        } else {
            return nil
        }
    }

    func fileByAddingBlock(count: Int = 1) -> File {
        return File(id: id, size: size + count)
    }
}

func day9() {
    let input = readInput(forDay: 9)

    var fileSystem: [File] = []
    var freeSpaceCount = 0
    // The digits alternate between indicating the length of a file and the length of free space.
    // Each file on disk also has an ID number based on the order of the files as they appear before they are rearranged, starting with ID 0.
    var fileID = 0
    var space = false
    for digit in input {
        guard digit != "\n" else { break }
        let size = Int(String(digit))!
        if !space {
            fileSystem.append(File(id: fileID, size: size))
            fileID = fileID + 1
        } else {
            if size > 0 {
                fileSystem.append(File(id: nil, size: size))
                freeSpaceCount += 1
            }
        }
        space.toggle()
    }

    func part1() {
        // The amphipod would like to move file blocks one at a time from the end of the disk to the leftmost free space block (until there are no gaps remaining between file blocks).
        while freeSpaceCount > 0 {
            // find the first space
            let firstSpaceIndex = fileSystem.firstIndex { file in
                file.isFreeSpace
            }
            guard let firstSpaceIndex else { break }
            let firstSpace = fileSystem[firstSpaceIndex]

            // remove the space, so there's room for the new guy
            if let newSpace = firstSpace.fileByRemovingBlock() {
                fileSystem[firstSpaceIndex] = newSpace
            } else { // otherwise if it's the last space, get rid of it
                fileSystem.remove(at: firstSpaceIndex)
            }

            // do this AFTER we potentially rearrange the array
            // find the last block
            let lastFileIndex = fileSystem.lastIndex { file in
                file.isFreeSpace == false
            }
            let lastFile = fileSystem[lastFileIndex!] // the guy that I'm moving.

            // clean up the bit we just moved
            if let newLastFile = lastFile.fileByRemovingBlock() {
                fileSystem[lastFileIndex!] = newLastFile
            } else {
                fileSystem.remove(at: lastFileIndex!)
                freeSpaceCount -= 1
            }

            // if the file right before the first space is the same ID as the last block, just combine, otherwise insert a new File
            let prevFileIndex = firstSpaceIndex - 1
            if prevFileIndex >= 0 {
                let prevFile = fileSystem[prevFileIndex]
                if prevFile.id == lastFile.id {
                    fileSystem[prevFileIndex] = prevFile.fileByAddingBlock()
                } else {
                    fileSystem.insert(File(id: lastFile.id, size: 1), at: firstSpaceIndex)
                }
            } else {
                fileSystem.insert(File(id: lastFile.id, size: 1), at: firstSpaceIndex)
            }
        }
    }

    // The final step of this file-compacting process is to update the filesystem checksum. To calculate the checksum, add up the result of multiplying each of these blocks' position with the file ID number it contains. The leftmost block is in position 0.
    func calculateChecksum(for system: [File]) -> Int {
        var position = 0
        var sum = 0
        for file in system {
            for _ in 0..<file.size {
                sum += position * (file.id ?? 0) // this is to avoid errors, there should be no id-less ones anymore
                position += 1
            }
        }
        return sum
    }

    // part 1
//    part1()
//    print("Checksum = \(calculateChecksum(for: fileSystem))")

    func part2() {
//        print("fileSystemBefore: \(fileSystem)")
      //  This time, attempt to move whole files to the leftmost span of free space blocks that could fit the file. Attempt to move each file exactly once in order of decreasing file ID number starting with the file with the highest file ID number. If there is no span of free space to the left of a file that is large enough to fit the file, the file does not move.
        var lastFileIndex = fileSystem.lastIndex { file in
            !file.isFreeSpace
        }!

        var currFileID = fileSystem[lastFileIndex].id ?? 0
        var fileToMove = fileSystem[lastFileIndex]
        var fileSize = fileToMove.size

        while currFileID > 0 { // do i need to _include_ 0?
//            print("fileSystemDuring: \(fileSystem)")
//            print("moving file \(currFileID)")
            // find where to put it
            if let insertIndex = fileSystem.firstIndex(where:{ file in
                file.isFreeSpace && file.size >= fileSize
            }), insertIndex < lastFileIndex {
//                print("found space at index \(insertIndex), with \(fileSystem[insertIndex].size) space")
                // remove the old file
                fileSystem.remove(at: lastFileIndex)
                // and replace it with space!
                if lastFileIndex < fileSystem.count {
                    if fileSystem[lastFileIndex].isFreeSpace {
                        fileSystem[lastFileIndex] = fileSystem[lastFileIndex].fileByAddingBlock(count: fileSize)
                    } else if fileSystem[lastFileIndex-1].isFreeSpace {
                        fileSystem[lastFileIndex-1] = fileSystem[lastFileIndex-1].fileByAddingBlock(count: fileSize)
                    } else {
                        fileSystem.insert(File(id: nil, size: fileSize), at: lastFileIndex)
                    }
                } else {
                    fileSystem.append(File(id: nil, size: fileSize))
                }
                // collapse space around it
                if fileSystem[lastFileIndex-1].isFreeSpace && fileSystem[lastFileIndex].isFreeSpace {
                    let totalFreeSpace = fileSystem[lastFileIndex-1].size + fileSystem[lastFileIndex].size
                    fileSystem.remove(at: lastFileIndex)
                    fileSystem[lastFileIndex - 1] = File(id: nil, size: totalFreeSpace)
                }
                // remove the appropriate space and insert new file
                if let newSpace = fileSystem[insertIndex].fileByRemovingBlock(count: fileSize) {
//                    print("space remains")
                    fileSystem[insertIndex] = newSpace
                    fileSystem.insert(fileToMove, at: insertIndex)
                } else {
//                    print("space collapsed")
                    fileSystem.remove(at: insertIndex)
                    fileSystem.insert(fileToMove, at: insertIndex)
                }
            }
            currFileID -= 1
            
            lastFileIndex = fileSystem.lastIndex(where: { file in
                file.id == currFileID
            })!

            fileToMove = fileSystem[lastFileIndex]
            fileSize = fileToMove.size
        }
//        print("fileSystemAfter: \(fileSystem)")

    }

    // part 2
    part2()
    print("Checksum = \(calculateChecksum(for: fileSystem))")
    // 20484652049928 is Too High
}


// 0099.111...2...333.44.5555.6666.777.8888
