//
//  ViewController.swift
//  VMS_PhotoArts+
//  This Application allows a specific user to first create an account or login as guest. Then user can shop pictures from a collection of pictures and add frames to it if they want and add it to the cart. Then from the cart users can checkout and will be receiving an email after checking out plus. They can also update their information and see their previous purchasing history.Fetching data takes place using GCD
//  Created by Vijay Murugappan Subbiah on 11/4/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import UIKit
import CoreData //Importing core data for creating user and cart and history database

// Referencing collection view delegates and datasource
class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    //OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityAnimation:UIActivityIndicatorView!
    
    //OBJECT HANDLERS
    var photoClassObj = [PhotoClass]()
    
    //VARIABLES
    var userName = String()
    var largePic = UIImage()
    var smallPic = UIImage()
    var inactiveQueue: DispatchQueue!
    let queuePhotos = DispatchQueue(label: "edu.cs.niu.queuePhotoArts") // Creating a dispatch queue
    
    //VIEW DID LOAD - Default view when loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        if let queue = inactiveQueue { // Activates the queue at the application level
            queue.activate()
        }
        if userName == "Guest" { // If its a guest account disable the user details button
            self.navigationItem.rightBarButtonItems?[1].isEnabled = false
        }
        //Create a customer size for each of the image items in collectionview. each item is 1/2 of the width of the screen minus 5 points.
        let itemSize = UIScreen.main.bounds.width/2 - 5
        //Assigning object to class uicollectionviewflowlayout
        let layout = UICollectionViewFlowLayout()
        //custom layout to hold items in collection view
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        //set spacing between the items in collection view.
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        //after configuring the layout assign the layout to the collection view.
        collectionView.collectionViewLayout = layout
        queuePhotos.sync { // Executing simple sync queue to retreive data from web api
            getJSON() // retreiving data from web api
        }
        collectionView.reloadData() // reloading collection view data
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //VIEW DID APPEAR - View when it is prepared to display to the user
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        collectionView.reloadData() // reloading collection view data
    }
    
    //ACTION
    @IBAction func logoutClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "login", sender: self) // navigates back to the login view controller
    }

    //USER DEFINED FUNCTIONS
    func getJSON() {
        /* Making GET request to url and retreiving details of the pictures, parsing those json data and storing them in the model */
        let url = URL(string: "http://faculty.cs.niu.edu/~krush/ios/photoarts-json") //URL for the json data
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        activityAnimation.isHidden = false // bringing out the activity indicator
        activityAnimation.startAnimating() // start animating while fetching the data from url
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data,response,error) in
            self.activityAnimation.stopAnimating() // stops animating when the data is fetched from the url
            self.activityAnimation.isHidden = true // hiding back the activity indicator
            if error != nil { // if fetch error - error checking
                self.showAlert(Title: "CONNECTION ERROR", Desc: (error?.localizedDescription)!) // producing alert for error in connecting
            }
            else {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any] // json parsing the data received
                    let jsonArray = jsonObj["photoarts"] as! [[String:AnyObject]] //array
                    for jsonData in jsonArray { // dictionary in array
                        let item_name = jsonData["item_name"] as! String
                        let item_number = jsonData["item_number"] as! String
                        let large_image = jsonData["large_image"] as! String
                        let small_image = jsonData["small_image"] as! String
                        self.queuePhotos.sync { // Executing another simple sync queue to retreive images from web url
                            self.largePic = self.loadImagefromURL(_UrlString: large_image) //loading image from the url received
                            self.smallPic = self.loadImagefromURL(_UrlString: small_image)
                        }
                        self.photoClassObj.append(PhotoClass(name: item_name, number: item_number, largeImg: self.largePic, smallImg: self.smallPic)) // storing all the retreived information to the model class
                        DispatchQueue.main.async { // updating view using main queue
                            self.collectionView.reloadData() // reloading collection view data after storing
                        }
                    }
                }
                catch {
                    self.showAlert(Title: "JSON PARSING ERROR", Desc: error.localizedDescription) // producing alert for error in JSON parsing
                }
            }
        }
        task.resume() // resuming the data task
    }
    
    func loadImagefromURL(_UrlString:String) -> UIImage {
        /* loading image from the specified url string */
        let newurl = NSURL(string: _UrlString) // url of the image
        let urlData = NSData(contentsOf: newurl! as URL) // retreiving data from the url
        let urlImage = UIImage(data: urlData! as Data) // converting into image
        return urlImage! // returing the image from the url
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
    
    
    //COLLECTION VIEW DATASOURCE AND DELEGATE METHODS
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoClassObj.count // dynamic creation of items depending on model count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // 1 section in collection view
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PhotoCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! PhotoCollectionCell // custom cell
        let classHandler:PhotoClass = photoClassObj[indexPath.item] // object for the class
        cell.cellImage.image = classHandler.s_image
        cell.cellLabel.text = classHandler.itemNumber
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detail", sender: self)  // navigate to detail view if any cell is selected
    }
    
    // this function will get called before the control is handed over to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" { // if destination id is detail
        let destinationVC = segue.destination as! DetailViewController
            if let indexPath = collectionView.indexPathsForSelectedItems?.first { // getting collection view cell index
                let classHandler:PhotoClass = photoClassObj[indexPath.item] // object for class
                destinationVC.image = classHandler.l_image
                destinationVC.itemNumber = classHandler.itemNumber
                destinationVC.navigationItem.title = classHandler.itemName
                destinationVC.userName = userName
            }
        }
        else if segue.identifier == "cart" { // if destination id is cart
            let nav = segue.destination as! UINavigationController
            let cartVC = nav.viewControllers[0] as! CartViewController
            cartVC.userName = userName
        }
        else if segue.identifier == "login" { // if destination id is login
            if userName == "Guest" {
                clearGuestData()
            }
        }
        else {
            let profVC = segue.destination as! ProfileViewController
            profVC.username = userName
        }
    }
}

