//
//  DetailViewController.swift
//  VMS_PhotoArts+
//
//  Created by Vijay Murugappan Subbiah on 11/4/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import UIKit
import CoreData // importing core data

// Referencing pickerview delegates and datasource and text field delegates
class DetailViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    
    //OUTLETS
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var frameTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var qtyStepper: UIStepper!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var cartBtn: UIButton!
    
    //VARIABLES
    var image = UIImage()
    var itemNumber = String()
    let pickerData = ["No Frame","Matte Black","Matte White","Brushed Silver","Matte Brass","Light Grey", "Wood Frame"]
    let pickerSize = ["7” x 5”","10” x 8”","14” x 11”","20” x 16”","24” x 18”","40” x 30”","54” x 40”","60” x 44”"]
    let pickerSizeF = ["7” x 5”","10” x 8”","14” x 11”","20” x 16”","24” x 18”","40” x 30”","54” x 40”"]
    var pickerViewF = UIPickerView()
    var pickerViewS = UIPickerView()
    var framed = Bool()
    var cartFrame = [Bool]()
    var cartItem = [String]()
    var cartQty = [Int]()
    var cartSubTotal = [Double]()
    var userName = String()

    //VIEW DID LOAD - Default view when loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        setcustomButton(button: cartBtn) // customizing button
        /* Customizing text fields */
        setcustomTextField(textfield: frameTextField, placeholdername: "Choose Frame")
        setcustomTextField(textfield: sizeTextField, placeholdername: "Choose Size")
        qtyLabel.text = String(1) // default value for the quantity label
        setPickerView() // setting up picker view
        /* assigning text field delegates */
        frameTextField.delegate = self
        sizeTextField.delegate = self
        /* hiding all text fields initially except frame */
        sizeTextField.isHidden = true
        qtyLabel.isHidden = true
        qtyStepper.isHidden = true
        priceLabel.isHidden = true
        isAllFieldsFilled() // check if button should be enabled or not
        updateUI() // update the screen
    }
    
    //USER DEFINED FUNCTIONS
    func isAllFieldsFilled() { // this functions checks whether all the text fields are filled then enables/disables the add to cart button
        if frameTextField.text == "" || sizeTextField.text == "" {
            cartBtn.isEnabled = false
        }
        else {
            cartBtn.isEnabled = true
        }
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
    
    func setPickerView() {
        /* Setting picker view delegates, datasources and frame,size textfield input view to picker view and creating a toolbar with select button on it and assigning to the text fields */
        pickerViewF.delegate = self
        pickerViewF.dataSource = self
        pickerViewS.delegate = self
        pickerViewS.dataSource = self
        frameTextField.inputView = pickerViewF
        sizeTextField.inputView = pickerViewS
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        let doneButton = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(CheckoutViewController.selectItem))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, doneButton, space], animated: false)
        frameTextField.inputAccessoryView = toolBar
        sizeTextField.inputAccessoryView = toolBar
    }
    
    func selectItem() {
        /* when clicked select in picker dismissing the picker view */
        frameTextField.endEditing(true)
        sizeTextField.endEditing(true)
    }
    
    func fieldDidChange() {
        /* this function multiplies the quantity with the price of framed/notframed,sized picture */
        if(frameTextField.text == "No Frame") {
            if(sizeTextField.text == "7” x 5”") {
                priceLabel.text = self.toPrice(price: "24.0")
            }
            else if(sizeTextField.text == "10” x 8”") {
                priceLabel.text = self.toPrice(price: "35.0")
            }
            else if(sizeTextField.text == "14” x 11”") {
                priceLabel.text = self.toPrice(price: "50.0")
            }
            else if(sizeTextField.text == "20” x 16”") {
                priceLabel.text = self.toPrice(price: "76.0")
            }
            else if(sizeTextField.text == "24” x 18”") {
                priceLabel.text = self.toPrice(price: "97.0")
            }
            else if(sizeTextField.text == "40” x 30”") {
                priceLabel.text = self.toPrice(price: "164.0")
            }
            else if(sizeTextField.text == "54” x 40”") {
                priceLabel.text = self.toPrice(price: "230.0")
            }
            else if(sizeTextField.text == "60” x 44”") {
                priceLabel.text = self.toPrice(price: "248.0")
            }
        }
        else {
            if(sizeTextField.text == "7” x 5”") {
                priceLabel.text = self.toPrice(price: "24.0")
            }
            else if(sizeTextField.text == "10” x 8”") {
                priceLabel.text = self.toPrice(price: "46.0")
            }
            else if(sizeTextField.text == "14” x 11”") {
                priceLabel.text = self.toPrice(price: "89.0")
            }
            else if(sizeTextField.text == "20” x 16”") {
                priceLabel.text = self.toPrice(price: "158.0")
            }
            else if(sizeTextField.text == "24” x 18”") {
                priceLabel.text = self.toPrice(price: "189.0")
            }
            else if(sizeTextField.text == "40” x 30”") {
                priceLabel.text = self.toPrice(price: "365.0")
            }
            else if(sizeTextField.text == "54” x 40”") {
                priceLabel.text = self.toPrice(price: "570.0")
            }
        }
    }
    
    func updateUI() {
        /* updating views with image information from previous collection view controller */
        imageView.image = image
        imageLabel.text = itemNumber
    }
    
    func setFrame(Color: UIColor) { // function for setting the background color for the frame view behind the image view
        frameView.backgroundColor = Color
    }
    
    func toPrice(price: String) -> String { // function for multiplying quantity with product price
        let doublePrice = Double(price)
        if let doubleQty = Double(qtyLabel.text!) {
          let totalPrice = (doublePrice! * doubleQty)
          return "$\(totalPrice)"
        }
        else {
            return "$\(price)"
        }
    }
    
    //TEXT FIELD DELEGATE METHODS
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isAllFieldsFilled()
    }
    
    //PICKER VIEW DELEGATE AND DATASOURCE METHODS
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // 1 component in picker view
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == pickerViewF) { // if active picker view is picker view frame
            return pickerData.count // frame array count
        }
        else {
            if(frameTextField.text == "No Frame") { // if no frame
                return pickerSize.count // no frame price list
            }
            else {
                return pickerSizeF.count // framed price list
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == pickerViewF) { // if active picker view is picker view frame
            return pickerData[row] // frame array index name
        }
        else {
            if(frameTextField.text == "No Frame") { // if no frame
                return pickerSize[row] // no frame price index name
            }
            else {
                return pickerSizeF[row] // framed price index name
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == pickerViewF) { // if active picker is picker view frame
            frameTextField.text = pickerData[row] // set frame array index name to textfield
            /* According to the frame picker the image background view's color will be changed */
            if(frameTextField.text == "Matte Black") {
                setFrame(Color: .black)
            }
            else if(frameTextField.text == "Matte White") {
                setFrame(Color: .white)
            }
            else if(frameTextField.text == "Brushed Silver") {
                setFrame(Color: .darkGray)
            }
            else if(frameTextField.text == "Matte Brass") {
                setFrame(Color: .yellow)
            }
            else if(frameTextField.text == "Light Grey") {
                setFrame(Color: .lightGray)
            }
            else if(frameTextField.text == "Wood Frame") {
                setFrame(Color: .brown)
            }
            else {
                setFrame(Color: .clear)
            }
            /* hiding all text fields initially except frame and unhiding size and price */
            sizeTextField.isHidden = false
            qtyLabel.isHidden = true
            qtyStepper.isHidden = true
            priceLabel.isHidden = false
        }
        else { // if size picker is active picker
            if(frameTextField.text == "No Frame") { /* Set prices according to no frame */
                sizeTextField.text = pickerSize[row] // set frame array index name to textfield
                if(sizeTextField.text == "7” x 5”") {
                    priceLabel.text = "$24.0"
                }
                else if(sizeTextField.text == "10” x 8”") {
                    priceLabel.text = "$35.0"
                }
                else if(sizeTextField.text == "14” x 11”") {
                    priceLabel.text = "$50.0"
                }
                else if(sizeTextField.text == "20” x 16”") {
                    priceLabel.text = "$76.0"
                }
                else if(sizeTextField.text == "24” x 18”") {
                    priceLabel.text = "$97.0"
                }
                else if(sizeTextField.text == "40” x 30”") {
                    priceLabel.text = "$164.0"
                }
                else if(sizeTextField.text == "54” x 40”") {
                    priceLabel.text = "$230.0"
                }
                else if(sizeTextField.text == "60” x 44”") {
                    priceLabel.text = "$248.0"
                }
                sizeTextField.isHidden = false
                qtyLabel.isHidden = false
                qtyStepper.isHidden = false
                priceLabel.isHidden = false
            }
            else { /* Set prices accordingly with frame */
                sizeTextField.text = pickerSizeF[row] // set frame array index name to textfield
                if(sizeTextField.text == "7” x 5”") {
                    priceLabel.text = "$29.0"
                }
                else if(sizeTextField.text == "10” x 8”") {
                    priceLabel.text = "$46.0"
                }
                else if(sizeTextField.text == "14” x 11”") {
                    priceLabel.text = "$89.0"
                }
                else if(sizeTextField.text == "20” x 16”") {
                    priceLabel.text = "$158.0"
                }
                else if(sizeTextField.text == "24” x 18”") {
                    priceLabel.text = "$189.0"
                }
                else if(sizeTextField.text == "40” x 30”") {
                    priceLabel.text = "$365.0"
                }
                else if(sizeTextField.text == "54” x 40”") {
                    priceLabel.text = "$570.0"
                }
                sizeTextField.isHidden = false
                qtyLabel.isHidden = false
                qtyStepper.isHidden = false
                priceLabel.isHidden = false
            }
        }
    }
    
    func fetchItemList() -> Bool {
        /* Fetching cart items from database and checking whether user is trying to add the same item using item number */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        request.predicate = NSPredicate(format: "username = %@", userName)
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                for item in results as! [NSManagedObject] {
                    if let item = item.value(forKey: "item") as? String {
                        self.cartItem.append(item)
                    }
                }
            }
        }
        catch {
            showAlert(Title: "FAILED", Desc: "failure to fetch details")
        }
        if self.cartItem.count == 0 {
            return false
        }
        else {
            for item in 0...(self.cartItem.count) { // 0 to cart item count
                if self.itemNumber == self.cartItem[item] { // comparing item number
                    return true
                }
                else {
                    return false
                }
            }
            return false
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
    
    func insertToCart(frame: Bool, item: String, quantity: Int, subTotal: Double) {
        /* inserting cart items into cart database */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let userCart: Cart = NSEntityDescription.insertNewObject(forEntityName: "Cart", into: context) as! Cart
        userCart.username = userName
        userCart.framed = frame
        userCart.item = item
        userCart.quantity = Int32(quantity)
        userCart.subtotal = subTotal
        do {
            try context.save()
        }
        catch {
            showAlert(Title: "FAILED", Desc: "failure to create cart")
        }
    }

    //ACTIONS
    @IBAction func stepperChanged(_ sender: UIStepper) { /* when stepper is changed assign quantity and calculate the price when quantity changed */
        let values = Int(sender.value)
        qtyLabel.text = String(values)
        fieldDidChange()
    }
    
    @IBAction func addToCart(_ sender: UIButton) {
    /* setting frame to true/false depending on no frame or framed */
    if(self.frameTextField.text == "No Frame") {
        self.framed = false
    }
    else {
        self.framed = true
    }
    let price = self.priceLabel.text?.replacingOccurrences(of: "$", with: "") /* to transfer price to double replacing dollar with blankspace */
        self.insertToCart(frame: self.framed, item: self.itemNumber, quantity: Int(self.qtyLabel.text!)!, subTotal: Double(price!)!) // adding to cart
        let alert = UIAlertController(title: "SUCCESS!", message: "Item was successfully added in shopping cart", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) {
            (UIAlertAction) in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
