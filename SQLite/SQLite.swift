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

struct Movie: Codable, CustomStringConvertible {
    var title: String
    var year: Int
    
    var description: String {
        "Movie[\(title), \(year)]"
    }
}

class SQLite: ObservableObject {
    static var shared = SQLite()
    
    @Published
    var movies: [Movie] = []
    
    var database: OpaquePointer?
    var storeRowStmt: OpaquePointer?
    var deleteRowsStmt: OpaquePointer?
    var retrieveRowStmt: OpaquePointer?
    var countStmt: OpaquePointer?
    
    @Published var movies: [Movie] = [Movie(title: "jói", year: 2020)]
    
    /// Total rows in the table
    /// - Returns: Int of numbers of rows
    func countRows() -> Int {
        guard database != nil else {
            os_log(.error, "DB pointer is nil")
            return 0
        }
        
        // Prepare (compile) the statement
        if (countStmt == nil) {
            // Store a movie in db
            let zSql = "SELECT COUNT(*) FROM Movie;"
            let nByte = Int32(zSql.count)
            
            if sqlite3_prepare_v2(database, zSql, nByte, &countStmt, nil) == SQLITE_OK {
                os_log(.info, "Compiled count row data")
            } else {
                os_log(.error, "Could not prepare count")
                return 0
            }
        }
        // Run the statement
        var counts: [Int32] = []
        var success = SQLITE_ROW
        while success == SQLITE_ROW {
            success = sqlite3_step(countStmt)
            let count = sqlite3_column_int(countStmt, 0)
            print("Count: \(count)")
            counts.append(count)
        }
        if success != SQLITE_DONE {
            os_log(.error, "Could not count rows")
            let errorMessage = String(cString: sqlite3_errmsg(database))
            print("Error: \(errorMessage)")
        }
        sqlite3_reset(countStmt)
        return Int(counts.first!)
    }
    
    /// Delete all rows from the table
    /// - Returns: Bool of true if deleted, otherwise false
    func deleteAllRows() -> Bool {
        guard database != nil else {
            os_log(.error, "DB pointer is nil")
            return false
        }
        
        // Prepare (compile) the statement
        if (deleteRowsStmt == nil) {
            // Store a movie in db
            let zSql = "DELETE FROM Movie;"
            let nByte = Int32(zSql.count)
            
            if sqlite3_prepare_v2(database, zSql, nByte, &deleteRowsStmt, nil) == SQLITE_OK {
                os_log(.info, "Compiled delete row data")
            } else {
                os_log(.error, "Could not prepare delete")
                return false
            }
        }
        
        // Run the statement
        let success = sqlite3_step(deleteRowsStmt)
        if success != SQLITE_DONE {
            os_log(.error, "Could not delete rows")
            return false
        }
        sqlite3_reset(deleteRowsStmt)
        return true
    }
    
    /// Store Movies in the Movie table
    /// - Parameter movies: [Movie] movie array to insert to db
    /// - Returns: the number of movies inserted to the db
    func storeMovies(_ movies: [Movie]) -> Int {
        var counter = 0
        guard database != nil else {
            os_log(.error, "DB pointer is nil")
            return counter
        }
        guard movies.count > 0 else {
            os_log(.info, "No movies to insert")
            return counter
        }
        
        // Prepare (compile) the statement
        if (storeRowStmt == nil) {
            // Store a movie in db
            let zSql = "INSERT INTO Movie (title, year) VALUES (?, ?);"
            let nByte = Int32(zSql.count)
            
            if sqlite3_prepare_v2(database, zSql, nByte, &storeRowStmt, nil) == SQLITE_OK {
                os_log(.info, "Compiled store row data")
            } else {
                os_log(.error, "Could not prepare store for row data")
                return counter
            }
        }
        
        for movie in movies {
            sqlite3_bind_text(storeRowStmt, 1, movie.title, -1, nil)
            sqlite3_bind_int64(storeRowStmt, 2, Int64(movie.year))
            
            // Run the statement
            var success = sqlite3_step(storeRowStmt)
            while success == SQLITE_BUSY {
                sqlite3_sleep(150)
                success = sqlite3_step(storeRowStmt)
            }
            if success != SQLITE_DONE {
                os_log(.error, "Could not insert row data for %@", movie.title)
            }
            counter += 1
            sqlite3_reset(storeRowStmt)
        }
        return counter
    }
    
    /// Retrieve all movies from the Movie table
    /// - Returns: [Movie] all the movies in the table
    func retrieveMovies() -> [Movie] {
        var movies: [Movie] = []
        guard database != nil else {
            os_log(.error, "DB pointer is nil")
            return movies
        }
        
        // Prepare (compile) the statement
        if (retrieveRowStmt == nil) {
            // Store a movie in db
            let zSql = "SELECT M.title, M.year FROM Movie AS M;"
            let nByte = Int32(zSql.count)
            
            if sqlite3_prepare_v2(database, zSql, nByte, &retrieveRowStmt, nil) == SQLITE_OK {
                os_log(.info, "Compiled retrieve row data")
            } else {
                os_log(.error, "Could not prepare for row data")
                return movies
            }
        }
        var success: Int32 = SQLITE_ROW
        while success == SQLITE_ROW {
            success = sqlite3_step(retrieveRowStmt)
            let titleSq = sqlite3_column_text(retrieveRowStmt, 0)
            let yearSq = sqlite3_column_int64(retrieveRowStmt, 1)
            
            // Convert
            if let titleSq = titleSq {
                let title = String(cString: titleSq)
                let year = Int(yearSq)
                movies.append(Movie(title: title, year: year))
            }
        }
        sqlite3_reset(retrieveRowStmt)
        
        return movies
    }
    
    // MARK: SQLite Setup and close down
    
    init() {
        // Open or set up database if needed
        if let docsDirURL = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("SQLBooks").appendingPathExtension("sqlite") {
            let filename = docsDirURL.absoluteString
            
            // Open file or create
            var success = sqlite3_open_v2(filename, &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_URI | SQLITE_OPEN_FULLMUTEX, nil)
            if success != SQLITE_OK {
                if let str = sqlite3_errmsg(database) {
                    let errorString = String(cString: str)
                    os_log(.error, "Could not open or create database, error: %d, %@, path: %@", errorString, filename)
                }
            }
            
            // Create table
            let sqlStatement = "CREATE TABLE IF NOT EXISTS Movie(title VARCHAR(25), year INT);"
            var statement: UnsafeMutableRawPointer!
            var errormsg: UnsafeMutablePointer<Int8>?
            success = sqlite3_exec(database, sqlStatement, nil, &statement, &errormsg)
            guard success == SQLITE_OK else {
                os_log(.error, "Could not create table, Error: %@", errormsg.debugDescription)
                sqlite3_free(errormsg)
                return
            }
            os_log(.info, "ThreadSafe: %d", sqlite3_threadsafe())
            os_log(.info, "Setup table finished: %@", filename)
        }
    }
    
    deinit {
        // Destroy the statements
        sqlite3_finalize(storeRowStmt)
        sqlite3_finalize(retrieveRowStmt)
        sqlite3_finalize(deleteRowsStmt)
        
        // Close the database properly
        sqlite3_close(database)
        
        os_log(.info, "Setup table finished")
    }
}


