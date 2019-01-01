//
//  TableViewController.swift
//  Article_Generator
//
//  Created by Charles Zhang on 2018-12-30.
//  Copyright © 2018 Firebird Studios. All rights reserved.
//


import UIKit

class TableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var lengthField: UITextField!
    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var randomizeSwitch: UISwitch!
    @IBOutlet weak var completeSwitch: UISwitch!
    
    let pickerList = [String](arrayLiteral: "Space", "Politics-Mideast", "Electronics", "Motorcycles", "For Sale", "Medicine")
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerList.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerList[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        subjectField.text = pickerList[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let picker = UIPickerView()
        subjectField.inputView = picker
        picker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.backgroundColor = UIColor(red: 243.0/255, green: 243.0/255, blue: 243.0/255, alpha: 1)
        
        let viewControllerParent = self.parent as! ViewController
        viewControllerParent.saveContrainerViewRefference(vc: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor(red: 151.0/255, green: 193.0/255, blue: 100.0/255, alpha: 1)
        let font = UIFont(name: "Montserrat", size: 18.0)
        headerView.textLabel?.font = font!
    }*/
}
