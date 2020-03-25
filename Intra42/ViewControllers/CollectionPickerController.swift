//
//  CollectionPickerController.swift
//  Intra42
//
//  Created by Felix Maury on 24/03/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

typealias CollectionPickerItem = (type: SettingsViewController.CollectionType, value: String)
typealias CollectionPickerDataSource = (Bool, @escaping ([(title: String, items: [CollectionPickerItem])]) -> Void) -> Void

protocol CollectionPickerDelegate: class {
    func selectItem(_ item: CollectionPickerItem)
}

class CollectionPickerController: UICollectionViewController {

    private let reuseIdentifier = "CollectionImageCell"
    private let headerReuseIdentifier = "CollectionHeader"
    private let activityView = UIActivityIndicatorView(style: .gray)
    
    weak var delegate: CollectionPickerDelegate?
    var dataSource: CollectionPickerDataSource?
    
    var items: [(title: String, items: [CollectionPickerItem])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            activityView.style = .large
        }
        self.edgesForExtendedLayout = []
        
        view.addSubview(activityView)
        activityView.hidesWhenStopped = true
        activityView.center = view.center
        activityView.startAnimating()

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        collectionView.collectionViewLayout = layout
        loadCollectionPickerItems()
    }
    
    func loadCollectionPickerItems(refresh: Bool = false) {
        guard let dataSource = dataSource else { return }
        dataSource(refresh) { [weak self] items in
            self?.items = items
            self?.activityView.stopAnimating()
            self?.collectionView.reloadData()
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items[section].items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = collectionView
                .dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! CollectionHeader
            let item = items[indexPath.section]
            sectionHeader.textLabel.text = item.title
            return sectionHeader
        } else {
            return UICollectionReusableView()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionImageCell
        let item = items[indexPath.section].items[indexPath.row]
        var isSelected = false
        switch item.type {
        case .icon:
            let image = UIImage(named: item.value)
            cell.imageView.image = image
            let iconName = UIApplication.shared.alternateIconName
            isSelected = item.value == iconName ?? "AppIconDefault"
        case .color:
            let color: UIColor = UIColor(hexRGB: item.value) ?? .clear
            let image = UIImage(color: color, size: CGSize(width: 50, height: 50))
            cell.imageView.image = image
            isSelected = API42Manager.shared.preferedPrimaryColor == color
        }
    
        if isSelected {
            cell.imageView.layer.borderWidth = 3
            cell.imageView.layer.borderColor = Colors.Warning.orange?.cgColor
        } else {
            cell.imageView.layer.borderWidth = 0
        }
        cell.imageView?.layer.cornerRadius = 10.0
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        let item = items[indexPath.section].items[indexPath.row]
        delegate.selectItem(item)
        self.navigationController?.popViewController(animated: true)
    }
}

extension CollectionPickerController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellCount = CGFloat(items[section].items.count)

        if cellCount > 0 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
            let totalCellWidth = cellWidth * cellCount
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right

            if totalCellWidth < contentWidth {
                let padding = (contentWidth - totalCellWidth) / 2.0
                return UIEdgeInsets(top: 10, left: padding, bottom: 10, right: padding)
            } else {
                return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            }
        }
        return UIEdgeInsets.zero
    }
    
    // Uncomment to show headers once coalitions can be sorted by campus/cursus
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        referenceSizeForHeaderInSection section: Int) -> CGSize {
//
//        return CGSize(width: collectionView.frame.width, height: 30)
//    }
}
