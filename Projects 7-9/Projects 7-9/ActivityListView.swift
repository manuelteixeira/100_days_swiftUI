//
//  ActivityListView.swift
//  Projects 7-9
//
//  Created by Manuel Teixeira on 13/11/2020.
//

import SwiftUI

struct ActivityListView: View {
    @ObservedObject var activityList = ActivityList()
    @State private var showAddActivity = false

    var body: some View {
        NavigationView {
            List(activityList.activities) { activity in
                NavigationLink(
                    destination: DetailView(activity: activity, activityList: activityList)) {
                    VStack {
                        Text(activity.title)
                            .font(.headline)
                        Text(activity.description)
                            .font(.subheadline)
                    }
                }
            }
            .navigationBarTitle("Activities")
            .navigationBarItems(trailing:
                Button(action: {
                    showAddActivity.toggle()
                }, label: {
                    Image(systemName: "plus")
                })
            )
            .sheet(isPresented: $showAddActivity) {
                AddActivity(activityList: activityList)
            }
        }
    }
}

struct ActivityListView_Previews: PreviewProvider {
    static var previews: some View {
        let activity = Activity(title: "Activity 1", description: "Description 1")
        let activityList = ActivityList(activities: [activity])
        ActivityListView(activityList: activityList)
    }
}
