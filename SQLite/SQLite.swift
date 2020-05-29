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
    var insertRow: OpaquePointer?
    
    @Published var movies: [Movie] = [Movie(title: "jói", year: 2020)]
    
    func storeMovies(_ movies: [Movie]) -> Int {
        var counter = 0
        guard dbHandle != nil else {
            os_log(.error, "DB pointer is nil")
            return counter
        }
        guard movies.count > 0 else {
            os_log(.info, "No movies to insert")
            return counter
        }
                
        // Store a movie in db
        let insertSQL = "INSERT INTO Movie (title, year) VALUES (?, ?);"
        
        // Prepare (compile) the statement
        if sqlite3_prepare_v3(dbHandle, insertSQL, -1, 0, &insertRow, nil) == SQLITE_OK {
            for (index, movie) in movies.enumerated() {
                if index > 0 {
                    
                }
                sqlite3_bind_text(insertRow, 1, movie.title, -1, nil)
                sqlite3_bind_int64(insertRow, 2, Int64(movie.year))
                
                // Run the statement
                let success = sqlite3_step(insertRow)
                if success != SQLITE_DONE {
                    os_log(.error, "Could not insert row data for %@", movie.title)
                }
                counter += 1
                sqlite3_reset(insertRow)
            }
            
        } else {
            os_log(.error, "Could not prepare for row data")
            return counter
        }
        
        return counter
    }
    
    func retrieveMovie(_ movie: Movie) -> Movie? {
        // Retrieve a movie from db
        
        return nil
    }
    
    // MARK: SQLite Setup and close down
    
    init() {
        // Open or set up database if needed
        if let docsDirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("SQLBooks").appendingPathExtension("sqlite") {
            let filename = docsDirURL.absoluteString
            
            // Open file or create
            var success = sqlite3_open_v2(filename, &dbHandle, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_URI, nil)
            if success != SQLITE_OK {
                let errorCode = sqlite3_errcode(dbHandle)
                if let errorString = sqlite3_errstr(errorCode) {
                    let str = String(cString: errorString)
                    os_log(.error, "Could not open or create database, error: %d, %@, path: %@", errorCode, str, filename)
                }
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
    
    deinit {
        // Destroy the statements
        if (insertRow != nil) {sqlite3_finalize(insertRow)}
        
        // Close the database properly
        if (dbHandle != nil) {sqlite3_close_v2(dbHandle)}
        
        os_log(.info, "Setup table finished")
    }
}


