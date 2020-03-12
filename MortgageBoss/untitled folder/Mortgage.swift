//
//  Mortgage.swift
//  MortgageBoss
//
//  Created by Carl von Havighorst on 1/19/20.
//  Copyright © 2020 WestWood Tech LLC. All rights reserved.
//

import Foundation
import Coredata

//@objc(Mortgage)
class Mortgage: ManagedObjectContext {
    
    var propertyAddress: String?
    var payOffDate: Date?
    var firstPaymentDate: Date?
    var origLoanAmount: NSNumber?
    var anualRate: NSNumber?
    var loanTermYears: NSNumber?
    var extraPayment: NSNumber?

    func isValidForMinPayment -> Boolean {
        let origAmt = origLoanAmount != nil ? true : false
        let intRate = anualRate != nil ? true : false
        let loanTerm = loanTermYears != nil ? true : false
        return origAmt && intRate && loanTerm
    }
    
    func minPayment -> NSNumber? {
        return 1
    }
    
    func numPayments -> Int {
        return loanTermYears * 12
    }
}
