//
//  ContentView.swift
//  LightingControl
//
//  Created by Filip Skup on 05/11/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var intensityWindow: Double = 5  // zakres 1–10
    @State private var debounceWorkItem: DispatchWorkItem? = nil
    @State private var network = NetworkManager.shared   // wspólny manager sieci

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Sterowanie Oświetleniem")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                
                // MARK: LED OKNO
                Group {
                    Text("💡 LED Okno")
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
                        Slider(value: $intensityWindow, in: 1...10, step: 1)
                            .tint(.blue)
                            .padding(.horizontal, 20)
                            .onChange(of: intensityWindow) { oldValue, newValue in
                                // Debounce — opóźnione wysyłanie komendy (2 sekundy po ostatnim ruchu)
                                debounceWorkItem?.cancel()
                                let workItem = DispatchWorkItem {
                                    let mappedValue = 11 - Int(newValue) // odwrócona skala 1–10 → 10–1
                                    network.updateVariable(value: mappedValue)
                                }
                                debounceWorkItem = workItem
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
                            }
                    }
                }
                
                Divider().padding(.vertical, 10)
                
                // MARK: LED CHOINKA
                Group {
                    Text("🎄 LED Choinka")
                        .font(.title2)
                        .bold()
                    
                    Button("Włącz LED Choinka") {
                        network.sendRequest(path: "/on2")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Fade Choinka") {
                        network.sendRequest(path: "/fade")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Wyłącz LED Choinka") {
                        network.sendRequest(path: "/off2")
                    }
                    .buttonStyle(.bordered)
                }
                
                Text(network.statusMessage)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
