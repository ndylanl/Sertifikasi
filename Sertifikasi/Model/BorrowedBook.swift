//
//  BorrowedBook.swift
//  Sertifikasi
//
//  Created by Nicholas Dylan Lienardi on 23/11/24.
//
import Foundation

struct BorrowedBook{
    var borrowID: Int64
    var userID: Int64
    var bookID: Int64
    var borrowDate: Date
    var returnDate: Date?
}
