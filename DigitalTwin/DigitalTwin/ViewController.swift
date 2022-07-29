//
//  ViewController.swift
//  DigitalTwin
//
//  Created by its on 27/07/22.
//

import UIKit
import CareKit
import CareKitStore
import CareKitUI
import ResearchKit

class ViewController: OCKDailyPageViewController{
    
    init(storeManager: OCKSynchronizedStoreManager = CareStoreReferenceManager.shared.synchronizedStoreManager) {
        super.init(storeManager: storeManager)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func dailyPageViewController(_ dailyPageViewController: OCKDailyPageViewController,
                                          prepare listViewController: OCKListViewController, for date: Date) {
        //check for onboarding survey
        checkIfSurveyIsComplete(surveyTask: .onboarding) { [weak self] isOnboarded in
            guard let strongSelf = self else {
                return
            }
            
            guard isOnboarded else {
                let onboardCard = OCKSurveyTaskViewController(
                    taskID: TaskIds.onboarding.rawValue,
                    eventQuery: OCKEventQuery(for: date),
                    storeManager: strongSelf.storeManager,
                    survey: Surveys.onboardingSurvey(),
                    extractOutcome: { _ in [OCKOutcomeValue(Date())] }
                )
                onboardCard.surveyDelegate = self
                listViewController.appendViewController(
                    onboardCard,
                    animated: false
                )
                return
            }
            
            //check for daily checkin survey
            /*strongSelf.checkIfSurveyIsComplete(surveyTask: .dailyCheckin, date: date) { isDailyCheckComplete in
                guard isDailyCheckComplete else {
                    let checkinSurveyCard = OCKSurveyTaskViewController(taskID: TaskIds.dailyCheckin.rawValue,
                                                                  eventQuery: .init(for: date),
                                                                  storeManager: strongSelf.storeManager,
                                                                  survey: Surveys.dailyCheckinSurvey(),
                                                                  extractOutcome: Surveys.extractAnswersFromCheckinSurvey)
                    checkinSurveyCard.surveyDelegate = self
                    listViewController.appendViewController(
                        checkinSurveyCard,
                        animated: false
                    )
                    return
                }
                strongSelf.fetchTasks(on: date) { tasks in
                    tasks.compactMap {
                        strongSelf.taskViewController(for: $0, on: date)
                    }.forEach {
                        listViewController.appendViewController($0, animated: false)
                    }
                }
            }*/
            
            strongSelf.fetchTasks(on: date) { tasks in
                tasks.compactMap {
                    strongSelf.taskViewController(for: $0, on: date)
                }.forEach {
                    listViewController.appendViewController($0, animated: false)
                }
            }
        }
    }
    
    private func checkIfSurveyIsComplete(surveyTask: TaskIds, date: Date? = nil, _ completion: @escaping (Bool) -> Void) {
        var query = OCKOutcomeQuery()
        if let date = date {
            query = OCKOutcomeQuery(for: date)
        }
        query.taskIDs = [surveyTask.rawValue]
        storeManager.store.fetchAnyOutcomes(
            query: query,
            callbackQueue: .main) { result in
                
                switch result {
                    
                case .failure:
                    print("Failed to fetch onboarding outcomes!")
                    completion(false)
                    
                case let .success(outcomes):
                    completion(!outcomes.isEmpty)
                }
            }
    }
    private func fetchTasks(
        on date: Date,
        completion: @escaping([OCKAnyTask]) -> Void) {
            var query = OCKTaskQuery(for: date)
            query.excludesTasksWithNoEvents = true
            storeManager.store.fetchAnyTasks(
                query: query,
                callbackQueue: .main) { result in
                    switch result {
                    case .failure:
                        print("Failed to fetch tasks for date \(date)")
                        completion([])
                        
                    case let .success(tasks):
                        completion(tasks)
                    }
                }
        }
    
    private func taskViewController(
        for task: OCKAnyTask,
        on date: Date) -> UIViewController? {
            switch task.id {
            case TaskIds.dailyCheckin.rawValue:
                return OCKSurveyTaskViewController(task: task,
                                            eventQuery: .init(for: date),
                                            storeManager: storeManager,
                                            survey: Surveys.dailyCheckinSurvey(),
                                            extractOutcome: Surveys.extractAnswersFromCheckinSurvey)
            case TaskIds.weeklySurvey.rawValue:
                return OCKSurveyTaskViewController(task: task,
                                            eventQuery: .init(for: date),
                                            storeManager: storeManager,
                                            survey: Surveys.weeklySurvey(),
                                            extractOutcome: Surveys.extractAnswersFromWeeklySurvey)
            case TaskIds.thirstEpisodes.rawValue:
                return OCKButtonLogTaskViewController(task: task,
                                                      eventQuery: .init(for: date),
                                                      storeManager: storeManager)
            case TaskIds.urinationEpisodes.rawValue:
                return OCKButtonLogTaskViewController(task: task,
                                                      eventQuery: .init(for: date),
                                                      storeManager: storeManager)
            default:
                return nil
            }
        }
}

extension ViewController: OCKSurveyTaskViewControllerDelegate {
    func surveyTask(viewController: OCKSurveyTaskViewController, for task: OCKAnyTask, didFinish result: Result<ORKTaskViewControllerFinishReason, Error>) {
        if case let .success(reason) = result, reason == .completed {
            reload()
        }
    }
}

extension ViewController: OCKOutcomeStoreDelegate {
    func outcomeStore(_ store: OCKAnyReadOnlyOutcomeStore, didAddOutcomes outcomes: [OCKAnyOutcome]) {
        storeManager.outcomeStore(store, didAddOutcomes: outcomes)
        print("")
    }
    
    func outcomeStore(_ store: OCKAnyReadOnlyOutcomeStore, didUpdateOutcomes outcomes: [OCKAnyOutcome]) {
        storeManager.outcomeStore(store, didUpdateOutcomes: outcomes)
        print("")
    }
    
    func outcomeStore(_ store: OCKAnyReadOnlyOutcomeStore, didDeleteOutcomes outcomes: [OCKAnyOutcome]) {
        storeManager.outcomeStore(store, didDeleteOutcomes: outcomes)
        print("")
    }
    
    func outcomeStore(_ store: OCKAnyReadOnlyOutcomeStore, didEncounterUnknownChange change: String) {
        storeManager.outcomeStore(store, didEncounterUnknownChange: change)
        print("")
    }
}

