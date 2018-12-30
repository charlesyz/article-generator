//
//  ViewController.swift
//  Article Generator
//
//  Created by Charles Zhang on 2018-08-26.
//  Copyright © 2018 Firebird Studios. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    // list of file names
    let model_list = ["model-sci-space-25", "model-talk-politics-mideast-25", "model-sci-electronics-25", "model-motorcycles", "model-forsale"]
    let tokenizer_list = ["tokenizer-sci-space", "tokenizer-talk-politics-mideast", "tokenizer-sci-electronics", "tokenizer-motorcycles", "tokenizer-forsale"]
    
    var inputData: String = ""
    var lengthData: Int = 100
    var modelData: Int = 2
    var randomize: Bool = true
    var completeSentence: Bool = true
    var tableReferenceController: TableViewController?
    
    // Create the Activity Indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    
    func saveContrainerViewRefference(vc: TableViewController){
        self.tableReferenceController = vc
    }
    
    @IBOutlet weak var outputField: UITextView!
    
    @IBAction func runButton(_ sender: UIButton) {
        
        // Start the loading animation
        activityIndicator.startAnimating()
        
        // get Data:
        inputData = tableReferenceController?.inputField.text ?? ""
        lengthData = Int(tableReferenceController?.lengthField.text ?? "100") ?? 100
        randomize = tableReferenceController?.randomizeSwitch.isOn ?? true
        completeSentence = tableReferenceController?.completeSwitch.isOn ?? true
        modelData = tableReferenceController?.pickerList.firstIndex(of: tableReferenceController?.subjectField.text ?? "Space") ?? 0
        
        // run the model
        let num: Int = modelData
        outputField.text = runLSTM(modelNum: num)
        
        // hide activity indicator
        activityIndicator.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.style = .whiteLarge
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRect(x: 0.0,y: 0.0,width: 40.0,height: 40.0);
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews(){
        
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    // close text field on return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func runLSTM(modelNum: Int) -> String {
        // load models and tokenizers
        let model = load_model(modelName: model_list[modelNum])
        let tokenizer = load_tokenizer(tokenizerName: tokenizer_list[modelNum])
        let num: Int = lengthData
        
        let output = generate_seq(model: model, tokenizer: tokenizer, seqLength: 25, seedText: inputData, numWords: num)
        
        return output
        
    }
    
    // Loads mlModel based on the model number (can be seen in model_list above)
    func load_model(modelName: String) -> model_25 {
        guard let modelUrl = Bundle(for: type(of: self)).url(forResource: modelName, withExtension:"mlmodelc") else {
            fatalError("File not found")
        }
        //let model = try? MLModel(contentsOf: modelUrl)
        let model = try? model_25(contentsOf: modelUrl)
        return model!
    }
    
    // loads tokenizer from PLIST located in /tokenizers
    func load_tokenizer(tokenizerName: String) -> Dictionary<String, Int> {
        
        if let path = Bundle(for: type(of: self)).url(forResource: tokenizerName, withExtension:"plist") {
            if let dict = NSDictionary(contentsOf: path) as? Dictionary<String, Int> {
                return dict
            }
            fatalError("Can't load dictionary: " + tokenizerName)
        }
        fatalError("No Dictionary " + tokenizerName)
    }
    
    func generate_seq(model: model_25, tokenizer: Dictionary<String, Int>, seqLength: Int, seedText: String, numWords: Int) -> String{
        var result: String = ""
        var inText = seedText
        
        // Prep the input
        inText = prep_input(input: inText)
        
        var randomText = ""
        // either the input text or a random word
        var displayText = ""
        // add a random word to the front if randomize is enabled. Will only randomize if input is < 25 words
        if randomize{
            randomText = tokenizer.key(forValue: Int(arc4random_uniform(UInt32(tokenizer.count))))!
            print("Random:" + randomText)
            
        }
        
        // only show the random word if the input string is empty.
        if inText != "" {
            displayText = inText + " "
        }
        else{
            displayText = randomText + " " + inText
        }
        
        inText = randomText + " " + inText
        
        
        print("Input:" + inText)
        
        var encoded = word_to_int(tokenizer: tokenizer, data: inText)
        
        // Tokenize the input
        encoded = pad_sequence(data: encoded, len: seqLength)
        guard let inputData = try? MLMultiArray(shape:[25,1,1], dataType:.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        
        // Put input into a NSMultiArray for use in the model
        for (index,item) in encoded.enumerated() {
            inputData[index] = NSNumber(floatLiteral: Double(item))
        }
        
        // Generate the text
        for count in 1...500{
            
            let input = model_25_input(input1: inputData)
            guard let output = try? model.prediction(input: input).output1 else{
                fatalError("Unexpected runtime error when predicting")
            }
            
            var maxIndex = 0
            for i in 0...output.count {
                if (output[i].doubleValue > output[maxIndex].doubleValue){maxIndex = i; }
            }
            
            // move the input data back 1, then append the new word on the end
            for i in 0..<24{
                inputData[i] = inputData[i + 1]
            }
            inputData[24] =  NSNumber(floatLiteral: Double(maxIndex))
            
            let outputWord: String = tokenizer.key(forValue: maxIndex)!
            result += outputWord + " "
    
            
            if completeSentence && [".", "!", "?"].contains(outputWord){
                break
            }
            else if count > numWords{
                break
            }

        }
        
        result = displayText + result
        
        print(result)
        return result
    }
    
    func prep_input(input: String) -> String {
        var data: String = input.lowercased()
        var letters = CharacterSet.letters
        
        letters.insert(charactersIn: " .,!?;:")
        
        // remove all non-letters / allowed chars
        data = data.components(separatedBy: letters.inverted).joined(separator: " ")
        
        // pad punctuation with spaces
        data = data.replacingOccurrences(of: ".", with: " .")
        data = data.replacingOccurrences(of: ",", with: " ,")
        data = data.replacingOccurrences(of: "!", with: " !")
        data = data.replacingOccurrences(of: "?", with: " ?")
        data = data.replacingOccurrences(of: ";", with: " ;")
        data = data.replacingOccurrences(of: ":", with: " :")
        
        // remove any double spaces
        let components = data.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        data = components.filter { !$0.isEmpty }.joined(separator: " ")
        
        return data
    }
    
    func word_to_int(tokenizer: Dictionary<String, Int>, data: String) -> Array<Int>{

        var output: [Int] = []
        for word in data.components(separatedBy: " "){
            if let val = tokenizer[word]{
                output.append(val)
            }
            else{
                print("NO WORD " + word + " IN DICTIONARY \n")
            }
        }
        return output
    }
    
    // take only the last len elements of array
    func pad_sequence(data: Array<Int>, len: Int) -> Array<Int>{
        var diff = len - data.count
        var input = data
        while diff > 0{
            input.insert(0, at: 0)
            diff -= 1
        }
        while diff < 0{
            input.removeFirst()
            diff += 1
        }
        return input;
    }
    
}

