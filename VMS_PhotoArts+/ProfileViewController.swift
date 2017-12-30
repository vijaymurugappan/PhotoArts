//
//  ProfileViewController.swift
//  VMS_PhotoArts+
//
//  Created by Vijay Murugappan Subbiah on 12/4/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import UIKit
import CoreData // importing core data

class ProfileViewController: UIViewController {
    
    //OUTLETS
    @IBOutlet weak var User: UILabel!
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var Street: UILabel!
    @IBOutlet weak var Apartment: UILabel!
    @IBOutlet weak var City: UILabel!
    @IBOutlet weak var State: UILabel!
    @IBOutlet weak var Zip: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    
    //ACTIONs
    @IBAction func updateButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "update", sender: self) // navigate to update page
    }
    
    @IBAction func showPHBtnClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "history", sender: self) // navigate to history page
    }
    
    //VARIABLE
    var username = String()

    //VIEW DID LOAD - Default view when loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData() // fetch data from user and display in label
        // Do any additional setup after loading the view.
    }
    
    //VIEW DID APPEAR - View when it is prepared to display to the user
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fetchData() // fetch data from user and display in label
    }

    func fetchData() {
        /* fetch data from user database and store them in text fields */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "username = %@", username)
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                for item in results as! [NSManagedObject] {
                    if let user = item.value(forKey: "username") as? String {
                       User.text = user
                    }
                    if let email = item.value(forKey: "email") as? String {
                       Email.text = email
                    }
                    if let street = item.value(forKey: "street") as? String {
                        Street.text = street
                    }
                    if let apt = item.value(forKey: "apartment") as? String {
                        Apartment.text = apt
                    }
                    if let city = item.value(forKey: "city") as? String {
                        City.text = city
                    }
                    if let state = item.value(forKey: "state") as? String {
                        State.text = state
                    }
                    if let zip = item.value(forKey: "zip") as? String {
                        Zip.text = zip
                    }
                    if let fname = item.value(forKey: "firstname") as? String {
                        firstName.text = fname
                    }
                    if let lname = item.value(forKey: "lastname") as? String {
                        lastName.text = lname
                    }
                }
            }
        }
        catch {
            showAlert(Title: "Database Error", Desc: "Error in fetching core data")
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
    
    // this function will get called before the control is handed over to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "update" { // if segue identifier is update
            let upVc = segue.destination as! UpdateProfileViewController
            upVc.username = User.text!
            upVc.email = Email.text!
            upVc.streets = Street.text!
            upVc.states = State.text!
            upVc.apartments = Apartment.text!
            upVc.zips = Zip.text!
            upVc.cities = City.text!
            upVc.lName = lastName.text!
            upVc.fName = firstName.text!
        }
        else if segue.identifier == "history" { // if segue identifier is history
            let hVC = segue.destination as! PurchaseHistoryViewController
            hVC.username = User.text!
        }
    }
}
