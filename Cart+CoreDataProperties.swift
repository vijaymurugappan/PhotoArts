//
//  Cart+CoreDataProperties.swift
//  VMS_PhotoArts+
//
//  Created by Vijay Murugappan Subbiah on 11/4/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import Foundation
import CoreData


extension Cart {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cart> {
        return NSFetchRequest<Cart>(entityName: "Cart")
    }

    @NSManaged public var framed: Bool
    @NSManaged public var item: String?
    @NSManaged public var item_total: Int32
    @NSManaged public var price: Double
    @NSManaged public var quantity: Int32
    @NSManaged public var subtotal: Double
    @NSManaged public var toUser: User?

}
