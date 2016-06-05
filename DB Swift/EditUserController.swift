//
//  CreateUserController.swift
//  DB-Swift
//
//  Created by David Schwarzmann on 31.05.16.
//  Copyright © 2016 David Schwarzmann. All rights reserved.
//

import Cocoa
import MySQL

/// Viewcontroller that handles the display of a specific patient
class EditUserController: NSViewController {

	/// The id of the patient thats going to be edited or created
	var id :Int!
	/// A semaphore flag that tells if a patient should get created or not
	var new :Bool!
	/// A reference to the parent viewcontroller to reload table data etc.
	var parent :UserController!
	/// The local representation of the patient that is edited or created
	var patient : Patient!

	/// References for the UI handling depending on the context (edit/create)
	@IBOutlet weak var idLabel: NSTextField!
	@IBOutlet weak var fnameField: NSTextField!
	@IBOutlet weak var lnameField: NSTextField!
	@IBOutlet weak var addressField: NSTextField!
	@IBOutlet weak var startDateField: NSTextField!
	@IBOutlet weak var endDateField: NSTextField!
	@IBOutlet weak var deleteButton: NSButton!
	

	/// Eventhandler that initializes the view
	override func viewDidLoad() {
		super.viewDidLoad()

		/// In general hide the button and activiate it only if necessary
		deleteButton.hidden = true

		/// Check which context is selected
		/// A new user shouldn't get created
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
				// Get the instance of the database controller to get a connection from the pool
				let con = try DatabaseController.getSharedInstance().getConnection()
				// Create a temporary array that stores the query result
				var p :[Patient] = []
				// Query the patient with the provided ID from the database
				p = try con.query("SELECT Patientennummer, Vorname, Nachname, Anschrift  FROM Patient WHERE Patientennummer = \(id);")
				// Store the patient inside the local attribute
				self.patient = p[0]
				// Release the database connection back to the pool
				con.release()

				// Display all stored values
				idLabel.stringValue =	String(patient.id)
				fnameField.stringValue = patient.fname
				lnameField.stringValue = patient.lname
				addressField.stringValue = patient.address

				/// TODO: Add date fields (Requires the model improvement first)

			} catch (let e) {
				// If an error occured during the process above the user gets presented the error
				self.presentError(NSError(domain: "", code: 1, userInfo: [
					NSLocalizedDescriptionKey: "\(e as ErrorType)"
					]))
				NSLog("\(e as ErrorType)")
			}
		/// A new user should get created
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

	/**
		Simple method that calls the parents methods to reload the tableview.
	*/
	func reloadTable() {
		parent.loadData()
		parent.reloadTable()

	}

	/**
		Method to update the patient
		Processes only fields that changed
	
		- Attention: If an error occurres during the update process the user gets presented a error message
	*/
	func updatePatient() {
		// Array that stores the fields and its values that have changed
		var update :[(String,String)] = []
		// Array that contains the SQL assignments for later usage in the query process
		var commands : [String] = []

		// Check if the first name has changed
		if (fnameField.stringValue != patient.fname) {
			update.append(("Vorname",fnameField.stringValue))
		}

		// Check if the last name has changed
		if (lnameField.stringValue != patient.lname) {
			update.append(("Nachname",lnameField.stringValue))
		}

		// Check if the address field has changed
		if (addressField.stringValue != patient.address) {
			update.append(("Anschrift",addressField.stringValue))
		}

		// Continue only if fields have changed
		if !update.isEmpty {

			// Generate the SQL assignments for later usage
			// COLUMN = "VALUE"
			for (col,val) in update {
				commands.append(col + " = \"" + val + "\"")
			}

			// Combine alle SQL assignments into one single command
			let query = commands.joinWithSeparator(",")

			do {
				// Get the instance of the database controller to get a connection from the pool
				let con = try DatabaseController.getSharedInstance().getConnection()
				// Update the specified patient with the changed fields
				let status = try con.query("UPDATE Patient SET \(query) WHERE Patientennummer = \(patient.id);")
				// Release the connection back to the pool
				con.release()
				// Print the the query status for debugging purposes
				print(status)
			} catch (let e) {
				// If an error occurs during the process present it to the user
				self.presentError(NSError(domain: "", code: 1, userInfo: [
					NSLocalizedDescriptionKey: "\(e as ErrorType)"
					]))
				return
			}

			// Reload the tableview in the parent controller to contain the new data
			self.reloadTable()
		}
	}

