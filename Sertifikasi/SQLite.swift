//
//  SQLite.swift
//  Sertifikasi
//
//  Created by Nicholas Dylan Lienardi on 22/11/24.
//

import Foundation
import SQLite

public func connectDB() throws -> Connection {
    do {
        let path = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory, .userDomainMask, true
        ).first! + "/" + Bundle.main.bundleIdentifier!
        
        // Create parent directory inside application support if it doesn’t exist
        try FileManager.default.createDirectory(
            atPath: path, withIntermediateDirectories: true, attributes: nil
        )
        
        let db = try Connection("\(path)/db.sqlite3")
        return db
    } catch {
        // Re-throw the error to the caller
        throw error
    }
}

func createTables(){
    do {
        // Get the path to the Application Support directory for the app
        let path = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory,
            .userDomainMask,
            true
        ).first! + "/" + Bundle.main.bundleIdentifier!
        
        // Create the directory if it doesn't exist
        try FileManager.default.createDirectory(
            atPath: path,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        let db = try connectDB()
        
        // Define the `User` table
        let userTable = Table("User")
        let userID = SQLite.Expression<Int64>("user_id")
        let userName = SQLite.Expression<String>("user_name")
        let userTelephone = SQLite.Expression<String>("user_telephone")
        let userAddress = SQLite.Expression<String>("user_address")
        
        try db.run(userTable.create(ifNotExists: true) { t in
            t.column(userID, primaryKey: true)
            t.column(userName)
            t.column(userTelephone)
            t.column(userAddress)
        })
//        Example of SQL Query
//        CREATE TABLE IF NOT EXISTS User (
//            user_id INTEGER PRIMARY KEY,
//            user_name TEXT,
//            user_telephone TEXT,
//            user_address TEXT
//        );

        
        // Define the `Category` table
        let categoryTable = Table("Category")
        let categoryID = SQLite.Expression<Int64>("category_id")
        let categoryName = SQLite.Expression<String>("category_name")
        
        try db.run(categoryTable.create(ifNotExists: true) { t in
            t.column(categoryID, primaryKey: true)
            t.column(categoryName)
        })
        
        // Define the `Book` table
        let bookTable = Table("Book")
        let bookID = SQLite.Expression<Int64>("book_id")
        let bookName = SQLite.Expression<String>("book_name")
        let bookAuthor = SQLite.Expression<String>("book_author")
        
        try db.run(bookTable.create(ifNotExists: true) { t in
            t.column(bookID, primaryKey: true)
            t.column(bookName)
            t.column(bookAuthor)
        })
        
        // Define the `BorrowedBook` table
        let borrowedBookTable = Table("BorrowedBook")
        let borrowedBookID = SQLite.Expression<Int64>("borrowed_book_id")
        let customerID = SQLite.Expression<Int64>("customer_id") // FK to User
        let borrowedBookIDFK = SQLite.Expression<Int64>("book_id") // FK to Book
        let borrowDate = SQLite.Expression<Date>("borrow_date")
        let returnDate = SQLite.Expression<Date>("return_date")
        
        try db.run(borrowedBookTable.create(ifNotExists: true) { t in
            t.column(borrowedBookID, primaryKey: true)
            t.column(customerID)
            t.column(borrowedBookIDFK)
            t.column(borrowDate)
            t.column(returnDate)
            t.foreignKey(customerID, references: userTable, userID, delete: .cascade)
            t.foreignKey(borrowedBookIDFK, references: bookTable, bookID, delete: .cascade)
        })
        
        // Define the `BookCategory` table
        let bookCategoryTable = Table("BookCategory")
        let bookCategoryID = SQLite.Expression<Int64>("book_category_id")
        let bookIDFK = SQLite.Expression<Int64>("book_id") // FK to Book
        let categoryIDFK = SQLite.Expression<Int64>("category_id") // FK to Category
        
        try db.run(bookCategoryTable.create(ifNotExists: true) { t in
            t.column(bookCategoryID, primaryKey: true)
            t.column(bookIDFK)
            t.column(categoryIDFK)
            t.foreignKey(bookIDFK, references: bookTable, bookID, delete: .cascade)
            t.foreignKey(categoryIDFK, references: categoryTable, categoryID, delete: .cascade)
        })
        
        print("Tables created successfully!")
    } catch {
        print("Error creating tables: \(error)")
    }
}
