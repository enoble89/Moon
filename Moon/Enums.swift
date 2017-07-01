//
//  Enums.swift
//  Moon
//
//  Created by Evan Noble on 6/5/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import Foundation

enum MyError: Error {
    case SignUpError
}

enum Sex: Int {
    case male
    case female
    case none
}

enum MainView: Int {
    case featured
    case moons
    case explore
}

enum AlcoholType: String {
    case beer = "Beer"
    case liquor = "Liquor"
    case wine = "Wine"
    
    static func from(int: Int) -> AlcoholType {
        switch int {
        case 0:
            return self.beer
        case 1:
            return self.liquor
        case 2:
            return self.wine
        default:
            return self.beer
        }
    }
}

enum DayOfWeek {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

enum HeartColor {
    case red
    case gray
}

enum Setting {
    case myAccount(option: SettingSections.MyAccount)
    case moreInformation(option: SettingSections.MoreInformation)
    case accountActions(option: SettingSections.AccountActions)
}

enum SettingSections {
    enum MyAccount: Int {
        case changeName = 0
        case changePhoneNumber = 2
        case changeEmail = 3
        case notifications = 4
    }
    
    enum AccountActions: Int {
        case logOut = 0
        case deleteAccount = 1
    }
    
    enum MoreInformation: Int {
        case privacyPolicy = 0
        case termsAndConditions = 1
        case support = 2
    }
}

enum SearchType: Int {
    case users
    case bars
}

enum UserTableSource {
    case user(id: String)
    case special(id: String)
    case event(id: String)
    case activity(id: String)
}
