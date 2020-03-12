//
//  DetailViewController.swift
//  MortgageBoss
//
//  Created by Carl von Havighorst on 1/19/20.
//  Copyright © 2020 WestWood Tech LLC. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController : UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mortgagePayments.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTableHeaderView", for: indexPath)

            return cell
        }
        
        let mortg = self.mortgagePayments[indexPath.row-1]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTableCell", for: indexPath) as! PaymentCellView
        let formattedNum = String(mortg.paymentNumber)
        cell.paymentNumberLabel.text = formattedNum
        let formattedValue = String(format: "%.02f",mortg.paymentAmount)
        cell.paymentAmountLabel.text = formattedValue
        cell.dateLabel.text = "01/2012"//mortg.paymentDate
        let formattedPrincipalValue = String(format: "%.02f",mortg.remainingPrincipal)
        cell.principalLabel.text = formattedPrincipalValue

        return cell
    }
    
    
    var mortgage: Mortgage?
    var mortgagePayments: [MortgagePayment] = []
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var origLoanTextField: UITextField!
    @IBOutlet weak var annualRateTextField: UITextField!
    @IBOutlet weak var termTextField: UITextField!
    @IBOutlet weak var firstPaymentTextField: UITextField!
    @IBOutlet weak var extraPaymentTextField: UITextField!
    @IBOutlet weak var principalNowTextField: UITextField!
    @IBOutlet weak var interestNowTextField: UITextField!

    @IBOutlet weak var minPaymentTextField: UITextField!
    @IBOutlet weak var numPaymentsTextField: UITextField!
    @IBOutlet weak var totalPaidTextField: UITextField!
    @IBOutlet weak var totalInterestTextField: UITextField!
    @IBOutlet weak var payOffDateTextField: UITextField!
    @IBOutlet weak var interestSavingsTextField: UITextField!
    @IBOutlet weak var timeSavingsTextField: UITextField!
    
    @IBOutlet fileprivate var picker : DatePickerView!
    fileprivate var pickerFromCode : CDatePickerViewEx = CDatePickerViewEx.init(frame: CGRect.zero)
    
    @IBOutlet weak var paymentsTableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (mortgage == nil) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            mortgage = Mortgage(context:context)
        }
        self.paymentsTableView.isHidden = true

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    
        if (textField == self.addressTextField) {
            self.mortgage?.propertyAddress = self.addressTextField.text
        } else if (textField == self.origLoanTextField) {
            if let loanAmt = Double(self.origLoanTextField.text ?? "") {
                self.mortgage?.origLoanAmount = Double(truncating: NSNumber(value:loanAmt))
            }
        } else if (textField == self.annualRateTextField) {
            if let annualRate = Double(self.annualRateTextField.text ?? "") {
                self.mortgage?.annualFixedRate = Double(truncating: NSNumber(value:annualRate))
            }
        } else if (textField == self.termTextField ) {
            if let term = Double(self.termTextField.text ?? "") {
                self.mortgage?.loanTermYears = Double(truncating: NSNumber(value:term))
                self.numPaymentsTextField.text = String(Int16(Double(truncating: NSNumber(value:term))) * 12)
            } else {
                self.termTextField.text = ""
                self.mortgage?.loanTermYears = 0
                self.numPaymentsTextField.text = ""
                //self.
            }
        } else if (textField == self.extraPaymentTextField ) {
            if let extraPay = Double(self.extraPaymentTextField.text ?? "") {
                self.mortgage?.extraPayment = Double(truncating: NSNumber(value:extraPay))
            }
        } else if (textField == self.principalNowTextField ) {
            if let principalNow = Double(self.principalNowTextField.text ?? "") {
                self.mortgage?.currentUpdatedPrincipal = Double(truncating: NSNumber(value:principalNow))
            }
        } else if (textField == self.interestNowTextField) {
            if let interestPaidNow = Double(self.interestNowTextField.text ?? "") {
                self.mortgage?.interestPaid = Double(truncating: NSNumber(value:interestPaidNow))
            }
        }
        
        if (self.annualRateTextField.text != nil &&
            self.origLoanTextField.text != nil &&
            self.termTextField.text != nil ) { // we can compute min payment!
            let monthlyInterestRate : Double = ((self.mortgage?.annualFixedRate ?? 1)/100)/12
            let loanTermMonths = (self.mortgage?.loanTermYears ?? 0)*12
            let origAmt = self.mortgage?.origLoanAmount ?? 0
            let base : Double = 1+monthlyInterestRate
            let power = Int16(loanTermMonths)
            if (power == 0) { return }
            if (monthlyInterestRate == 0 ) { return }
            var answer1 = 1.0
            for _ in 1...power {
                answer1 = answer1 * base
            }
            let discLeft = (answer1-1)
            let discRight = answer1*monthlyInterestRate
            let discountFactor = (discLeft/discRight)
            let minPayment = (self.mortgage?.origLoanAmount ?? 1)/discountFactor

            let formattedValue = String(format: "%.02f",minPayment)
            self.mortgage?.minPayment = minPayment
            self.mortgage?.discountFactor = discountFactor
            self.mortgage?.periodicInterest = monthlyInterestRate
            self.minPaymentTextField.text = String(formattedValue)
            let formattedPaidValue = String(format: "%.02f",minPayment * (self.mortgage?.loanTermYears ?? 0)*12)
            let totalInterest = (minPayment * (self.mortgage?.loanTermYears ?? 0)*12 ) - origAmt
            let formattedInterestValue = String(format: "%.02f",totalInterest)

            self.totalPaidTextField.text = formattedPaidValue
            self.totalInterestTextField.text = formattedInterestValue
            
            self.mortgagePayments = generatePayments()
            self.paymentsTableView.reloadData()
            self.paymentsTableView.isHidden = false
        }
        
    }
    
    @IBAction func showDatePicker(_ sender: UIButton) {
        
        picker.minYear = 1990
        picker.maxYear = 2022
        picker.rowHeight = 60
        
        picker.selectToday()
        //picker.selectRow(50, inComponent: 1, animated: false)
        //picker.selectRow(500, inComponent: 0, animated: false)
        
        picker.isHidden = false
        /*var frame = picker.bounds
        frame.origin.y = picker.frame.size.height
        pickerFromCode.frame = frame
        
        view.addSubview(pickerFromCode)
        pickerFromCode.selectToday()*/
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func generatePayments() -> [MortgagePayment] {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        var payments: [MortgagePayment] = []
        var leftoverPrincipal: Double = self.mortgage?.origLoanAmount ?? 0
        var numPayments : Int16 = 1
        var crtInterestPaid = leftoverPrincipal * (self.mortgage?.periodicInterest ?? 0)
        while leftoverPrincipal > 0 {
            let payment : MortgagePayment = MortgagePayment(context:context)
            payment.paymentDate = Date()
            if( leftoverPrincipal < self.mortgage?.minPayment ?? 0){
                payment.paymentAmount = leftoverPrincipal
            } else {
                payment.paymentAmount = self.mortgage?.minPayment ?? 0
            }
            payment.paymentNumber = numPayments
            numPayments += 1
            payment.interestPaid = crtInterestPaid
            leftoverPrincipal = leftoverPrincipal - payment.paymentAmount
            if(leftoverPrincipal > 0){
                leftoverPrincipal = leftoverPrincipal + crtInterestPaid
                crtInterestPaid = leftoverPrincipal * (self.mortgage?.periodicInterest ?? 0)
            }
            payment.remainingPrincipal = leftoverPrincipal
            payments.append(payment)
        }
        
        return payments
    }
}

class PaymentCellView : UITableViewCell {
    
    @IBOutlet weak var paymentNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var paymentAmountLabel: UILabel!
    @IBOutlet weak var paymentAmountButton: UIButton!
    @IBOutlet weak var principalLabel: UILabel!
}
