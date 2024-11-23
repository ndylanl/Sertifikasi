//
//  ContentView.swift
//  Sertifikasi
//
//  Created by Nicholas Dylan Lienardi on 21/11/24.
//

import SwiftUI

struct ContentView: View {
    //Initialize thr DB and ensure only one instance appears for each viewmodel.
    @StateObject var bookViewModel = BookViewModel()
    @StateObject var categoryViewModel = CategoryViewModel()
    @StateObject var userViewModel = UserViewModel()
    @StateObject var bookCategoryViewModel = BookCategoryViewModel()
    @StateObject var borrowedBookViewModel = BorrowedBookViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                
                NavigationLink("Go to Category View (CRUD)", destination: CategoryView(viewModel: categoryViewModel, bookCategoryViewModel: bookCategoryViewModel))
                    .padding()
                    .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                    .foregroundColor(.blue)
                    .font(.headline)
                    .padding(.vertical, 4)
                
                NavigationLink("Go to Book View (CRUD)", destination: BookView(viewModel: bookViewModel, categoryViewModel: categoryViewModel, borrowedBookViewModel: borrowedBookViewModel))
                    .padding()
                    .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                    .foregroundColor(.green)
                    .font(.headline)
                    .padding(.vertical, 4)
                
                NavigationLink("Go to User View (CRUD)", destination: UserView(userViewModel: userViewModel, bookViewModel: bookViewModel, borrowedBookViewModel: borrowedBookViewModel))
                    .padding()
                    .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                    .foregroundColor(.orange)
                    .font(.headline)
                
                    .padding(.vertical, 4)
                
                
            }
            .navigationTitle("Library Sertifikasi")
            .listStyle(PlainListStyle())
        }
    }
}

struct DetailView: View {
    var body: some View {
        Text("Detail View")
            .font(.largeTitle)
            .padding()
    }
}


#Preview {
    ContentView()
}
