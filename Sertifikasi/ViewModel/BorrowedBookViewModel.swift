//
//  BorrowedBookViewModel.swift
//  Sertifikasi
//
//  Created by Nicholas Dylan Lienardi on 23/11/24.
//

import Foundation
import SQLite

class BorrowedBookViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var users: [User] = []  // Add a property to store categories
    @Published var borrowedBooks: [BorrowedBook] = []
    
    let borrowedBooksSQL = Table("BorrowedBook")
    
    let borrowIDSQL = SQLite.Expression<Int64>("borrowed_book_id")
    let userIDSQL = SQLite.Expression<Int64>("customer_id")
    let bookIDSQL = SQLite.Expression<Int64>("book_id")
    let borrowDateSQL = SQLite.Expression<Date>("borrow_date")
    let returnDateSQL = SQLite.Expression<Date?>("return_date")
    
    func createBorrowedBook(borrowID: Int64, userID: Int64, bookID: Int64, borrowDate: Date, returnDate: Date?) {
        do {
            let db = try connectDB()
            try db.run(borrowedBooksSQL.insert(
                borrowIDSQL <- borrowID,
                userIDSQL <- userID,
                bookIDSQL <- bookID,
                borrowDateSQL <- borrowDate,
                returnDateSQL <- returnDate
            ))
        } catch {
            print(error)
        }
    }
    
    func readBorrowedBooks() {
        do {
            let db = try connectDB()
            let query = try db.prepare(borrowedBooksSQL)
            self.borrowedBooks = query.map { row in
                BorrowedBook(
                    borrowID: row[borrowIDSQL],
                    userID: row[userIDSQL],
                    bookID: row[bookIDSQL],
                    borrowDate: row[borrowDateSQL]
                )
            }
        } catch {
            print(error)
        }
    }
    
    func updateBorrowedBook(borrowID: Int64, userID: Int64, bookID: Int64, borrowDate: Date, returnDate: Date?) {
        do {
            let db = try connectDB()
            let target = borrowedBooksSQL.filter(borrowIDSQL == borrowID)
            try db.run(target.update(
                userIDSQL <- userID,
                bookIDSQL <- bookID,
                borrowDateSQL <- borrowDate,
                returnDateSQL <- returnDate
            ))
        } catch {
            print(error)
        }
    }
    
    func updateUserBorrowsBook(userID: Int64, selectedBooks: Set<Int64>) {
        do {
            let db = try connectDB()
            
            // Remove all previous book borrowings for this user
            let booksToDelete = borrowedBooksSQL.filter(userIDSQL == userID)
            try db.run(booksToDelete.delete())
            
            // Remove the selected books from other users
            for bookID in selectedBooks {
                let otherUsersBooks = borrowedBooksSQL.filter(bookIDSQL == bookID)
                try db.run(otherUsersBooks.delete())
            }
            
            // Add new selected books for the current user
            for bookID in selectedBooks {
                try db.run(borrowedBooksSQL.insert(
                    userIDSQL <- userID,
                    bookIDSQL <- bookID,
                    borrowDateSQL <- Date(),
                    returnDateSQL <- Date()
                ))
            }
        } catch {
            print("Error updating user borrows: \(error)")
        }
    }

    
    func deleteBorrowedBook(borrowID: Int64) {
        do {
            let db = try connectDB()
            let target = borrowedBooksSQL.filter(borrowIDSQL == borrowID)
            try db.run(target.delete())
        } catch {
            print(error)
        }
    }
    
    func deleteBorowedBookBookID(id: Int64){
        do {
            let db = try connectDB()
            let target = borrowedBooksSQL.filter(bookIDSQL == id)
            try db.run(target.delete())
        } catch {
            print(error)
        }
    }
    
    func calcBorrowedBookCount(userID: Int64) -> Int{
        var borrowedBookCount = 0
        
        for borrowedBook in borrowedBooks {
            if borrowedBook.userID == userID {
                borrowedBookCount += 1
            }
        }
        return borrowedBookCount
    }
    
    func fetchBookPerUser(userID: Int64) -> [Int64]{
        var books: [Int64] = []
        
        for borrowedBook in borrowedBooks {
            if borrowedBook.userID == userID {
                books.append(borrowedBook.bookID)
            }
        }
        
        return books
    }
}
