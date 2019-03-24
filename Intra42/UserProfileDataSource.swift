//
//  UserProfileDataSource.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-22.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

protocol UserProfileCell {
    var userId: Int { get set }
}

protocol UserProfileDataSource {
    
    var selectedCell: UserProfileCell? { get set }
    
    func showUserProfileController(atDestination destination: UserProfileController)
}

extension UserProfileDataSource {
    
    func showUserProfileController(atDestination destination: UserProfileController) {
        if let cell = self.selectedCell {
            API42Manager.shared.request(url: "https://api.intra.42.fr/v2/users/\(cell.userId)") { (data) in
                guard let data = data else { return }
                destination.userProfile = UserProfile(data: data)
                if let userId = destination.userProfile?.userId {
                    API42Manager.shared.getCoalitionInfoFor(userId: userId, completionHandler: { (name, color, logo) in
                        destination.coalitionName = name
                        destination.coalitionColor = color
                        destination.coalitionLogo = logo
                        destination.isLoadingData = false
                        destination.tableView.reloadData()
                    })
                }
            }
        }
    }
}
