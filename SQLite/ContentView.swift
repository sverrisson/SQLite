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
        VStack {
            Text(movies.first!.title)
            
            Button(action: {
                let movie = Movie(title: "Back to the Future", year: 1999)
                let success = SQLite.shared.StoreMovie(movie)
                print(success)
                
            }, label: {
                Text("Store Movie")
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(movies: SQLite.shared.movies)
    }
}
