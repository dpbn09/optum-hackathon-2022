//
//  OCKDailyStore+PopulateCarePlan.swift
//  DigitalTwin
//
//  Created by its on 27/07/22.
//

import Foundation
import CareKit
import CareKitStore

extension OCKStore {
    func seedTasks() {
        //onboarding task
        let onboardSchedule = OCKSchedule.dailyAtTime(
            hour: 0, minutes: 0,
            start: Date(), end: nil,
            text: "Task Due!",
            duration: .allDay
        )
        var onboardTask = OCKTask(
            id: TaskIds.onboarding.rawValue,
            title: "Onboard",
            carePlanUUID: nil,
            schedule: onboardSchedule
        )
        onboardTask.instructions = "You'll need to complte this onboarding step before we get started!"
        onboardTask.impactsAdherence = false
        
        //daily one time checkin task
        let checkinSchedule = OCKSchedule.dailyAtTime(hour: 0, minutes: 0, start: Date(), end: nil, text: nil, duration: .allDay)
        var checkInTask = OCKTask(id: TaskIds.dailyCheckin.rawValue,
                                 title: "You need to complete this daily check in survey",
                                 carePlanUUID: nil, schedule: checkinSchedule)
        checkInTask.impactsAdherence = false
        
        //weekly one time task
        let week = Calendar.current.date(byAdding: .weekOfYear, value: 0, to: Date())
        let weeklyElement = OCKScheduleElement(start: week!, end: nil, interval: DateComponents(weekOfYear: 1), text: nil, targetValues: [], duration: .allDay)
        let weeklySurveySchedule = OCKSchedule(composing: [weeklyElement])
        var weeklyTask = OCKTask(id: TaskIds.weeklySurvey.rawValue, title: "You need to complete this survey every week", carePlanUUID: nil, schedule: weeklySurveySchedule)
        weeklyTask.impactsAdherence = false
        
        //daily activities
        let wholeDaychedule = OCKSchedule(composing: [
            OCKScheduleElement(start: Calendar.current.startOfDay(for: Date()),
                               end: nil,
                               interval: DateComponents(day: 1),
                               text: "Anytime throughout the day",
                               targetValues: [],
                               duration: .allDay)
        ])
        var thirstTask = OCKTask(id: TaskIds.thirstEpisodes.rawValue,
                                 title: "Track Thirst",
                                 carePlanUUID: nil, schedule: wholeDaychedule)
        
        thirstTask.instructions = "If you feel thirsty, please log it here."
        thirstTask.impactsAdherence = false
        
        var urinationTask = OCKTask(id: TaskIds.urinationEpisodes.rawValue,
                                    title: "Track Peeing Frequency",
                                    carePlanUUID: nil, schedule: wholeDaychedule)
        
        urinationTask.instructions = "If you feel the urge to pee, please log it here."
        urinationTask.impactsAdherence = false
        
        
        //adding tasks
        addAnyTasks(
            [onboardTask, thirstTask, urinationTask, weeklyTask, checkInTask],
            callbackQueue: .main) { result in
                
                switch result {
                    
                case let .success(tasks):
                    print("Seeded \(tasks.count) tasks")
                    
                case let .failure(error):
                    print("Failed to seed tasks: \(error as NSError)")
                }
            }
    }
}
