//
//  CategoryView.swift
//  Sertifikasi
//
//  Created by Nicholas Dylan Lienardi on 23/11/24.
//
import SwiftUI

struct CategoryView: View {
    @ObservedObject var viewModel: CategoryViewModel
    @ObservedObject var bookCategoryViewModel: BookCategoryViewModel
    @State private var showingAddCategorySheet = false
    @State private var showingEditCategorySheet = false
    
    // State variables for new category
    @State private var newCategoryName = ""
    
    // State variables for editing category
    @State private var editedCategoryID: Int64?
    @State private var editedCategoryName = ""
    
    var body: some View {
        VStack {
            // Button to load categories
            Button("Load Categories") {
                viewModel.readCategory()
                bookCategoryViewModel.readBookCategory()
            }
            
            // List to display categories
            List {
                ForEach(viewModel.categories, id: \.categoryID) { category in
                    VStack(alignment: .leading) {
                        Text(category.name)
                            .font(.headline)
                    }
                    .onTapGesture {
                        // Set the category details into the edit state and show the edit sheet when tapped
                        editedCategoryID = category.categoryID
                        editedCategoryName = category.name
                        showingEditCategorySheet.toggle()
                    }
                }
                .onDelete(perform: deleteCategory)  // Swipe to delete functionality
            }
            .onAppear {
                // Automatically load categories when the view appears
                viewModel.readCategory()
            }
            
            // Button to show the modal sheet for adding a new category
            Button("Add New Category") {
                showingAddCategorySheet.toggle()
            }
            .padding()
            .sheet(isPresented: $showingAddCategorySheet) {
                // The content of the modal sheet for adding a new category
                VStack {
                    Text("Add New Category")
                        .font(.headline)
                    
                    // Input fields for the new category
                    TextField("Enter category name", text: $newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    // Button to create the new category
                    Button("Create Category") {
                        // Call the createCategory method to insert the new category
                        if !newCategoryName.isEmpty {
                            let categoryID = (viewModel.categories.max(by: { $0.categoryID < $1.categoryID })?.categoryID ?? 0) + 1
                            viewModel.createCategory(categoryID: categoryID, name: newCategoryName)
                            viewModel.readCategory()  // Refresh the list of categories
                            showingAddCategorySheet = false  // Close the sheet
                            
                            // Reset fields
                            newCategoryName = ""
                        }
                    }
                    .padding()
                    .disabled(newCategoryName.isEmpty) // Disable if input is empty
                    
                    Spacer()
                }
                .padding()
            }
            
            // Edit Category Modal
            .sheet(isPresented: $showingEditCategorySheet) {
                // The content of the modal sheet for editing a category
                VStack {
                    Text("Edit Category")
                        .font(.headline)
                    
                    // Input fields for editing the category
                    TextField("Enter category name", text: $editedCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    // Button to update the category
                    Button("Update Category") {
                        // Call the updateCategory method to update the category details
                        if let categoryID = editedCategoryID, !editedCategoryName.isEmpty {
                            viewModel.updateCategory(categoryID: categoryID, name: editedCategoryName)
                            viewModel.readCategory()  // Refresh the list after updating
                            showingEditCategorySheet = false  // Close the sheet
                        }
                    }
                    .padding()
                    .disabled(editedCategoryName.isEmpty) // Disable if input is empty
                    
                    Spacer()
                }
                .padding()
            }
        }
        .padding()
    }
    
    // Delete category function
    func deleteCategory(at offsets: IndexSet) {
        // Delete the category at the given index
        if let index = offsets.first {
            let category = viewModel.categories[index]
            viewModel.deleteCategory(categoryID: category.categoryID)
            bookCategoryViewModel.deleteBookCategoryCategoryID(id: category.categoryID)
            viewModel.readCategory()  // Refresh the list of categories
            bookCategoryViewModel.readBookCategory()
        }
    }
}
