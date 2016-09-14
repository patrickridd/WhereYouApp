//
//  MessageTableViewCell.swift
//  WhereYouApp
//
//  Created by Patrick Ridd on 8/29/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    var loggedInUser: User?
    var userContact: User?
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var hasRespondedLabel: UILabel!
    @IBOutlet weak var timeResponded: UILabel!
    @IBOutlet weak var shouldRespondByLabel: UILabel!
    @IBOutlet weak var newMessageIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.doesRelativeDateFormatting = true
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    
    // Updates View with Message Details
    func updateWith(message: Message) {
        guard let user = UserController.sharedController.loggedInUser else {
            return
        }
        
        self.loggedInUser = user
        if message.sender.phoneNumber == user.phoneNumber {
            self.userContact = message.receiver
        } else {
            self.userContact = message.sender
        }
        if message.sender.name == nil || message.receiver.name == nil {
            contactName.text = "Deleted Contact"
            hasRespondedLabel.text = ""
            timeResponded.text = ""
            shouldRespondByLabel.text = ""
            return
            
        }
        
        guard let userContact = self.userContact else {
            print("No contact in MessageTableViewCell")
            return
        }
        
        // Set contactlabel and image to the name of the loggedInUser's contact
        let formatedPhoneNumber = NumberController.sharedController.formatPhoneForDisplay(userContact.phoneNumber)
        if userContact.phoneNumber == userContact.name {
            self.contactName.text = formatedPhoneNumber
        } else {
            self.contactName.text = userContact.name
        }
        
        self.profileImage.image = userContact.photo
        
        // Sender is looking at message that has not been responded to
        if message.timeResponded == nil && message.sender.phoneNumber == loggedInUser?.phoneNumber {
            updateWithWaitingForReceiverResponse(message)
        }
            // Receiver is looking at message that needs to be filled out and responded to
        else if message.timeResponded == nil && message.receiver.phoneNumber == loggedInUser?.phoneNumber {
            updateWithYouHaveANewMessage(message)
        }
            
            // Contact Responded to Logged In User's request.
        else if message.timeResponded != nil && message.receiver.phoneNumber != loggedInUser?.phoneNumber{
            updateWithContactRespondedToRequest(message)
        }
            // Logged In User responded to a message request
        else if message.timeResponded != nil && message.receiver.phoneNumber == loggedInUser?.phoneNumber {
            updateWithUserRespondedToContactsRequest(message)
        }
        
    }
    
    
    // Cell tells you that your request hasn't been responded to yet
    func updateWithWaitingForReceiverResponse(message: Message) {
        guard let userContact = userContact else {
            print("User's contact was nil")
            return
        }
        
        if userContact.name == userContact.phoneNumber {
        let formatedPhoneNumber = NumberController.sharedController.formatPhoneForDisplay(userContact.phoneNumber)
        hasRespondedLabel.text = "You sent \(formatedPhoneNumber) a CheckInTime"
        } else {
            hasRespondedLabel.text = "You sent \(userContact.name!) a CheckInTime"

        }
        
        if message.timeDue.timeIntervalSince1970 < NSDate().timeIntervalSince1970 {
            newMessageIcon.image = UIImage(named: "checkedInLate")
            hasRespondedLabel.text = "Time for \(userContact.name!) to CheckIn..."
            shouldRespondByLabel.textColor = .redColor()        } else {
            newMessageIcon.image = UIImage(named: "checkedInPending")
        }
        
        timeResponded.text = ""
        shouldRespondByLabel.text = "CheckInTime: \(dateFormatter.stringFromDate(message.timeDue))"
        
    }
    
    // Cell tells you your contact wants to know WhereYouApp
    func updateWithYouHaveANewMessage(message: Message) {
        guard let userContact = userContact else {
            print("User's contact was nil")
            return
        }
        timeResponded.text = ""
        
        if userContact.name == userContact.phoneNumber {
            let formatedPhoneNumber = NumberController.sharedController.formatPhoneForDisplay(userContact.phoneNumber)
           
            shouldRespondByLabel.text = "CheckInTime: \(dateFormatter.stringFromDate(message.timeDue))"
            hasRespondedLabel.text = "\(formatedPhoneNumber) wants you to CheckIn"
            
            if message.timeDue.timeIntervalSince1970 < NSDate().timeIntervalSince1970 {
                newMessageIcon.image = UIImage(named: "checkedInLate")
                hasRespondedLabel.text = "CheckIn with \(formatedPhoneNumber) now."
            } else {
                newMessageIcon.image = UIImage(named: "checkedInPending")
            }
            
        } else {
            
            shouldRespondByLabel.text = "CheckInTime: \(dateFormatter.stringFromDate(message.timeDue))"
            hasRespondedLabel.text = "\(userContact.name!) sent you a CheckInTime"
            if message.timeDue.timeIntervalSince1970 < NSDate().timeIntervalSince1970 {
                newMessageIcon.image = UIImage(named: "checkedInLate")
                hasRespondedLabel.text = "CheckIn with \(userContact.name!) now."
            } else {
                newMessageIcon.image = UIImage(named: "checkedInPending")
            }
        }
    }
    
    // Cell tells User that user's contact responded to WhereYouApp request
    func updateWithContactRespondedToRequest(message: Message) {
        guard let userContact = userContact else {
            print("User's contact was nil")
            return
        }
        if userContact.name == userContact.phoneNumber {
            let formatedPhoneNumber = NumberController.sharedController.formatPhoneForDisplay(userContact.phoneNumber)
            hasRespondedLabel.text = formatedPhoneNumber
            hasRespondedLabel.text = "\(formatedPhoneNumber) has CheckedIn."
            
        } else {
            hasRespondedLabel.text = "\(userContact.name!) has CheckedIn."
            newMessageIcon.image = UIImage(named: "checkedIn")

            
        }
        
        guard let checkInAt = message.timeResponded else {
            return
        }
        timeResponded.text = " CheckedIn at \(dateFormatter.stringFromDate(checkInAt))"
        
    }
    
    // Cell tell user that they responded to the contacts WhereYouApp request
    func updateWithUserRespondedToContactsRequest(message: Message) {
        guard let userContact = userContact, checkedInAt = message.timeResponded else {
            print("User's contact was nil")
            return
        }
        if userContact.name == userContact.phoneNumber{
            let formatedPhoneNumber = NumberController.sharedController.formatPhoneForDisplay(userContact.phoneNumber)
            hasRespondedLabel.text = "You CheckedIn with \(formatedPhoneNumber)"
        } else {
            hasRespondedLabel.text = "You CheckedIn with \(userContact.name!)"
        }
        newMessageIcon.image = UIImage(named: "checkedIn")

        timeResponded.text = "You CheckedIn \(dateFormatter.stringFromDate(checkedInAt))"
        shouldRespondByLabel.text = ""
    }
    
    
}
