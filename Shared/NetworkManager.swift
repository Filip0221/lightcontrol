//
//  NetworkManager.swift
//  LightingControl
//
//  Created by Filip Skup on 05/11/2025.
//

import Observation
import Foundation

/// Klasa odpowiedzialna za komunikację z ESP32.
@Observable
final class NetworkManager {
    static let shared = NetworkManager() // singleton, współdzielony między widokami
    
    var statusMessage: String = "Gotowy"
    
    /// Adres IP Twojego ESP32
    private let baseURL = "http://192.168.0.147"
    
    private init() {} // blokada tworzenia wielu instancji
    
    // MARK: - Public API
    
    /// Wysyła prosty GET request (np. /on1, /off1)
    func sendRequest(path: String) {
        guard let url = URL(string: baseURL + path) else { return }
        Task { @MainActor in
            statusMessage = "Wysyłam żądanie..."
        }
        
        URLSession.shared.dataTask(with: url) { _, response, error in
            Task { @MainActor in
                if let error = error {
                    self.statusMessage = "Błąd: \(error.localizedDescription)"
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.statusMessage = "OK — \(path) wykonano"
                } else {
                    self.statusMessage = "Nieoczekiwany błąd"
                }
            }
        }.resume()
    }
    
    /// Wysyła żądanie do zmiany jasności (np. /update_var?value=5)
    func updateVariable(value: Int) {
        guard let url = URL(string: "\(baseURL)/update_var?value=\(value)") else { return }
        Task { @MainActor in
            statusMessage = "Aktualizuję jasność..."
        }
        
        URLSession.shared.dataTask(with: url) { _, response, error in
            Task { @MainActor in
                if let error = error {
                    self.statusMessage = "Błąd: \(error.localizedDescription)"
                } else {
                    self.statusMessage = "Jasność ustawiona na \(value)"
                }
            }
        }.resume()
    }
}
