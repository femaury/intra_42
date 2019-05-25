//
//  UserActions.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-22.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class UserActions {
    
    let removeFriend = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let call = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let email = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    init(removeFriendClosure: ((UIAlertAction) -> Void)?, cancelClosure: ((UIAlertAction) -> Void)?) {
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelClosure)
        
        // Remove friend actions
        
        let delAction = UIAlertAction(title: "Remove friend", style: .destructive, handler: removeFriendClosure)
        delAction.setValue(UIImage(named: "trash"), forKey: "image")
        
        removeFriend.addAction(delAction)
        removeFriend.addAction(cancel)
        
        // Calling actions
        
        let callAction = UIAlertAction(title: "Call", style: .default) { (_) in
            guard let phoneNumber = self.call.title else { return }
            if phoneNumber.isPhoneNumber, let phoneURL = URL(string: "tel://\(phoneNumber)") {
                if UIApplication.shared.canOpenURL(phoneURL) {
                    UIApplication.shared.open(phoneURL)
                }
            }
        }
        callAction.setValue(UIImage(named: "phone"), forKey: "image")
        
        let textAction = UIAlertAction(title: "Send message", style: .default) { (_) in
            guard let phoneNumber = self.call.title else { return }
            if phoneNumber.isPhoneNumber, let smsURL = URL(string: "sms:\(phoneNumber)") {
                if UIApplication.shared.canOpenURL(smsURL) {
                    UIApplication.shared.open(smsURL)
                }
            }
        }
        textAction.setValue(UIImage(named: "speech_bubble"), forKey: "image")
        
        let copyNumberAction = UIAlertAction(title: "Copy", style: .default) { (_) in
            UIPasteboard.general.string = self.call.title
        }
        copyNumberAction.setValue(UIImage(named: "copy"), forKey: "image")
        
        call.addAction(callAction)
        call.addAction(textAction)
        call.addAction(copyNumberAction)
        call.addAction(cancel)
        
        // Email Actions
        
        let emailAction = UIAlertAction(title: "Send email", style: .default) { (_) in
            guard let phoneNumber = self.email.title else { return }
            if phoneNumber.isPhoneNumber, let mailURL = URL(string: "mailto:\(phoneNumber)") {
                if UIApplication.shared.canOpenURL(mailURL) {
                    UIApplication.shared.open(mailURL)
                }
            }
        }
        emailAction.setValue(UIImage(named: "message"), forKey: "image")
        
        let copyEmailAction = UIAlertAction(title: "Copy", style: .default) { (_) in
            UIPasteboard.general.string = self.email.title
        }
        copyEmailAction.setValue(UIImage(named: "copy"), forKey: "image")
        
        email.addAction(emailAction)
        email.addAction(copyEmailAction)
        email.addAction(cancel)
    }
}
