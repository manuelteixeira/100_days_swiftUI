//
//  DetailView.swift
//  Projects 7-9
//
//  Created by Manuel Teixeira on 13/11/2020.
//

import SwiftUI

struct DetailView: View {
    @ObservedObject var activity: Activity
    @ObservedObject var activityList: ActivityList

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Text(activity.id)
                Text(activity.title)
                Text(activity.description)                
            }
        }

        VStack {
            Text("\(activity.timesCompleted) Times completed ")
                .font(.headline)
                .padding()
        }

        Button("Completed another one 🥇") {
            activity.timesCompleted += 1
            UserDefaults.save(activityList: activityList)
        }
        .foregroundColor(Color.white)
        .font(.title2)
        .padding()
        .background(Color.blue)
        .cornerRadius(10)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let activity = Activity(title: "Activity 1", description: "Description 1", timesCompleted: 0)
        let activityList = ActivityList(activities: [activity])
        DetailView(activity: activity, activityList: activityList)
    }
}
