//
//  HomeView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import SwiftUI
import Foundation

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink("Scan Barcode", destination: ScanView())
                NavigationLink("Blacklisted Ingredients", destination: BlacklistView())
                NavigationLink("Results History", destination: HistoryView())
            }
            .navigationTitle("Not in My Breakfast")
        }
    }
}

struct Previews_HomeView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
