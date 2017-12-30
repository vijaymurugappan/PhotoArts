//
//  ForgotPasswordViewController.swift
//  VMS_PhotoArts+
//
//  Created by Vijay Murugappan Subbiah on 12/5/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import UIKit
import MessageUI //importing message ui for mail
import CoreData // importing core data

//Referencing text field delegates and mail composer delegates
class ForgotPasswordViewController: UIViewController,UITextFieldDelegate,MFMailComposeViewControllerDelegate {
    
    //OUTLETS
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    //VARIABLES
    var username = String()
    var password = String()
    
    //ACTION
    @IBAction func sendBtnClicked(sender: UIButton) {
        if(!retreiveData()) { // if cannot retreive data
            emailTextField.text = ""
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Email not associated with this account!", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red]) // produce error message as placeholder
        }
        else {
            sendMail() // send mail if retreived data
        }
    }

    //VIEW DID LOAD - Default view when loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self // referencing delegate
        /* customizing text field and button */
        setcustomTextField(textfield: emailTextField, placeholdername: "Enter your email address")
        setcustomButton(button: sendButton)
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
    
    //if touched outside text field resigns keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //resigns keyboard when clicked return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkButton() // check to enable button when text field did end editing
    }
    
    func retreiveData() -> Bool {
        /* retreives email from the user database for this specific user */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "email = %@", emailTextField.text!)
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                for item in results as! [NSManagedObject] {
                    if let user = item.value(forKey: "username") as? String {
                        username = user
                    }
                    if let pass = item.value(forKey: "password") as? String {
                        password = pass
                    }
                    return true
                }
            }
        }
        catch {
            showAlert(Title: "FAILED", Desc: "Failed to retreive data from database") // produce alert when failed to retreive
        }
        return false
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
    
    func sendMail() {
        if MFMailComposeViewController.canSendMail() { // if current device can send a main
            let mailCompose = MFMailComposeViewController() // creating object for mfmailcompose viewcontroller
            mailCompose.mailComposeDelegate = self
            let toRecipents = [emailTextField.text!]
            let emailTitle = "PhotoArts+ username and password details"
            let messageBody = "Hi User, \nUsername: \(username) \nPassword: \(password)"
            mailCompose.setToRecipients(toRecipents) // assigning mail recipients
            mailCompose.setSubject(emailTitle) // assigning mail subject
            mailCompose.setMessageBody(messageBody, isHTML: false) // assigning mail body
            self.present(mailCompose, animated: true, completion: nil) // presenting message view controller which opens messages app
        }
        else { // if simulator
            let alertController = UIAlertController(title: "Sending mail..", message: self.emailTextField.text, preferredStyle: .alert)
            let dismissButton = UIAlertAction(title: "Dismiss", style: .cancel, handler: { // completion handler for alert action
                (alert: UIAlertAction!) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(dismissButton) // adding action to controller
            self.present(alertController, animated: true, completion: nil) // presenting controller
        }
    }
    
    //MAIL COMPOSER DELEGATE METHOD
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        /* producing alert when mail is cancelled, not delivered, saved to draft, mail sent */
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.failed.rawValue:
            self.showAlert(Title: "MAIL FAILED", Desc: "mail did not deliver")
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.saved.rawValue:
            self.showAlert(Title: "MAIL SAVED", Desc: "mail saved to draft")
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent.rawValue:
            self.showAlert(Title: "MAIL SENT", Desc: "mail has been sent to the employee")
            controller.dismiss(animated: true, completion: nil)
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkButton() { // checking if all text fields are filled and enables / disables the button
        if emailTextField.text == "" {
            sendButton.isEnabled = false
        }
        else {
            sendButton.isEnabled = true
        }
    }

}
