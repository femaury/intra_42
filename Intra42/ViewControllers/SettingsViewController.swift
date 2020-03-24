//
//  SettingsViewController.swift
//  Intra42
//
//  Created by Felix Maury on 23/03/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    enum CollectionType {
        case color
        case icon
    }
    private var selectedCollectionType: CollectionType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "APPEARANCE"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "If your coalition's icon isn't available, "
                + "you can make a pull request on github to add it to the app."
        case 1:
            return "Reset your app icon and set your primary color to your coalition's primary color."
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "settingsCell")
        
        switch indexPath.section {
        case 0:
            let imageSize = CGSize(width: 25, height: 25)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Primary color"
                if let color = API42Manager.shared.preferedPrimaryColor {
                    cell.imageView?.image = UIImage(color: color, size: imageSize)
                    cell.imageView?.layer.cornerRadius = 5.0
                    cell.imageView?.clipsToBounds = true
                }
                cell.accessoryType = .disclosureIndicator
            case 1:
                if let name = UIApplication.shared.alternateIconName {
                    let image = UIImage(named: name)
                    cell.imageView?.image = image
                } else {
                    cell.imageView?.image = UIImage.appIcon
                }
                cell.textLabel?.text = "App icon"
                cell.imageView?.layer.cornerRadius = 5.0
                cell.imageView?.clipsToBounds = true
                cell.accessoryType = .disclosureIndicator
            default:
                break
            }
            
            // Resize ImageViews
            UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
            let imageRect = CGRect.init(origin: CGPoint.zero, size: imageSize)
            cell.imageView?.image?.draw(in: imageRect)
            cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        case 1:
            cell.textLabel?.text = "Reset appearance"
            cell.textLabel?.textColor = .red
            cell.accessoryType = .none
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                selectedCollectionType = .color
            case 1:
                selectedCollectionType = .icon
            default:
                return
            }
            performSegue(withIdentifier: "CollectionViewSegue", sender: self)
        case 1:
            let alertController = UIAlertController(
                title: "Reset",
                message: "Are you sure you want to reset the app's appearance?",
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "Reset", style: .destructive) { _ in
                UIApplication.shared.setAlternateIconName(nil)
                API42Manager.shared.preferedPrimaryColor = API42Manager.shared.coalitionColor
                tableView.reloadData()
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                tableView.deselectRow(at: indexPath, animated: true)
            }
            alertController.addAction(action)
            alertController.addAction(cancel)
            present(alertController, animated: true)
        default:
            return
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CollectionViewSegue", let type = selectedCollectionType {
            if let dest = segue.destination as? CollectionPickerController {
                dest.delegate = self
                switch type {
                case .color:
                    dest.dataSource = { refresh, completionHandler in
                        API42Manager.shared.getAllCoalitions { coalitions in
                            var items: [(title: String, items: [CollectionPickerItem])] = []
                            let groups = coalitions.count / 4
                            for countI in 0...groups - 1 {
                                items.append(("", items: []))
                                for countJ in 0...3 {
                                    let index = (countI * 4) + countJ
                                    let color = coalitions[index]["color"].stringValue
                                    items[countI].items.append((type, color))
                                }
                            }
                            completionHandler(items)
                        }
                    }
                case .icon:
                    dest.dataSource = { _, completionHandler in
                        let items: [CollectionPickerItem] = [
                            (type: type, value: "AppIconDefault"),
                            (type: type, value: "AppIconOrd"),
                            (type: type, value: "AppIconFed"),
                            (type: type, value: "AppIconAll"),
                            (type: type, value: "AppIconAss")
                        ]
                        completionHandler([("Paris", items)])
                    }
                }
            }
        }
    }
}

// MARK: - Collection Picker Delegate

extension SettingsViewController: CollectionPickerDelegate {
    
    func selectItem(_ item: CollectionPickerItem) {
        switch item.type {
        case .color:
            let color = UIColor(hexRGB: item.value)
            API42Manager.shared.preferedPrimaryColor = color
            setColorTo(color)
        case .icon:
            UIApplication.shared.setAlternateIconName(item.value == "AppIconDefault" ? nil : item.value)
        }
        tableView.reloadData()
    }
    
    private func setColorTo(_ color: UIColor?) {
        
        self.tabBarController?.tabBar.tintColor = color
        
        if let children = self.tabBarController?.children {
            for child in children {
                guard let navController = child as? UINavigationController else { continue }
                navController.navigationBar.tintColor = color
            }
        }
    }
}
