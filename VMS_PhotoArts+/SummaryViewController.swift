//
//  SummaryViewController.swift
//  VMS_PhotoArts+
//
//  Created by Vijay Murugappan Subbiah on 11/5/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import UIKit
import MessageUI // importing message ui when sending mail
import CoreData // importing core data

//referencing mail compose view controller delegate
class SummaryViewController: UIViewController, MFMailComposeViewControllerDelegate {

    //OUTLETS
    @IBOutlet weak var shipStreet: UILabel!
    @IBOutlet weak var shipApt: UILabel!
    @IBOutlet weak var shipCity: UILabel!
    @IBOutlet weak var shipSt: UILabel!
    @IBOutlet weak var shipZip: UILabel!
    @IBOutlet weak var billStreet: UILabel!
    @IBOutlet weak var billApt: UILabel!
    @IBOutlet weak var billCity: UILabel!
    @IBOutlet weak var billSt: UILabel!
    @IBOutlet weak var billZip: UILabel!
    @IBOutlet weak var shipStatus: UILabel!
    @IBOutlet weak var productFee: UILabel!
    @IBOutlet weak var shipFee: UILabel!
    @IBOutlet weak var cardFname: UILabel!
    @IBOutlet weak var cardLname: UILabel!
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var cardExpDate: UILabel!
    @IBOutlet weak var cardCVV: UILabel!
    @IBOutlet weak var emailID: UILabel!
    @IBOutlet weak var grandTotal: UILabel!
    @IBOutlet weak var purchaseBtn: UIButton!
    
    //VARIABLES
    var shippingStreet = String()
    var shippingApt = String()
    var shippingCity = String()
    var shippingSt = String()
    var shippingZip = String()
    var billingApt = String()
    var billingStreet = String()
    var billingCity = String()
    var billingSt = String()
    var billingZip = String()
    var shippingStatus = String()
    var productFees = Double()
    var shippingFee = Double()
    var firstName = String()
    var lastName = String()
    var cardNum = String()
    var expDate = String()
    var CVV = String()
    var email = String()
    var total = Double()
    var username = String()
    var framed = [Bool]()
    var itemNum = [String]()
    var quantity = [Int]()
    var subTot = [Double]()
    
    //ACTION
    @IBAction func purchaseClicked(sender: UIButton) {
        fetchFromCart() // fetch from cart details which are checked out
        for item in 0...itemNum.count-1 { // count of item number
            storeToUserHistory(framed: framed[item], itemNum: itemNum[item], quantity: quantity[item], subTot: subTot[item]) // storing to user purchase history
        }
        deleteCart() // delete items from cart after order is placed
        showAlert(Title: "Order Placed", Desc: "Product summary has been mailed to you.Thank you for choosing PhotoArts+")
    }
    
    func deleteCart() {
        /* Function for deleting cart details for that username */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart") // according to the specific item number
        fetchRequest.predicate = NSPredicate(format: "username = %@", username)
        do {
            if let result = try? context.fetch(fetchRequest) {
                for item in result {
                    context.delete(item as! NSManagedObject) // deleting item
                }
            }
        }
    }
    
    func storeToUserHistory(framed: Bool, itemNum: String, quantity: Int, subTot: Double) {
        /* This function stores the cart details to the user purchase history database with the time stamp */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let history: PurchaseHistory = NSEntityDescription.insertNewObject(forEntityName: "PurchaseHistory", into: context) as! PurchaseHistory
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        history.framed = framed
        history.item = itemNum
        history.quantity = Int32(quantity)
        history.subtotal = subTot
        history.username = username
        history.datetime = dateString
        do {
            try context.save()
        }
        catch {
            produceAlert(Title: "FAILED", Desc: "Failed in saving history to database")
        }
    }
    
