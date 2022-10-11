//
//  ViewController.swift
//  EViOS4
//
//  Created by Mavrik on 10/10/2022.
//

import CoreData
import UIKit

class ViewController: UIViewController {
	
	@IBOutlet var tableView: UITableView! {
		didSet {
			tableView.register(UINib(nibName: ExpenseItemCell.ID, bundle: .main), forCellReuseIdentifier: ExpenseItemCell.ID)
		}
	}
	
	private let appContext = AppDelegate.shared.persistentContainer.viewContext
    private var controller: NSFetchedResultsController<Expense>!

	override func viewDidLoad() {
		super.viewDidLoad()

        if !UserDefaults.standard.bool(forKey: "sectionsHaveBeenCreated") {

            let context = AppDelegate.shared.persistentContainer.viewContext

            let section1 = ExpenseSection(context: context)
            section1.name = "Section 1"
            let section2 = ExpenseSection(context: context)
            section2.name = "Section 2"

            AppDelegate.shared.saveContext()

            UserDefaults.standard.set(true, forKey: "sectionsHaveBeenCreated")
        }
		
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
        guard let sectionExpense = controller.sections?[indexPath.section].objects?[indexPath.row] as? Expense
        else { return }

		appContext.delete(sectionExpense)

		saveData()
		loadFromData()
	}
}

extension ViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        controller.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        controller.sections?[section].name ?? ""
    }

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        controller.sections?[section].numberOfObjects ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseItemCell.ID, for: indexPath) as? ExpenseItemCell else { return ExpenseItemCell() }

        let sectionExpense = controller.sections?[indexPath.section].objects?[indexPath.row] as? Expense
		
		cell.setupCell(item: sectionExpense!)
		
		return cell
	}
}

extension ViewController : ModalDelegate {
    func addNewExpense(name: String, price: Float, date: Date, section: ExpenseSection) {
		
		let newExpense = Expense(context: appContext)
		newExpense.name = name
		newExpense.value = price
		newExpense.date = date
        newExpense.section = section
		
		saveData()
		loadFromData()
	}
	
	private func loadFromData() {
		let request = Expense.fetchRequest()

        /// Vu que l'on utilise un NSFetchedResultsController,
        /// la première clé de tri doit obligatoirement être la section elle-même.
        let orderBySection = NSSortDescriptor(key: "section.name", ascending: true)
		let orderByDate = NSSortDescriptor(key: "date", ascending: true)
		let orderByPrice = NSSortDescriptor(key: "value", ascending: true)
		request.sortDescriptors = [orderBySection, orderByDate, orderByPrice]

        controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: appContext,
            sectionNameKeyPath: "section.name",
            cacheName: nil)
        controller.delegate = self

        do {
            try controller.performFetch()
        } catch {
            print(error)
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

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections([sectionIndex], with: .automatic)
        case .delete:
            tableView.deleteSections([sectionIndex], with: .automatic)
        case .move:
            break
        case .update:
            break
        @unknown default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            break
        case .update:
            break
        @unknown default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
