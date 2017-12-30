//
//  CartViewController.swift
//  VMS_PhotoArts+
//
//  Created by Vijay Murugappan Subbiah on 11/5/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import UIKit
import CoreData // importing coredata

// Referencing table view delegates and datasource and text field delegates and custom delegate for item table view cell
class CartViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ItemTableViewCellDelegate {
    
    //OUTLETS
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var checkoutBtn: UIButton!
    @IBOutlet weak var totalLabel: UILabel!
    
    //VARIABLES
    var cartFrame = [Bool]()
    var cartItem = [String]()
    var cartPrice = Double()
    var cartQty = [Int]()
    var cartSubTotal = [Double]()
    var userName = String()
    
    //ACTIONS
    @IBAction func logoutClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "login", sender: self) // navigates back to the login view controller
    }
    
    @IBAction func barBtnClicked(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "add", sender: self) // When clicked add navigates to the collection view controller
    }

    @IBAction func checkoutClicked(_ sender: UIButton) {
        if userName != "Guest" { //if username other than guest
            performSegue(withIdentifier: "checkout", sender: self) // navigate to the checkout page
        }
        else {
            let optionsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet) //creating an action sheet
            let createAction = UIAlertAction(title: "CREATE AN ACCOUNT", style: .default, handler: { // completion handler for alert action
                (alert: UIAlertAction!) -> Void in
                self.performSegue(withIdentifier: "create", sender: self) // if guest wants to create an account navigates to sign up page
                optionsMenu.dismiss(animated: true, completion: nil) // dismissing the controller after button is clicked
            })
            let guestAction = UIAlertAction(title: "CHECKOUT AS GUEST", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.performSegue(withIdentifier: "checkout", sender: self) // if guest wants to checkout as guest then navigates to checkout
                optionsMenu.dismiss(animated: true, completion: nil)
            })
            optionsMenu.addAction(createAction) // adding actions
            optionsMenu.addAction(guestAction)
            self.present(optionsMenu, animated: true, completion: nil) // presenting action sheet
        }
    }
    
    //VIEW DID LOAD - Default view when loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        setcustomButton(button: checkoutBtn) // customizing the checkout button
        cartTableView.delegate = self // setting delegate and datasource for table view
        cartTableView.dataSource = self
        updateCart() // update cart items before fetching
        fetchCart() // fetch cart items
        updateTotal()
        if cartItem.count > 0 { // if total items is atleast 1 enable checkout button
            checkoutBtn.isEnabled = true
        }
        else { // else disable checkout button
            checkoutBtn.isEnabled = false
        }
        // Do any additional setup after loading the view.
    }
    
    //VIEW DID APPEAR - View when it is prepared to display to the user
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        cartTableView.reloadData() // reload cart table view data
    }
    
    //USER DEFINED FUNCTIONS
    func updateCart() {
        /* Function for updating cart's username from guest to the account which guest created to transfer cart items */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // referencing app delegate
        let context = appDelegate.persistentContainer.viewContext // referencing the context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart") // fetch request for cart
        fetchRequest.predicate = NSPredicate(format: "username = %@", "Guest") // giving a predicate to the fetch request to fetch according to username
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest) // storing results in variable
            if (results.count > 0) { // if there are any results
                for item in results as! [NSManagedObject] {
                    item.setValue(userName, forKey: "username") // changing to new username from guest
                }
            }
        }
        catch {
            showAlert(Title: "FAILED", Desc: "failed to udpate items in cart") // if failed updating
        }
    }
    
    func fetchCart() {
        /* Function for fetching cart details for that username */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        request.predicate = NSPredicate(format: "username = %@", userName)
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                for item in results as! [NSManagedObject] {
                    if let frame = item.value(forKey: "framed") as? Bool {
                        cartFrame.append(frame) // appending elements to their array variables
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
            showAlert(Title: "FAILED", Desc: "failed retreiving items from the cart") // if failed fetching cart
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
    
    func setcustomButton(button: UIButton) {
        button.layer.cornerRadius = 8.0 // Rounding the corners of the button
    }
    
    func updateTotal() { // updating price, item count and subtotal
        cartPrice = 0.0
        for price in cartSubTotal {
            cartPrice = cartPrice + price
        }
        totalLabel.text = String(cartPrice)
    }
    
    func stepperPressed() { // Custom delegate function from item table view cell
        cartSubTotal.removeAll() // clear array
        fetchCart() // fetch updated array
        updateTotal() // update totals
    }
    
    func deleteData(itemNum: String) {
        /* Function for deleting cart details for that username */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart") // according to the specific item number
        fetchRequest.predicate = NSPredicate(format: "item = %@", itemNum)
        do {
            if let result = try? context.fetch(fetchRequest) {
                for item in result {
                    context.delete(item as! NSManagedObject) // deleting item
                }
            }
        }
    }
    
    //TABLE VIEW DELEGATES AND DATASOURCE
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // 1 section in a table view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItem.count // item count + 1 for the grand total
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "WELCOME \(userName)," // section header for displaying username
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell: ItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath) as! ItemTableViewCell // custom cell
        itemLabel.text = String(cartItem.count)
        itemCell.delegate = self // referencing custom item cell delegate
        itemCell.itemLabel.text = cartItem[indexPath.item]
        itemCell.qtyLabel.text = String(cartQty[indexPath.item])
        itemCell.qtyStepper.value = Double(itemCell.qtyLabel.text!)! // value for stepper
        itemCell.qty = Double(itemCell.qtyLabel.text!)!
        itemCell.totalLabel.text = String(cartSubTotal[indexPath.item])
        if (cartFrame[indexPath.item]) {
            itemCell.frameLabel.text = "FRAMED"
        }
        else {
            itemCell.frameLabel.text = "NO FRAME"
        }
        return itemCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        /* Cell when edited - Swiped */
        if editingStyle == UITableViewCellEditingStyle.delete { // delete button
            deleteData(itemNum: cartItem[indexPath.item]) // deletes item from cart
            cartItem.remove(at: indexPath.item)//remove item number from the array
            cartSubTotal.remove(at: indexPath.item)//remove subtotal from the array
            cartQty.remove(at: indexPath.item) // removes qty from array
            cartFrame.remove(at: indexPath.item) // removes frame from array
            tableView.deleteRows(at: [indexPath], with: .fade) // delete the table row
            updateTotal() // update total, subtotal and item total
            cartTableView.reloadData() // reload data
        }
    }
    
    func clearGuestData() {
        /* Function for clearing the cart when guest clicks logout by deleting all items from cart database */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // referencing app delegate
        let context = appDelegate.persistentContainer.viewContext // referencing the context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart") // fetch request for cart
        do {
            if let result = try? context.fetch(fetchRequest) {
                for item in result {
                    context.delete(item as! NSManagedObject) // deleting all object
                }
            }
        }
    }
    
    // this function will get called before the control is handed over to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkout" { // if destination id is web
            let checkoutVC = segue.destination as! CheckoutViewController
            checkoutVC.productfee = cartPrice
            checkoutVC.userName = userName
        }
        else if segue.identifier == "create" { // if destination id is create
            let signVC = segue.destination as! SignUpViewController
            signVC.isGuest = true
        }
        else if segue.identifier == "add" { // if destination id is add
            let addVC = segue.destination as! ViewController
            addVC.userName = userName
        }
        else if segue.identifier == "login" { // if destination id is login
            if userName == "Guest" {
                clearGuestData()
            }
        }
    }
    
    // if guest creats and account and comes back to this view
    @IBAction func unwindToCart(_ segue:UIStoryboardSegue){
        if segue.identifier == "created" {
            let vc = segue.source as! SignUpViewController
            userName = vc.userTextField.text! // assign his username
            cartTableView.reloadData()
        }
    }
}
