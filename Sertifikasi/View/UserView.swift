//
//  UserView.swift
//  Sertifikasi
//
//  Created by Nicholas Dylan Lienardi on 23/11/24.
//

import SwiftUI

struct UserView: View {
    @ObservedObject var userViewModel : UserViewModel
    @ObservedObject var bookViewModel : BookViewModel
    @ObservedObject var borrowedBookViewModel: BorrowedBookViewModel
    @State private var selectedUserID: Int64?
    @State private var showingCreateUserSheet = false
    @State private var showingEditUserSheet = false
    @State private var selectedUser: User?
    @State private var editedUserID: Int64?
    
    var body: some View {
        VStack {
            Button("Load Users") {
                userViewModel.readUsers()
                bookViewModel.readBooks()
                borrowedBookViewModel.readBorrowedBooks()
            }
            
            List {
                ForEach(userViewModel.users, id: \.userID) { user in
                    VStack(alignment: .leading) {
                        Text("Username: \(user.name)")
                            .font(.headline)
                        Text("Telephone: \(user.telephone)")
                            .font(.subheadline)
                        Text("Address: \(user.address)")
                            .font(.subheadline)
                        
                        // Borrowed books section
                        Text("Borrowed Books:")
                            .font(.subheadline)
                            .padding(.top, 5)
                        
                        ForEach(borrowedBookViewModel.fetchBookPerUser(userID: user.userID), id: \.self) { bookID in
                            if let book = bookViewModel.books.first(where: { $0.bookID == bookID }) {
                                Text("- \(book.name)")
                                    .font(.body)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .onTapGesture {
                        userViewModel.readUsers()
                        bookViewModel.readBooks()
                        borrowedBookViewModel.readBorrowedBooks()
                        selectedUser = user
                        editedUserID = user.userID
                        showingEditUserSheet.toggle() // Show the edit sheet when tapped
                    }
                }
                .onDelete(perform: deleteUser) // Swipe-to-delete
            }
            .onAppear{
                userViewModel.readUsers()
                bookViewModel.readBooks()
                borrowedBookViewModel.readBorrowedBooks()
            }
            
            // Button to show the modal sheet for creating a new user
            Button("Add New User") {
                userViewModel.readUsers()
                showingCreateUserSheet.toggle()
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingCreateUserSheet) {
            // The content of the modal sheet for creating a new user
            UserCreateView(userViewModel: userViewModel)
        }
        .sheet(isPresented: $showingEditUserSheet) {
            // The content of the modal sheet for editing the user
            if let user = selectedUser {
                UserEditView(userViewModel: userViewModel, user: user, bookViewModel: bookViewModel, borrowedBookViewModel: borrowedBookViewModel, editedUserID: editedUserID!)
            }
        }
    }
    
    // Delete user method
    private func deleteUser(at offsets: IndexSet) {
        for index in offsets {
            let user = userViewModel.users[index]
            userViewModel.deleteUser(userID: user.userID)
            userViewModel.readUsers() // Refresh the list after deletion
        }
    }
}

struct UserEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var userName: String
    @State private var userTelephone: String
    @State private var userAddress: String
    @State private var editedUserID: Int64?
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var bookViewModel: BookViewModel
    @ObservedObject var borrowedBookViewModel: BorrowedBookViewModel
    
    @State var selectedBooks: Set<Int64> = [] // To keep track of selected categories
    
    var user: User
    
    init(userViewModel: UserViewModel, user: User, bookViewModel: BookViewModel, borrowedBookViewModel: BorrowedBookViewModel, editedUserID: Int64) {
        _userName = State(initialValue: user.name)
        _userTelephone = State(initialValue: user.telephone)
        _userAddress = State(initialValue: user.address)
        self.userViewModel = userViewModel
        self.bookViewModel = bookViewModel
        self.borrowedBookViewModel = borrowedBookViewModel
        self.user = user
        self.editedUserID = editedUserID
    }
    
    var body: some View {
        VStack {
            Text("Edit User")
                .font(.headline)
            
            TextField("Enter Name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Enter Telephone", text: $userTelephone)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Enter Address", text: $userAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Categories Selection
            if !bookViewModel.books.isEmpty{
                VStack(alignment: .leading) {
                    Text("Borrow Books")
                        .font(.subheadline)
                    ForEach(bookViewModel.books, id: \.bookID) { book in
                        HStack {
                            Text(book.name)
                            Spacer()
                            if selectedBooks.contains(book.bookID) {
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                Image(systemName: "circle")
                            }
                        }
                        .onTapGesture {
                            if selectedBooks.contains(book.bookID) {
                                selectedBooks.remove(book.bookID)
                            } else {
                                selectedBooks.insert(book.bookID)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
            }
            
            Button("Update User") {
                if !userName.isEmpty && !userTelephone.isEmpty && !userAddress.isEmpty {
                    userViewModel.updateUser(userID: user.userID, name: userName, telephone: userTelephone, address: userAddress)
                    borrowedBookViewModel.updateUserBorrowsBook(userID: user.userID, selectedBooks: selectedBooks)
                    
                    borrowedBookViewModel.readBorrowedBooks()
                    userViewModel.readUsers() // Refresh the list
                    presentationMode.wrappedValue.dismiss() // Dismiss the sheet
                } else {
                    print("not valid")
                }
            }
            .padding()
            .disabled(userName.isEmpty || userTelephone.isEmpty || userAddress.isEmpty) // Disable if inputs are empty
            
            Spacer()
        }
        .padding()
        .onAppear {
            loadInitialBooks()
        }
    }
    private func loadInitialBooks() {
        selectedBooks = Set(borrowedBookViewModel.fetchBookPerUser(userID: user.userID))
    }
}

struct UserCreateView: View {
    @Environment(\.presentationMode) var presentationMode // To dismiss the sheet
    @State private var userName: String = ""
    @State private var userTelephone: String = ""
    @State private var userAddress: String = ""
    @ObservedObject var userViewModel: UserViewModel // Injected UserViewModel
    
    var body: some View {
        VStack {
            Text("Create New User")
                .font(.headline)
            
            TextField("Enter Name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Enter Telephone", text: $userTelephone)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Enter Address", text: $userAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Create User") {
                // Call the createUser method from the UserViewModel to add a new user
                if !userName.isEmpty && !userTelephone.isEmpty && !userAddress.isEmpty {
                    let userID = (userViewModel.users.max(by: { $0.userID < $1.userID })?.userID ?? 0) + 1
                    userViewModel.createUser(userID: userID, name: userName, telephone: userTelephone, address: userAddress)
                    userViewModel.readUsers() // Refresh the list of users
                    
                    // Dismiss the sheet
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            .disabled(userName.isEmpty || userTelephone.isEmpty || userAddress.isEmpty) // Disable if inputs are empty
            
            Spacer()
        }
        .padding()
    }
}
