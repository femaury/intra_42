//
//  ClustersViewController.swift
//  Intra42
//
//  Created by Felix Maury on 19/02/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

struct ClusterPostInfo: Decodable {
    let kind: String
    let host: String?
    let label: String?
}

struct ClusterData: Decodable {
    let position: Int
    let campusId: Int
    let name: String
    let nameShort: String
    let hostPrefix: String
    let map: [[ClusterPostInfo]]
    
    var capacity: Int {
        var count = 0
        for column in map {
            count += column.filter { $0.kind == "USER" }.count
        }
        return count
    }
}

class ClustersViewController: UIViewController, ClustersViewDelegate {

    private let availableCampusIDs = [1]
    let noClusterLabel = UILabel()
    let noClusterView = UIView()
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    let scrollViewContent = UIView()
    
    var clustersData: [ClusterData] = []
    var clustersView: ClustersView?
    var clusters: [String: ClusterPerson] = [:]
    var selectedCampus: (id: Int, name: String) = (0, "") //Campus
    var selectedCell: UserProfileCell?
    var minZoomScale: CGFloat = 0.5
    
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet weak var headerSegment: UISegmentedControl!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoStackView: UIStackView!
    // Array corresponding to infoStackView subviews containing user and friend count of cluster
    var occupancy: [(users: Int, friends: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cluster Maps"
        noClusterView.backgroundColor = .white
        headerSegment.tintColor = API42Manager.shared.preferedPrimaryColor
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
            
            activityIndicator.style = .medium
            noClusterView.backgroundColor = .systemBackground
            headerSegment.selectedSegmentTintColor = API42Manager.shared.preferedPrimaryColor
        }
        
        noClusterView.frame = view.frame
        noClusterLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width - 40, height: 200)
        noClusterLabel.text = """
        
        Sorry, this campus' map is not available yet...
        
        Feel free to open an issue on github or contact me to help speed up the process!
        """
        noClusterLabel.textAlignment = .center
        noClusterLabel.numberOfLines = 0
        noClusterView.addSubview(noClusterLabel)
        noClusterLabel.center = noClusterView.convert(noClusterView.center, from: noClusterLabel)
        view.addSubview(noClusterView)
        
