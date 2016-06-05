//
//  PatientModel.swift
//  DB-Swift
//
//  Created by David Schwarzmann on 31.05.16.
//  Copyright © 2016 David Schwarzmann. All rights reserved.
//

import MySQL

/**
	The model that represents a patient that is stored inside a database

	- Requires: MySQL
*/
struct Patient: QueryRowResultType, QueryParameterDictionaryType {

	/// The id of the patient
	let id: Int

	/// The first name of the patient
	let fname: String

	/// The last name of the patient
	let lname: String

	/// The address of the patient
	let address: String

	// TODO: add his dates to the model

	/**
		Decode a row of a database to map it to its attributes
	
		- Parameter r: The queried row
	
		- Returns: Returns a instance of the queried Patient

	*/
	static func decodeRow(r: QueryRowResult) throws -> Patient {
		return try Patient(
			id: r <| 0, // as index
			fname: r <| "Vorname", // as field name
			lname: r <| "Nachname", // as field name
			address: r <| "Anschrift" // as field name
		)
	}

	/**
		Method that is automatically invoked if a instance of `Patient` is used to build a query.
 


	*/
	func queryParameter() throws -> QueryDictionary {
		return QueryDictionary([
			"Patientennummer": id,
			"Vorname": fname,
			"Nachname": lname,
			"Anschrift": address
			])
	}
}
