//
//  CustomError.swift
//  Intra 42
//
//  Created by Felix Maury on 2019-02-27.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation

struct CustomError: Error {
    
    private(set) var title: String
    private(set) var description: String
    private(set) var code: Int
    
    init(title: String?, description: String, code: Int) {
        self.title = title ?? "Error"
        self.description = description
        self.code = code
    }
}
