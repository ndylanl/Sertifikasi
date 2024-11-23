//
//  SertifikasiApp.swift
//  Sertifikasi
//
//  Created by Nicholas Dylan Lienardi on 21/11/24.
//

import SwiftUI
import SwiftData

@main
struct SertifikasiApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear{
                    createTables()
                }
        }
    }
}