    func fetchFromCart() {
        /* This function fetches the cart details to the user database for that username */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        request.predicate = NSPredicate(format: "username = %@", username)
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                for item in results as! [NSManagedObject] {
                    if let user = item.value(forKey: "username") as? String {
                        username = user
                    }
                    if let frame = item.value(forKey: "framed") as? Bool {
                        framed.append(frame)
                    }
                    if let itemnumber = item.value(forKey: "item") as? String {
                        itemNum.append(itemnumber)
                    }
                    if let qty = item.value(forKey: "quantity") as? Int {
                        quantity.append(qty)
                    }
                    if let subTotal = item.value(forKey: "subtotal") as? Double {
                        subTot.append(subTotal)
                    }
                }
            }
        }
        catch {
            produceAlert(Title: "Database Error", Desc: "Error in fetching core data")
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
    
    func showAlert(Title: String, Desc: String) { // producing alert for mail
        let alertController = UIAlertController(title: Title, message: Desc, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) {
            (UIAlertAction) in
            self.sendMail() // sending mail when success alert is produced
            //exit(0) // exits the app after purchasing
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendMail() {
        if MFMailComposeViewController.canSendMail() { // if current device can send a main
            let mailCompose = MFMailComposeViewController() // creating object for mfmailcompose viewcontroller
            mailCompose.mailComposeDelegate = self
            let lastfour = cardNum.substring(from:cardNum.index(cardNum.endIndex, offsetBy: -4))
            let toRecipents = [email, "class1photoarts@gmail.com"]
            let emailTitle = "PhotoArts+ purchase order details"
            let messageBody = "Hi \(firstName),\(lastName) your purchase order details \n\n\nSHIPPING ADDRESS : \n\(shippingStreet),\(shippingApt) \n\(shippingCity),\(shippingSt) \(shippingZip) \n\nSHIPPING STATUS : \(shippingStatus) \n\nCARD INFORMATION: \n\(firstName) \n\(lastName) \nXXXXXXXXXXXX\(lastfour) \n\(expDate) \n\nBILLING ADDRESS : \n\(billingStreet),\(billingApt) \n\(billingCity),\(billingSt) \(billingZip) \n\nProduct Cost: $\(productFees) \nShipping Cost: $\(shippingFee) \nTax: $0 \nGrand Total: $\(total) \n\n\n Thank you for shopping at PhotoArts+"
            mailCompose.setToRecipients(toRecipents) // assigning mail recipients
            mailCompose.setSubject(emailTitle) // assigning mail subject
            mailCompose.setMessageBody(messageBody, isHTML: false) // assigning mail body
            self.present(mailCompose, animated: true, completion: nil) // presenting message view controller which opens messages app
        }
        else { // if simulator
            let alertController = UIAlertController(title: "Sending mail..", message: self.email, preferredStyle: .alert)
            let dismissButton = UIAlertAction(title: "Dismiss", style: .cancel, handler: { // completion handler for alert action
                (alert: UIAlertAction!) -> Void in
                exit(0)
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
            self.produceAlert(Title: "MAIL FAILED", Desc: "mail did not deliver")
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.saved.rawValue:
            self.produceAlert(Title: "MAIL SAVED", Desc: "mail saved to draft")
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent.rawValue:
            self.produceAlert(Title: "MAIL SENT", Desc: "mail has been sent to the employee")
            controller.dismiss(animated: true, completion: nil)
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }

    //VIEW DID LOAD - Default view when loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        total = productFees + shippingFee // calculating total amount
        let lastfour = cardNum.substring(from:cardNum.index(cardNum.endIndex, offsetBy: -4))
        let securedCardNum = "XXXXXXXXXXXX" + lastfour // displaying only the last 4 digits of the card
        updateView(securedCard: securedCardNum) // updating the view
        setcustomButton(button: purchaseBtn) // customizing button
        // Do any additional setup after loading the view.
    }
    
    func setcustomButton(button: UIButton) {
        button.layer.cornerRadius = 8.0 // Rounding the corners of the button
    }
    
    func updateView(securedCard: String) {
        /* updating view from the checkout details to summary view */
        shipStreet.text = shippingStreet
        shipApt.text = shippingApt
        shipSt.text = shippingSt
        shipCity.text = shippingCity
        shipZip.text = shippingZip
        billStreet.text = billingStreet
        billApt.text = billingApt
        billSt.text = billingSt
        billCity.text = billingCity
        billZip.text = billingZip
        shipStatus.text = shippingStatus
        cardFname.text = firstName
        cardLname.text = lastName
        cardNumber.text = securedCard
        cardExpDate.text = expDate
        cardCVV.text = CVV
        emailID.text = email
        productFee.text = "$\(productFees)"
        shipFee.text = "$\(shippingFee)"
        grandTotal.text = "$\(total)"
    }
}
