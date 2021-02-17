//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Manuel Teixeira on 12/02/2021.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }

    enum SortFilter {
        case name, mostRecent
    }

    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var isShowingSort = false
    @State private var sortFilter: SortFilter = .name

    let filter: FilterType

    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }

    var filterProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people.sorted {
                switch sortFilter {
                case .name:
                    return $0.name < $1.name
                case .mostRecent:
                    return $0.dateAdded < $1.dateAdded
                }
            }
        case .contacted:
            return prospects.people.filter { $0.isContacted }.sorted {
                switch sortFilter {
                case .name:
                    return $0.name < $1.name
                case .mostRecent:
                    return $0.dateAdded < $1.dateAdded
                }
            }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }.sorted {
                switch sortFilter {
                case .name:
                    return $0.name < $1.name
                case .mostRecent:
                    return $0.dateAdded < $1.dateAdded
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filterProspects) { prospect in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        .contextMenu(ContextMenu(menuItems: {
                            Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted") {
                                prospects.toggle(prospect)
                            }

                            if !prospect.isContacted {
                                Button("Remind me") {
                                    addNotifications(for: prospect)
                                }
                            }
                        }))

                        Spacer()

                        if filter == .none && prospect.isContacted {
                            Image(systemName: "checkmark.seal.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationBarTitle(title)
            .navigationBarItems(leading:
                Button(action: {
                    isShowingSort = true
                }, label: {
                    Image(systemName: "arrow.up.arrow.down.square.fill")
                    Text("Sort")
                })
                , trailing: Button(action: {
                    self.isShowingScanner = true
                }, label: {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                }))
            .sheet(isPresented: $isShowingScanner, content: {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
            })
            .actionSheet(isPresented: $isShowingSort, content: {
                ActionSheet(title: Text("Sort by"), message: nil, buttons: [
                    .default(Text("Name")) { sortFilter = .name },
                    .default(Text("Most recent")) { sortFilter = .mostRecent },
                    .cancel()
                ])
            })
        }
    }

    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        isShowingScanner = false

        switch result {
        case let .success(code):
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }

            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            prospects.add(person)

            let person1 = Prospect()
            person1.name = "Manel"
            person1.emailAddress = "manel@apple.com"
            prospects.add(person1)
        case let .failure(error):
            print(error.localizedDescription)
        }
    }

    func addNotifications(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default

//            var dateComponents = DateComponents()
//            dateComponents.hour = 9
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            center.add(request)
        }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
                    if success {
                        addRequest()
                    } else {
                        print("Doh")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        var prospects = Prospects()

        ProspectsView(filter: .none)
            .environmentObject(prospects)
    }
}
