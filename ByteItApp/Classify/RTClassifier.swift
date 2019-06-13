//
//  RTClassifier.swift
//  GestureClassifier
//
//  Created by Abishkar Chhetri on 4/19/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import UIKit
import CoreMotion
import CoreML

public class RTClassifier: NSObject {
    //    var exoEar = ExoEarController()
    var timer:Timer = Timer()
    //meta parameters
    //    var motionManager = CMMotionManager()
    var data: Dictionary<String, Participant> = Dictionary<String, Participant>()
    let knn: KNNDTW = KNNDTW()
    var training_samples: [knn_curve_label_pair] = [knn_curve_label_pair]()
    var trainingData: Dictionary<String, SampleData> = Dictionary<String, SampleData>()
    var currentIndexInPredictionWindow = 0
    var predictionWindowSize = 50
    var sampleBuffer:SampleBuffer = SampleBuffer(number: 0, count: 50)
    let realtimeSample:SampleData = SampleData(number:0)
    var distanceThreshold:Float = 1000000
    
    
    var sample = SampleData(number:0)
    
    struct ModelConstants {
        static let numOfFeatures = 6
        static let sensorsUpdateInterval = 1.0 / 20.0
        static let flexWindowSize = 100
    }
    //internal data structures
    
    func configure() {
        self.sample = SampleData(number: 0)
        self.knn.configure(neighbors: 3, max_warp: 0) //max_warp isn't implemented yet
        //        self.knn.train(data_sets: training_samples)
        //        self.exoEar.connectExoEar()
    }
    
    func performModelPrediction (realtime:Bool = false) -> String? {
        // Perform model prediction
        if training_samples.count < 6 {
            return "Need more training data"
        }
        
        
        var prediction:knn_certainty_label_pair
        
        if realtime {
            prediction  = knn.predict(curveToTestAccX: self.realtimeSample.accX, curveToTestAccY: self.realtimeSample.accY, curveToTestAccZ: self.realtimeSample.accZ, curveToTestGyrX: self.realtimeSample.gyrX, curveToTestGyrY: self.realtimeSample.gyrY, curveToTestGyrZ: self.realtimeSample.gyrZ)
        } else {
            prediction  = knn.predict(curveToTestAccX: self.sample.accX, curveToTestAccY: self.sample.accY, curveToTestAccZ: self.sample.accZ, curveToTestGyrX: self.sample.gyrX, curveToTestGyrY: self.sample.gyrY, curveToTestGyrZ: self.sample.gyrZ)
        }
        
        if realtime {
            //            print("minDistance: ", prediction.minDistance)
            //            print("dist threshold: ", self.distanceThreshold)
            //            print("prediction: ", prediction.label)
            //            print("prediction probability: ", prediction.probability)
            //            if prediction.minDistance < self.distanceThreshold {
            print(prediction.label)
            if prediction.label.lowercased() != "none" {
                print("predicted " + prediction.label, "with ", prediction.probability*100,"% certainty", "minDistance: ",prediction.minDistance)
                return prediction.label
                
            } else {
                return "None"
            }
        } else {
            print("predicted " + prediction.label, "with ", prediction.probability*100,"% certainty", "minDistance: ",prediction.minDistance)
            return prediction.label
        }
        
    }
    
