//
//  Surveys.swift
//  DigitalTwin
//
//  Created by its on 27/07/22.
//

import Foundation
import CareKit
import ResearchKit
import HealthKit
import CareKitStore

struct Surveys {
    private init() {}
    
    static let onboardId = "onboard"
    static let ondoardingCompletionId = "onboarding.completion.step"
    static let ondoardingRequestPermissionId = "onboarding.request.permission.step"
    
    static func onboardingSurvey() -> ORKTask {
        let hkTypesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .bloodGlucose)!, HKObjectType.quantityType(forIdentifier: .dietarySugar)!]
        let hkPermissionType = ORKHealthKitPermissionType(sampleTypesToWrite: nil,
                                                          objectTypesToRead: hkTypesToRead)
        let notificationPermissionType = ORKNotificationPermissionType(authorizationOptions: [.alert, .badge, .sound])
        
        let requestPermissionStep = ORKRequestPermissionsStep(identifier: ondoardingRequestPermissionId, permissionTypes: [hkPermissionType, notificationPermissionType])
        requestPermissionStep.title = "Health Data Request"
        requestPermissionStep.text = "Please review the health data types below and enable sharing to contribute to the study."
        
        let completionStep = ORKCompletionStep(identifier: ondoardingCompletionId)
        completionStep.title = "Onboarding Complete"
        completionStep.text = "Congrats, your onboarding has been completed"
        
        let surveyTask = ORKOrderedTask(identifier: onboardId, steps: [requestPermissionStep, completionStep])
        return surveyTask
    }
    
    
    static let checkInId = "checkin"
    static let checkInFromId = "checkin.form"
    static let checkInSleepItemId = "checkin.form.sleep"
    static let checkInVisionItemId = "checkin.form.vision"
    static let checkInFatigueItemId = "checkin.form.fatigue"
    static let checkInDizinessItemId = "checkin.form.diziness"
    static let checkInComplteItemId = "checkin.complete"
    
    static func dailyCheckinSurvey() -> ORKTask {
        let focusTrouble = ORKTextChoice(text: "Yes, Seems to have trouble with my focus", value: NSNumber(integerLiteral: 0))
        let floaters = ORKTextChoice(text: "Yes, I see floaters in my line of vision", value: NSNumber(integerLiteral: 1))
        let blurry = ORKTextChoice(text: "Yes, my eyesight seems a little blurry", value: NSNumber(integerLiteral: 2))
        let noChange = ORKTextChoice(text: "No, my eyes are fine", value: NSNumber(integerLiteral: 3))
        let visionAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [focusTrouble, floaters, blurry, noChange])
        let visionItem = ORKFormItem(identifier: checkInVisionItemId, text: "Have you noticed any change to your vision?", answerFormat: visionAnswerFormat)
        visionItem.isOptional = false
        
        let sameAsAlways = ORKTextChoice(text: "No, I'm feeling same as always", value: NSNumber(integerLiteral: 0))
        let exhausted = ORKTextChoice(text: "Yes, I'm exhausted", value: NSNumber(integerLiteral: 1))
        let litteTired = ORKTextChoice(text: "I'm a little more tired than usual", value: NSNumber(integerLiteral: 2))
        let fatigueAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [sameAsAlways, exhausted, litteTired])
        let fatigueItem = ORKFormItem(identifier: checkInFatigueItemId, text: "Have you been experiencing excessive tiredness or fatigue?", answerFormat: fatigueAnswerFormat)
        fatigueItem.isOptional = false
        
        let yes = ORKTextChoice(text: "Yes", value: NSNumber(integerLiteral: 0))
        let no = ORKTextChoice(text: "No", value: NSNumber(integerLiteral: 1))
        let dizzinessAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [yes, no])
        let dizinessItem = ORKFormItem(identifier: checkInDizinessItemId, text: "Do you experience Dizziness?", answerFormat: dizzinessAnswerFormat)
        dizinessItem.isOptional = false
        
        let sleepItemAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 12, minimumValue: 0, defaultValue: 0, step: 1, vertical: false, maximumValueDescription: nil, minimumValueDescription: nil)
        let sleepItem = ORKFormItem(identifier: checkInSleepItemId, text: "How many hours of sleep you had?", answerFormat: sleepItemAnswerFormat)
        sleepItem.isOptional = false
        
        let formStep = ORKFormStep(identifier: checkInFromId, title: "Daily Check In Survey", text: "Please answer following questions")
        formStep.isOptional = false
        formStep.formItems = [visionItem, fatigueItem, dizinessItem, sleepItem]
        
        let completionStep = ORKCompletionStep(identifier: checkInComplteItemId)
        completionStep.title = "Checkin Complete"
        completionStep.text = "Congrats, your checkin for today has been completed"
        
        let surveyTask = ORKOrderedTask(identifier: checkInId, steps: [formStep, completionStep])
        return surveyTask
    }
    
    static func extractAnswersFromCheckinSurvey(_ result: ORKTaskResult) -> [OCKOutcomeValue]? {
        guard let response = result.results?.compactMap({ $0 as? ORKStepResult }).first(where: { $0.identifier == checkInFromId  }),
              let scaleResults = response.results?.compactMap({ $0 as? ORKScaleQuestionResult }),
              let sleepAnswer = scaleResults.first(where: { $0.identifier == checkInSleepItemId })?.scaleAnswer,
              let choiceResults = response.results?.compactMap({ $0 as? ORKChoiceQuestionResult }),
              let visionAnswer = (choiceResults.first(where: { $0.identifier == checkInVisionItemId })?.answer as? [NSNumber])?.first,
              let fatigueAnswer = (choiceResults.first(where: { $0.identifier == checkInFatigueItemId })?.answer as? [NSNumber])?.first,
              let dizzinessAnswer = (choiceResults.first(where: { $0.identifier == checkInDizinessItemId })?.answer as? [NSNumber])?.first else {
            return nil
        }
        var sleepValue = OCKOutcomeValue(Double(truncating: sleepAnswer))
        sleepValue.kind = checkInSleepItemId
        
        var visionValue = OCKOutcomeValue(Int(truncating: visionAnswer))
        visionValue.kind = checkInVisionItemId
        
        var fatigueValue = OCKOutcomeValue(Int(truncating: fatigueAnswer))
        fatigueValue.kind = checkInFatigueItemId
        
        var dizzinessValue = OCKOutcomeValue(Int(truncating: dizzinessAnswer))
        dizzinessValue.kind = checkInDizinessItemId
        
        return [sleepValue, visionValue, dizzinessValue, fatigueValue]
    }
    
    static let weeklySurveyId = "weeklySurvey"
    
    static let weekSurveyWeightFromId = "weeklySurvey.weight.form"
    static let weeklyFormWeightItemId = "weeklySurvey.weight"
    
    static let weekSurveyThirstFromId = "weeklySurvey.thirst.form"
    static let weeklyFormThirstItemId = "weeklySurvey.thirst"
    
    static let weekSurveyPeeFromId = "weeklySurvey.pee.form"
    static let weeklyFormPeeItemId = "weeklySurvey.pee"
    
    static let weekSurveyWoundFromId = "weeklySurvey.wound.form"
    static let weeklyFormWoundItemId = "weeklySurvey.wound"
    
    static let weekSurveySensationFromId = "weeklySurvey.sensation.form"
    static let weeklyFormSensationItemId = "weeklySurvey.sensation"
    
    static let weeklySurveyCompleteItemId = "checkin.complete"
    
    static func weeklySurvey() -> ORKTask {
        let overWeight = ORKTextChoice(text: "Yes, I've experienced Weight Gain", value: NSNumber(integerLiteral: 0))
        let weightLoss = ORKTextChoice(text: "Yes, I've experienced Weight Loss", value: NSNumber(integerLiteral: 1))
        let noChange = ORKTextChoice(text: "No", value: NSNumber(integerLiteral: 2))
        let weightAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [overWeight, weightLoss, noChange])
        let weightItem = ORKFormItem(identifier: weeklyFormWeightItemId, text: "Do you have problem with your weight?", answerFormat: weightAnswerFormat)
        weightItem.isOptional = false
        
        let weightFormStep = ORKFormStep(identifier: weekSurveyWeightFromId, title: "Weight Survey", text: nil)
        weightFormStep.isOptional = false
        weightFormStep.formItems = [weightItem]
        
        
        let yes = ORKTextChoice(text: "Yes", value: NSNumber(integerLiteral: 0))
        let no = ORKTextChoice(text: "No", value: NSNumber(integerLiteral: 1))
        let thirstAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [yes, no])
        let thirstItem = ORKFormItem(identifier: weeklyFormThirstItemId, text: "Have you found yourself drinking more water than usual in recent week?", answerFormat: thirstAnswerFormat)
        thirstItem.isOptional = false
        
        let thirstFormStep = ORKFormStep(identifier: weekSurveyThirstFromId, title: "Thirst Survey", text: nil)
        thirstFormStep.isOptional = false
        thirstFormStep.formItems = [thirstItem]
        
        
        let yesItSeems = ORKTextChoice(text: "Yes, I see to go a lot more than usual!", value: NSNumber(integerLiteral: 0))
        let noIDontThink = ORKTextChoice(text: "No, I don't think so", value: NSNumber(integerLiteral: 1))
        let peeAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [yesItSeems, noIDontThink])
        let peeItem = ORKFormItem(identifier: weeklyFormPeeItemId, text: "Are you peeing more than usual?", answerFormat: peeAnswerFormat)
        peeItem.isOptional = false
        
        let peeFormStep = ORKFormStep(identifier: weekSurveyPeeFromId, title: "Peeing Survey", text: nil)
        peeFormStep.isOptional = false
        peeFormStep.formItems = [peeItem]
        
        
        let yesItSeemsTakingLonger = ORKTextChoice(text: "Yes, they seems to be taking longer", value: NSNumber(integerLiteral: 0))
        let noTheyAreHealingFine = ORKTextChoice(text: "No, they are healing just fine", value: NSNumber(integerLiteral: 1))
        let woundsAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [yesItSeemsTakingLonger, noTheyAreHealingFine])
        let woundItem = ORKFormItem(identifier: weeklyFormWoundItemId, text: "have you notices that any cuts and grazes you might have seen to be taking longer to heal than usual?", answerFormat: woundsAnswerFormat)
        woundItem.isOptional = false
        
        let woundFormStep = ORKFormStep(identifier: weekSurveyWoundFromId, title: "Peeing Survey", text: nil)
        woundFormStep.isOptional = false
        woundFormStep.formItems = [woundItem]
        
        
        let yesFrequesntly = ORKTextChoice(text: "Yes, frequently", value: NSNumber(integerLiteral: 0))
        let yesOnceOrTwice = ORKTextChoice(text: "Yes, once or twice", value: NSNumber(integerLiteral: 1))
        let noSensation = ORKTextChoice(text: "No", value: NSNumber(integerLiteral: 2))
        let sensationAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [yesFrequesntly, yesOnceOrTwice, noSensation])
        let sensationItem = ORKFormItem(identifier: weeklyFormSensationItemId, text: "Have you experienced recent tingling or a pins and needles sensation in the hands or feet?", answerFormat: sensationAnswerFormat)
        sensationItem.isOptional = false
        
        let sensationFormStep = ORKFormStep(identifier: weekSurveySensationFromId, title: "Sensation Survey", text: nil)
        sensationFormStep.isOptional = false
        sensationFormStep.formItems = [sensationItem]
        
        
        let completionStep = ORKCompletionStep(identifier: weeklySurveyCompleteItemId)
        completionStep.title = "Survey Complete"
        completionStep.text = "Congrats, your weekly survey for the week has been completed"
        
        let surveyTask = ORKOrderedTask(identifier: weeklySurveyId, steps: [weightFormStep, thirstFormStep, peeFormStep, woundFormStep, sensationFormStep, completionStep])
        return surveyTask
    }
    
    static func extractAnswersFromWeeklySurvey(_ result: ORKTaskResult) -> [OCKOutcomeValue]? {
        guard let response = result.results?.compactMap({ $0 as? ORKStepResult }).first(where: { $0.identifier == weekSurveyWeightFromId  }),
              let choiceResults = response.results?.compactMap({ $0 as? ORKChoiceQuestionResult }),
              let answer = (choiceResults.first(where: { $0.identifier == weeklyFormWeightItemId })?.answer as? [NSNumber])?.first else {
            return nil
        }
        var weightValue = OCKOutcomeValue(Int(truncating: answer))
        weightValue.kind = weeklyFormWeightItemId
        
        guard let response = result.results?.compactMap({ $0 as? ORKStepResult }).first(where: { $0.identifier == weekSurveyThirstFromId  }),
              let choiceResults = response.results?.compactMap({ $0 as? ORKChoiceQuestionResult }),
              let answer = (choiceResults.first(where: { $0.identifier == weeklyFormThirstItemId })?.answer as? [NSNumber])?.first else {
            return nil
        }
        var thirstValue = OCKOutcomeValue(Int(truncating: answer))
        thirstValue.kind = weeklyFormThirstItemId
        
        guard let response = result.results?.compactMap({ $0 as? ORKStepResult }).first(where: { $0.identifier == weekSurveyPeeFromId  }),
              let choiceResults = response.results?.compactMap({ $0 as? ORKChoiceQuestionResult }),
              let answer = (choiceResults.first(where: { $0.identifier == weeklyFormPeeItemId })?.answer as? [NSNumber])?.first else {
            return nil
        }
        var peeValue = OCKOutcomeValue(Int(truncating: answer))
        peeValue.kind = weeklyFormPeeItemId
        
        guard let response = result.results?.compactMap({ $0 as? ORKStepResult }).first(where: { $0.identifier == weekSurveyWoundFromId  }),
              let choiceResults = response.results?.compactMap({ $0 as? ORKChoiceQuestionResult }),
              let answer = (choiceResults.first(where: { $0.identifier == weeklyFormWoundItemId })?.answer as? [NSNumber])?.first else {
            return nil
        }
        var woundValue = OCKOutcomeValue(Int(truncating: answer))
        woundValue.kind = weeklyFormWoundItemId
        
        guard let response = result.results?.compactMap({ $0 as? ORKStepResult }).first(where: { $0.identifier == weekSurveySensationFromId  }),
              let choiceResults = response.results?.compactMap({ $0 as? ORKChoiceQuestionResult }),
              let answer = (choiceResults.first(where: { $0.identifier == weeklyFormSensationItemId })?.answer as? [NSNumber])?.first else {
            return nil
        }
        var sensationValue = OCKOutcomeValue(Int(truncating: answer))
        sensationValue.kind = weeklyFormSensationItemId
        
        return [weightValue, thirstValue, peeValue, woundValue, sensationValue]
    }
}
