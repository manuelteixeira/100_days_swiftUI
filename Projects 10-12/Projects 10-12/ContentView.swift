//
//  ContentView.swift
//  Projects 10-12
//
//  Created by Manuel Teixeira on 14/12/2020.
//

import SwiftUI

struct ContentView: View {
    @State private var users = [User]()
    
    var body: some View {
        List(users, id: \.id) { user in
            VStack {
                Text(user.name)
                Text("\(user.age)")
                Text(user.email)
                Text(user.about)
                Text(user.address)
                Text(user.company)
                Text(user.formattedDate)
            }
        }
        .onAppear(perform: loadData)
    }
    
    func loadData() {
        let url = URL(string: "https://www.hackingwithswift.com/samples/friendface.json")
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let decodedUsers = try? decoder.decode([User].self, from: data) {
                users = decodedUsers
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
