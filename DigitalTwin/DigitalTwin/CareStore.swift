//
//  CareStore.swift
//  DigitalTwin
//
//  Created by its on 27/07/22.
//

import Foundation
import CareKit
import CareKitStore

enum TaskIds: String, CaseIterable {
    case onboarding
    case weeklySurvey
    case dailyCheckin
    case thirstEpisodes
    case urinationEpisodes
}

final class CareStoreReferenceManager {
    static let shared = CareStoreReferenceManager()
    
    lazy var synchronizedStoreManager: OCKSynchronizedStoreManager = {
        let store = OCKStore(name: "DiabetiesTracker")
        store.seedTasks()
        let manager = OCKSynchronizedStoreManager(wrapping: store)
        return manager
    }()
    
    private init() {}
}
