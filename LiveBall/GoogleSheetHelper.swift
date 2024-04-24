import Foundation

func getClassNames(completion: @escaping ([String]?, Error?) -> Void) {
    // Check if class names are cached
    if let cached_class_names = UserDefaults.standard.stringArray(forKey: "CachedClassNames") {
        completion(cached_class_names, nil)
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
                let new_items = try JSONDecoder().decode([String].self, from: data)
                // Cache the class names
                UserDefaults.standard.set(new_items, forKey: "CachedClassNames")
                completion(new_items, nil)
            } catch {
                print("Error decoding JSON: \(error)")
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

            // Print status code
            print("Status Code: \(http_response.statusCode)")

            // Check for data
            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let new_items = try JSONDecoder().decode([String].self, from: data)
                // Cache the class names
                completion(new_items, nil)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }

        task.resume()
    } else {
        print("POST_SESSION_ENDPOINT environment variable is not set or is invalid.")
    }
}
