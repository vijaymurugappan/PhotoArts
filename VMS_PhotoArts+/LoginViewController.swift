//
//  LoginViewController.swift
//  VMS_PhotoArts+
//
//  Created by Vijay Murugappan Subbiah on 11/5/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import UIKit
import CoreData // importing core data
import LocalAuthentication // importing local authentication for touch id access

//Referencing text field delegates
class LoginViewController: UIViewController,UITextFieldDelegate {
    
    //OUTLETS
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var guestBtn: UIButton!
    @IBOutlet weak var touchBtn: UIButton!
    
    //VARAIBLES
    var userFlag = Bool()
    var passFlag = Bool()
    var userName = String()
    
    //ACTIONS
    @IBAction func guestClicked(_ sender: UIButton) { // guest login
        userName = "Guest" // make username to be guest
        performSegue(withIdentifier: "collection", sender: self) // navigate to collection view without authentication
    }
    
    @IBAction func useTouchIDButton(_ sender: UIButton) { // touch login
        let context:LAContext = LAContext() // object for local authentication context
        
        // Check to see if the user device is TouchID enabled
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        {
            // Tell the user that the app is using the finger print.
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Using TouchID", reply: { (successful, error) in
                if successful {
                    let alertController = UIAlertController(title: "Using TouchID", message: "Success!", preferredStyle: .alert)
                    
                    let dismissButton = UIAlertAction(title: "OK", style: .cancel, handler: {
                        
                        (alert: UIAlertAction!) -> Void in
                        self.performSegue(withIdentifier: "touchcollection", sender: self) // navigate to collection view
                    })
                    alertController.addAction(dismissButton)
                    self.present(alertController, animated: true, completion: nil)
                    
                } else {
                    let alertController = UIAlertController(title: "ERROR", message: "Unable to login with TouchID", preferredStyle: .alert)
                    
                    let dismissButton = UIAlertAction(title: "OK", style: .cancel, handler: {
                        
                        (alert: UIAlertAction!) -> Void in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    alertController.addAction(dismissButton)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        checkData() // authenticate user and password
    }
    
    //USER DEFINED FUNCTIONS
    func checkData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                for item in results as! [NSManagedObject] {
                    if let user = item.value(forKey: "username") as? String {
                        if(userTextField.text == user) { // checking whether username matches database
                            userFlag = true // set flag
                            break
                        }
                        else {
                            userFlag = false // reset flag
                        }
                    }
                }
                for item in results as! [NSManagedObject] {
                    if let pwd = item.value(forKey: "password") as? String {
                        if (passwordTextField.text == pwd) { // checking whether password matches
                            passFlag = true
                            break
                        }
                        else {
                            passFlag = false
                        }
                    }
                }
            }
            if (userFlag == true && passFlag == true) { // if both flags are set
                userName = userTextField.text! // store the username for passing it
                performSegue(withIdentifier: "collection", sender: self) // navigate to collection view
            }
            else {
                showAlert(Title: "Invalid User or Password", Desc: "Please check your username or password") // produce alert for invalid user
            }
        }
        catch {
            showAlert(Title: "Database Error", Desc: "Error in fetching core data") // produce alert for error in core data fetch
        }
    }
    
    func createDummyData() { // dummy data for testing touch id
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let user: User = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
        user.username = "DummyTouch"
        user.email = "dummytouchuser@example.com"
        user.street = "123 street"
        user.city = "TouchCity"
        user.state = "NA"
        user.zip = "00000"
        user.apartment = "Apartment NA"
        user.firstname = "Mr.Touch"
        user.lastname = "Test"
        do {
            try context.save()
        }
        catch {
            showAlert(Title: "FAILED", Desc: "Failed in saving history to database")
        }
    }
    
    func showAlert(Title: String, Desc: String) {
        /* Producing alerts for specific error title and description with an action to dismiss the controller */
        let alertController = UIAlertController(title: Title, message: Desc, preferredStyle: .alert) // alert controller
        let alertAction = UIAlertAction(title: "OK", style: .default) { // completion handler for alert action
            (UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction) // adding action to controller
        self.present(alertController, animated: true, completion: nil) // presenting alert controller
    }
    
    //TEXT FIELD DELEGATE METHODS
    
    //if touched outside text field resigns keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //resigns keyboard when clicked return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }

    //VIEW DID LOAD - Default view when loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        createDummyData() // for touch id
        /* referencing delegates */
        userTextField.delegate = self
        passwordTextField.delegate = self
        /* clearing text fields for log out */
        userTextField.text = ""
        passwordTextField.text = ""
        /* Setting custom text fields and buttons */
        setcustomTextField(textfield: userTextField, placeholdername: "USERNAME")
        setcustomTextField(textfield: passwordTextField, placeholdername: "PASSWORD")
        setcustomButton(button: loginBtn)
        setcustomButton(button: registerBtn)
        setcustomButton(button: guestBtn)
        setcustomButton(button: touchBtn)
        let infoLightBtn = UIButton(type: .infoLight) // creating a button with type info light
        infoLightBtn.tintColor = UIColor.black // changing background color for info light button to black
        infoLightBtn.addTarget(self, action: #selector(navigateAction), for: .touchUpInside) // adding action for that button
        let barBtn = UIBarButtonItem(customView: infoLightBtn) // creating a bar button item with info light button
        self.navigationItem.rightBarButtonItem = barBtn // placing the bar button to the right pane of the navigation bar
        // Do any additional setup after loading the view.
    }
    
    @objc func navigateAction() { // selector action for the info light button
        performSegue(withIdentifier: "AUTHOR", sender: self) // navigating to the author view
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

    // this function will get called before the control is handed over to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "collection") { // if segue identifier is collection
            let vc = segue.destination as! ViewController
            vc.userName = userName
        }
        if (segue.identifier == "touchcollection") { // if segue identifier is touch collection for touch id
            let vc = segue.destination as! ViewController
            vc.userName = "DummyTouch"
        }
    }

}
