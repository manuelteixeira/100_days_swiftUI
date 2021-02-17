# Day 85 - Project 16, part 7

- Challenge
    1. Add an icon to the “Everyone” screen showing whether a prospect was contacted or not.

        ```swift
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
        ```

    2. Use JSON and the documents directory for saving and loading our user data.

        ```swift
        init() {
            let url = FileManager.getDocumentsDirectory().appendingPathComponent(Self.saveKey)

            do {
                let data = try Data(contentsOf: url)
                
                if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                    people = decoded
                    return
                }
            } catch {
                print(error.localizedDescription)
            }

            people = []
        }

        private func save() {
            if let encoded = try? JSONEncoder().encode(people) {
                let url = FileManager.getDocumentsDirectory().appendingPathComponent(Self.saveKey)

                do {
                    try encoded.write(to: url)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        ```

    3. Use an action sheet to customize the way users are sorted in each screen – by name or by most recent.

        ```swift
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
        ```

        ```swift
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
        ```