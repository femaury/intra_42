//
//  Clusters.swift
//  Intra42
//
//  Created by Felix Maury on 10/03/2020.
//  Copyright © 2020 Felix Maury. All rights reserved.
//

import Foundation

struct ClusterPerson {
    var id: Int
    var name: String
}

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
    let hostSuffix: String?
    let map: [[ClusterPostInfo]]
    
    var capacity: Int {
        var count = 0
        for column in map {
            count += column.filter { $0.kind == "USER" }.count
        }
        return count
    }
}
