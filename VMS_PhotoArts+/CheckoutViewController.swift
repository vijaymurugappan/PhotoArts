//
//  CheckoutViewController.swift
//  VMS_PhotoArts+
//
//  Created by Vijay Murugappan Subbiah on 11/5/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import UIKit
import CoreData // import core data

//referencing text field delegates, picker view delegates and datasource
class CheckoutViewController: UIViewController,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    //OUTLETS
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var shippingStreet: UITextField!
    @IBOutlet weak var shippingApartment: UITextField!
    @IBOutlet weak var shippingCity: UITextField!
    @IBOutlet weak var shippingState: UITextField!
    @IBOutlet weak var shippingZip: UITextField!
    @IBOutlet weak var billingStreet: UITextField!
    @IBOutlet weak var billingApartment: UITextField!
    @IBOutlet weak var billingCity: UITextField!
    @IBOutlet weak var billingState: UITextField!
    @IBOutlet weak var billingZip: UITextField!
    @IBOutlet weak var shippingFee: UITextField!
    @IBOutlet weak var cardFname: UITextField!
    @IBOutlet weak var cardLname: UITextField!
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var cardExpDate: UITextField!
    @IBOutlet weak var cardSecurityCode: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //VARIABLES
    var userName = String()
    var email = String()
    var shipStreet = String()
    var shipApartment = String()
    var shipCity = String()
    var shipState = String()
    var shipZip = String()
    var bilStreet = String()
    var bilApartment = String()
    var bilCity = String()
    var bilState = String()
    var bilZip = String()
    var Fee = String()
    var fName = String()
    var lName = String()
    var expDate = String()
    var Cnumber = String()
    var cvv = String()
    var statePicker = UIPickerView()
    var shippingPicker = UIPickerView()
    var datePicker = UIDatePicker()
    let statesArray = ["AL","AK","AS","AZ","AR","CA","CO","CT","DE","DC","FM","FL","GA","GU","HI","ID","IL","IN","IA","KS","KY","LA","ME","MH","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","MP","OH","OK","OR","PW","PA","PR","RI","SC","SD","TN","TX","UT","VT","VI","VA","WA","WV","WI","WY"]
    let shippingArray = ["Standard($19.95) - 12days","Priority($24.95) - 10days","Expedited($34.95) - 8days","Rush($50.00) - 5days"]
    let formatter = DateFormatter()
    var productfee = Double()
    var shippingfee = 19.95
    
    //ACTION
    @IBAction func confirmClicked(_ sender: UIButton) {
        if(isAllFieldsFilled()) { // check if all fields are filled
            if(isAllFieldsValid()) { // check if all fields are valid
                assignValues()
                performSegue(withIdentifier: "summary", sender: self) // navigate to summary view
            }
            else {
                produceAlert(Title: "INVALID", Desc: "please fill all the fields before checkout")
            }
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        /* if switch is on then shipping address will be copied to billing address */
        if sender.isOn {
            billingStreet.text = shippingStreet.text
            billingApartment.text = shippingApartment.text
            billingZip.text = shippingZip.text
            billingState.text = shippingState.text
            billingCity.text = shippingCity.text
        }
        else {
            billingStreet.text = ""
            billingApartment.text = ""
            billingZip.text = ""
            billingState.text = ""
            billingCity.text = ""
        }
    }
    
    //USER DEFINED FUNCTIONS
    func assignValues() { // store all the text field values to variables
        email = emailTextField.text!
        shipStreet = shippingStreet.text!
        shipApartment = shippingApartment.text!
        shipCity = shippingCity.text!
        shipState = shippingState.text!
        shipZip = shippingZip.text!
        bilStreet = billingStreet.text!
        bilApartment = billingApartment.text!
        bilCity = billingCity.text!
        bilState = billingState.text!
        bilZip = billingZip.text!
        Fee = shippingFee.text!
        fName = cardFname.text!
        lName = cardLname.text!
        expDate = cardExpDate.text!
        cvv = cardSecurityCode.text!
        Cnumber = cardNumber.text!
    }
    
    func isAllFieldsValid() -> Bool { // checking if all fields are valid - email,zip,credit car number,cvv
        if !isValidZipCode(testStr: billingZip.text!) {
            billingZip.text = ""
            billingZip.attributedPlaceholder = NSAttributedString(string: "Invalid Zip", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red]) // creating a red placeholder of the error message
            return false
        }
        else if !isValidZipCode(testStr: shippingZip.text!) {
            shippingZip.text = ""
            shippingZip.attributedPlaceholder = NSAttributedString(string: "Invalid Zip", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            return false
        }
        else if !isValidCreditCardNumber(testString: cardNumber.text!) {
            cardNumber.text = ""
            cardNumber.attributedPlaceholder = NSAttributedString(string: "Credit Card numbers should be 15 or 16 characters", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            return false
        }
        else if !isValidEmail(testStr: emailTextField.text!) {
            emailTextField.text = ""
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Please Enter a valid email address", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            return false
        }
        else if !isValidCVV(testString: cardSecurityCode.text!) {
            cardSecurityCode.text = ""
            cardSecurityCode.attributedPlaceholder = NSAttributedString(string: "Invalid CVV", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            return false
        }
        return true
    }
    
    func isAllFieldsFilled() -> Bool { // produce alert for each field if its incomplete
        if shippingStreet.text == "" {
            self.showAlert(Title: "Please Enter Shipping Street")
            return false
        }
        else if shippingApartment.text == "" {
            self.showAlert(Title: "Please Enter Shipping Apartment")
            return false
        }
        else if shippingCity.text == "" {
            self.showAlert(Title: "Please Enter Shipping City")
            return false
        }
        else if shippingState.text == "" {
            self.showAlert(Title: "Please Enter Shipping State")
            return false
        }
        if shippingZip.text == "" {
            self.showAlert(Title: "Please Enter Shipping Zip")
            return false
        }
        else if billingState.text == "" {
            self.showAlert(Title: "Please Enter Billing State")
            return false
        }
        else if billingZip.text == "" {
            self.showAlert(Title: "Please Enter Billing Zip")
            return false
        }
        else if emailTextField.text == "" {
            self.showAlert(Title: "Please Enter Email")
            return false
        }
        else if billingStreet.text == "" {
            self.showAlert(Title: "Please Enter Billing Street")
            return false
        }
        else if billingCity.text == "" {
            self.showAlert(Title: "Please Enter Billing City")
            return false
        }
        else if billingApartment.text == "" {
            self.showAlert(Title: "Please Enter Billing Apartment")
            return false
        }
        else if cardFname.text == "" {
            self.showAlert(Title: "Please Enter Card First Name")
            return false
        }
        else if cardLname.text == "" {
            self.showAlert(Title: "Please Enter Card Last Name")
            return false
        }
        else if cardNumber.text == "" {
            self.showAlert(Title: "Please Enter Card Number")
            return false
        }
        else if cardExpDate.text == "" {
            self.showAlert(Title: "Please Enter Card Expiry Date")
            return false
        }
        else if cardSecurityCode.text == "" {
            self.showAlert(Title: "Please Enter Card Security Code")
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
    
    func isValidCreditCardNumber(testString: String) -> Bool { // validate whether credit card number whether it should be 15 or 16 characters
        if testString.count == 16 || testString.count == 15 {
            return true
        }
        else {
            return false
        }
    }
    
    func isValidCVV(testString: String) -> Bool { // validate whether credit card cvv whether it should be 3 or 4 characters
        if (testString.count == 3 || testString.count == 4) {
            return true
        }
        else {
            return false
        }
    }
    
    // keyboard resigned when touched outside of the text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        scrollView.endEditing(true)
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y: 200) , animated: true) // moving keyboard up when text field did begin editing
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y: 0) , animated: true)  // moving keyboard back down when text field did end editing
    }
    
    //resigns keyboard when clicked return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        shippingStreet.resignFirstResponder()
        shippingApartment.resignFirstResponder()
        shippingCity.resignFirstResponder()
        shippingState.resignFirstResponder()
        shippingZip.resignFirstResponder()
        billingStreet.resignFirstResponder()
        billingApartment.resignFirstResponder()
        billingCity.resignFirstResponder()
        billingState.resignFirstResponder()
        billingZip.resignFirstResponder()
        shippingFee.resignFirstResponder()
        cardFname.resignFirstResponder()
        cardLname.resignFirstResponder()
        cardNumber.resignFirstResponder()
        cardExpDate.resignFirstResponder()
        cardSecurityCode.resignFirstResponder()
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // 1 component in the picker view
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == statePicker) {
            return statesArray.count // count of number of states array
        }
        else {
            return shippingArray.count // count of number of shipping array
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == statePicker) {
            return statesArray[row] // title of number of states array
        }
        else {
            return shippingArray[row] // title of number of shipping array
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == statePicker) {
            if shippingState.isEditing == true { // if shipping state is edited
                shippingState.text = statesArray[row] // assign the selected title to text field
            }
            else if billingState.isEditing == true { // if billing state is edited
                billingState.text = statesArray[row] // assign the selected title to text field
            }
        }
        else {
            shippingFee.text = shippingArray[row] // assign the selected title to text field
            /* assigning shipping price to variable */
            if shippingFee.text == "Standard($19.95) - 12days" {
                shippingfee = 19.95
            }
            else if shippingFee.text == "Priority($24.95) - 10days" {
                shippingfee = 24.95
            }
            else if shippingFee.text == "Expedited($34.95) - 8days" {
                shippingfee  = 34.95
            }
            else if shippingFee.text == "Rush($50.00) - 5days" {
                shippingfee = 50.00
            }
        }
    }
    
    @objc func whenChanged() {
        cardExpDate.text = formatter.string(from: datePicker.date) // assigns date when date picker changes
    }
    
    //VIEW DID LOAD - Default view when loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        /* setting custom buttons and text fields */
        setcustomButton(button: confirmBtn)
        setcustomTextField(textfield: emailTextField, placeholdername: "Please enter a valid email address")
        setcustomTextField(textfield: shippingStreet, placeholdername: "Street")
        setcustomTextField(textfield: shippingApartment, placeholdername: "Apartment")
        setcustomTextField(textfield: shippingCity, placeholdername: "City")
        setcustomTextField(textfield: shippingState, placeholdername: "State")
        setcustomTextField(textfield: shippingZip, placeholdername: "Zip Code")
        setcustomTextField(textfield: billingStreet, placeholdername: "Street")
        setcustomTextField(textfield: billingApartment, placeholdername: "Apartment")
        setcustomTextField(textfield: billingCity, placeholdername: "City")
        setcustomTextField(textfield: billingState, placeholdername: "State")
        setcustomTextField(textfield: billingZip, placeholdername: "Zip")
        setcustomTextField(textfield: shippingFee, placeholdername: "Shipping and Processing Fee")
        setcustomTextField(textfield: cardFname, placeholdername: "First name on card")
        setcustomTextField(textfield: cardLname, placeholdername: "Last name on card")
        setcustomTextField(textfield: cardNumber, placeholdername: "Credit card number")
        setcustomTextField(textfield: cardExpDate, placeholdername: "Exp: MM/YYYY")
        setcustomTextField(textfield: cardSecurityCode, placeholdername: "CVV")
        fetchUserValues(user: userName) // fetch user values according to the username
        setPickerView() // setup picker view
        shippingFee.text = shippingArray[0] // assign initial picker data
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
    
    func setPickerView() { // setting picker view for state text field with toolbar
        statePicker.delegate = self
        statePicker.dataSource = self
        shippingPicker.delegate = self
        shippingPicker.dataSource = self
        shippingState.inputView = statePicker
        billingState.inputView = statePicker
        shippingFee.inputView = shippingPicker
        cardExpDate.inputView = datePicker
        datePicker.datePickerMode = .date
        formatter.dateFormat = "MM/yyyy";
        datePicker.addTarget(self, action: #selector(whenChanged), for: .valueChanged)
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44)) // creating toolbar
        let doneButton = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(CheckoutViewController.selectItem))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, doneButton, space], animated: false)
        /* adding it to text fields */
        shippingState.inputAccessoryView = toolBar
        billingState.inputAccessoryView = toolBar
        shippingFee.inputAccessoryView = toolBar
        cardExpDate.inputAccessoryView = toolBar
    }
    
    @objc func selectItem() {
        /* // resign state,shipping and cardexpiry date picker */
        shippingState.endEditing(true)
        billingState.endEditing(true)
        shippingFee.endEditing(true)
        cardExpDate.endEditing(true)
    }
    
    func fetchUserValues(user: String) {
        /* this function fetches user values for this specific logged in username */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "username = %@", user)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            if (results.count > 0) {
                for item in results as! [NSManagedObject] {
                    emailTextField.text = item.value(forKey: "email") as? String
                    shippingStreet.text = item.value(forKey: "street") as? String
                    shippingApartment.text = item.value(forKey: "apartment") as? String
                    shippingCity.text = item.value(forKey: "city") as? String
                    shippingState.text = item.value(forKey: "state") as? String
                    shippingZip.text = item.value(forKey: "zip") as? String
                    cardFname.text = item.value(forKey: "firstname") as? String
                    cardLname.text = item.value(forKey: "lastname") as? String
                }
            }
        }
        catch {
            produceAlert(Title: "FAILED", Desc: "failure to fetch data from database")
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
    
    // this function will get called before the control is handed over to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "summary" { // if segue identifier is summary
            let summaryVC = segue.destination as! SummaryViewController
            summaryVC.billingStreet = bilStreet
            summaryVC.billingApt = bilApartment
            summaryVC.billingSt = bilState
            summaryVC.billingCity = bilCity
            summaryVC.billingZip = bilZip
            summaryVC.shippingStreet = shipStreet
            summaryVC.shippingApt = shipApartment
            summaryVC.shippingSt = shipState
            summaryVC.shippingCity = shipCity
            summaryVC.shippingZip = shipZip
            summaryVC.email = email
            summaryVC.shippingStatus = Fee
            summaryVC.firstName = fName
            summaryVC.lastName = lName
            summaryVC.cardNum = Cnumber
            summaryVC.expDate = expDate
            summaryVC.CVV = cvv
            summaryVC.productFees = productfee
            summaryVC.shippingFee = shippingfee
            summaryVC.username = userName
        }
    }
}
