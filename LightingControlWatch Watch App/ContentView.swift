//
//  ContentView.swift
//  LightingControlWatch Watch App
//
//  Created by Filip Skup on 05/11/2025.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var intensityWindow: Double = 5  // zakres 1–10
    @State private var debounceWorkItem: DispatchWorkItem? = nil
    @State private var network = NetworkManager.shared
    
    // Adres IP Twojego ESP32
    let baseURL = "http://192.168.0.147"
    var body: some View {
        VStack {
            Text("LED Okno")
                .font(.title2)
                .bold()
            
            Button("Włącz LED Okno") {
                network.sendRequest(path: "/on1")
            }
            .buttonStyle(.borderedProminent)
            
            Button("Wyłącz LED Okno") {
                network.sendRequest(path: "/off1")
            }
            .buttonStyle(.bordered)
            VStack {
                Text("Jasność okna: \(Int(intensityWindow)) / 10")
                    .focusable(true) // pozwala kontrolować koronką
                    .digitalCrownRotation(
                        $intensityWindow,
                        from: 1,
                        through: 10,
                        by: 1,
                        sensitivity: .medium,
                        isContinuous: false,
                        isHapticFeedbackEnabled: true
                    )
                    .onChange(of: intensityWindow) { _, newValue in
                        debounceWorkItem?.cancel()
                    
                        let workItem = DispatchWorkItem {
                            let mappedValue = 11 - Int(newValue)
                            network.updateVariable(value: mappedValue)
                        }
                    
                        debounceWorkItem = workItem
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: workItem)
                    }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
