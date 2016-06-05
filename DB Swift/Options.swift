//
//  Options.swift
//  DB-Swift
//
//  Created by David Schwarzmann on 31.05.16.
//  Copyright © 2016 David Schwarzmann. All rights reserved.
//

import MySQL

/**
	Options used for connecting to a mysql server

	- host: Specifies the host of the database server
	- port: Specifies the port of the database server
	- user: The name of the user that is allowed to connect to the database
	- passwod: The password of the user
	- database: The name of the database

	- Requires: MySQL
*/
struct Options: ConnectionOption {
	var host: String = "127.0.0.1"
	var port: Int = 3306
	var user: String = "root"
	var password: String = ""
	var database: String = "mysql"
}