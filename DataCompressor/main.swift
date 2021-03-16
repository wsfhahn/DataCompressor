//
//  File.swift
//
//
//  Created by William Hahn on 3/12/21.
//
//        ( )
//         |
//     []     []
//         ]]
//     _-_-_-_-_
//

// not sure if i even used foundation but its handy to keep around
import Foundation
import Compression
import CoreData

// gather data from the user (me), code is broken for now
func gatherData() -> (String?, Int, String?) {
    var userString: String?
    var tempString: String?
    var pageSize: Int = 0
    var outputFile: String?
    
    print("String to compress?")
    userString = readLine()
    
    print("Page size? (defaults to 128)")
    tempString = readLine()
    
    // optionals suck balls like what the actual fuck. why apple, why?!?!?
    if tempString != nil {
        pageSize = Int(tempString!) ?? 128
    } else if tempString == nil {
        pageSize = 128
    }
    
    print("File to write?")
    outputFile = readLine()
    
    return (userString, pageSize, outputFile)
}


// don't forget to work on this bit, good luck parsing lzfse data from file as utf8
let userData = gatherData()
let sourceData = userData.0!.data(using: .utf8)
let pageSize = userData.1
let outputFile = userData.2

// this code is gold, works flawlessly
func compressData(uncompressedData: Data?, pageSize: Int) -> Data {
    var compressedData = Data()
    do {
        let outputFilter = try OutputFilter(.compress, using: .lzfse) { (data: Data?) -> Void in
            if let data = data {
                compressedData.append(data)
            }
        }
        
        var index = 0
        let bufferSize = uncompressedData!.count
        
        while true {
            let rangeLength = min(pageSize, bufferSize - index)
            
            let subdata = uncompressedData!.subdata(in: index ..< index + rangeLength)
            index += rangeLength
            
            try outputFilter.write(subdata)
            
            if rangeLength == 0 {
                break
            }
        }
    } catch {
        fatalError("Something went wrong: \(error.localizedDescription)")
    }
    return compressedData
}

// work good for writing compressed data, not so much raw strings
func writeData(dataToWrite: Data, outputFile: String?) {
    let fileURL = NSURL(fileURLWithPath: outputFile!)
    
    do {
        try dataToWrite.write(to: fileURL as URL)
    } catch {
        fatalError("Something happened! \(error.localizedDescription)")
    }
}

func compress() {
    let compressedData = compressData(uncompressedData: sourceData, pageSize: pageSize)
    writeData(dataToWrite: compressedData, outputFile: outputFile)
}
