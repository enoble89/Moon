//
//  UserAPIType.swift
//  Moon
//
//  Created by Evan Noble on 7/5/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import Foundation
import RxSwift

enum APIError: Error {
    case jsonCastingFailure
    case noSignedInUser
    case noUserInfo
}

protocol UserAPIType {
    // Relationship Actions
    func acceptFriend(userID: String, friendID: String) -> Observable<Void>
    func declineFriend(userID: String, friendID: String) -> Observable<Void>
    func requestFriend(userID: String, friendID: String) -> Observable<Void>
    func removeFriend(userID: String, friendID: String) -> Observable<Void>
    func cancelFriend(userID: String, friendID: String) -> Observable<Void>
    
    // Blocking
    func blockUser(userID: String, blockID: String) -> Observable<Void>
    func unblockUser(userID: String, blockID: String) -> Observable<Void>
    func getBlockedUserList(userID: String) -> Observable<[UserSnapshot]>
    func reportUser(userId: String) -> Observable<Void>
    
    // User Info
    func getFriends(userID: String) -> Observable<[UserSnapshot]>
    func getUserProfile(userID: String) -> Observable<UserProfile>
    func canViewFullProfile(userID: String, viewerID: String) -> Observable<Bool>
    func update(profile: UserProfile) -> Observable<Void>
    func getActivityLikers(activityID: String) -> Observable<[UserSnapshot]>
    func getActivityFeed(userID: String) -> Observable<[Activity]>
    func searchForUser(searchText: String) -> Observable<[UserSnapshot]>
    func update(email: String, for userID: String) -> Observable<Void>
    func add(phoneNumber: String, for userID: String) -> Observable<Void>
    func getUserBy(phoneNumbers: [String], userID: String) -> Observable<[UserSnapshot]>
    
    // Actions
    func goToBar(userID: String, barID: String, timeStamp: Double) -> Observable<Void>
    func goWithGroup(userID: String, groupID: String, timeStamp: Double) -> Observable<Void>
    func likeActivity(userID: String, activityUserID: String) -> Observable<Void>
    func likeSpecial(userID: String, specialID: String) -> Observable<Void>
    func likeEvent(userID: String, eventID: String) -> Observable<Void>
    func likeGroupActivity(userID: String, groupID: String) -> Observable<Void>
    func getSuggestedFriends(userID: String) -> Observable<[UserSnapshot]>
    
    // Liked Info
    func hasLikedSpecial(userID: String, SpecialID: String) -> Observable<Bool>
    func hasLikedEvent(userID: String, EventID: String) -> Observable<Bool>
    func hasLikedActivity(userID: String, ActivityID: String) -> Observable<Bool>
    func hasLikedGroupActivity(userID: String, groupID: String) -> Observable<Bool>
    
    // Relation Info
    func pendingFriendRequest(userID1: String, userID2: String) -> Observable<Bool>
    func areFriends(userID1: String, userID2: String) -> Observable<Bool>
    func sentFriendRequest(userID1: String, userID2: String) -> Observable<Bool>
    func getFriendRequest(userID: String) -> Observable<[UserSnapshot]>
    
    // Settings
    func getNotificationSettings(userID: String) -> Observable<[NotificationSetting]>
    func updateNotificationSettings(userID: String, settings: [NotificationSetting]) -> Observable<Void>
    func getPrivacySetting(userID: String) -> Observable<Bool>
    func updatePrivacySetting(userID: String, privacy: Bool) -> Observable<Void>
}
