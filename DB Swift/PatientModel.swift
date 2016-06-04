//
//  PatientModel.swift
//  DB-Swift
//
//  Created by David Schwarzmann on 31.05.16.
//  Copyright © 2016 David Schwarzmann. All rights reserved.
//

import MySQL

struct Patient: QueryRowResultType, QueryParameterDictionaryType {
	let id: Int
	let fname: String
	let lname: String
	let address: String

	// Decode query results (selecting rows) to the model
	// see selecting sample
	static func decodeRow(r: QueryRowResult) throws -> Patient {
		return try Patient(
			id: r <| 0, // as index
			fname: r <| "Vorname", // as field name
			lname: r <| "Nachname", // as field name
			address: r <| "Anschrift" // as field name
		)
	}

	// Use the model as a query paramter
	// see inserting sample
	func queryParameter() throws -> QueryDictionary {
		return QueryDictionary([
			"Patientennummer": id,
			"Vorname": fname,
			"Nachname": lname,
			"Anschrift": address
			])
	}
}
