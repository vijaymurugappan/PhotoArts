//
//  PhotoClass.swift
//  VMS_PhotoArts+
//  This is the model class for the photo collection
//  Created by Vijay Murugappan Subbiah on 11/4/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import UIKit

class PhotoClass: NSObject {
    let itemName: String!
    let itemNumber: String!
    let l_image: UIImage!
    let s_image: UIImage!
    
    init(name: String, number: String, largeImg: UIImage, smallImg: UIImage) {
        itemName = name
        itemNumber = number
        l_image = largeImg
        s_image = smallImg
    }
}
