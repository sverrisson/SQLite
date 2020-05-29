//
//  SQLite.swift
//  SQLite
//
//  Created by Hannes Sverrisson on 29/05/2020.
//  Copyright © 2020 Hannes Sverrisson. All rights reserved.
//

import Combine
import SQLite3
import Foundation
import os.log

struct Movie: Codable {
    var title: String
    var year: Int
}

class SQLite: ObservableObject {
    static var shared = SQLite()
    
    var dbHandle: OpaquePointer?
    
    @Published var movies: [Movie] = [Movie(title: "jói", year: 2020)]
    
    func StoreMovie(_ movie: Movie) -> Bool {
        guard dbHandle != nil else {
            os_log(.error, "DB pointer is nil")
            return false
        }
        
        
        // Store a movie in db
        var statement: OpaquePointer?
        let row = "INSERT INTO Movie (title, year) VALUES (?, ?);"
        if sqlite3_prepare(dbHandle, row, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, movie.title, -1, nil)
            sqlite3_bind_int64(statement, 2, Int64(movie.year))
            
            guard sqlite3_step(statement) == SQLITE_DONE else {
                os_log(.error, "Could not insert row data")
                return false
            }
        } else {
            os_log(.error, "Could not prepare for row data")
            return false
        }
        sqlite3_finalize(statement)
        return true
    }
    
    func RetrieveMovie(_ movie: Movie) -> Movie? {
        // Retrieve a movie from db
        
        return nil
    }
    
    // MARK: SQLite Setup
    
    
    init() {
        // Open or set up database if needed
        if let docsDirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("SQLBooks").appendingPathExtension("sqlite"), let name = docsDirURL.absoluteString.cString(using: .ascii) {
            let filename: UnsafePointer<Int8> = name.withUnsafeBufferPointer { $0.baseAddress! }
            
            var success = sqlite3_open(filename, &dbHandle)
            guard success == SQLITE_OK else {
                if let handle = dbHandle {
                    sqlite3_close(handle)
                }
                dbHandle = nil
                os_log(.error, "Could not open or create database: %@", filename)
                return
            }
            
            // Create table
            let sqlStatement = "CREATE TABLE IF NOT EXISTS Movie(title VARCHAR(25), year INT);"
            var statement: UnsafeMutableRawPointer!
            var errormsg: UnsafeMutablePointer<Int8>?
            success = sqlite3_exec(dbHandle, sqlStatement, nil, &statement, &errormsg)
            guard success == SQLITE_OK else {
                os_log(.error, "Could not create table, Error: %@", errormsg.debugDescription)
                sqlite3_free(errormsg)
                return
            }
            os_log(.info, "Setup table finished")
        }
    }
    
}


