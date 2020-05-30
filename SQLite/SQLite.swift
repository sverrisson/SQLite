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
    
    var database: OpaquePointer?
    var storeRow: OpaquePointer?
    var deleteRows: OpaquePointer?
    var retrieveRow: OpaquePointer?
    
    @Published var movies: [Movie] = [Movie(title: "jói", year: 2020)]
    
    
    /// Delete all rows from the table
    /// - Returns: Bool of true if deleted, otherwise false
    func deleteAllRows() -> Bool {
        guard database != nil else {
            os_log(.error, "DB pointer is nil")
            return false
        }
        
        // Prepare (compile) the statement
        if (deleteRows == nil) {
            // Store a movie in db
            let zSql = "DELETE FROM Movie;"
            let nByte = Int32(zSql.count)
            
            if sqlite3_prepare_v2(database, zSql, nByte, &deleteRows, nil) == SQLITE_OK {
                os_log(.info, "Combiled delete row data")
            } else {
                os_log(.error, "Could not prepare delete")
                return false
            }
        }
        
        // Run the statement
        let success = sqlite3_step(deleteRows)
        if success != SQLITE_DONE {
            os_log(.error, "Could not delete rows")
            return false
        }
        sqlite3_reset(deleteRows)
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
        if (storeRow == nil) {
            // Store a movie in db
            let zSql = "INSERT INTO Movie (title, year) VALUES (?, ?);"
            let nByte = Int32(zSql.count)
            
            if sqlite3_prepare_v2(database, zSql, nByte, &storeRow, nil) == SQLITE_OK {
                os_log(.info, "Combiled store row data")
            } else {
                os_log(.error, "Could not prepare store for row data")
                return counter
            }
        }
        
        for movie in movies {
            sqlite3_bind_text(storeRow, 1, movie.title, -1, nil)
            sqlite3_bind_int64(storeRow, 2, Int64(movie.year))
            
            // Run the statement
            var success = sqlite3_step(storeRow)
            while success == SQLITE_BUSY {
                sqlite3_sleep(150)
                success = sqlite3_step(storeRow)
            }
            if success != SQLITE_DONE {
                os_log(.error, "Could not insert row data for %@", movie.title)
            }
            counter += 1
            sqlite3_reset(storeRow)
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
        if (retrieveRow == nil) {
            // Store a movie in db
            let zSql = "SELECT M.title, M.year FROM Movie AS M;"
            let nByte = Int32(zSql.count)
            
            if sqlite3_prepare_v2(database, zSql, nByte, &retrieveRow, nil) == SQLITE_OK {
                os_log(.info, "Combiled retrieve row data")
            } else {
                os_log(.error, "Could not prepare for row data")
                return movies
            }
        }
        var success: Int32 = SQLITE_ROW
        while success == SQLITE_ROW {
            success = sqlite3_step(retrieveRow)
            let titleSq = sqlite3_column_text(retrieveRow, 0)
            let yearSq = sqlite3_column_int64(retrieveRow, 1)
            
            // Convert
            if let titleSq = titleSq {
                let title = String(cString: titleSq)
                let year = Int(yearSq)
                movies.append(Movie(title: title, year: year))
            }
        }
        sqlite3_reset(retrieveRow)
        
        return movies
    }
    
    // MARK: SQLite Setup and close down
    
    init() {
        // Open or set up database if needed
        if let docsDirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("SQLBooks").appendingPathExtension("sqlite") {
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
            os_log(.info, "Setup table finished")
        }
    }
    
    deinit {
        // Destroy the statements
        sqlite3_finalize(storeRow)
        sqlite3_finalize(retrieveRow)
        sqlite3_finalize(deleteRows)
        
        // Close the database properly
        sqlite3_close(database)
        
        os_log(.info, "Setup table finished")
    }
}


