//
//  ModalViewController.swift
//  EViOS4
//
//  Created by Mavrik on 10/10/2022.
//

import UIKit

protocol ModalDelegate {
	func addNewExpense(name: String, price: Float, date: Date)
}

class ModalViewController: UIViewController {
	
	@IBOutlet var saveButton: UIButton!
	@IBOutlet var itemNameField: UITextField!
	@IBOutlet var itemPriceField: UITextField!
	@IBOutlet var datePicker: UIDatePicker!
	
	var delegate: ModalDelegate? = nil
	var floatValue: Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

		 saveButton.isEnabled = false
    }
	
	@IBAction func cancelButtonTapped() {
		self.dismiss(animated: true)
	}
	
	@IBAction func saveButtonTapped() {
		guard let myDelegate = delegate else { return }
		
		myDelegate.addNewExpense(name: itemNameField.text!, price: floatValue, date: datePicker.date)
		
		self.dismiss(animated: true)
	}
	
	@IBAction func textFieldChanged() {
		if itemNameField.text != "" && itemPriceField.text != "" {
			saveButton.isEnabled = isFloat(str: itemPriceField.text)
		}
		else {
			saveButton.isEnabled = false
		}
	}
	
	private func isFloat(str: String?) -> Bool {
		if let floatValue = Float(str ?? "") {
			self.floatValue = floatValue
			return true
		}
		return false
	}
}
