//
//  DatabaseController.swift
//  DB-Swift
//
//  Created by David Schwarzmann on 02.06.16.
//  Copyright © 2016 David Schwarzmann. All rights reserved.
//

import MySQL

/// Simple class that provides some convenient methods for handling the database
/// TODO: Extend this class to allow simpler queries
class DatabaseController {

	/// A pool of connections to the database
	let pool :ConnectionPool

	/// Singleton instance of this class
	static let sharedInstance :DatabaseController = DatabaseController()

	///	Internal init too make sure only one instance of this class exists.
	internal init() {
		let options = Options(host: "127.0.0.1", port: 65433, user: "root", password: "admin", database: "KinikWoSc")
		pool = ConnectionPool(options: options)
	}

	/**
		Simple method to recieve a `Connection` to the MySQL server from the pool
	
		- Attention: Make sure to release the connection back to the pool as soon it isn't used anymore
	
		- Throws: Throws an error if no connection to the server could be established

		- Returns: Returns a `Connection` to the server
	*/
	func getConnection() throws -> Connection {
		return try pool.getConnection()
	}

	// MARK: Static methods

	/**
		Static method to retrieve the singleton instance
	
		- Returns: The instance of this class
	*/
	static func getSharedInstance() -> DatabaseController {
		return DatabaseController.sharedInstance
	}


}

