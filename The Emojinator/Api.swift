//
//  Api.swift
//  The Emojinator
//
//  Created by Jason Dufair on 2/22/22.
//

import Foundation

class Api : ObservableObject {
    @Published var emojiList = [String]()
    
    func loadEmojiList(completion:@escaping ([String]) -> ()) {
        guard let url = URL(string: "https://emoji-server.azurewebsites.net/emojis") else {
            print("Invalid emojis URL")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                let emojiList = try! JSONDecoder().decode([String].self, from: data!)
                completion(emojiList)
            }
        }.resume()
    }
}
