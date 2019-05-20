//
//  storeSensorData.swift
//  GestureiOS
//
//  Created by fluid on 11/14/18.
//  Copyright © 2018 fluid. All rights reserved.
//

import UIKit

class StoreSensorData: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        do {
            // get the documents folder url
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                // create the destination url for the text file to be saved
                let fileURL = documentDirectory.appendingPathComponent("file.txt")
                // define the string/text to be saved
                let text = "Hello World !!!"
                // writing to disk
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
                print("saving was successful")
                // any code posterior code goes here
                // reading from disk
                let savedText = try String(contentsOf: fileURL)
                print("savedText:", savedText)   // "Hello World !!!\n"
            }
        } catch {
            print("error:", error)
        }
        
    }
}
    

