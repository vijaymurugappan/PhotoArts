//
//  UpdateProfileViewController.swift
//  VMS_PhotoArts+
//
//  Created by Vijay Murugappan Subbiah on 12/4/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import UIKit
import CoreData //import core data

//Referencing text field delegates, picker view delegates and datasource
class UpdateProfileViewController: UIViewController,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    //OUTLETS
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var Street: UITextField!
    @IBOutlet weak var Apartment: UITextField!
    @IBOutlet weak var City: UITextField!
    @IBOutlet weak var State: UITextField!
    @IBOutlet weak var Zip: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    
    //VARIABLES
    var username = String()
    var email = String()
    var streets = String()
    var apartments = String()
    var cities = String()
    var states = String()
    var zips = String()
    var fName = String()
    var lName = String()
    let statesArray = ["AL","AK","AS","AZ","AR","CA","CO","CT","DE","DC","FM","FL","GA","GU","HI","ID","IL","IN","IA","KS","KY","LA","ME","MH","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","MP","OH","OK","OR","PW","PA","PR","RI","SC","SD","TN","TX","UT","VT","VI","VA","WA","WV","WI","WY"]
    let picker = UIPickerView()
    
    //ACTION
    @IBAction func updateClicked(sender: UIButton) {
        if isAllFieldsFilled() { // check if all fields are filled
            if isAllFieldsValid() { // check if all fields are valid
                updateUserDetails() // fetch user details and populate
                _ = navigationController?.popViewController(animated: true) // navigate back to profile view
            }
        }
        else {
            produceAlert(Title: "INVALID", Desc: "please fill all fields before updating user") // produce alert if fields are incomplete
        }
    }
    
    //USER DEFINED FUNCTIONS
    func updateUserDetails() {
        /* this function updates user details from the text fields according to the user name */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "username = %@", username)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            if (results.count > 0) {
                for item in results as! [NSManagedObject] {
                    item.setValue(emailTextField.text, forKey: "email")
                    item.setValue(Street.text, forKey: "street")
                    item.setValue(City.text, forKey: "city")
                    item.setValue(State.text, forKey: "state")
                    item.setValue(Apartment.text, forKey: "apartment")
                    item.setValue(Zip.text, forKey: "zip")
                    item.setValue(firstName.text, forKey: "firstname")
                    item.setValue(lastName.text, forKey: "lastname")
                }
            }
        }
        catch {
            produceAlert(Title: "UPDATE ERROR", Desc: "database could not be updated")
        }
    }
    
    func produceAlert(Title: String, Desc: String) {
        /* Producing alerts for specific error title and description with an action to dismiss the controller */
        let alertController = UIAlertController(title: Title, message: Desc, preferredStyle: .alert) // alert controller
        let alertAction = UIAlertAction(title: "OK", style: .default) { // completion handler for alert action
            (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction) // adding action to controller
        self.present(alertController, animated: true, completion: nil) // presenting alert controller
    }
    
    func isAllFieldsFilled() -> Bool { // produce alert for each field if its incomplete
        if emailTextField.text == "" {
            self.showAlert(Title: "Please Enter Email")
            return false
        }
        else if firstName.text == "" {
            self.showAlert(Title: "Please Enter First Name")
            return false
        }
        else if lastName.text == "" {
            self.showAlert(Title: "Please Enter Last Name")
            return false
        }
        else if Street.text == "" {
            self.showAlert(Title: "Please Enter Street")
            return false
        }
        else if Apartment.text == "" {
            self.showAlert(Title: "Please Enter Apartment")
            return false
        }
        if City.text == "" {
            self.showAlert(Title: "Please Enter City")
            return false
        }
        else if State.text == "" {
            self.showAlert(Title: "Please Select State")
            return false
        }
        else if Zip.text == "" {
            self.showAlert(Title: "Please Enter Zip")
            return false
        }
        return true
    }
    
    func isAllFieldsValid() -> Bool { // checking if all fields are valid - email,zip
        if !isValidEmail(testStr: emailTextField.text!) {
            emailTextField.text = ""
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Please Enter a valid email address", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red]) // creating a red placeholder of the error message
            return false
        }
        else if !isValidZipCode(testStr: Zip.text!) {
            Zip.text = ""
            Zip.attributedPlaceholder = NSAttributedString(string: "Invalid Zip", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            return false
        }
        return true
    }
    
    func showAlert(Title: String) { // show alert for each error message displayed
        let alertController = UIAlertController(title: nil, message: Title, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) {
            (UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setcustomButton(button: UIButton) {
        button.layer.cornerRadius = 8.0 // Rounding the corners of the button
    }
    
    func setcustomTextField(textfield: UITextField, placeholdername: String) {
        textfield.backgroundColor = UIColor.clear // clearing background color
        textfield.layer.borderWidth = 1.0 // making 1.0 of border width
        textfield.layer.cornerRadius = 8.0 // rounding the corners of the text field
        textfield.layer.borderColor = UIColor.white.cgColor // border color to white
        textfield.attributedPlaceholder = NSAttributedString(string: placeholdername, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white]) // giving placeholder name and its color
    }
    
    func fetchValues() {
        /* assigning user profile to text fields */
        emailTextField.text = email
        Street.text = streets
        Apartment.text = apartments
        City.text = cities
        State.text = states
        Zip.text = zips
        firstName.text = fName
        lastName.text = lName
    }
    
    func isValidEmail(testStr:String) -> Bool { // regex for the email
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidZipCode(testStr: String) -> Bool { // regex for the US zip codes
        let zipRegEx = "\\d{5}(-\\d{4})?$"
        let zipTest = NSPredicate(format: "SELF MATCHES %@", zipRegEx)
        return zipTest.evaluate(with:testStr)
    }
    
    //TEXT FIELD DELEGATE METHODS AND DATA SOURCE
    
    // keyboard resigned when touched outside of the text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //resigns keyboard when clicked return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        Street.resignFirstResponder()
        Apartment.resignFirstResponder()
        City.resignFirstResponder()
        State.resignFirstResponder()
        Zip.resignFirstResponder()
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        return true
    }
    
    func setPickerView() { // setting picker view for state text field with toolbar
        picker.delegate = self
        picker.dataSource = self
        State.inputView = picker
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44)) // creating toolbar
        let doneButton = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(SignUpViewController.selectItem))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, doneButton, space], animated: false)
        State.inputAccessoryView = toolBar //adding it to text field
    }
    
    func selectItem() {
        State.endEditing(true) // resign state picker
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // 1 component in the picker view
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statesArray.count // count of number of states array
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statesArray[row] // title of number of states array
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        State.text = statesArray[row] // assign the selected title to text field
    }
    
    //VIEW DID LOAD - Default view when loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        /* customizing text fields and button */
        setcustomTextField(textfield: emailTextField, placeholdername: "EMAIL")
        setcustomTextField(textfield: Street, placeholdername: "STREET")
        setcustomTextField(textfield: Apartment, placeholdername: "APARTMENT")
        setcustomTextField(textfield: City, placeholdername: "CITY")
        setcustomTextField(textfield: State, placeholdername: "STATE")
        setcustomTextField(textfield: Zip, placeholdername: "ZIP")
        setcustomTextField(textfield: firstName, placeholdername: "FIRST NAME")
        setcustomTextField(textfield: lastName, placeholdername: "LAST NAME")
        setcustomButton(button: updateBtn)
        fetchValues() // fetch values from user profile
        setPickerView() // setting up the picker view
        
    }

}
