//
//  UserAPIController.swift
//  Moon
//
//  Created by Evan Noble on 6/14/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import Foundation
import SwaggerClient
import RxSwift
import RxCocoa

protocol UserAPIType {
    func acceptFriend(userID: String, friendID: String) -> Observable<Void>
    func declineFriend(userID: String, friendID: String) -> Observable<Void>
    func requestFriend(userID: String, friendID: String) -> Observable<Void>
    func getFriendRequest(userID: String) -> Observable<[UserProfile]>
    
    func blockUser(userID: String, blockID: String) -> Observable<Void>
    func unblockUser(userID: String, blockID: String) -> Observable<Void>
    func getBlockedUserList(userID: String) -> Observable<[UserProfile]>
    
    func getFriends(userID: String) -> Observable<[UserProfile]>
    func getUserInfo(userID: String) -> Observable<UserProfile>
    func getUserActivity(userID: String) -> Observable<Activity>
    func getActivityLikes(activityID: String) -> Observable<[UserProfile]>
    
    func goToBar(userID: String, barID: String) -> Observable<Void>
    func likeActivity(userID: String, activityID: String) -> Observable<Void>
    func likeSpecial(userID: String, specialID: String) -> Observable<Void>
    func likeEvent(userID: String, eventID: String) -> Observable<Void>
    func update(profile: UserProfile) -> Observable<Void>
}

class UserAPIController: UserAPIType {
    func acceptFriend(userID: String, friendID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body = Body4()
            body.userID = userID
            body.friendID = friendID
            UserAPI.acceptFriend(body: body, completion: { (error) in
                if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    func declineFriend(userID: String, friendID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body = Body5()
            body.userID = userID
            body.friendID = friendID
            UserAPI.declineFriend(body: body, completion: { (error) in
                if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    func requestFriend(userID: String, friendID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body = Body3()
            body.userID = userID
            body.friendID = friendID
            UserAPI.requestFriend(body: body, completion: { (error) in
                if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    func getFriendRequest(userID: String) -> Observable<[UserProfile]> {
        return Observable.create({ (observer) -> Disposable in
            //TODO: backend needs to implement this endpoint
            return Disposables.create()
        })
    }
}

extension UserAPIController {
    func blockUser(userID: String, blockID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body = Body6()
            body.userID = userID
            body.blockID = blockID
            UserAPI.blockUser(body: body, completion: { (error) in
                if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    func unblockUser(userID: String, blockID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body = Body7()
            body.userID = userID
            body.blockID = blockID
            UserAPI.unblockUser(body: body, completion: { (error) in
                if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    func getBlockedUserList(userID: String) -> Observable<[UserProfile]> {
        return Observable.create({ (observer) -> Disposable in
            UserAPI.getUserBlocklist(userID: userID, completion: { (profiles, error) in
                if let p = profiles {
                    observer.onNext(p)
                } else if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
}

extension UserAPIController {
    func getFriends(userID: String) -> Observable<[UserProfile]> {
        return Observable.create({ (observer) -> Disposable in
            UserAPI.getFriends(userID: userID, completion: { (profiles, error) in
                if let p = profiles {
                    observer.onNext(p)
                } else if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    func getUserInfo(userID: String) -> Observable<UserProfile> {
        return Observable.create({ (observer) -> Disposable in
            UserAPI.getUser(userID: userID, completion: { (profile, error) in
                if let p = profile {
                    observer.onNext(p)
                } else if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    func getUserActivity(userID: String) -> Observable<Activity> {
        return Observable.create({ (observer) -> Disposable in
            UserAPI.getUserActivity(userID: userID, completion: { (activities, error) in
                if let a = activities {
                    //TODO: API should only return the latest Activity
                    observer.onNext(a.first!)
                } else if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    func getActivityLikes(activityID: String) -> Observable<[UserProfile]> {
        return Observable.create({ (observer) -> Disposable in
            UserAPI.getActivityLikes(activityID: activityID, completion: { (profiles, error) in
                if let p = profiles {
                    observer.onNext(p)
                } else if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
}

extension UserAPIController {
    func goToBar(userID: String, barID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body = Body1()
            body.userID = userID
            body.barID = barID
            UserAPI.goToBar(body: body, completion: { (error) in
                if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    func likeActivity(userID: String, activityID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body = Body()
            body.userID = userID
            body.activityID = activityID
            UserAPI.likeActivity(body: body, completion: { (error) in
                if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    func likeSpecial(userID: String, specialID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body = Body2()
            body.userID = userID
            body.specialID = specialID
            UserAPI.likeSpecial(body: body, completion: { (error) in
                if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    func likeEvent(userID: String, eventID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            //TODO: need api endpoint for liking an event
            return Disposables.create()
        })
    }
    func update(profile: UserProfile) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            UserAPI.updateProfile(body: profile, completion: { (error) in
                if let e = error {
                    observer.onError(e)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
}
