//
//  User.swift
//  WhereYouApp
//
//  Created by Patrick Ridd on 8/30/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CloudKit

let NewContactAdded = "NewContactAdded"


class User: NSManagedObject {

    static let recordType = "User"
    static let nameKey = "name"
    static let phoneNumberKey = "phoneNumber"
    static let imageKey = "image"
    static let contactsKey = "contacts"
    static let messagesKey = "messages"
    
    var contactReferences: [CKReference] = []
    var messageReferences: [CKReference] = []
    var contacts = [User]() {
        didSet {
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName(NewContactAdded, object: nil)
        }
    }
    
    var record: CKRecord? {
        guard let data = ckRecordID, let ckRecord = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CKRecord else {
            return nil
        }
        return ckRecord
    }
    var cloudKitReference: CKReference? {
        guard let record = self.record else {
            return nil
        }
        let reference = CKReference(recordID: record.recordID, action: .DeleteSelf)
        return reference
    }

// Insert code here to add functionality to your managed object subclass
    convenience init(name: String , phoneNumber: String, imageData: NSData, insertIntoManagedObjectContext context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.imageData = imageData
        self.timeCreated = NSDate()
    
    }
    
    
    
    var photo: UIImage {
           guard let image = UIImage(data: imageData) else {
                if let profileImage = UIImage(named: "profile") {
                    return profileImage
                }
                return UIImage()
        }
        
        return image
    }
    
    var temporaryPhotoURL: NSURL {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension("jpg")
        imageData.writeToURL(fileURL, atomically: true)
        
        return fileURL
    }
    
    var imageAsset: CKAsset {
        let asset = CKAsset(fileURL: self.temporaryPhotoURL)
        return asset
    }

    /////////////// CloudKit Initializer ////////////////
    
 
    convenience init?(record: CKRecord) {
        guard let name = record[User.nameKey] as? String,
            phoneNumber = record[User.phoneNumberKey] as? String,
            image = record[User.imageKey] as? CKAsset else {
                return nil
        }
        
        let context = Stack.sharedStack.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.ckRecordID = NSKeyedArchiver.archivedDataWithRootObject(record)
        guard let photoData = NSData(contentsOfURL: image.fileURL) else {
            self.imageData = NSData()
            return
        }
        self.imageData = photoData
    
       
    }
    
}
