//
//  BarAPIType.swift
//  Moon
//
//  Created by Evan Noble on 7/5/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import Foundation
import RxSwift

protocol BarAPIType {
    func getBarFriends(barID: String, userID: String) -> Observable<[Activity]>
    func getBarPeople(barID: String) -> Observable<[Activity]>
    
    func getBarInfo(barID: String) -> Observable<BarProfile>
    func getBarEvents(barID: String) -> Observable<[BarEvent]>
    func getBarSpecials(barID: String) -> Observable<[Special]>
    
    func getBarsIn(region: String) -> Observable<[BarProfile]>
    func getEventsIn(region: String) -> Observable<[BarEvent]>
    func getSpecialsIn(region: String, type: AlcoholType) -> Observable<[Special]>
    func getTopBarsIn(region: String) -> Observable<[TopBar]>
    
    func getEventLikers(eventID: String) -> Observable<[Snapshot]>
    func getSpecialLikers(specialID: String) -> Observable<[Snapshot]>
}