    func startTrain(gesture: String, number: Int) {
        let label = gesture + "-" + String(number)
        print("startTrain")
        print(label, number)
        self.trainingData[label] = SampleData(number: 0)
        let exoEar = Shared.instance.gruController
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: ModelConstants.sensorsUpdateInterval, repeats: true) { timer in
            let data = exoEar.getData()
            self.trainingData[label]!.accX.append(Float(data[0].0))
            self.trainingData[label]!.accY.append(Float(data[0].1))
            self.trainingData[label]!.accZ.append(Float(data[0].2))
            self.trainingData[label]!.gyrX.append(Float(data[1].0))
            self.trainingData[label]!.gyrY.append(Float(data[1].1))
            self.trainingData[label]!.gyrZ.append(Float(data[1].2))
        }
        //        self.trainingData[label]?.normalizeVals() //note
    }
    
    func stepTrain(gesture: String, count: Int, sample: SampleData) {
        let label = gesture + "-" + String(count)
        self.trainingData[label] = sample
    }
    func stopTrain() {
        print("stopTrain")
        self.timer.invalidate()
        self.timer = Timer()
    }
    
    func finalTrain() {
        var totalWindowLength = 0
        var n = 0
        print(self.trainingData)
        for (label, sample) in self.trainingData {
            let properLabel = label.components(separatedBy: "-")[0]
            self.training_samples.append(knn_curve_label_pair(curveAccX: sample.accX, curveAccY: sample.accY, curveAccZ: sample.accZ , curveGyrX: sample.gyrX,curveGyrY: sample.gyrY, curveGyrZ: sample.gyrZ, label: properLabel))
            totalWindowLength += sample.accX.count
            n+=1
            print(self.training_samples.count)
        }
        if training_samples.count < 12 {
            print("ERROR: Need more training data")
        } else {
            self.knn.train(data_sets: self.training_samples)
            print("trained")
        }
        
        self.predictionWindowSize = (totalWindowLength / n) + 20
        print("window Size equals: ", self.predictionWindowSize)
        
    }
    
    public func startRecording() {
        //        var currentIndexInPredictionWindow = 0
        
        //TODO:
        let exoEar = Shared.instance.gruController
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: ModelConstants.sensorsUpdateInterval, repeats: true) { timer in
            let data = exoEar.getData()
            //            NSLog("")
            //            print(data)
            self.sample.accX.append(Float(data[0].0))
            self.sample.accY.append(Float(data[0].1))
            self.sample.accZ.append(Float(data[0].2))
            self.sample.gyrX.append(Float(data[1].0))
            self.sample.gyrY.append(Float(data[1].1))
            self.sample.gyrZ.append(Float(data[1].2))
        }
    }
    public func doPrediction() -> String {
        self.timer.invalidate()
        self.timer = Timer()
        let label = performModelPrediction()!
        self.sample = SampleData(number: 0)
        return label
    }
    public func runRealTime() -> String {
        
        //        let vc = UIApplication.shared.keyWindow!.rootViewController as! ClassifyViewController
        var result:String = ""
        let exoEar = Shared.instance.gruController
        self.timer.invalidate()
        self.sampleBuffer = SampleBuffer(number: 0, count: self.predictionWindowSize)
        self.timer = Timer.scheduledTimer(withTimeInterval: ModelConstants.sensorsUpdateInterval, repeats: true) { timer in
            let data = exoEar.getData()
            //            print(data)
            self.sampleBuffer.accX.write(element: Float(data[0].0))
            //            print(data[0].0)
            self.sampleBuffer.accY.write(element: Float(data[0].1))
            self.sampleBuffer.accZ.write(element: Float(data[0].2))
            self.sampleBuffer.gyrX.write(element: Float(data[1].0))
            self.sampleBuffer.gyrY.write(element: Float(data[1].1))
            self.sampleBuffer.gyrZ.write(element: Float(data[1].2))
            
            self.currentIndexInPredictionWindow += 1
            
            if self.currentIndexInPredictionWindow % (self.predictionWindowSize) == 0 && self.currentIndexInPredictionWindow > (self.predictionWindowSize)+1 {
                
                //                self.sampleBuffer.normalizeVals()
                
                var accX = self.sampleBuffer.accX.getArray()
                //                print(accX)
                //                let maxAccX = accX.max()
                //                accX = accX.map{$0/maxAccX!}
                self.realtimeSample.accX = accX
                
                var accY = self.sampleBuffer.accY.getArray()
                //                let maxAccY = accY.max()
                //                accY = accY.map{$0/maxAccY!}
                self.realtimeSample.accY = accY
                
                var accZ = self.sampleBuffer.accZ.getArray()
                //                let maxAccZ = accZ.max()
                //                accZ = accZ.map{$0/maxAccZ!}
                self.realtimeSample.accZ = accZ
                
                var gyrX = self.sampleBuffer.gyrX.getArray()
                //                let maxGyrX = gyrX.max()
                //                gyrX = gyrX.map{$0/maxGyrX!}
                self.realtimeSample.gyrX = gyrX
                
                var gyrY = self.sampleBuffer.gyrY.getArray()
                //                let maxGyrY = gyrY.max()
                //                gyrY = gyrY.map{$0/maxGyrY!}
                self.realtimeSample.gyrY = gyrY
                
                var gyrZ = self.sampleBuffer.gyrZ.getArray()
                //                let maxGyrZ = gyrZ.max()
                //                gyrZ = gyrZ.map{$0/maxGyrZ!}
                self.realtimeSample.gyrZ = gyrZ
                
                result = self.performModelPrediction(realtime: true)!
                //                ClassifyViewController.addClassifiedGesture(predictedLabel: result)
//                let vc = UIApplication.shared.windows[0].rootViewController?.children[1] as? ClassifyViewController
                print("listing result")
                let vc = Shared.instance.getVC(name: "ClassifyViewController") as! ClassifyViewController
                vc.addClassifiedGesture(predictedLabel: result)
                
            }
        }
        return result
    }
}
