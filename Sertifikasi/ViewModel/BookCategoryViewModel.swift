//
//  BookCategoryViewModel.swift
//  Sertifikasi
//
//  Created by Nicholas Dylan Lienardi on 23/11/24.
//
import Foundation
import SQLite

class BookCategoryViewModel: ObservableObject{
    var bookCategories: [BookCategory] = []
    
    let bookCategoriesSQL = Table("BookCategory")
    
    let idSQL = SQLite.Expression<Int64>("book_category_id")
    let bookIDSQL = SQLite.Expression<Int64>("book_id")
    let categoryIDSQL = SQLite.Expression<Int64>("category_id")
    
    func createBookCategory(id: Int64, bookID: Int64, categoryID: Int64) {
        do {
            let db = try connectDB()
            try db.run(bookCategoriesSQL.insert(
                idSQL <- id,
                bookIDSQL <- bookID,
                categoryIDSQL <- categoryID
            ))
        } catch {
            print(error)
        }
    }
    
    func readBookCategory() {
        do {
            let db = try connectDB()
            let query = try db.prepare(bookCategoriesSQL)
            self.bookCategories = query.map { row in
                BookCategory(
                    id: row[idSQL],
                    bookID: row[bookIDSQL],
                    categoryID: row[categoryIDSQL])
            }
        } catch {
            print("Error fetching books: \(error)")
        }
    }
    
    func updateBookCategory(id: Int64, bookID: Int64, categoryID: Int64) {
        do {
            let db = try connectDB()
            let target = bookCategoriesSQL.filter(idSQL == id)
            try db.run(target.update(
                bookIDSQL <- bookID,
                categoryIDSQL <- categoryID
            ))
        } catch {
            print(error)
        }
    }
    
    func deleteBookCategory(id: Int64) {
        do {
            let db = try connectDB()
            let target = bookCategoriesSQL.filter(idSQL == id)
            try db.run(target.delete())
        } catch {
            print(error)
        }
    }
    
    func deleteBookCategoryCategoryID(id: Int64){
        do {
            let db = try connectDB()
            let target = bookCategoriesSQL.filter(categoryIDSQL == id)
            try db.run(target.delete())
        } catch {
            print(error)
        }
    }
}
