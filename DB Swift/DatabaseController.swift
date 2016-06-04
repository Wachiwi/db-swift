//
//  DatabaseController.swift
//  DB-Swift
//
//  Created by David Schwarzmann on 02.06.16.
//  Copyright © 2016 David Schwarzmann. All rights reserved.
//

import MySQL

class DatabaseController {

	let pool :ConnectionPool
	static let sharedInstance :DatabaseController = DatabaseController()

	internal init() {
		let options = Options(host: "127.0.0.1", port: 65433, user: "root", password: "admin", database: "KinikWoSc")
		pool = ConnectionPool(options: options)
	}

	func getConnection() throws -> Connection {
		return try pool.getConnection()
	}

	// MARK: Static methods

	static func getSharedInstance() -> DatabaseController {
		return DatabaseController.sharedInstance
	}


}

