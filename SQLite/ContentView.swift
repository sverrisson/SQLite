//
//  ContentView.swift
//  SQLite
//
//  Created by Hannes Sverrisson on 29/05/2020.
//  Copyright © 2020 Hannes Sverrisson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var movies: [Movie]
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(movies.first!.title)
            
            Button(action: {
                let list = [
                    Movie(title: "Citizen Kane", year: 1941),
                    Movie(title: "The Godfather", year: 1972),
                    Movie(title: "Casablanca", year: 1943)
                ]
                let total = SQLite.shared.storeMovies(list)
                print("Stored \(total) movies!")
                
            }, label: {
                Text("Store Movies")
            })
            
            
            Button(action: {
                let movies = SQLite.shared.retrieveMovies()
                print("Deleted: \(movies.count)")
                print(movies)
                
            }, label: {
                Text("Retrive Movies")
            })
            
            Button(action: {
                print("Retrieved \(SQLite.shared.deleteAllRows()) movies!")
                
            }, label: {
                Text("Delete All Movies")
                    .foregroundColor(.red)
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(movies: SQLite.shared.movies)
    }
}
