//
//  ContentView.swift
//  SQLite
//
//  Created by Hannes Sverrisson on 29/05/2020.
//  Copyright © 2020 Hannes Sverrisson. All rights reserved.
//

import SwiftUI
import SQLiteNano

struct ContentView: View {
    @EnvironmentObject var database: SQLiteNano
    
    var trailingView: some View {
        HStack {
            Button(action: {
                let list = [
                    Movie(title: "Three Colors: Red", year: 1994),
                    Movie(title: "Boyhood", year: 2014),
                    Movie(title: "Citizen Kane", year: 1941),
                    Movie(title: "The Godfather", year: 1972),
                    Movie(title: "Casablanca", year: 1943)
                    ].shuffled()
                let upToMovies = 1 // (0..<list.count).randomElement()
                let total = self.database.storeMovies(Array(list.prefix(upToMovies)))
                print("Stored \(total) movies! \(list.prefix(upToMovies))")
                self.database.retrieveMovies()
                
            }, label: {
                Text("Store")
            })
//
//            Spacer()
//
//            Button(action: {
//                self.database.retrieveMovies()
//                print("Retrieved: \(self.database.movies.count)")
//
//            }, label: {
//                Text("Retrieve")
//            })
        }
    }
    
    var leadingView: some View {
        HStack {
            Button(action: {
                print("Deleted \(self.database.deleteAllRows()) movies!")
                self.database.retrieveMovies()
                
            }, label: {
                Text("Delete All")
                    .foregroundColor(.red)
            })
            
//
//            Spacer()
//
//            Button(action: {
//                print("Counted \(self.database.countRows()) movies!")
//
//            }, label: {
//                Text("Total")
//            })
        }
    }
    
    var body: some View {
        NavigationView {
            List(self.database.movies) { movie in
                NavigationLink(destination: DetailView(movie: movie)) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(movie.title)
                            Spacer()
                            Text("Year:")
                                .font(.caption)
                            Text(String(movie.year))
                        }.font(.headline)
                        
                        Text("\(movie.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationBarTitle(Text("Movies \(self.database.movies.count)"))
            .navigationBarItems(leading: leadingView, trailing: trailingView)
            
            DetailView(movie: database.movies.first ?? Movie(title: "Casablanca", year: 1943))
        }
        .onAppear {
            self.database.retrieveMovies()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var db = SQLiteNano("Movies")
    static var previews: some View {
        ContentView()
            .environmentObject(db)
    }
}
