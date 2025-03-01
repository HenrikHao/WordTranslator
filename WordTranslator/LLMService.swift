import Foundation

enum LLMServiceError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

class LLMService {
    static let shared = LLMService()
    
    private init() {}
    
    func translateText(_ text: String, apiKey: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Create the request
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create the request body
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful translation assistant. Translate the given word to English and provide a brief explanation of its meaning."
                ],
                [
                    "role": "user",
                    "content": "Translate this word: \(text)"
                ]
            ],
            "temperature": 0.7,
            "max_tokens": 150
        ]
        
        // Convert the request body to JSON data
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Make the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(LLMServiceError.requestFailed(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(LLMServiceError.invalidResponse))
                return
            }
            
            do {
                // Parse the response
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(.success(content.trimmingCharacters(in: .whitespacesAndNewlines)))
                } else {
                    completion(.failure(LLMServiceError.invalidResponse))
                }
            } catch {
                completion(.failure(LLMServiceError.decodingFailed(error)))
            }
        }
        
        task.resume()
    }
}
