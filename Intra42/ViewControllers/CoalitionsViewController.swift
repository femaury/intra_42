//
//  CoalitionsViewController.swift
//  Intra42
//
//  Created by Felix Maury on 2019-06-30.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit
import SVGKit

class CoalitionsViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Coalitions"
        
        // Keeps navbar background color black in iOS 13
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemBackground
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
            
            activityIndicator.style = .large
        }

        if let cursusId = API42Manager.shared.userProfile?.mainCursusId,
            let campusId = API42Manager.shared.userProfile?.mainCampusId {
            loadCoalitionsScores(forCampusId: campusId, cursusId: cursusId)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    func loadCoalitionsScores(forCampusId campusId: Int, cursusId: Int) {
        let url = API42Manager.shared.baseURL + "blocs?filter[cursus_id]=\(cursusId)&filter[campus_id]=\(campusId)"
        API42Manager.shared.request(url: url) { [weak self] (data) in
            guard let safeSelf = self, let bloc = data?.array?.first else {
                let errorLabel = UILabel()
                errorLabel.text = "There was an error fetching coalitions data..."
                errorLabel.numberOfLines = 0
                self?.activityIndicator.isHidden = true
                self?.stackView.addArrangedSubview(errorLabel)
                return
            }
            
            let coalitions = bloc["coalitions"].arrayValue
            var coalitionViews: [CoalitionView] = []
            for coa in coalitions {
                let coverURL = coa["cover_url"].stringValue
                let colorHex = coa["color"].stringValue
                let coalitionView = CoalitionView(frame: CGRect(x: 0, y: 0, width: safeSelf.view.frame.width, height: 200.0))
                _ = coalitionView.backgroundImage.imageFrom(urlString: coverURL)
                coalitionView.name.text = coa["name"].stringValue
                coalitionView.scoreLabel.countFromZero(to: coa["score"].floatValue, duration: .brisk)
                coalitionView.name.textColor = UIColor(hexRGB: colorHex)
                coalitionView.scoreLabel.textColor = UIColor(hexRGB: colorHex)
                coalitionView.flagView.color = UIColor(hexRGB: colorHex) ?? .black
                coalitionView.score = coa["score"].intValue
                if let url: URL = URL(string: coa["image_url"].stringValue) {
                    URLSession.shared.dataTask(with: url) { (data, _, error) in
                        guard error == nil, let imgData = data else { return }
                        DispatchQueue.main.async {
                            coalitionView.logo.image = SVGKImage(data: imgData)?.uiImage
                        }
                    }.resume()
                }
                coalitionViews.append(coalitionView)
            }
            coalitionViews.sort(by: { $0.score > $1.score })
            for view in coalitionViews {
                safeSelf.stackView.addArrangedSubview(view)
            }
            safeSelf.activityIndicator.isHidden = true
        }
    }
}
