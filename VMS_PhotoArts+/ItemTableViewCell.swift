//
//  ItemTableViewCell.swift
//  VMS_PhotoArts+
//  Custom Table View cell for the Item Table View
//  Created by Vijay Murugappan Subbiah on 11/5/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import UIKit
import CoreData // importing core data

protocol ItemTableViewCellDelegate: class { // creating a custom delegate with a function
    func stepperPressed()
}

class ItemTableViewCell: UITableViewCell {
    
    //OUTLETS
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var qtyStepper: UIStepper!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var frameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //VARIABLES
    var cartFrame = [Bool]()
    var cartItem = [String]()
    var cartQty = [Int]()
    var cartSubTotal = [Double]()
    var userName = String()
    var index = Int()
    var qty:Double!
    weak var delegate: ItemTableViewCellDelegate? // object for the delegate
    
    //ACTION
    @IBAction func stepperClicked(sender: UIStepper) { // when stepper is changed the function is called
        fetchCart() // fetching items from the cart to find index
        for i in 0...cartItem.count {
            if itemLabel.text == cartItem[i] { // if item number matches with cart items
                index = i // retreive index
                break
            }
        }
        let values = Int(sender.value)
        qtyLabel.text = String(values) // stepper value assigned to quantity
        totalLabel.text = String(Double(qtyLabel.text!)! * (cartSubTotal[index])/qty) // compute if increased quantity
        updateData(itemNum: itemLabel.text!, qty: Int32(qtyLabel.text!)!, total: Double(totalLabel.text!)!, framed: cartFrame[index]) // update core data of new changes
        delegate?.stepperPressed() // reference the function of the delegate
    }
    
    //USER DEFINED FUNCTIONS
    func updateData(itemNum: String, qty: Int32, total: Double, framed: Bool ) {
        /* Function for updating cart details for that item number when stepper is changed */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // referencing app delegate
        let context = appDelegate.persistentContainer.viewContext // referencing the context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart") // fetch request for cart
        fetchRequest.predicate = NSPredicate(format: "item = %@", itemNum) // giving a predicate to the fetch request to fetch according to item number
        fetchRequest.predicate = NSPredicate(format: "framed = %@", framed as CVarArg) // according to whether it is framed or not
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            if (results.count > 0) {
                for item in results as! [NSManagedObject] { // updating quantity and subtotal
                    item.setValue(qty, forKey: "quantity")
                    item.setValue(total, forKey: "subtotal")
                }
            }
        }
        catch {
            updateData(itemNum: itemNum, qty: qty, total: total, framed: framed) // try again
        }
    }
    
    func fetchCart() {
        /* Function for fetching cart details to find the current index */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                for item in results as! [NSManagedObject] {
                    if let frame = item.value(forKey: "framed") as? Bool {
                        cartFrame.append(frame)
                    }
                    if let item = item.value(forKey: "item") as? String {
                        cartItem.append(item)
                    }
                    if let quantity = item.value(forKey: "quantity") as? Int {
                        cartQty.append(quantity)
                    }
                    if let subtotal = item.value(forKey: "subtotal") as? Double {
                        cartSubTotal.append(subtotal)
                    }
                }
            }
        }
        catch {
           fetchCart() // try again
        } 
    }
}
