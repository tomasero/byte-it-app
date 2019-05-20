//
//  DynamicDataSource.swift
//  GestureiOS
//
//  Created by fluid on 11/21/18.
//  Copyright © 2018 fluid. All rights reserved.
//
import UIKit

class DynamicDataSource: NSObject,UITableViewDataSource,UITableViewDelegate {
    
    var sampleFileNames: [String] = []
    var fileNameCount: [String: Int] = [:]
    var uniqueFileNames: [String: String] = [:]
    
    override init(){
        super.init()
    }
    
    
    func setData(sampleFileNames:[String]){
        self.sampleFileNames = sampleFileNames
    }
    
    func setCount(fileDict:[String: Int]){
        self.fileNameCount = fileDict
    }
    
    func setName(fileNameDict:[String: String]){
        self.uniqueFileNames = fileNameDict
    }

    func getCount() -> [String: Int]{
        return self.fileNameCount
    }
    
    func getName() -> [String: String]{
        return self.uniqueFileNames
    }
    
    func getData() -> [String]{
        return self.sampleFileNames
    }
    
//    func addData(fileName:String){
//        self.sampleFileNames.append(fileName)
//    }
//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleFileNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UITableViewCell  else {
            fatalError("The dequeued cell is not an instance of TableViewCell.")
        }
        
        cell.textLabel?.text = sampleFileNames[indexPath.row]
        
        return cell
    }
    
        // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                
                
               let fileManager = FileManager.default
                do {
                    let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create: true)
                    let fileURL = documentDirectory.appendingPathComponent(self.sampleFileNames[indexPath.row]).appendingPathExtension("txt")
                    print("Deleting File at File Path: \(fileURL.path)")
                    
                    try fileManager.removeItem(atPath: fileURL.path)
                    
                    print("File successfully deleted")
                    
                } catch {
                    print(error)
                }
                
                
                sampleFileNames.remove(at: indexPath.row)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
        }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
}
