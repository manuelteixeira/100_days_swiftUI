//
//  AddActivity.swift
//  Projects 7-9
//
//  Created by Manuel Teixeira on 13/11/2020.
//

import SwiftUI

struct AddActivity: View {
    @ObservedObject var activityList: ActivityList

    @State private var title = ""
    @State private var description = ""

    var body: some View {
        Form {
            Section(header: Text("Activity information")) {
                TextField("Write here the title", text: $title)
                TextField("Write here the description", text: $description)
            }
            .padding(.top)
        }
        .onDisappear {
            saveActivity()
        }
    }

    func saveActivity() {
        let activity = Activity(title: title, description: description)
        activityList.activities.append(activity)

        UserDefaults.save(activityList: activityList)
    }
}

struct AddActivity_Previews: PreviewProvider {
    static var previews: some View {
        let activity = Activity(title: "Activity 1", description: "Description 1")
        let activityList = ActivityList(activities: [activity])
        AddActivity(activityList: activityList)
    }
}
