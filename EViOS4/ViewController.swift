//
//  ViewController.swift
//  EViOS4
//
//  Created by Mavrik on 10/10/2022.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet var tableView: UITableView! {
		didSet {
			tableView.register(UINib(nibName: ExpenseItemCell.ID, bundle: .main), forCellReuseIdentifier: ExpenseItemCell.ID)
		}
	}
	
	private let appContext = AppDelegate.shared.persistentContainer.viewContext
	private var itemList = [Expense]() {
		didSet {
			tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		loadFromData()
	}
	
	@IBAction func addButtonTapped() {
		if let modal = storyboard?.instantiateViewController(withIdentifier: "ModalViewController") as? ModalViewController {
			modal.delegate = self
			self.present(modal, animated: true, completion: nil)
		}
	}
}

extension ViewController : UITableViewDelegate {
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		let itemToRemove = itemList[indexPath.row]
		
		appContext.delete(itemToRemove)
		
		saveData()
		loadFromData()
	}
}

extension ViewController : UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		itemList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseItemCell.ID, for: indexPath) as? ExpenseItemCell else { return ExpenseItemCell() }
		
		cell.setupCell(item: itemList[indexPath.row])
		
		return cell
	}
}

extension ViewController : ModalDelegate {
	func addNewExpense(name: String, price: Float, date: Date) {
		
		let newExpense = Expense(context: appContext)
		newExpense.name = name
		newExpense.value = price
		newExpense.date = date
		
		saveData()
		loadFromData()
	}
	
	private func loadFromData() {
		let request = Expense.fetchRequest()
		
		let orderByDate = NSSortDescriptor(key: "date", ascending: true)
		let orderByPrice = NSSortDescriptor(key: "value", ascending: true)
		request.sortDescriptors = [orderByDate, orderByPrice]
		
		if let newList = try? appContext.fetch(request) {
			itemList = newList
		}
	}
	
	private func saveData() {
		do {
			try appContext.save()
		}
		catch {
			appContext.rollback()
			print("Error while saving new item")
		}
	}
}

