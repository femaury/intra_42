//
//  ClustersViewController.swift
//  Intra42
//
//  Created by Felix Maury on 19/02/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import UIKit

class ClustersViewController: UIViewController, ClustersViewDelegate, SideMenuCaller {

    private let availableCampusIDs = [1, 5, 7, 8, 9, 12, 14, 16, 17, 21, 28]
    let noClusterLabel = UILabel()
    let noClusterView = UIView()
    
    var clustersData: [ClusterData] = []
    var clustersView: ClustersView?
    var clusters: [String: ClusterPerson] = [:]
    var selectedCampus: (id: Int, name: String) = (0, "Cluster Maps") //Campus
    var selectedCell: UserProfileCell?
    var minZoomScale: CGFloat = 0.5
    
    @IBOutlet weak var headerSegment: UISegmentedControl!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewTop: NSLayoutConstraint!
    @IBOutlet weak var infoScrollview: UIScrollView!
    @IBOutlet weak var infoDragIndicator: UIView!
    @IBOutlet weak var infoStackview: UIStackView!
    
    enum InfoViewState {
        case hidden
        case half
        case full
    }
    private var currentInfoViewState: InfoViewState = .half
    private var halfInfoContentHeight: CGFloat = 0
    private let minInfoContentHeight: CGFloat = 30
    private var maxInfoViewTop: CGFloat {
        max(100, safeAreaHeight - infoContentHeight)
    }
    private var halfInfoViewTop: CGFloat {
        safeAreaHeight - (halfInfoContentHeight + 20)
    }
    private var minInfoViewTop: CGFloat {
        safeAreaHeight - minInfoContentHeight
    }
    private var infoContentHeight: CGFloat {
        CGFloat(clustersData.count * 55) + minInfoContentHeight
    }
    private var originalInfoViewTop: CGFloat = 0
    private var safeAreaHeight: CGFloat {
        infoView.frame.height + 100
    }
    
