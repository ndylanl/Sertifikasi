//
//  BookViewModel.swift
//  Sertifikasi
//
//  Created by Nicholas Dylan Lienardi on 23/11/24.
//
// BookViewModel.swift

import Foundation
import SQLite

class BookViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var bookCategories: [BookCategory] = []
    
    let booksSQL = Table("Book")
    let bookCategoriesSQL = Table("BookCategory")
    
    let bookIDSQL = SQLite.Expression<Int64>("book_id")
    let nameSQL = SQLite.Expression<String>("book_name")
    let authorSQL = SQLite.Expression<String>("book_author")
    let categoryIDSQL = SQLite.Expression<Int64>("category_id")
    
    let bookCategoryIDSQL = SQLite.Expression<Int64>("book_category_id")
    let bookIDFKSQL = SQLite.Expression<Int64>("book_id") // FK to Book
    let categoryIDFKSQL = SQLite.Expression<Int64>("category_id") // FK to Category
    
    func createBook(bookID: Int64, name: String, author: String) {
        do {
            let db = try connectDB()
            try db.run(booksSQL.insert(bookIDSQL <- bookID, nameSQL <- name, authorSQL <- author))
        } catch {
            print(error)
        }
    }
    
    func readBooks() {
        do {
            let db = try connectDB()
            let query = try db.prepare(booksSQL)
            self.books = query.map { row in
                Book(
                    bookID: row[bookIDSQL],
                    name: row[nameSQL],
                    author: row[authorSQL]
                )
            }
        } catch {
            print("Error fetching books: \(error)")
        }
        fetchCategoriesForBook()
    }
    
    func updateBook(bookID: Int64, name: String, author: String) {
        do {
            let db = try connectDB()
            let target = booksSQL.filter(bookIDSQL == bookID)
            try db.run(target.update(nameSQL <- name, authorSQL <- author))
        } catch {
            print(error)
        }
    }
    
    func deleteBook(bookID: Int64) {
        do {
            let db = try connectDB()
            let target = booksSQL.filter(bookIDSQL == bookID)
            try db.run(target.delete())
        } catch {
            print(error)
        }
    }
    
    func fetchCategoriesForBook() {
        do {
            let db = try connectDB()
            let query = try db.prepare(bookCategoriesSQL)
            self.bookCategories = query.map { row in
                BookCategory(
                    id: row[bookCategoryIDSQL],
                    bookID: row[bookIDFKSQL],
                    categoryID: row[categoryIDFKSQL])
            }
        } catch {
            print("Error fetching books: \(error)")
        }
    }
    
    func fetchCategoryPerBook(bookID: Int64) -> [Int64]{
        var categories: [Int64] = []
        
        for bookCategory in bookCategories {
            if bookCategory.bookID == bookID {
                categories.append(bookCategory.categoryID)
            }
        }
        return categories
    }
    
    func updateBookCategories(bookID: Int64, selectedCategories: Set<Int64>) {
        do {
            let db = try connectDB()
            // Remove existing categories for this book
            let categoriesToDelete = bookCategoriesSQL.filter(bookIDSQL == bookID)
            try db.run(categoriesToDelete.delete())
            
            // Add new selected categories for this book
            for categoryID in selectedCategories {
                try db.run(bookCategoriesSQL.insert(bookIDSQL <- bookID, categoryIDSQL <- categoryID))
            }
        } catch {
            print("Error updating categories: \(error)")
        }
    }
}