        if let id = API42Manager.shared.userProfile?.mainCampusId, let name = API42Manager.shared.userProfile?.mainCampusName {
            selectedCampus = (id, name)
            title = name
            noClusterLabel.text = name + (noClusterLabel.text ?? "")
            if availableCampusIDs.contains(selectedCampus.id) {
                noClusterView.isHidden = true
                addNewClusterView()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13.0, *) {
            headerSegment.selectedSegmentTintColor = API42Manager.shared.preferedPrimaryColor
        } else {
            headerSegment.tintColor = API42Manager.shared.preferedPrimaryColor
        }
        for case let infoView as ClusterInfoView in infoStackView.arrangedSubviews {
            infoView.outerProgressBar.layer.borderColor = API42Manager.shared.preferedPrimaryColor?.cgColor
            infoView.innerProgressBar.backgroundColor = API42Manager.shared.preferedPrimaryColor
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    func addNewClusterView() {
        let id = selectedCampus.id
        if getClustersData(forCampus: id) {
            for sub in scrollViewContent.subviews {
                sub.removeFromSuperview()
            }
            for sub in scrollView.subviews {
                sub.removeFromSuperview()
            }
            
            var pos = headerSegment.selectedSegmentIndex
            if pos < 0 { pos = 0 }
            
            let data = clustersData[pos]
            var highestCol = 0
            for col in data.map {
                highestCol = col.count > highestCol ? col.count : highestCol
            }
            let height = highestCol * 60
            let width = data.map.count * 40
            
            let clustersView = ClustersView(withData: clustersData, forPos: pos, width: width, height: height)
            self.clustersView = clustersView
            clustersView.delegate = self
            
            minZoomScale = UIScreen.main.bounds.width / CGFloat(width)
            
            scrollViewContent.frame = clustersView.frame
            scrollViewContent.addSubview(clustersView)
            
            scrollView.contentSize = scrollViewContent.frame.size
            scrollView.addSubview(scrollViewContent)
            scrollView.minimumZoomScale = minZoomScale
            scrollView.maximumZoomScale = 4.0
            scrollView.zoomScale = minZoomScale
            
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            headerStackView.addArrangedSubview(activityIndicator)
            loadClusterLocations()
        }
    }
    
    func getClustersData(forCampus id: Int) -> Bool {
        if availableCampusIDs.contains(id) {
            let name = "cluster_map_campus_\(id)"
            if let path = Bundle.main.path(forResource: name, ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                    clustersData = try JSONDecoder().decode([ClusterData].self, from: data)
                    print("jsonData: \(clustersData)")
                    if clustersData.count < 2 {
                        headerSegment.isHidden = true
                    }
                    headerSegment.removeAllSegments()
                    for (index, cluster) in clustersData.enumerated() {
                        headerSegment.insertSegment(withTitle: cluster.nameShort, at: index, animated: false)
                        occupancy.append((0, 0))
                    }
                    headerSegment.selectedSegmentIndex = 0
                    return true
                } catch let error {
                    print("ERROR: json parsing - \(error.localizedDescription)")
                }
            }
        }
        noClusterView.isHidden = false
        return false
    }
    
    func loadClusterLocations() {
        API42Manager.shared.getLocations(forCampusId: 1, page: 1) { (data) in
            var clusters: [String: ClusterPerson] = [:]
            
            for location in data {
                let host = location["host"].stringValue
                let name = location["user"]["login"].stringValue
                let id = location["user"]["id"].intValue
                
                for (index, cluster) in self.clustersData.enumerated() {
                    if host.contains(cluster.hostPrefix) {
                        self.occupancy[index].users += 1
                        if FriendDataManager.shared.hasFriend(withId: id) {
                            self.occupancy[index].friends += 1
                        }
                    }
                }
                clusters.updateValue(ClusterPerson(id: id, name: name), forKey: host)
            }
            self.clusters = clusters
            self.clustersView?.setupLocations(withUsers: clusters)
            self.setupClusterInfo()
            self.navigationItem.rightBarButtonItems![0].isEnabled = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    func setupClusterInfo() {
        for sub in infoStackView.arrangedSubviews {
            sub.removeFromSuperview()
        }
        for case let (index, cluster) in clustersData.enumerated() {
            let infoView = ClusterInfoView()
            let friends = occupancy[index].friends
            let friendText = "\(friends) friend\(friends == 1 ? "" : "s")"
            let users = occupancy[index].users
            let total = cluster.capacity
            let progText = "\(users)/\(total)"
            infoView.friendsLabel.text = friendText
            infoView.nameLabel.text = cluster.name
            infoView.progressLabel.text = progText
            let progress = (Double(users) / Double(total) * Double(infoStackView.frame.width))
            setClusterOccupancy(
                backBar: infoView.outerProgressBar,
                progressBar: infoView.innerProgressBar,
                progress: progress
            )
            infoStackView.addArrangedSubview(infoView)
        }
    }
    
    func setClusterOccupancy(backBar: UIView, progressBar: UIView, progress: Double) {
        progressBar.frame = CGRect(x: 0, y: 0, width: progress, height: Double(backBar.frame.height))
        progressBar.roundCorners(corners: [.topLeft, .bottomLeft], radius: 5.0)
        progressBar.backgroundColor = API42Manager.shared.preferedPrimaryColor
        backBar.layer.cornerRadius = 5.0
        backBar.layer.borderWidth = 1.0
        backBar.layer.borderColor = API42Manager.shared.preferedPrimaryColor?.cgColor
    }
    
    @IBAction func clusterFloorChanged(_ sender: UISegmentedControl) {
        clustersView?.clearUserImages()
        clustersView?.changePosition(to: sender.selectedSegmentIndex)
    }
    
    func refreshClusters() {
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItems![0].isEnabled = false
        clustersView?.clearUserImages()
        loadClusterLocations()
    }
    
    @IBAction func showOptions(_ sender: Any) {
        let optionsAction = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        let changeCampus = UIAlertAction(title: "Change campus", style: .default) { [weak self] (_) in
            guard let self = self else { return }
            let campusController = TablePickerController()
            campusController.modalPresentationStyle = .fullScreen
            campusController.delegate = self
            campusController.selectedItem = self.selectedCampus
            campusController.dataSource = API42Manager.shared.getAllCampus
            _ = campusController.view
            self.navigationController?.pushViewController(campusController, animated: true)
        }
        let refresh = UIAlertAction(title: "Refresh", style: .destructive) { [weak self] (_) in
            self?.refreshClusters()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        optionsAction.addAction(changeCampus)
        optionsAction.addAction(refresh)
        optionsAction.addAction(cancel)
        present(optionsAction, animated: true, completion: nil)
    }
}

// MARK: - Prepare for segue

extension ClustersViewController: UserProfileDataSource {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserProfileSegue" {
            if let destination = segue.destination as? UserProfileController {
                showUserProfileController(atDestination: destination)
            }
        }
    }
}

// MARK: - Table Picker Delegate

extension ClustersViewController: TablePickerDelegate {
    
    func selectItem(_ item: TablePickerItem) {
        selectedCampus = item
        title = item.name
        if availableCampusIDs.contains(item.id) {
            noClusterView.isHidden = true
            addNewClusterView()
        } else {
            noClusterView.isHidden = false
            noClusterLabel.text = item.name
                + "\n\nSorry, this campus' map is not available yet... Feel free to open an issue on github to help speed up the process!"
        }
    }
}

// MARK: - Scroll View Delegate

extension ClustersViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollViewContent
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        infoStackView.isHidden = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale == minZoomScale {
            infoStackView.isHidden = false
        }
    }
}
