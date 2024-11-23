//
//  BookView.swift
//  Sertifikasi
//
//  Created by Nicholas Dylan Lienardi on 23/11/24.
//

import SwiftUI

struct BookView: View {
    @ObservedObject var viewModel: BookViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    @ObservedObject var borrowedBookViewModel: BorrowedBookViewModel
    @State private var showingAddBookSheet = false  // State to control when the sheet is presented
    @State private var showingEditBookSheet = false  // State for the edit sheet
    
    // State variables for new book
    @State private var newBookName = ""
    @State private var newBookAuthor = ""
    
    // State variables for editing a book
    @State private var editedBookID: Int64?
    @State private var editedBookName = ""
    @State private var editedBookAuthor = ""
    
    @State private var selectedCategoryID: Int64? = nil
    
    var body: some View {
        VStack {
            // Category filter
            HStack {
                Text("Filter by Category:")
                    .font(.subheadline)
                Picker("Select Category", selection: $selectedCategoryID) {
                    Text("All").tag(Int64?.none) // Option to show all books
                    ForEach(categoryViewModel.categories, id: \.categoryID) { category in
                        Text(category.name).tag(Int64?.some(category.categoryID))
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding()
            // Button to trigger the fetch of books
            Button("Load Books") {
                viewModel.readBooks()
                categoryViewModel.readCategory()
            }
            
            // Display books in a List with swipe-to-delete functionality
            List {
                ForEach(filteredBooks, id: \.bookID) { book in
                    VStack(alignment: .leading) {
                        Text("Book Title: \(book.name)")
                            .font(.headline)
                        Text("Book Author: \(book.author)")
                            .font(.subheadline)
                        Text("Categories: \(categoryViewModel.getSelectedCategories(categoryID: viewModel.fetchCategoryPerBook(bookID: book.bookID)))")
                    }
                    .onTapGesture {
                        // Set the book details into the edit state and show the edit sheet when the book is tapped
                        editedBookID = book.bookID
                        editedBookName = book.name
                        editedBookAuthor = book.author
                        showingEditBookSheet.toggle()
                    }
                }
                .onDelete(perform: deleteBook)  // Swipe to delete functionality
            }
            .onAppear {
                // Automatically load books when the view appears
                categoryViewModel.readCategory()
                viewModel.readBooks()
            }
            
            // Button to show the modal sheet for creating a new book
            Button("Add New Book") {
                showingAddBookSheet.toggle()
            }
            .padding()
            .sheet(isPresented: $showingAddBookSheet) {
                AddBookSheet(viewModel: viewModel, categoryViewModel: categoryViewModel, showingSheet: $showingAddBookSheet, newBookName: $newBookName, newBookAuthor: $newBookAuthor)
            }
            
            // Edit Book Modal
            .sheet(isPresented: $showingEditBookSheet) {
                EditBookSheet(viewModel: viewModel, categoryViewModel: categoryViewModel, showingSheet: $showingEditBookSheet, editedBookID: $editedBookID, editedBookName: $editedBookName, editedBookAuthor: $editedBookAuthor)
            }
        }
        .padding()
    }
    
    // Filtered books based on selected category
    private var filteredBooks: [Book] {
        if let selectedCategoryID = selectedCategoryID {
            return viewModel.books.filter { book in
                let bookCategories = viewModel.fetchCategoryPerBook(bookID: book.bookID)
                return bookCategories.contains(selectedCategoryID)
            }
        } else {
            return viewModel.books
        }
    }
    
    // Delete book function
    func deleteBook(at offsets: IndexSet) {
        // Delete the book at the given index
        if let index = offsets.first {
            let book = viewModel.books[index]
            viewModel.deleteBook(bookID: book.bookID)
            borrowedBookViewModel.deleteBorowedBookBookID(id: book.bookID)
            viewModel.readBooks()  // Refresh the list of books
        }
    }
}

struct AddBookSheet: View {
    @ObservedObject var viewModel: BookViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    @Binding var showingSheet: Bool
    @Binding var newBookName: String
    @Binding var newBookAuthor: String
    @State var selectedCategories: Set<Int64> = [] // To keep track of selected categories
    
    var body: some View {
        if categoryViewModel.categories.isEmpty{
            VStack{
                Spacer()
                Text("Create a category first")
                Spacer()
            }
        } else {
            VStack {
                Text("Add New Book")
                    .font(.headline)
                
                TextField("Enter book name", text: $newBookName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Enter author name", text: $newBookAuthor)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Categories Selection
                VStack(alignment: .leading) {
                    Text("Select Categories")
                        .font(.subheadline)
                    ForEach(categoryViewModel.categories, id: \.categoryID) { category in
                        HStack {
                            Text(category.name) // Example, replace with actual category name
                            Spacer()
                            if selectedCategories.contains(category.categoryID) {
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                Image(systemName: "circle")
                            }
                        }
                        .onTapGesture {
                            if selectedCategories.contains(category.categoryID) {
                                selectedCategories.remove(category.categoryID)
                            } else {
                                selectedCategories.insert(category.categoryID)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                
                Button("Create Book") {
                    if !newBookName.isEmpty && !newBookAuthor.isEmpty {
                        let bookID = (viewModel.books.max(by: { $0.bookID < $1.bookID })?.bookID ?? 0) + 1
                        viewModel.createBook(bookID: bookID, name: newBookName, author: newBookAuthor)
                        viewModel.updateBookCategories(bookID: bookID, selectedCategories: selectedCategories)
                        
                        viewModel.readBooks() // Refresh the list of books
                        showingSheet = false
                        newBookName = ""
                        newBookAuthor = ""
                        selectedCategories.removeAll()
                    }
                }
                .padding()
                .disabled(newBookName.isEmpty || newBookAuthor.isEmpty || selectedCategories.isEmpty)
                
                Spacer()
            }
            .padding()
        }
    }
}


struct EditBookSheet: View {
    @ObservedObject var viewModel: BookViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    @Binding var showingSheet: Bool
    @Binding var editedBookID: Int64?
    @Binding var editedBookName: String
    @Binding var editedBookAuthor: String
    @State var selectedCategories: Set<Int64> = [] // To track selected categories
    
    var body: some View {
        VStack {
            Text("Edit Book")
                .font(.headline)
            
            // Input fields for editing the book
            TextField("Enter book name", text: $editedBookName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Enter author name", text: $editedBookAuthor)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Categories Selection
            VStack(alignment: .leading) {
                Text("Edit Categories")
                    .font(.subheadline)
                ForEach(categoryViewModel.categories, id: \.categoryID) { category in
                    HStack {
                        Text(category.name)
                        Spacer()
                        if selectedCategories.contains(category.categoryID) {
                            Image(systemName: "checkmark.circle.fill")
                        } else {
                            Image(systemName: "circle")
                        }
                    }
                    .onTapGesture {
                        if selectedCategories.contains(category.categoryID) {
                            selectedCategories.remove(category.categoryID)
                        } else {
                            selectedCategories.insert(category.categoryID)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding()
            
            // Update button
            Button("Update Book") {
                if let bookID = editedBookID, !editedBookName.isEmpty, !editedBookAuthor.isEmpty {
                    viewModel.updateBook(bookID: bookID, name: editedBookName, author: editedBookAuthor)
                    viewModel.updateBookCategories(bookID: bookID, selectedCategories: selectedCategories)
                    viewModel.readBooks()  // Refresh the book list
                    showingSheet = false  // Close the sheet
                    resetForm()
                }
            }
            .padding()
            .disabled(editedBookName.isEmpty || editedBookAuthor.isEmpty || selectedCategories.isEmpty)
            
            Spacer()
        }
        .padding()
        .onAppear {
            loadInitialCategories()
        }
    }
    
    // Load the initial categories associated with the book
    private func loadInitialCategories() {
        if let bookID = editedBookID {
            selectedCategories = Set(viewModel.fetchCategoryPerBook(bookID: bookID))
        }
    }
    
    // Reset form state
    private func resetForm() {
        editedBookName = ""
        editedBookAuthor = ""
        selectedCategories.removeAll()
    }
}
