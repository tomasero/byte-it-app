//
//  ExoEarController.swift
//  GestureiOS
//
//  Created by Tomas Vega on 11/27/18.
//  Copyright © 2018 fluid. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

class ExoEarController: UIViewController,
                        CBCentralManagerDelegate,
                        CBPeripheralDelegate {
  
  var manager:CBCentralManager!
  var _peripheral:CBPeripheral!
  var sendCharacteristic: CBCharacteristic!
  var loadedService: Bool = true

  let NAME = "GVS"
  let UUID_SERVICE = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
  let UUID_WRITE = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
  let UUID_READ = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
  
  
  func initExoEar() {
    manager = CBCentralManager(delegate: self, queue: nil)
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
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

  
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("Data")
    // Make sure it is the peripheral we want
    //    print(characteristic.uuid)
        if characteristic.uuid == UUID_READ {
        // Get bytes into string
            let dataReceived = characteristic.value! as NSData
         // print(dataReceived)

        var uAccX: UInt32 = 0
        var uAccY: UInt32 = 0
        var uAccZ: UInt32 = 0
        var uNAccX: UInt32 = 0
        var uNAccY: UInt32 = 0
        var uNAccZ: UInt32 = 0
        var uGyrX: UInt32 = 0
        var uGyrY: UInt32 = 0
        var uGyrZ: UInt32 = 0
        var uNGyrX: UInt32 = 0
        var uNGyrY: UInt32 = 0
        var uNGyrZ: UInt32 = 0
      
        dataReceived.getBytes(&uAccX, range: NSRange(location: 0, length: 4))
        dataReceived.getBytes(&uAccY, range: NSRange(location: 4, length: 4))
        dataReceived.getBytes(&uAccZ, range: NSRange(location: 8, length: 4))
       
        dataReceived.getBytes(&uGyrX, range: NSRange(location: 12, length: 4))
        dataReceived.getBytes(&uGyrY, range: NSRange(location: 16, length: 4))
        dataReceived.getBytes(&uGyrZ, range: NSRange(location: 20, length: 4))
            
//        dataReceived.getBytes(&uNAccX, range: NSRange(location: 24, length: 4))
//        dataReceived.getBytes(&uNAccY, range: NSRange(location: 28, length: 4))
//        dataReceived.getBytes(&uNAccZ, range: NSRange(location: 32, length: 4))
//
//        dataReceived.getBytes(&uNGyrX, range: NSRange(location: 36, length: 4))
//        dataReceived.getBytes(&uNGyrY, range: NSRange(location: 40, length: 4))
//        dataReceived.getBytes(&uNGyrZ, range: NSRange(location: 44, length: 4))
      
      
        var accX: Int32 = Int32(uAccX)
        var accY: Int32 = Int32(uAccY)
        var accZ: Int32 = Int32(uAccZ)
//        var nAccX: Int32 = Int32(uNAccX)
//        var nAccY: Int32 = Int32(uNAccY)
//        var nAccZ: Int32 = Int32(uNAccZ)
        var gyrX: Int32 = Int32(uGyrX)
        var gyrY: Int32 = Int32(uGyrY)
        var gyrZ: Int32 = Int32(uGyrZ)
//        var nGyrX: Int32 = Int32(uNGyrX)
//        var nGyrY: Int32 = Int32(uNGyrY)
//        var nGyrZ: Int32 = Int32(uNGyrZ)

   //     print(accX, accY, accZ)
//        print(nAccX, nAccY, nAccZ)
     //   print(gyrX, gyrY, gyrZ)
//        print(nGyrX, nGyrY)

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
            
        currAccX = Int32(alpha * Float(accX) + (1 - alpha) * Float(currAccX))
        currAccY = Int32(alpha * Float(accY) + (1 - alpha) * Float(currAccY))
        currAccZ = Int32(alpha * Float(accZ) + (1 - alpha) * Float(currAccZ))

        currGyrX = Int32(alpha * Float(gyrX) + (1 - alpha) * Float(currGyrX))
        currGyrY = Int32(alpha * Float(gyrY) + (1 - alpha) * Float(currGyrY))
        currGyrZ = Int32(alpha * Float(gyrZ) + (1 - alpha) * Float(currGyrZ))

        let distX = abs(currAccX - oldAccX)
        let distY = abs(currAccY - oldAccY)
        let distZ = abs(currAccZ - oldAccZ)


        //      print(currAccX, oldAccX, distX);
        //      print(currAccY, oldAccY, distY);

        oldAccX = currAccX
        oldAccY = currAccY
        oldAccY = currAccZ

        oldGyrX = currGyrX
        oldGyrY = currGyrY
        oldGyrY = currGyrZ

            
        }
    
    }
  
    func getData() -> [(Int32, Int32, Int32)] {
    return [(currAccX, currAccY, currAccZ), (currGyrX, currGyrY, currGyrZ)]
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    print("success")
    print(characteristic.uuid)
    print(error)
  }
  
  // Peripheral disconnected
  // Potentially hide relevant interface
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    debugPrint("Disconnected.")
    
    // Start scanning again
    central.scanForPeripherals(withServices: nil, options: nil)
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
