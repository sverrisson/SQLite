//
//  ContentView.swift
//  SQLite
//
//  Created by Hannes Sverrisson on 29/05/2020.
//  Copyright © 2020 Hannes Sverrisson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var database: SQLite
    
    var leadingView: some View {
        HStack {
            Button(action: {
                let list = [
                    Movie(title: "Three Colors: Red", year: 1994),
                    Movie(title: "Boyhood", year: 2014),
                    Movie(title: "Citizen Kane", year: 1941),
                    Movie(title: "The Godfather", year: 1972),
                    Movie(title: "Casablanca", year: 1943)
                    ].shuffled()
                let upToMovies = (0..<list.count).randomElement()
                let total = self.database.storeMovies(Array(list.prefix(upToMovies ?? 0)))
                print("Stored \(total) movies!")
                self.database.retrieveMovies()
                
            }, label: {
                Text("Store")
            })
            
            Spacer()
            
            Button(action: {
                self.database.retrieveMovies()
                print("Retrieved: \(self.database.movies.count)")
                
            }, label: {
                Text("Retrieve")
            })
        }
    }
    
    var trailingView: some View {
        HStack {
            Button(action: {
                print("Deleted \(self.database.deleteAllRows()) movies!")
                self.database.retrieveMovies()
                
            }, label: {
                Text("Delete All")
                    .foregroundColor(.red)
            })
            
            Spacer()
            
            Button(action: {
                print("Counted \(self.database.countRows()) movies!")
                
            }, label: {
                Text("Total")
            })
        }
    }
    
    var body: some View {
        NavigationView {
            List(self.database.movies) { movie in
                HStack {
                    Text(movie.title)
                    Text(String(movie.year))
                }
            }
            .navigationBarTitle(Text("Movies"))
            .navigationBarItems(leading: leadingView, trailing: trailingView)
        }
        .onAppear {
            self.database.retrieveMovies()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var db = SQLite("Movies")
    static var previews: some View {
        ContentView()
            .environmentObject(db)
    }
}
