//
//  SignUpViewController.swift
//  VMS_PhotoArts+
//
//  Created by Vijay Murugappan Subbiah on 11/5/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import UIKit
import CoreData // importing core data

// referencing text field delegates, picker view delegates and datasource
class SignUpViewController: UIViewController, UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    //OUTLETS
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var Street: UITextField!
    @IBOutlet weak var Apartment: UITextField!
    @IBOutlet weak var City: UITextField!
    @IBOutlet weak var State: UITextField!
    @IBOutlet weak var Zip: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var confirmPwdTextField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    
    //VARIABLES
    let statesArray = ["AL","AK","AS","AZ","AR","CA","CO","CT","DE","DC","FM","FL","GA","GU","HI","ID","IL","IN","IA","KS","KY","LA","ME","MH","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","MP","OH","OK","OR","PW","PA","PR","RI","SC","SD","TN","TX","UT","VT","VI","VA","WA","WV","WI","WY"]
    let picker = UIPickerView()
    var userArray = [String]()
    var emailArray = [String]()
    var userFlag = Bool()
    var emailFlag = Bool()
    var isGuest = Bool()
    
    //ACTION
    @IBAction func registerClicked(_ sender: UIButton) {
        /* This function saves all the user information to the user database */
        if isAllFieldsFilled() { // if all fields filled
            if isAllFieldsValid() { // if all fields are validated
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let user: User = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
                for user in userArray {
                    if userTextField.text == user { // checking if username already exists in db
                        userFlag = true
                        break
                    }
                    userFlag = false
                }
                for email in emailArray {
                    if emailTextField.text == email { // checking if email already exists in db
                        emailFlag = true
                        break
                    }
                    emailFlag = false
                }
                if userFlag {
                    userTextField.text = ""
                    userTextField.attributedPlaceholder = NSAttributedString(string: "Username already exists", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                }
                else if emailFlag {
                    emailTextField.text = ""
                    emailTextField.attributedPlaceholder = NSAttributedString(string: "Email already associated with another account", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                }
                else { // adding information
                    user.username = userTextField.text
                    user.password = passwordTextField.text
                    user.apartment = Apartment.text
                    user.street = Street.text
                    user.state = State.text
                    user.city = City.text
                    user.zip = Zip.text
                    user.firstname = firstName.text
                    user.lastname = lastName.text
                    user.email = emailTextField.text
                    do {
                        try context.save()
                    }
                    catch {
                        showAlert(Title: "FAILED", Desc: "failure to save data in database") // produce alert if error in saving data
                    }
                    produceAlert(Title: "SUCCESSFULLY REGISTERED") // produce alert when successfully registered
                }
            }
            else {
                showAlert(Title: "INVALID", Desc: "please fill all the fields before registering") // produce alert if fields are incomplete
            }
        }
    }
    
    //VIEW DID LOAD - Default view when loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser() // fetch user details for validation
        setPickerView() // set picker view for state
        /* setting custom buttons and text fields */
        setcustomButton(button: registerBtn)
        setcustomTextField(textfield: userTextField, placeholdername: "USERNAME")
        setcustomTextField(textfield: passwordTextField, placeholdername: "PASSWORD")
        setcustomTextField(textfield: confirmPwdTextField, placeholdername: "CONFIRM PASSWORD")
        setcustomTextField(textfield: emailTextField, placeholdername: "EMAIL ADDRESS")
        setcustomTextField(textfield: firstName, placeholdername: "FIRST NAME")
        setcustomTextField(textfield: lastName, placeholdername: "LAST NAME")
        setcustomTextField(textfield: Street, placeholdername: "STREET")
        setcustomTextField(textfield: Apartment, placeholdername: "APARTMENT")
        setcustomTextField(textfield: City, placeholdername: "CITY")
        setcustomTextField(textfield: State, placeholdername: "ST")
        setcustomTextField(textfield: Zip, placeholdername: "ZIP")
    }
    
    //USER DEFINED FUNCTIONS
    func fetchUser() {
        /* this function fetches user from user database */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                for item in results as! [NSManagedObject] {
                    if let username = item.value(forKey: "username") as? String {
                        userArray.append(username)
                    }
                    if let email = item.value(forKey: "email") as? String {
                        emailArray.append(email)
                    }
                }
            }
        }
        catch {
            showAlert(Title: "Fetch Error", Desc: "Error in fetching user details")
        }
    }
    
    func showAlert(Title: String, Desc: String) {
        /* Producing alerts for specific error title and description with an action to dismiss the controller */
        let alertController = UIAlertController(title: Title, message: Desc, preferredStyle: .alert) // alert controller
        let alertAction = UIAlertAction(title: "OK", style: .default) { // completion handler for alert action
            (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction) // adding action to controller
        self.present(alertController, animated: true, completion: nil) // presenting alert controller
    }
    
    func produceAlert(Title: String) { //alert for success message
        let alertController = UIAlertController(title: Title, message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) {
            (UIAlertAction) in
            if self.isGuest { // if it is redirected from guest account
                self.performSegue(withIdentifier: "created", sender: self) // navigating back to cart page
            }
            else {
                _ = self.navigationController?.popViewController(animated: true) // navigate to login page
            }
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
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
    
    @objc func selectItem() {
        State.endEditing(true) // resign state picker
    }
    
    func setcustomTextField(textfield: UITextField, placeholdername: String) {
        textfield.backgroundColor = UIColor.clear // clearing background color
        textfield.layer.borderWidth = 1.0 // making 1.0 of border width
        textfield.layer.cornerRadius = 8.0 // rounding the corners of the text field
        textfield.layer.borderColor = UIColor.white.cgColor // border color to white
        textfield.attributedPlaceholder = NSAttributedString(string: placeholdername, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white]) // giving placeholder name and its color
    }
    
    func setcustomButton(button: UIButton) {
        button.layer.cornerRadius = 8.0 // Rounding the corners of the button
    }
    
    func isAllFieldsValid() -> Bool { // checking if all fields are valid - user,password,email,zip
        if !isValidUser(testStr: userTextField.text!) {
            userTextField.text = ""
            userTextField.attributedPlaceholder = NSAttributedString(string: "Please Enter More than 6 characters", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red]) // creating a red placeholder of the error message
            return false
        }
        else if !doesPasswordMatch(testStr: passwordTextField.text!, testStr2: confirmPwdTextField.text!) {
            confirmPwdTextField.text = ""
            confirmPwdTextField.attributedPlaceholder = NSAttributedString(string: "Passwords does not match", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            return false
        }
        else if !isValidEmail(testStr: emailTextField.text!) {
            emailTextField.text = ""
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Please Enter a valid email address", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            return false
        }
        else if !isValidZipCode(testStr: Zip.text!) {
            Zip.text = ""
            Zip.attributedPlaceholder = NSAttributedString(string: "Invalid Zip", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            return false
        }
        return true
    }
    
    func isAllFieldsFilled() -> Bool { // produce alert for each field if its incomplete
        if userTextField.text == "" {
            self.showAlert(Title: "Please Enter User Name")
            return false
        }
        else if passwordTextField.text == "" {
            self.showAlert(Title: "Please Enter Password")
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
        else if emailTextField.text == "" {
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
    
    func isValidUser(testStr: String) -> Bool { // validating username to minimum of 7 digits
        if testStr.count <= 6 {
            return false
        }
        else {
            return true
        }
    }
    
    func doesPasswordMatch(testStr: String, testStr2: String) -> Bool { // checking if both password and confirm password matches
        if testStr == testStr2 {
            return true
        }
        else {
            return false
        }
    }

    func isValidEmail(testStr:String) -> Bool {  // regex for the email
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidZipCode(testStr: String) -> Bool { // regex for the US zip codes
        let zipRegEx = "\\d{5}(-\\d{4})?$"
        let zipTest = NSPredicate(format: "SELF MATCHES %@", zipRegEx)
        return zipTest.evaluate(with:testStr)
    }
    
    //TEXT FIELD DELEGATES
    
    //if touched outside text field resigns keyboard
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
        userTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPwdTextField.resignFirstResponder()
        return true
    }
    
    //PICKER VIEW DELEGATES AND DATASOURCE
    
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
    

}
