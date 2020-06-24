//
//  SwiftUIView.swift
//  SQLite
//
//  Created by Hannes Sverrisson on 04/06/2020.
//  Copyright © 2020 Hannes Sverrisson. All rights reserved.
//

import SwiftUI
import SQLiteNano

struct DetailView: View {
    var movie: Movie
    
    var body: some View {
        VStack {
            Text(movie.title)
                .font(.largeTitle)
            Text(String(movie.year))
                .font(.title)
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(movie: Movie(title: "Casablanca", year: 1943))
    }
}
