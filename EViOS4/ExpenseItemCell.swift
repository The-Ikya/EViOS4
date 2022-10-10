//
//  ExpenseItemCell.swift
//  EViOS4
//
//  Created by Mavrik on 10/10/2022.
//

import UIKit

class ExpenseItemCell: UITableViewCell {
	
	static let ID = "ExpenseItemCell"
	
	@IBOutlet var itemName: UILabel!
	@IBOutlet var itemPrice: UILabel!
	
	private var expenseItem: Expense! {
		didSet {
			itemName.text = expenseItem.name
			itemPrice.text = formattedCurrency(value: expenseItem.value)
		}
	}
	
	func setupCell(item: Expense) {
		expenseItem = item
	}
	
	private func formattedCurrency(value: Float) -> String? {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.usesGroupingSeparator = true
		formatter.locale = Locale.current
		
		return formatter.string(from: NSNumber(floatLiteral: Double(value)))
	}
}
