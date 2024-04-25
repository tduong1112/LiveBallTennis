import Foundation

func getClassNames(completion: @escaping ([String]?, Error?) -> Void) {
    // Check if class names are cached
    if let cached_class_names = UserDefaults.standard.stringArray(forKey: "CachedClassNames") {
        completion(cached_class_names, nil)
        print("Pulled Class Names From Cache")
        return
    }
    
    if let post_url_string = ProcessInfo.processInfo.environment["POST_SESSION_ENDPOINT"],
       let url_string = URL(string: post_url_string + "/class") {
        var request = URLRequest(url: url_string, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                completion(nil, error)
                return
            }
            
            do {
                let class_names = try JSONDecoder().decode([String].self, from: data)
                // Cache the class names
                UserDefaults.standard.set(class_names, forKey: "CachedClassNames")
                completion(class_names, nil)
            } catch {
                print("Error decoding Class Name JSON: \(error)")
                completion(nil, error)
            }
        }
        
        task.resume()
    } else {
        let error = NSError(domain: "Invalid URL", code: -1, userInfo: nil)
        completion(nil, error)
    }
}


func getPlayerNamesFromClass(class_name: String, completion: @escaping ([String]?, Error?) -> Void) {
    
    let parameters = "{\n    \"class_name\": \"\(class_name)\"\n\n}"
    let post_data = parameters.data(using: .utf8)
    
    if let post_url_string = ProcessInfo.processInfo.environment["POST_SESSION_ENDPOINT"],
        let url_string = URL(string: post_url_string + "/playerList") {
        var request = URLRequest(url: url_string, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = post_data

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for error
            if let error = error {
                print("Error: \(error)")
                return
            }

            // Check for response
            guard let http_response = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            // Check for data
            guard let data = data else {
                print("No data received")
                return
            }

            do {
                print("Player Names requested for \(class_name)")
                let player_names = try JSONDecoder().decode([String].self, from: data)
                completion(player_names, nil)

            } catch {
                print("Error decoding Player Name JSON: \(error)")
                let appDomain = Bundle.main.bundleIdentifier!
                UserDefaults.standard.removePersistentDomain(forName: appDomain)
            }
        }

        task.resume()
    } else {
        print("POST_SESSION_ENDPOINT environment variable is not set or is invalid.")
    }
}
