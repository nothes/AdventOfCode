//
//  day7.swift
//  AoC
//
//  Created by Rachael Worthington on 12/6/22.
//

import Foundation

let DISK_SIZE = 70000000
let INSTALL_SIZE_REQD = 30000000

func day7() {
    let path = "/Users/rachael/Documents/AoC-remote/AoC/AoC/Day 7/input"
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        parseInput(text)
        findSmallestDirToDelete()
    } catch {
        print(error.localizedDescription)
    }
}

class DiskObj {
    let name: String
    var containedObjects: Dictionary<String, DiskObj> // must be unique names
    let parentObject: DiskObj?
    var size: Int
    let dir: Bool

    init(name: String, containedObjects: Dictionary<String, DiskObj>, parentObject: DiskObj?, size: Int, dir: Bool) {
        self.name = name
        self.containedObjects = containedObjects
        self.parentObject = parentObject
        self.size = size
        self.dir = dir
    }

    func addFileSize(_ size: Int) {
        self.size += size
        if let parentObject = parentObject {
            parentObject.addFileSize(size)
        }
    }

    func smallDirs() -> [DiskObj] {
        var smallFiles = Array(containedObjects.filter { (_, value) in
            return value.size <= 100000 && value.dir == true
        }.values)

        for (_, file) in containedObjects {
            smallFiles.append(contentsOf: file.smallDirs())
        }

        return smallFiles
    }

    func sizeOfSmallDirs() -> Int {
         return self.smallDirs().reduce(into: 0) { partialResult, obj in partialResult += obj.size }
    }

    func dirsBiggerThan(_ targetSize: Int) -> [DiskObj] {
        var bigEnoughDirs = Array(containedObjects.filter { (_, obj) in obj.dir == true }.filter { (_, obj) in obj.size >= targetSize }.values)

        for (_, file) in self.containedObjects {
            bigEnoughDirs.append(contentsOf: file.dirsBiggerThan(targetSize))
        }

        return bigEnoughDirs
    }

    // returns the size of that directory
    func smallestDirLargerThan(_ targetSize: Int) -> Int {
        return self.dirsBiggerThan(targetSize).sorted { (tuple1, tuple2) in return tuple1.size < tuple2.size }[0].size
    }
}

var root: DiskObj = DiskObj(name: "/", containedObjects: [:], parentObject: nil, size: 0, dir: true)
var currentDir: DiskObj = root

fileprivate func parseInput(_ text: String) {
    var cmds = text.split(separator: "\n")

    var nextCmd = String(cmds.removeFirst())
    while cmds.isEmpty == false {
        if nextCmd.first == "$" { // new command!
            let parts = nextCmd.split(separator: " ")
            switch parts[1] { //
            case "ls": // each of the next lines should be a file or a dir.
                       // check next command:
                var peekedCmd = cmds[0].split(separator: " ")[0]
                while peekedCmd != "$" && cmds.isEmpty == false {
                    let content = cmds.removeFirst().split(separator: " ")
                    let name = String(content[1])
                    if content[0] == "dir" {
                        if currentDir.containedObjects[name] == nil {
                            let dir = DiskObj(name: name, containedObjects: [:], parentObject: currentDir, size: 0, dir: true)
                            currentDir.containedObjects[name] = dir
                        }
                    } else { // file & size
                        if let size = Int(content[0]) {
                            assert(size >= 0, "file size must be positive")
                            if currentDir.containedObjects[name] == nil {
                                let file = DiskObj(name: name, containedObjects: [:], parentObject: currentDir, size: size, dir: false)
                                currentDir.containedObjects[name] = file
                                currentDir.addFileSize(size)
                            }
                        }
                    }
                    if cmds.isEmpty == false {
                        peekedCmd = cmds[0].split(separator: " ")[0]
                    }
                }
            case "cd": // change directory relative to your current position.
                let newLocation = String(parts[2])
                if newLocation == "/" {
                    currentDir = root
                } else if newLocation == ".." {
                    if let parent = currentDir.parentObject {
                        currentDir = parent
                    } else {
                        print("trying to go up 1 dir, but we don't know where that should go")
                    }
                } else {
                    if let newDir = currentDir.containedObjects[newLocation] {
                        currentDir = newDir
                    } else {
                        print("tried to cd into a directory \(newLocation) we don't know exists")
                        return
                    }
                }
            default:
                print("you didn't consume all the last command.")
            }
        }
        if cmds.isEmpty == false {
            nextCmd = String(cmds.removeFirst())
        }
    }

    print("total used size: \(root.size)")
    print("total size of <= 100000 dirs: \(root.sizeOfSmallDirs())")
}

func findSmallestDirToDelete() {
    let freeSpace = DISK_SIZE - root.size
    let spaceStillNeeded = INSTALL_SIZE_REQD - freeSpace

    if spaceStillNeeded <= 0 {
        print("nothing to delete, you have \(freeSpace) free, already!")
        return
    }

    print("delete the dir with size \(root.smallestDirLargerThan(spaceStillNeeded))")
}
