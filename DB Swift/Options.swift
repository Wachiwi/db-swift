//
//  Options.swift
//  DB-Swift
//
//  Created by David Schwarzmann on 31.05.16.
//  Copyright © 2016 David Schwarzmann. All rights reserved.
//

import MySQL

struct Options: ConnectionOption {
	var host: String = "127.0.0.1"
	var port: Int = 3306
	var user: String = "root"
	var password: String = ""
	var database: String = "mysql"
}