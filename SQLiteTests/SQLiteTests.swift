//
//  SQLiteTests.swift
//  SQLiteTests
//
//  Created by Hannes Sverrisson on 29/05/2020.
//  Copyright © 2020 Hannes Sverrisson. All rights reserved.
//

import XCTest
@testable import SQLite

class SQLiteTests: XCTestCase {
    var database: SQLite!
    var list: [Movie]!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.database = SQLite("Test")
        
        self.list = [
        Movie(title: "Three Colors: Red", year: 1994),
        Movie(title: "Boyhood", year: 2014),
        Movie(title: "Citizen Kane", year: 1941),
        Movie(title: "The Godfather", year: 1972),
        Movie(title: "Casablanca", year: 1943),
        Movie(title: "Three Colors: Red", year: 1994),
        Movie(title: "Boyhood", year: 2014),
        Movie(title: "Citizen Kane", year: 1941),
        Movie(title: "The Godfather", year: 1972),
        Movie(title: "Casablanca", year: 1943),
        Movie(title: "Three Colors: Red", year: 1994),
        Movie(title: "Boyhood", year: 2014),
        Movie(title: "Citizen Kane", year: 1941),
        Movie(title: "The Godfather", year: 1972),
        Movie(title: "Casablanca", year: 1943),
        Movie(title: "Three Colors: Red", year: 1994),
        Movie(title: "Boyhood", year: 2014),
        Movie(title: "Citizen Kane", year: 1941),
        Movie(title: "The Godfather", year: 1972),
        Movie(title: "Casablanca", year: 1943),
        ].shuffled()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let list = [
            Movie(title: "Three Colors: Red", year: 1994),
            Movie(title: "Boyhood", year: 2014),
            Movie(title: "Citizen Kane", year: 1941),
            Movie(title: "The Godfather", year: 1972),
            Movie(title: "Casablanca", year: 1943)
            ]
        let total = self.database.storeMovies(list)
        print("Stored \(total) movies!")
        self.database.retrieveMovies()
        let m = self.database.movies
        XCTAssertEqual(list, m, "Same movies stored and retrieved")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            _ = self.database.storeMovies(list)
            self.database.retrieveMovies()
        }
    }

}
