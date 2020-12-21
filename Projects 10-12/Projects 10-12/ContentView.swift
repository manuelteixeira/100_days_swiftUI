//
//  ContentView.swift
//  Projects 10-12
//
//  Created by Manuel Teixeira on 14/12/2020.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var users: FetchedResults<User>
    
    var body: some View {
        NavigationView {
            List(users, id: \.id) { user in
                NavigationLink(destination: DetailView(user: user)) {
                    VStack(alignment: .leading) {
                        Text(user.wrappedName)
                            .font(.headline)
                        Text("\(user.age)")
                        Text(user.wrappedEmail)
                            .font(.subheadline)
                    }
                }
            }
            .onAppear(perform: loadData)
            .navigationBarTitle("Users")
        }
    }
    
    func loadData() {
        if users.isEmpty {
            let url = URL(string: "https://www.hackingwithswift.com/samples/friendface.json")
            let request = URLRequest(url: url!)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else { return }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.userInfo[CodingUserInfoKey.context!] = self.moc
                if let decodedUsers = try? decoder.decode([User].self, from: data) {
                    print(decodedUsers)
                }
                
            }.resume()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
