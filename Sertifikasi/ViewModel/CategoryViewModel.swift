//
//  CategoryViewModel.swift
//  Sertifikasi
//
//  Created by Nicholas Dylan Lienardi on 23/11/24.
//

import Foundation
import SQLite

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    
    let categoriesSQL = Table("Category")
    
    let categoryIDSQL = SQLite.Expression<Int64>("category_id")
    let nameSQL = SQLite.Expression<String>("category_name")
    
    func createCategory(categoryID: Int64, name: String) {
        do {
            let db = try connectDB()
            try db.run(categoriesSQL.insert(categoryIDSQL <- categoryID, nameSQL <- name))
        } catch {
            print(error)
        }
    }
    
    func readCategory() {
        do {
            let db = try connectDB()
            let query = try db.prepare(categoriesSQL)
            self.categories = query.map { row in
                Category(
                    categoryID: row[categoryIDSQL],
                    name: row[nameSQL]
                )
            }
        } catch {
            print("Error fetching books: \(error)")
        }
    }
    
    func updateCategory(categoryID: Int64, name: String) {
        do {
            let db = try connectDB()
            let target = categoriesSQL.filter(categoryIDSQL == categoryID)
            try db.run(target.update(nameSQL <- name))
        } catch {
            print(error)
        }
    }
    
    func deleteCategory(categoryID: Int64) {
        do {
            let db = try connectDB()
            let target = categoriesSQL.filter(categoryIDSQL == categoryID)
            try db.run(target.delete())
        } catch {
            print(error)
        }
    }
    
    func getSelectedCategories(categoryID: [Int64]) -> [String]{
        var categories: [String] = []
        
        for category in self.categories{
            for categoryId in categoryID{
                if category.categoryID == categoryId{
                    categories.append(category.name)
                }
            }
        }
        
        return categories
    }
}