	/**
		Method to insert a patient
	
		- Attention: If an error occurres during the update process the user gets presented a error message
	*/
	func insertPatient() {
		// Array that stores the fields that are going to inserted
		var inserts :[(String,String)] = []
		// Array that stores the SQL commands of the inserted fields
		var commands : ([String],[String]) = ([],[])

		// Check if the first name is empty
		if (!fnameField.stringValue.isEmpty) {
			inserts.append(("Vorname",fnameField.stringValue))
		}

		// Check if the first name is empty
		if (!lnameField.stringValue.isEmpty) {
			inserts.append(("Nachname",lnameField.stringValue))
		}

		// Check if the first name is empty
		if (!addressField.stringValue.isEmpty) {
			inserts.append(("Anschrift",addressField.stringValue))
		}

		// Proceed only if at least field was entered
		if !inserts.isEmpty {

			// Add the ID of the patient first
			commands.0.append("Patientennummer")
			commands.1.append(String(id!))

			// Generate the SQL commands for later usage
			for (col,val) in inserts {
				commands.0.append(col)
				commands.1.append("\"" + val + "\"")
			}

			// Generate a default SQL date for now
			// TODO: Add date handling
			commands.0.append("Aufnahmedatum")
			let date = String(SQLDate.now())
			let desiredLength = date.startIndex.advancedBy(date.characters.count-6)
			commands.1.append("\"" + date.substringToIndex(desiredLength) + "\"")

			// Combine alle SQL partials into two commands
			let query :(String, String) = ("(" + commands.0.joinWithSeparator(",") + ")", "(" + commands.1.joinWithSeparator(",") + ")")

			do {
				// Get the instance of the database controller to get a connection from the pool
				let con = try DatabaseController.getSharedInstance().getConnection()
				// Insert the patient with the values specified in the fields
				let status = try con.query("INSERT INTO Patient \(query.0) VALUES \(query.1)")
				// Release the connection back to the pool
				con.release()
				// Print the query status of the insert command for debugging purposes
				print(status)
			} catch (let e) {
				// If an error occurs during the process present it to the user
				self.presentError(NSError(domain: "", code: 1, userInfo: [
					NSLocalizedDescriptionKey: "\(e as ErrorType)"
					]))
				return
			}

			// Reload the tableview in the parent controller to contain the new data
			self.reloadTable()
		}
	}

	/**
		Eventhandler for the OK button 
 		It decides based upon the state of `new` which action should be executed
	*/
	@IBAction func buttonClicked(sender: AnyObject) {
		if new! {
			insertPatient()
		} else {
			updatePatient()
		}

		// Dismiss the sheet
		self.dismissController(self)
	}

	/**
		Method for handling the event of deleting a patient

		- Attention: If an error occurres during the update process the user gets presented a error message
	*/
	@IBAction func deletePatient(sender: AnyObject) {
		do {
			// Get the instance of the database controller to get a connection from the pool
			let con = try DatabaseController.getSharedInstance().getConnection()
			// Delete the patient that is specified by the segue attribute
			let status = try con.query("DELETE FROM Patient WHERE Patientennummer = \(id)")
			// Release the connection back to the pool
			con.release()
			// Print the query status of the insert command for debugging purposes
			print(status)
		} catch (let e) {
			// If an error occurs during the process present it to the user
			self.presentError(NSError(domain: "", code: 1, userInfo: [
				NSLocalizedDescriptionKey: "\(e as ErrorType)"
				]))
			return
		}

		// Reload the tableview in the parent controller to contain the new data
		self.reloadTable()
		// Dismiss the sheet
		self.dismissController(self)
	}
}
