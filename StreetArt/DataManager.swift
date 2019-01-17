//
//  DataManager.swift
//  StreetArt
//
//  Created by Axel Rivera on 1/6/19.
//  Copyright © 2019 Axel Rivera. All rights reserved.
//

import Foundation
import Alamofire

class DataManager {
    static let shared = DataManager()

    var user: User?
    var reportCodes = ReportCodeArray()

    init() {
        // Initializers go here
    }

    func fetchUser(completionHandler: ((User?) -> Void)?) {
        guard ApiClient.shared.isAuthenticated else {
            completionHandler?(nil)
            return
        }

        ApiClient.shared.user { [weak self] (result) in
            result.withValue({ (user) in
                self?.user = user
            })

            dLog("user: \(String(describing: self?.user?.id))")

            completionHandler?(self?.user)
        }
    }

    func resetUser() {
        user = nil
    }

    func fetchReportCodes(force: Bool, completionHandler: ((ReportCodeArray) -> Void)?) {
        if !reportCodes.isEmpty && !force {
            completionHandler?(reportCodes)
            return
        }

        ApiClient.shared.reportCodes { [weak self] (result) in
            result.withValue({ (reportCodes) in
                self?.reportCodes = reportCodes
            })

            completionHandler?(self?.reportCodes ?? ReportCodeArray())
        }
    }

    func resetReportCodes() {
        reportCodes = ReportCodeArray()
    }

}
