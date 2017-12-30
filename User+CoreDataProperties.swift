//
//  User+CoreDataProperties.swift
//  VMS_PhotoArts+
//
//  Created by Vijay Murugappan Subbiah on 11/4/17.
//  Copyright © 2017 z1807314. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var password: String?
    @NSManaged public var username: String?
    @NSManaged public var toCart: Cart?

}
