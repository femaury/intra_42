//
//  LogsTableCell.swift
//  Intra42
//
//  Created by Felix Maury on 2019-03-08.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import UIKit

class LocationLog {
    var day: String
    var logs: [(location: String, time: String)]
    
    init(day: String, logs: [(String, String)]) {
        self.day = day
        self.logs = logs
    }
}

class LogsTableCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    var subMenuTable: UITableView?
    var locationLogs: [LocationLog] = [] {
        didSet {
            subMenuTable?.reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpTable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpTable()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        subMenuTable?.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
    }
    
    func setUpTable() {
        subMenuTable = UITableView(frame: .zero, style: .plain)
        subMenuTable?.delegate = self
        subMenuTable?.dataSource = self
        subMenuTable?.allowsSelection = false
        self.addSubview(subMenuTable!)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return locationLogs.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return locationLogs[section].day
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationLogs[section].logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let log = locationLogs[indexPath.section].logs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "LogCell")
        cell.textLabel?.text = log.location
        cell.detailTextLabel?.text = log.time
        return cell
    }
}
