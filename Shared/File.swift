// MARK: - Helper Functions
    
    /// Wysyła prosty GET request (np. /on1, /off1)
    func sendRequest(path: String) {
        guard let url = URL(string: baseURL + path) else { return }
        statusMessage = "Wysyłam żądanie..."
        
        URLSession.shared.dataTask(with: url) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    statusMessage = "Błąd: \(error.localizedDescription)"
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    statusMessage = "OK — \(path) wykonano"
                } else {
                    statusMessage = "Nieoczekiwany błąd"
                }
            }
        }.resume()
    }
    
    /// Wysyła żądanie do zmiany jasności (np. /update_var?value=5)
    func updateVariable(value: Int) {
        guard let url = URL(string: "\(baseURL)/update_var?value=\(value)") else { return }
        statusMessage = "Aktualizuję jasność..."
        
        URLSession.shared.dataTask(with: url) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    statusMessage = "Błąd: \(error.localizedDescription)"
                } else {
                    statusMessage = "Jasność ustawiona na \(value)"
                }
            }
        }.resume()
    }