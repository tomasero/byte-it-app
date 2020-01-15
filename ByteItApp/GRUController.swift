//
//  GRUController.swift
//  ByteItApp
//
//  Created by Tomás Vega on 6/1/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit
//import CoreMotion

class GRUController: UIViewController,
    CBCentralManagerDelegate,
CBPeripheralDelegate {
    
    var manager:CBCentralManager!
    var _peripheral:CBPeripheral!
    var sendCharacteristic: CBCharacteristic!
    var loadedService: Bool = true
    var tag = -1
    
    let NAME = "GVS"
    let UUID_SERVICE = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let UUID_WRITE = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    let UUID_READ = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    //    let motionManager = CMMotionManager()
    
    func getPeripheralState() -> String {
        if let peripheral: CBPeripheral = _peripheral {
            switch(peripheral.state){
            case .disconnected:
                return "Disconnected"
            case .connecting:
                return "Connecting"
            case .connected:
                return "Connected"
            case .disconnecting:
                return "Disconnecting"
            default:
                return "Unknown"
            }
        }
        return "Disconnected"
    }
    
    
    func connect() {
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func disconnect() {
        if manager != nil && _peripheral != nil{
            manager.cancelPeripheralConnection(_peripheral)
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState")
        if central.state == CBManagerState.poweredOn {
            print("Buscando a Marc")
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    // Found a peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        // Check if this is the device we want
        if device?.contains(NAME) == true {
            print(peripheral.name)
            print(peripheral.identifier)
            // Stop looking for devices
            // Track as connected peripheral
            // Setup delegate for events
            self.manager.stopScan()
            self._peripheral = peripheral
            self._peripheral.delegate = self
            
            // Connect to the perhipheral proper
            manager.connect(peripheral, options: nil)
            debugPrint("Found Bean.")
        }
    }
    
    // Connected to peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Ask for services
        peripheral.discoverServices(nil)
        debugPrint("Getting services ...")
    }
    
    // Discovered peripheral services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Look through the service list
        for service in peripheral.services! {
            let thisService = service as CBService
            // If this is the service we want
            if service.uuid == UUID_SERVICE {
                // Ask for specific characteristics
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
            debugPrint("Service: ", service.uuid)
        }
    }
    
    // Discovered peripheral characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        debugPrint("Enabling ...")
        // Look at provided characteristics
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            // If this is the characteristic we want
            print(thisCharacteristic.uuid)
            if thisCharacteristic.uuid == UUID_READ {
                // Start listening for updates
                // Potentially show interface
                self._peripheral.setNotifyValue(true, for: thisCharacteristic)
                
                // Debug
                debugPrint("Set to notify: ", thisCharacteristic.uuid)
            } else if thisCharacteristic.uuid == UUID_WRITE {
                sendCharacteristic = thisCharacteristic
                loadedService = true
            }
            debugPrint("Characteristic: ", thisCharacteristic.uuid)
        }
    }
    
    let alpha: Float = 0.2
    var currAccX: Int32 = 0
    var currAccY: Int32 = 0
    var currAccZ: Int32 = 0
    var oldAccX: Int32 = 0
    var oldAccY: Int32 = 0
    var oldAccZ: Int32 = 0
    
    var currGyrX: Int32 = 0
    var currGyrY: Int32 = 0
    var currGyrZ: Int32 = 0
    var oldGyrX: Int32 = 0
    var oldGyrY: Int32 = 0
    var oldGyrZ: Int32 = 0
    
    var currVBat: Int32 = 0
    var oldVBat: Int32 = 0
    
    func getVBat() -> Int32 {
        return self.currVBat
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        print(peripheral.identifier)
        // Make sure it is the peripheral we want
        if characteristic.uuid == UUID_READ {
            // Get bytes into string
            let dataReceived = characteristic.value! as NSData
            
            var uAccX: UInt32 = 0
            var uAccY: UInt32 = 0
            var uAccZ: UInt32 = 0
            var uGyrX: UInt32 = 0
            var uGyrY: UInt32 = 0
            var uGyrZ: UInt32 = 0
            var vBat: UInt32 = 0
            
            dataReceived.getBytes(&uAccX, range: NSRange(location: 0, length: 4))
            dataReceived.getBytes(&uAccY, range: NSRange(location: 4, length: 4))
            dataReceived.getBytes(&uAccZ, range: NSRange(location: 8, length: 4))
            
            dataReceived.getBytes(&uGyrX, range: NSRange(location: 12, length: 4))
            dataReceived.getBytes(&uGyrY, range: NSRange(location: 16, length: 4))
            dataReceived.getBytes(&uGyrZ, range: NSRange(location: 20, length: 4))
            
            dataReceived.getBytes(&vBat, range: NSRange(location: 24, length: 4))
            
            var accX: Int32 = Int32(uAccX)
            var accY: Int32 = Int32(uAccY)
            var accZ: Int32 = Int32(uAccZ)
            var gyrX: Int32 = Int32(uGyrX)
            var gyrY: Int32 = Int32(uGyrY)
            var gyrZ: Int32 = Int32(uGyrZ)
            
            let max: Int32 = 65536
            let mid: Int32 = 65536/2
            
            if (accX > mid) {
                accX = accX - max
            }
            if (accY > mid) {
                accY = accY - max
            }
            if (accZ > mid) {
                accZ = accZ - max
            }
            
            if (gyrX > mid) {
                gyrX = gyrX - max
            }
            if (gyrY > mid) {
                gyrY = gyrY - max
            }
            if (gyrZ > mid) {
                gyrZ = gyrZ - max
            }
            
//            currAccX = Int32(alpha * Float(accX) + (1 - alpha) * Float(currAccX))
//            currAccY = Int32(alpha * Float(accY) + (1 - alpha) * Float(currAccY))
//            currAccZ = Int32(alpha * Float(accZ) + (1 - alpha) * Float(currAccZ))
//
//            currGyrX = Int32(alpha * Float(gyrX) + (1 - alpha) * Float(currGyrX))
//            currGyrY = Int32(alpha * Float(gyrY) + (1 - alpha) * Float(currGyrY))
//            currGyrZ = Int32(alpha * Float(gyrZ) + (1 - alpha) * Float(currGyrZ))
            currAccX = accX
            currAccY = accY
            currAccZ = accZ
            
            currGyrX = gyrX
            currGyrY = gyrY
            currGyrZ = gyrZ
            
            self.currVBat = Int32(alpha * Float(vBat) + (1 - alpha) * Float(currVBat))
            //            print(self.currVBat)
//            let distX = abs(currAccX - oldAccX)
//            let distY = abs(currAccY - oldAccY)
//            let distZ = abs(currAccZ - oldAccZ)

            
            oldAccX = currAccX
            oldAccY = currAccY
            oldAccY = currAccZ
            
            oldGyrX = currGyrX
            oldGyrY = currGyrY
            oldGyrY = currGyrZ
            
            
        }
        
    }
    
    // add parameter to getData to indicate whether to use iphone data or exoear data
    func getData(fromGRU:Bool = true) -> [(Int32, Int32, Int32)] {
        return [(currAccX, currAccY, currAccZ), (currGyrX, currGyrY, currGyrZ)]
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("success")
        print(characteristic.uuid)
        print(error)
        debugPrint("Connected.", self.tag)
        let classifyVC = Shared.instance.getVC(name: "ClassifyViewController") as! ClassifyViewController
        classifyVC.peripheralStateChanged(tag: self.tag, state: "Connected")
        let gesturesVC = Shared.instance.getVC(name: "GesturesViewController") as! GesturesViewController
        gesturesVC.peripheralStateChanged(tag: self.tag, state: "Connected")
    }
    
    // Peripheral disconnected
    // Potentially hide relevant interface
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        debugPrint("Disconnected.", self.tag)
        let classifyVC = Shared.instance.getVC(name: "ClassifyViewController") as! ClassifyViewController
        classifyVC.peripheralStateChanged(tag: self.tag, state: "Disconnected")
        let gesturesVC = Shared.instance.getVC(name: "GesturesViewController") as! GesturesViewController
        gesturesVC.peripheralStateChanged(tag: self.tag, state: "Disconnected")
    }
    
}

//func getData() -> NSData{
//  let state: UInt16 = stateValue ? 1 : 0
//  let power:UInt16 = UInt16(thresholdValue)
//  var theData : [UInt16] = [ state, power ]
//  print(theData)
//  let data = NSData(bytes: &theData, length: theData.count)
//  return data
//}
//
//func updateSettings() {
//  if loadedService {
//    if _peripheral?.state == CBPeripheralState.connected {
//      if let characteristic:CBCharacteristic? = sendCharacteristic{
//        let data: Data = getData() as Data
//        _peripheral?.writeValue(data,
//                                for: characteristic!,
//                                type: CBCharacteristicWriteType.withResponse)
//      }
//    }
//  }
//}
