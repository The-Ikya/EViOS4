//
//  ModalViewController.swift
//  EViOS4
//
//  Created by Mavrik on 10/10/2022.
//

import UIKit

protocol ModalDelegate {
    func addNewExpense(name: String, price: Float, date: Date, section: ExpenseSection)
}

class ModalViewController: UIViewController {
	
	@IBOutlet var saveButton: UIButton!
	@IBOutlet var itemNameField: UITextField!
	@IBOutlet var itemPriceField: UITextField!
	@IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var sectionsTableView: UITableView!
	
	var delegate: ModalDelegate? = nil
	var floatValue: Float = 0.0

    private var sections = [ExpenseSection]()
    private var selectedSection: ExpenseSection?

    override func viewDidLoad() {
        super.viewDidLoad()

		 saveButton.isEnabled = false

        let request = ExpenseSection.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            sections = try AppDelegate.shared.persistentContainer.viewContext.fetch(request)
        } catch {
            print(error)
        }
    }
	
	@IBAction func cancelButtonTapped() {
		self.dismiss(animated: true)
	}
	
	@IBAction func saveButtonTapped() {
		guard let myDelegate = delegate,
            let section = selectedSection
        else { return }
		
		myDelegate.addNewExpense(name: itemNameField.text!,
                                 price: floatValue,
                                 date: datePicker.date,
                                 section: section)
		
		self.dismiss(animated: true)
	}
	
	@IBAction func textFieldChanged() {
        checkForValidData()
	}

    private func checkForValidData() {
        if itemNameField.text != "",
           itemPriceField.text != "",
           selectedSection != nil {
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

extension ModalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell")!

        cell.textLabel?.text = sections[indexPath.row].name

        return cell
    }
}

extension ModalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSection = sections[indexPath.row]
        checkForValidData()
    }
}
