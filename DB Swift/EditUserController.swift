//
//  CreateUserController.swift
//  DB-Swift
//
//  Created by David Schwarzmann on 31.05.16.
//  Copyright © 2016 David Schwarzmann. All rights reserved.
//

import Cocoa
import MySQL

class EditUserController: NSViewController {

	var id :Int!
	var new :Bool!
	var parent :UserController!
	var patient : Patient!

	@IBOutlet weak var idLabel: NSTextField!
	@IBOutlet weak var fnameField: NSTextField!
	@IBOutlet weak var lnameField: NSTextField!
	@IBOutlet weak var addressField: NSTextField!
	@IBOutlet weak var startDateField: NSTextField!
	@IBOutlet weak var endDateField: NSTextField!
	@IBOutlet weak var deleteButton: NSButton!
	

	override func viewDidLoad() {
		super.viewDidLoad()

		deleteButton.hidden = true

		if (!new) {
			// Set all fields to read only
			idLabel.enabled = false
			fnameField.enabled = true
			lnameField.enabled = true
			addressField.enabled = true
			startDateField.enabled = false
			endDateField.enabled = false
			deleteButton.hidden = false
			deleteButton.enabled = true

			do {
				let con = try DatabaseController.getSharedInstance().getConnection()
				var p :[Patient] = []
				p = try con.query("SELECT Patientennummer, Vorname, Nachname, Anschrift  FROM Patient WHERE Patientennummer = \(id);")
				self.patient = p[0]
				con.release()
				idLabel.stringValue =	String(p[0].id)
				fnameField.stringValue = p[0].fname
				lnameField.stringValue = p[0].lname
				addressField.stringValue = p[0].address

				//print(patient)

			} catch (let e) {
				self.presentError(NSError(domain: "", code: 1, userInfo: [
					NSLocalizedDescriptionKey: "\(e as ErrorType)"
					]))
				NSLog("\(e as ErrorType)")
			}
		} else {
			// Set input fields to the required status
			idLabel.stringValue =	String(self.id)
			fnameField.enabled = true
			lnameField.enabled = true
			addressField.enabled = true
			startDateField.enabled = false
			endDateField.enabled = false

		}
	}

	func updatePatient() {
		var update :[(String,String)] = []
		var commands : [String] = []

		if (fnameField.stringValue != patient.fname) {
			update.append(("Vorname",fnameField.stringValue))
		}

		if (lnameField.stringValue != patient.lname) {
			update.append(("Nachname",lnameField.stringValue))
		}

		if (addressField.stringValue != patient.address) {
			update.append(("Anschrift",addressField.stringValue))
		}

		if !update.isEmpty {

			for (col,val) in update {
				commands.append(col + " = \"" + val + "\"")
			}

			let query = commands.joinWithSeparator(",")
			//print(query)

			do {
				let con = try DatabaseController.getSharedInstance().getConnection()
				let status = try con.query("UPDATE Patient SET \(query) WHERE Patientennummer = \(patient.id);")
				con.release()
				print(status)
			} catch (let e) {
				self.presentError(NSError(domain: "", code: 1, userInfo: [
					NSLocalizedDescriptionKey: "\(e as ErrorType)"
					]))
				return
			}

			parent.loadData()
			parent.reloadTable()
		}
	}

	func insertPatient() {
		var inserts :[(String,String)] = []
		var commands : ([String],[String]) = ([],[])

		if (!fnameField.stringValue.isEmpty) {
			inserts.append(("Vorname",fnameField.stringValue))
		}

		if (!lnameField.stringValue.isEmpty) {
			inserts.append(("Nachname",lnameField.stringValue))
		}

		if (!addressField.stringValue.isEmpty) {
			inserts.append(("Anschrift",addressField.stringValue))
		}

		if !inserts.isEmpty {

			commands.0.append("Patientennummer")
			commands.1.append(String(id!))

			for (col,val) in inserts {
				commands.0.append(col)
				commands.1.append("\"" + val + "\"")
			}

			commands.0.append("Aufnahmedatum")

			let date = String(SQLDate.now())
			let desiredLength = date.startIndex.advancedBy(date.characters.count-6)
			commands.1.append("\"" + date.substringToIndex(desiredLength) + "\"")


			let query :(String, String) = ("(" + commands.0.joinWithSeparator(",") + ")", "(" + commands.1.joinWithSeparator(",") + ")")

			do {
				let con = try DatabaseController.getSharedInstance().getConnection()
				print("INSERT INTO Patient \(query.0) VALUES \(query.1)")
				let status = try con.query("INSERT INTO Patient \(query.0) VALUES \(query.1)")
				con.release()
				print(status)
			} catch (let e) {
				self.presentError(NSError(domain: "", code: 1, userInfo: [
					NSLocalizedDescriptionKey: "\(e as ErrorType)"
					]))
				return
			}

			parent.loadData()
			parent.reloadTable()
		}
	}

	@IBAction func buttonClicked(sender: AnyObject) {

		if new! {
			insertPatient()
		} else {
			updatePatient()
		}

		self.dismissController(self)
	}

	@IBAction func deletePatient(sender: AnyObject) {
	}
}