    // Array corresponding to infoStackView subviews containing user and friend count of cluster
    var occupancy: [(users: Int, friends: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Cluster Maps"
        noClusterView.backgroundColor = .white
        headerSegment.tintColor = API42Manager.shared.preferedPrimaryColor
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
            
            noClusterView.backgroundColor = .systemBackground
            headerSegment.selectedSegmentTintColor = API42Manager.shared.preferedPrimaryColor
        }
        
        infoScrollview.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
        infoDragIndicator.roundCorners(corners: .allCorners, radius: 2.0)
        
        showAcivityIndicator()
        
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
        
        func loadClusters(forId id: Int, name: String) {
            selectedCampus = (id, name)
            navigationItem.title = name
            if availableCampusIDs.contains(selectedCampus.id) {
                noClusterView.isHidden = true
                addNewClusterView()
            } else {
                hideAcivityIndicator()
            }
        }
        
        if let id = API42Manager.shared.userProfile?.mainCampusId, let name = API42Manager.shared.userProfile?.mainCampusName {
            loadClusters(forId: id, name: name)
        } else {
            let coverView = UIView(frame: view.frame)
            coverView.backgroundColor = .white
            if #available(iOS 13.0, *) {
                coverView.backgroundColor = .systemBackground
            }
            view.addSubview(coverView)
            API42Manager.shared.userProfileCompletionHandlers.append({ profile in
                coverView.removeFromSuperview()
                guard let profile = profile else {
                    self.hideAcivityIndicator()
                    return
                }
                let id = profile.mainCampusId, name = profile.mainCampusName
                loadClusters(forId: id, name: name)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13.0, *) {
            headerSegment.selectedSegmentTintColor = API42Manager.shared.preferedPrimaryColor
        } else {
            headerSegment.tintColor = API42Manager.shared.preferedPrimaryColor
        }
        for case let infoView as ClusterInfoView in infoStackview.arrangedSubviews {
            infoView.outerProgressBar.layer.borderColor = API42Manager.shared.preferedPrimaryColor?.cgColor
            infoView.innerProgressBar.backgroundColor = API42Manager.shared.preferedPrimaryColor
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    func addNewClusterView(firstCampusLoad load: Bool = true) {
        let id = selectedCampus.id
        if !load || getClustersData(forCampus: id) {
            var pos = headerSegment.selectedSegmentIndex
            if pos < 0 { pos = 0 }
            
            let data = clustersData[pos]
            let height = (data.map.first?.count ?? 0) * 60
            let width = data.map.count * 40
    
            clustersView?.removeFromSuperview()
            
            let clustersView = ClustersView(withData: clustersData, forPos: pos, width: width, height: height)
            self.clustersView = clustersView
            clustersView.delegate = self
            
            minZoomScale = (UIScreen.main.bounds.width / CGFloat(max(width, height))) * 0.95
            
            scrollView.contentSize = clustersView.frame.size
            scrollView.addSubview(clustersView)
            scrollView.minimumZoomScale = minZoomScale
            scrollView.maximumZoomScale = 4.0
            scrollView.zoomScale = minZoomScale
            
            let clusterHeight = CGFloat(height) * minZoomScale
            halfInfoContentHeight = safeAreaHeight - (clusterHeight + 100)

            if load {
                loadClusterLocations(forCampus: id)
                showInfoView(withState: .half)
            } else {
                self.clustersView?.locations = self.clusters
                self.clustersView?.setupLocations()
                hideAcivityIndicator()
            }
        }
    }
    
    func getClustersData(forCampus id: Int) -> Bool {
        if availableCampusIDs.contains(id) {
            let name = "cluster_map_campus_\(id)"
            print("Getting map: \(name)")
            if let path = Bundle.main.path(forResource: name, ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                    clustersData = try JSONDecoder().decode([ClusterData].self, from: data)

                    headerSegment.isHidden = clustersData.count < 2
                    headerSegment.removeAllSegments()
                    occupancy = []
                    for (index, cluster) in clustersData.enumerated() {
                        headerSegment.insertSegment(withTitle: cluster.nameShort, at: index, animated: false)
                        occupancy.append((0, 0))
                    }
                    headerSegment.selectedSegmentIndex = 0
                    return true
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            }
        }
        hideAcivityIndicator()
        noClusterView.isHidden = false
        return false
    }
    
    func loadClusterLocations(forCampus id: Int) {
        API42Manager.shared.getLocations(forCampusId: id, page: 1) { (data) in
            var clusters: [String: ClusterPerson] = [:]
            self.occupancy = Array(repeating: (0, 0), count: self.occupancy.count)
            
            print("LOCATION DATA")
            print(data)
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
            self.clustersView?.locations = clusters
            self.clustersView?.setupLocations()
            self.setupClusterInfo()
            self.navigationItem.rightBarButtonItems![0].isEnabled = true
            self.hideAcivityIndicator()
        }
    }
    
    func setupClusterInfo() {
        for case let infoView as ClusterInfoView in infoStackview.arrangedSubviews {
            infoView.removeFromSuperview()
        }
        if clustersData.isEmpty {
            infoView.isHidden = true
            return
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
            let progress = (Double(users) / Double(total) * Double(infoView.frame.width - 40))
            setClusterOccupancy(
                backBar: infoView.outerProgressBar,
                progressBar: infoView.innerProgressBar,
                progress: progress
            )
            infoStackview.addArrangedSubview(infoView)
        }
    }
    
    func setClusterOccupancy(backBar: UIView, progressBar: UIView, progress: Double) {
        progressBar.frame = CGRect(x: 0, y: 0, width: progress, height: Double(backBar.frame.height))
        progressBar.roundCorners(corners: [.topLeft, .bottomLeft], radius: 5.0)
        progressBar.backgroundColor = API42Manager.shared.preferedPrimaryColor
        backBar.layer.cornerRadius = 5.0
        backBar.layer.borderWidth = 1.0
        backBar.layer.borderColor = API42Manager.shared.preferedPrimaryColor?.cgColor
        backBar.clipsToBounds = true
    }

    @IBAction func clusterFloorChanged(_ sender: UISegmentedControl) {
        showAcivityIndicator()
        scrollView.setZoomScale(minZoomScale, animated: true)
        clustersView?.clearUserImages()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.addNewClusterView(firstCampusLoad: false)
            for case let infoView as ClusterInfoView in self.infoStackview.arrangedSubviews {
                infoView.isHidden = false
            }
        }
    }
    
    func refreshClusters() {
        showAcivityIndicator()
        hideInfoView()
        navigationItem.rightBarButtonItems![0].isEnabled = false
        clustersView?.clearUserImages()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loadClusterLocations(forCampus: self.selectedCampus.id)
            self.scrollView.setZoomScale(self.minZoomScale, animated: true)
            self.showInfoView(withState: .half)
        }
    }
    
    @IBAction func showOptions(_ sender: Any) {
        let optionsAction = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        let changeCampus = UIAlertAction(title: "Change campus", style: .default) { [weak self] (_) in
            guard let self = self else { return }
            let campusController = TablePickerController()
            campusController.modalPresentationStyle = .fullScreen
            campusController.delegate = self
            campusController.selectedItem = self.selectedCampus
            campusController.dataSource = { refresh, completionHandler in
                API42Manager.shared.getAllCampus(refresh: refresh) { campuses in
                    completionHandler(campuses.filter { self.availableCampusIDs.contains($0.id) })
                }
            }
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
    
    @IBAction func showSideMenu(_ sender: Any) {
        showSideMenu()
    }
}

// MARK: - Activity Indicator

extension ClustersViewController {
    
    private func showAcivityIndicator() {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        if #available(iOS 13.0, *) {
            activityIndicatorView.style = .medium
        }
        activityIndicatorView.startAnimating()
        navigationItem.titleView = activityIndicatorView
    }
    
    private func hideAcivityIndicator() {
        navigationItem.titleView = nil
    }
}

// MARK: - Draggable Info View Methods

extension ClustersViewController {
    
    @IBAction func panInfoView(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view).y
        let velocity = gesture.velocity(in: self.view).y
        
        switch gesture.state {
        case .began:
            originalInfoViewTop = infoViewTop.constant
        case .changed:
            let newTop = originalInfoViewTop + translation
            print("new top: \(newTop)")
            if newTop > -100 && newTop < minInfoViewTop {
                if newTop < safeAreaHeight - infoContentHeight {
                    print("-------- changing above content height")
                    let infoContentTop = safeAreaHeight - infoContentHeight
                    print(infoContentTop)
                    let extra = infoContentTop - newTop
                    print(extra)
                    infoViewTop.constant = extra == 1.0 ? newTop - 1 : infoContentTop - (extra / log(extra))
                } else {
                    print("-------- changing below content height")
                    infoViewTop.constant = newTop
                }
            }
        case .ended, .cancelled:
            let infoViewHeight = safeAreaHeight - infoViewTop.constant
            if infoViewTop.constant < maxInfoViewTop + 75 || velocity < -2000.0
                || infoViewTop.constant < halfInfoViewTop - 100 {
                let newHeight = safeAreaHeight - maxInfoViewTop
                let timeNeeded = Double(abs(newHeight - infoViewHeight) / velocity)
                showInfoView(withState: .full, withDuration: timeNeeded)
            } else if infoViewTop.constant < safeAreaHeight - 100 && velocity < 2000.0 {
                var diff = abs(halfInfoViewTop - infoViewHeight)
                if diff == 0 { diff = 0.1 }
                let timeNeeded = Double(diff / velocity)
                showInfoView(withState: .half, withDuration: timeNeeded)
            } else {
                let timeNeeded = Double(infoViewHeight / velocity)
                hideInfoView(withDuration: timeNeeded)
            }
        default:
            break
        }
    }
    
    @IBAction func tapInfoView(_ sender: UITapGestureRecognizer) {
        if infoViewTop.constant == minInfoViewTop {
            showInfoView(withState: .half)
        }
    }
    
    private func showInfoView(withState state: InfoViewState, withDuration duration: Double = 0.5) {
        switch state {
        case .half:
            if halfInfoViewTop > safeAreaHeight - infoContentHeight {
                infoViewTop.constant = halfInfoViewTop
            } else {
                fallthrough
            }
        case .full:
            infoViewTop.constant = maxInfoViewTop
        case .hidden:
            return
        }
        let duration = duration > 0.6 ? 0.6 : duration
        UIView.animate(withDuration: duration) {
            self.infoView.superview?.layoutIfNeeded()
        }
    }
    
    private func hideInfoView(withDuration duration: Double = 0.5) {
        stackViewBottom.constant = minInfoContentHeight
        infoViewTop.constant = minInfoViewTop
        let duration = duration > 0.6 ? 0.6 : duration
        UIView.animate(withDuration: duration) {
            self.infoView.superview?.layoutIfNeeded()
        }
        currentInfoViewState = .hidden
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
        navigationItem.title = item.name
        if availableCampusIDs.contains(item.id) {
            showAcivityIndicator()
            noClusterView.isHidden = true
            for case let infoView as ClusterInfoView in infoStackview.arrangedSubviews {
                infoView.removeFromSuperview()
            }
            addNewClusterView()
        } else {
            noClusterView.isHidden = false
        }
    }
}

// MARK: - Scroll View Delegate

extension ClustersViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return clustersView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        hideInfoView()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale == minZoomScale {
            showInfoView(withState: .half)
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: offsetX, bottom: 0, right: 0)
    }
}
