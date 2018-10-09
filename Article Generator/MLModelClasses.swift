//
//  MLModelClasses.swift
//  Article Generator
//
//  Created by Charles Zhang on 2018-08-29.
//  Copyright © 2018 Firebird Studios. All rights reserved.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class model_25_input : MLFeatureProvider {
    
    /// input1 as 1 element vector of doubles
    var input1: MLMultiArray
    
    /// lstm_1_h_in as optional 200 element vector of doubles
    var lstm_1_h_in: MLMultiArray? = nil
    
    /// lstm_1_c_in as optional 200 element vector of doubles
    var lstm_1_c_in: MLMultiArray? = nil
    
    /// lstm_2_h_in as optional 200 element vector of doubles
    var lstm_2_h_in: MLMultiArray? = nil
    
    /// lstm_2_c_in as optional 200 element vector of doubles
    var lstm_2_c_in: MLMultiArray? = nil
    
    var featureNames: Set<String> {
        get {
            return ["input1", "lstm_1_h_in", "lstm_1_c_in", "lstm_2_h_in", "lstm_2_c_in"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "input1") {
            return MLFeatureValue(multiArray: input1)
        }
        if (featureName == "lstm_1_h_in") {
            return lstm_1_h_in == nil ? nil : MLFeatureValue(multiArray: lstm_1_h_in!)
        }
        if (featureName == "lstm_1_c_in") {
            return lstm_1_c_in == nil ? nil : MLFeatureValue(multiArray: lstm_1_c_in!)
        }
        if (featureName == "lstm_2_h_in") {
            return lstm_2_h_in == nil ? nil : MLFeatureValue(multiArray: lstm_2_h_in!)
        }
        if (featureName == "lstm_2_c_in") {
            return lstm_2_c_in == nil ? nil : MLFeatureValue(multiArray: lstm_2_c_in!)
        }
        return nil
    }
    
    init(input1: MLMultiArray, lstm_1_h_in: MLMultiArray? = nil, lstm_1_c_in: MLMultiArray? = nil, lstm_2_h_in: MLMultiArray? = nil, lstm_2_c_in: MLMultiArray? = nil) {
        self.input1 = input1
        self.lstm_1_h_in = lstm_1_h_in
        self.lstm_1_c_in = lstm_1_c_in
        self.lstm_2_h_in = lstm_2_h_in
        self.lstm_2_c_in = lstm_2_c_in
    }
}


/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class model_25_output : MLFeatureProvider {
    
    /// output1 as 12934 element vector of doubles
    let output1: MLMultiArray
    
    /// lstm_1_h_out as 200 element vector of doubles
    let lstm_1_h_out: MLMultiArray
    
    /// lstm_1_c_out as 200 element vector of doubles
    let lstm_1_c_out: MLMultiArray
    
    /// lstm_2_h_out as 200 element vector of doubles
    let lstm_2_h_out: MLMultiArray
    
    /// lstm_2_c_out as 200 element vector of doubles
    let lstm_2_c_out: MLMultiArray
    
    var featureNames: Set<String> {
        get {
            return ["output1", "lstm_1_h_out", "lstm_1_c_out", "lstm_2_h_out", "lstm_2_c_out"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "output1") {
            return MLFeatureValue(multiArray: output1)
        }
        if (featureName == "lstm_1_h_out") {
            return MLFeatureValue(multiArray: lstm_1_h_out)
        }
        if (featureName == "lstm_1_c_out") {
            return MLFeatureValue(multiArray: lstm_1_c_out)
        }
        if (featureName == "lstm_2_h_out") {
            return MLFeatureValue(multiArray: lstm_2_h_out)
        }
        if (featureName == "lstm_2_c_out") {
            return MLFeatureValue(multiArray: lstm_2_c_out)
        }
        return nil
    }
    
    init(output1: MLMultiArray, lstm_1_h_out: MLMultiArray, lstm_1_c_out: MLMultiArray, lstm_2_h_out: MLMultiArray, lstm_2_c_out: MLMultiArray) {
        self.output1 = output1
        self.lstm_1_h_out = lstm_1_h_out
        self.lstm_1_c_out = lstm_1_c_out
        self.lstm_2_h_out = lstm_2_h_out
        self.lstm_2_c_out = lstm_2_c_out
    }
}


/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class model_25 {
    var model: MLModel
    
    /**
     Construct a model with explicit path to mlmodel file
     - parameters:
     - url: the file url of the model
     - throws: an NSError object that describes the problem
     */
    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }
    
    /// Construct a model that automatically loads the model from the app's bundle
    convenience init() {
        let bundle = Bundle(for: model_25.self)
        let assetPath = bundle.url(forResource: "model_sci_space_25_1", withExtension:"mlmodelc")
        try! self.init(contentsOf: assetPath!)
    }
    
    /**
     Make a prediction using the structured interface
     - parameters:
     - input: the input to the prediction as model_sci_space_25_1Input
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as model_sci_space_25_1Output
     */
    func prediction(input: model_25_input) throws -> model_25_output {
        let outFeatures = try model.prediction(from: input)
        let result = model_25_output(output1: outFeatures.featureValue(for: "output1")!.multiArrayValue!, lstm_1_h_out: outFeatures.featureValue(for: "lstm_1_h_out")!.multiArrayValue!, lstm_1_c_out: outFeatures.featureValue(for: "lstm_1_c_out")!.multiArrayValue!, lstm_2_h_out: outFeatures.featureValue(for: "lstm_2_h_out")!.multiArrayValue!, lstm_2_c_out: outFeatures.featureValue(for: "lstm_2_c_out")!.multiArrayValue!)
        return result
    }
    
    /**
     Make a prediction using the convenience interface
     - parameters:
     - input1 as 1 element vector of doubles
     - lstm_1_h_in as optional 200 element vector of doubles
     - lstm_1_c_in as optional 200 element vector of doubles
     - lstm_2_h_in as optional 200 element vector of doubles
     - lstm_2_c_in as optional 200 element vector of doubles
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as model_sci_space_25_1Output
     */
    func prediction(input1: MLMultiArray, lstm_1_h_in: MLMultiArray?, lstm_1_c_in: MLMultiArray?, lstm_2_h_in: MLMultiArray?, lstm_2_c_in: MLMultiArray?) throws -> model_25_output {
        let input_ = model_25_input(input1: input1, lstm_1_h_in: lstm_1_h_in, lstm_1_c_in: lstm_1_c_in, lstm_2_h_in: lstm_2_h_in, lstm_2_c_in: lstm_2_c_in)
        return try self.prediction(input: input_)
    }
}
