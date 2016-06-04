//
//  UserController.swift
//  DB Swift
//
//  Created by David Schwarzmann on 04.05.16.
//  Copyright © 2016 David Schwarzmann. All rights reserved.
//

import Cocoa
import MySQL

class UserController: NSViewController, NSTableViewDataSource {

	var rows :[Patient] = []
	var selected :Int? = nil

	@IBOutlet weak var table: NSTableView!

	override func viewDidLoad() {
		super.viewDidLoad()

		loadData()
	}

	func loadData() {
		do {
			let con = try DatabaseController.getSharedInstance().getConnection()
			rows = try con.query("SELECT Patientennummer, Vorname, Nachname, Anschrift  FROM Patient;")
			con.release()

			// Debugging Ausgabe
			//print(rows.count)
			//for row in rows {
			//	print("\(row.id) - \(row.fname) \(row.lname); \(row.address)" )
			//}
		}catch (let e){
			self.presentError(NSError(domain: "", code: 1, userInfo: [
				NSLocalizedDescriptionKey: "\(e as ErrorType)"
				]))
			NSLog("\(e as ErrorType)")
		}
	}

	func nextID(patients :[Patient]) -> Int {
		var max = -1
		for patient in patients {
			if patient.id > max {
				max = patient.id
			}
		}
		return max + 1
	}

	func reloadTable() {
		self.table.reloadData()
	}

	// MARK: Data Sources

	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return rows.count
	}

	func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?{
		var result = ""

		let columnIdentifier = tableColumn!.identifier
		//print("Col:\(columnIdentifier)")
		if columnIdentifier == "id" {
			result = String(rows[row].id)
		}
		if columnIdentifier == "name" {
			result = rows[row].fname + " " + rows[row].lname
		}
		if columnIdentifier == "address" {
			result = rows[row].address
		}
		return result
	}

	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		if(segue.identifier == "editUser") {
			let nextController = (segue.destinationController as! EditUserController)

			if (table.selectedRow == -1) {
				self.presentError(NSError(domain: "", code: 1, userInfo: [
					NSLocalizedDescriptionKey: "No row selected!"
					]))
				return
			}
			nextController.parent = self
			nextController.id = rows[table.selectedRow].id
			nextController.new = false
		}

		if(segue.identifier == "createUser") {
				let nextController = (segue.destinationController as! EditUserController)
				nextController.parent = self
				nextController.id = nextID(rows)
				nextController.new = true
		}
	}
}

