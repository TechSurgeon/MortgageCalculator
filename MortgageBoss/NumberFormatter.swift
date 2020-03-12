//
//  NumberFormatter.swift
//  MortgageBoss
//
//  Created by Carl von Havighorst on 1/19/20.
//  Copyright © 2020 WestWood Tech LLC. All rights reserved.
//

import Foundation

extension Int {
    func format(f: String) -> String {
        return String(format: "%\(f)d", self)
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

