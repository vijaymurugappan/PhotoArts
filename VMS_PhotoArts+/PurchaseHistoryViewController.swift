//
//  PurchaseHistoryViewController.swift
//  VMS_PhotoArts+
//
//  Created by Vijay Murugappan Subbiah on 12/4/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import UIKit
import CoreData // import core data

class PurchaseHistoryViewController: UITableViewController {
    
    //VARIABLES
    var username = String()
    var dateTime = [String]()
    var isFramed = [Bool]()
    var itemnum = [String]()
    var quant = [Int]()
    var subTot = [Double]()

    //VIEW DID LOAD - Default view when loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFromHistory() // fetching from purchase history database
    }
    
    func fetchFromHistory() {
        /* This function fetches purchase history from its database according to this user */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PurchaseHistory")
        request.predicate = NSPredicate(format: "username = %@", username)
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                for item in results as! [NSManagedObject] {
                    if let dateNTime = item.value(forKey: "datetime") as? String {
                        dateTime.append(dateNTime)
                    }
                    if let frame = item.value(forKey: "framed") as? Bool {
                        isFramed.append(frame)
                    }
                    if let itemnumber = item.value(forKey: "item") as? String {
                        itemnum.append(itemnumber)
                    }
                    if let qty = item.value(forKey: "quantity") as? Int {
                        quant.append(qty)
                    }
                    if let subTotal = item.value(forKey: "subtotal") as? Double {
                        subTot.append(subTotal)
                    }
                }
            }
        }
        catch {
            showAlert(Title: "Database Error", Desc: "Error in fetching core data") // produce error if not able to fetch data 
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // 1 section in table view
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemnum.count // number of itemnumber array
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemcell: ItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: "purchasecell", for: indexPath) as! ItemTableViewCell // custom cell
        itemcell.itemLabel.text = itemnum[indexPath.item]
        itemcell.qtyLabel.text = String(quant[indexPath.item])
        itemcell.totalLabel.text = "$\(subTot[indexPath.item])"
        itemcell.dateLabel.text = dateTime[indexPath.item]
        if(isFramed[indexPath.item]) {
            itemcell.frameLabel.text = "FRAMED"
        }
        else {
            itemcell.frameLabel.text = "NO FRAME"
        }
        return itemcell
    }
}
