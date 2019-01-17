//
//  LocalAnalytics.swift
//  StreetArt
//
//  Created by Axel Rivera on 8/25/18.
//  Copyright © 2018 Axel Rivera. All rights reserved.
//

import Foundation
import Firebase

class LocalAnalytics {
    static let shared = LocalAnalytics()

    var isProduction: Bool {
#if PRODUCTION_BUILD
    #if SAO_PRODUCTION
        return true
    #else
        return false
    #endif
#else
        return false
#endif
    }

    enum CustomEvent: String {
        case login = "login"
        case logout = "logout"
        case registrationStart = "registration_start"
        case registrationSuccess = "registration_success"
        case favorite = "favorite"
        case unfavorite = "unfavorite"
        case submitContent = "submit_content"
        case photoDetail = "photo_detail"
        case mapDetail = "map_detail"
        case sharePhoto = "share_photo"
        case getDirections = "get_directions"
        case submitCorrection = "submit_correction"
        case reportPhotoIntent = "report_photo_intent"
        case reportPhoto = "report_photo"
        case forgotPassword = "forgot_password"
        case forgotPasswordProgress = "forgot_password_progress"
        case forgotPasswordSuccess = "forgot_password_success"
        case updatePassword = "update_password"
        case updatePasswordSuccess = "update_password_success"
        case mySubmissions = "my_submissions"
        case submissionStart = "submission_start"
        case submissionSuccess = "submission_success"
        case submissionUpdateLocation = "submission_update_location"
        case submissionResetPhoto = "submission_reset_photo"

        var string: String {
            return self.rawValue
        }
    }

    enum CustomParameter: String {
        case appId = "app_id"
        case forgotPasswordStep = "forgot_password_step"

        var string: String {
            return self.rawValue
        }
    }

    func appOpen() {
        logEvent(
            string: AnalyticsEventAppOpen,
            parameters: [CustomParameter.appId.string: Settings.shared.deviceIdentifier]
        )
    }

    func forgotPasswordStart() {
        logEvent(string: CustomEvent.forgotPassword.string)
    }

    func forgotPasswordStepSecurityCode() {
        let parameters = [ CustomParameter.forgotPasswordStep.string: "security_code" ]
        logEvent(string: CustomEvent.forgotPasswordProgress.string, parameters: parameters)
    }

    func forgotPasswordStepPasswordUpdate() {
        let parameters = [ CustomParameter.forgotPasswordStep.string: "password_update" ]
        logEvent(string: CustomEvent.forgotPasswordProgress.string, parameters: parameters)
    }

    func forgotPasswordSuccess() {
        logEvent(string: CustomEvent.forgotPasswordSuccess.string)
    }

    func customEvent(_ event: CustomEvent, submission: Submission? = nil) {
        var parameters: [String: String]?

        if let submission = submission {
            parameters = [
                AnalyticsParameterItemID: submission.title == nil ? "\(submission.id)" : "\(submission.id)-\(submission.title!)"
            ]

            if let title = submission.title {
                parameters?[AnalyticsParameterItemName] = title
            }
        }

        logEvent(string: event.string, parameters: parameters)
    }

    func logEvent(string: String, parameters: [String: String]? = nil) {
        guard isProduction else {
            return
        }

        Analytics.logEvent(string, parameters: parameters)
    }
}
