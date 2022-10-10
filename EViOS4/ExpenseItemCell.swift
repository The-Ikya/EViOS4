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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func setupCell(item: Expense) {
		itemName.text = item.name
		itemPrice.text = formattedCurrency(value: item.value)
	}
	
	private func formattedCurrency(value: Float) -> String? {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.usesGroupingSeparator = true
		formatter.locale = Locale.current
		
		return formatter.string(from: NSNumber(floatLiteral: Double(value)))
	}
}
