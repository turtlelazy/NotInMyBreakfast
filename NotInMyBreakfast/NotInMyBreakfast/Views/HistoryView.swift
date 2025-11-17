//
//  HistoryView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/17/25.
//

import Foundation
import SwiftUI

struct HistoryView: View {
    @State private var history: [String] = ["737628064502", "5000159484695"]
    
    var body: some View {
        List(history, id: \.self) { code in
            Text(code)
        }
        .navigationTitle("Scan History")
    }
}
