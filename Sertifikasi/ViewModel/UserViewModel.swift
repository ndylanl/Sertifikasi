//
//  UserViewModel.swift
//  Sertifikasi
//
//  Created by Nicholas Dylan Lienardi on 23/11/24.
//

import Foundation
import SQLite

class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var selectedUserID: Int64? = nil
    
    let usersSQL = Table("User")
    let userIDSQL = SQLite.Expression<Int64>("user_id")
    let nameSQL = SQLite.Expression<String>("user_name")
    let telephoneSQL = SQLite.Expression<String>("user_telephone")
    let addressSQL = SQLite.Expression<String>("user_address")
    
    // Create a new user
    func createUser(userID: Int64, name: String, telephone: String, address: String) {
        do {
            let db = try connectDB()
            try db.run(usersSQL.insert(userIDSQL <- userID, nameSQL <- name, telephoneSQL <- telephone, addressSQL <- address))
        } catch {
            print(error)
        }
    }
    
    // Fetch all users
    func readUsers() {
        do {
            let db = try connectDB()
            let query = try db.prepare(usersSQL)
            self.users = query.map { row in
                User(
                    userID: row[userIDSQL],
                    name: row[nameSQL],
                    telephone: row[telephoneSQL],
                    address: row[addressSQL]
                )
            }
        } catch {
            print(error)
        }
    }
    
    // Update user details
    func updateUser(userID: Int64, name: String, telephone: String, address: String) {
        do {
            let db = try connectDB()
            let target = usersSQL.filter(userIDSQL == userID)
            try db.run(target.update(nameSQL <- name, telephoneSQL <- telephone, addressSQL <- address))
        } catch {
            print(error)
        }
    }
    
    // Delete a user
    func deleteUser(userID: Int64) {
        do {
            let db = try connectDB()
            let target = usersSQL.filter(userIDSQL == userID)
            try db.run(target.delete())
        } catch {
            print(error)
        }
    }
}
