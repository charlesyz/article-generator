//
//  ViewController.swift
//  Article Generator
//
//  Created by Charles Zhang on 2018-08-26.
//  Copyright © 2018 Firebird Studios. All rights reserved.
//

import UIKit
import CoreML
class ViewController: UIViewController {

    // list of file names
    let model_list = ["model-sci-space-25", "model-talk-politics-mideast-25"]
    let tokenizer_list = ["tokenizer-sci-space", "tokenizer-talk-politics-mideast"]
    // UI elements
    let outputField: UITextView = {
        let outputField = UITextView(frame: CGRect(x: 20.0, y: 90.0, width: 300, height: 400))
        outputField.textAlignment = NSTextAlignment.left
        outputField.textColor = UIColor.black
        outputField.backgroundColor = UIColor.white
        outputField.font = UIFont.boldSystemFont(ofSize: 15)
        return outputField
    }()
    let inputField: UITextField = {
        let inputField = UITextField(frame: CGRect(x: 40, y: 30, width: 300, height: 40))
        inputField.placeholder = "Enter seed text here"
        inputField.font = UIFont.systemFont(ofSize: 15)
        inputField.borderStyle = UITextBorderStyle.roundedRect
        inputField.autocorrectionType = UITextAutocorrectionType.no
        inputField.keyboardType = UIKeyboardType.default
        inputField.returnKeyType = UIReturnKeyType.done
        inputField.clearButtonMode = UITextFieldViewMode.whileEditing;
        inputField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        return inputField
    }()
    let lengthField: UITextField = {
        let lengthField = UITextField(frame: CGRect(x: 160, y: 600, width: 80, height: 40))
        lengthField.placeholder = "Length"
        lengthField.text = "100"
        lengthField.font = UIFont.systemFont(ofSize: 15)
        lengthField.borderStyle = UITextBorderStyle.roundedRect
        lengthField.autocorrectionType = UITextAutocorrectionType.no
        lengthField.keyboardType = UIKeyboardType.default
        lengthField.returnKeyType = UIReturnKeyType.done
        lengthField.clearButtonMode = UITextFieldViewMode.whileEditing;
        lengthField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        return lengthField
    }()
    let modelField: UITextField = {
        let modelField = UITextField(frame: CGRect(x: 250, y: 600, width: 80, height: 40))
        modelField.placeholder = "Model#(0/1)"
        modelField.text = "1"
        modelField.font = UIFont.systemFont(ofSize: 15)
        modelField.borderStyle = UITextBorderStyle.roundedRect
        modelField.autocorrectionType = UITextAutocorrectionType.no
        modelField.keyboardType = UIKeyboardType.default
        modelField.returnKeyType = UIReturnKeyType.done
        modelField.clearButtonMode = UITextFieldViewMode.whileEditing;
        modelField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        return modelField
    }()
    let runButton: UIButton = {
        let runButton : UIButton = UIButton(frame: CGRect(x: 50, y: 600, width: 100, height: 50))
        runButton.backgroundColor = .black
        runButton.setTitle("Button", for: .normal)
        runButton.addTarget(self, action:#selector(runButtonClicked), for: .touchUpInside)
        return runButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background color
        self.view.backgroundColor = .white
        
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        //setting toolbar as inputAccessoryView
        self.outputField.inputAccessoryView = toolbar
        self.inputField.inputAccessoryView = toolbar
        self.lengthField.inputAccessoryView = toolbar
        self.modelField.inputAccessoryView = toolbar
        
        // subviews
        self.view.addSubview(outputField)
        
        self.view.addSubview(inputField)
        self.view.addSubview(runButton)
        self.view.addSubview(modelField)
        self.view.addSubview(lengthField)
        
        // tap recognizer to dismiss keyboard
        let _: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //outputLabel.text = runLSTM(modelNum: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    // run button
    @objc func runButtonClicked(sender: UIButton!) {
        let num: Int = Int(modelField.text!)!
        outputField.text = runLSTM(modelNum: num)
    }
    
    func runLSTM(modelNum: Int) -> String {
        // load models and tokenizers
        let model = load_model(modelName: model_list[modelNum])
        let tokenizer = load_tokenizer(tokenizerName: tokenizer_list[modelNum])
        let num: Int = Int(lengthField.text!)!
        
        let output = generate_seq(model: model, tokenizer: tokenizer, seqLength: 25, seedText: inputField.text!, numWords: num)
        
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
        
        for _ in 1...numWords{
            
            // func: prepare inputs
            if inText == ""{
                for _ in 0..<seqLength{
                    let num = arc4random_uniform(UInt32(tokenizer.count))
                    inText.append(tokenizer.key(forValue: Int(num))! + " ")
                }
                print(inText)
            }
            inText = String(inText.filter { !"\n\t\r".contains($0) })
            
            var encoded = word_to_int(tokenizer: tokenizer, data: inText)
            encoded = pad_sequence(data: encoded, len: seqLength)
            
            guard let inputData = try? MLMultiArray(shape:[25,1,1], dataType:.double) else {
                fatalError("Unexpected runtime error. MLMultiArray")
            }
            
            for (index,item) in encoded.enumerated() {
                inputData[index] = NSNumber(floatLiteral: Double(item))
            }
            let input = model_25_input(input1: inputData)
            guard let output = try? model.prediction(input: input).output1 else{
                fatalError("Unexpected runtime error when predicting")
            }
            
            var maxIndex = 0
            for i in 0...output.count {
                if (output[i].doubleValue > output[maxIndex].doubleValue){maxIndex = i; }
            }
            
            let outputWord: String = tokenizer.key(forValue: maxIndex)!
            result += outputWord + " "
            inText += " " + outputWord
        }
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

