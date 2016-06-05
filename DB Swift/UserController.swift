//
//  UserController.swift
//  DB Swift
//
//  Created by David Schwarzmann on 04.05.16.
//  Copyright © 2016 David Schwarzmann. All rights reserved.
//

import Cocoa
import MySQL

/// Viewcontroller that handles the display of the patients
class UserController: NSViewController, NSTableViewDataSource {

	/// Datasource for the tableview that contains all existent patient of the database (at all time)
	var patients :[Patient] = []

	/// Rerence to the tableview that contains the patients
	@IBOutlet weak var table: NSTableView!

	/// Eventhandler that initially loads the patients from the database as soon the view is loaded
	override func viewDidLoad() {
		super.viewDidLoad()
		loadData()
	}

	/**
		Method that loads the patients from the database into the datasource attribute of this controller
	
		- Attention: Since this method catches possible errors the user is presented with an possible unreadable error
									message that needs to be confirmed
	
		- SeeAlso: `UserController.patients`
	*/
	func loadData() {
		do {
			// Get the instance of the database controller to get a connection from the pool
			let con = try DatabaseController.getSharedInstance().getConnection()
			// Query all patients, automatically decode the result and store the instances inside the patients attribute
			patients = try con.query("SELECT Patientennummer, Vorname, Nachname, Anschrift  FROM Patient;")
			// Release the connection back to the pool
			con.release()
		}catch (let e){
			// If an error occurrs, catch it and present it to the user
			self.presentError(NSError(domain: "", code: 1, userInfo: [
				NSLocalizedDescriptionKey: "\(e as ErrorType)"
				]))
			NSLog("\(e as ErrorType)")
		}
	}

	/**
		Calculates the next ID of a newly inserted patient
	
		- Attention: This method doesnt calculate the best ID, because it could lead to inconsistency
		
									If a patient is newly created an deleted instanly aftwerwards a new ID gets calculated an freed
 									afterwards. So if a new patient is then created it gets the same ID as the previous, deleted
	
		- Parameter patients: To calculate the next ID of a patient it needs a list of all currently existing patients
 													inside the database.
	
		- Returns: Returns the next ID of a patient
	*/
	func nextID(patients :[Patient]) -> Int {
		var max = -1
		for patient in patients {
			if patient.id > max {
				max = patient.id
			}
		}
		return max + 1
	}

	/**
		Simple method that allows other views to reload the table if new data is inserted or should queried
	*/
	func reloadTable() {
		self.table.reloadData()
	}

	// MARK: Data Sources

	/**
		Methods that need to be implemented to be conform to the `NSTableViewDataSource` protocol
	
		- Parameter tableView: The table that is queried. It can be nil since there is only one table inside the view
	
		- Returns: Returns the number of rows that are stored inside the tableview
	*/
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return patients.count
	}

	/**
		Methods that need to be implemented to be conform to the `NSTableViewDataSource` protocol
	
		- Parameters: 
			- tableView: The table that is queried. It can be nil since there is only one table inside the view
			- objectValueForTableColumn: ??? Don't know
			- tableColumn: The table column that is going to be populated
	 		- row: The index of the row

		- Returns: The value that is going to be set for the column
	*/
	func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?{
		var result = ""

		let columnIdentifier = tableColumn!.identifier

		/// Check which column is populated an set the corresponding attribute
		if columnIdentifier == "id" {
			result = String(patients[row].id)
		}

		if columnIdentifier == "name" {
			result = patients[row].fname + " " + patients[row].lname
		}

		if columnIdentifier == "address" {
			result = patients[row].address
		}

		return result
	}

	/**
		Eventhandler to customize segues inside the storyboard.
		In this situation it is used to determine which button is clicked by the user and 
		send correct data with the segue since all segues have the same controller as a target.
	
		- Parameters:
			- segue: The segue that is going to happen
			- sender: The object that emitted the event
	*/
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {

		/// Since the user wants to edit a user set the proper attributes inside the destination controller
		if(segue.identifier == "editUser") {
			let nextController = (segue.destinationController as! EditUserController)

			/**
				Shouldn't happen but to make sure this error gets handled the user is presented with an error message
				if he doesn't select a row inside the table
			*/
			if (table.selectedRow == -1) {
				self.presentError(NSError(domain: "", code: 1, userInfo: [
					NSLocalizedDescriptionKey: "No row selected!"
					]))
				return
			}

			/// Set the attributes
			nextController.parent = self
			nextController.id = patients[table.selectedRow].id
			nextController.new = false
		}

		/// Since the user wants to create a user set the proper attributes inside the destination controller
		if(segue.identifier == "createUser") {
				let nextController = (segue.destinationController as! EditUserController)

				/// Set the attributes
				nextController.parent = self
				nextController.id = nextID(patients)
				nextController.new = true
		}
	}
}

