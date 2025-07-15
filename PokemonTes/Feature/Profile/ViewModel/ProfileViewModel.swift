//
//  ProfileViewModel.swift
//  PokemonTes
//
//  Created by Phincon on 13/07/25.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

protocol ProfileViewModelProtocol {
    var username: BehaviorRelay<String> { get }
    var email: BehaviorRelay<String> { get }
    var isLoading: PublishRelay<Bool> { get }
    var didUpdateProfile: PublishRelay<Void> { get }
    
    func logout()
    func updateProfile(username: String, email: String, password: String)
    func getUserProfile() -> UserModel?
}

class ProfileViewModel: ProfileViewModelProtocol {
    
    let username = BehaviorRelay<String>(value: "")
    let email = BehaviorRelay<String>(value: "")
    let isLoading = PublishRelay<Bool>()
    let didUpdateProfile = PublishRelay<Void>()
    
    private let realm = try! Realm()
    private let disposeBag = DisposeBag()
    
    init() {
        loadProfile()
    }
    
    func loadProfile() {
        guard let profile = SessionManager.shared.currentUser else { return }
        username.accept(profile.name)
        email.accept(profile.email)
    }
    
    func logout() {
        SessionManager.shared.logoutUser()
    }
    
    func updateProfile(username: String, email: String, password: String) {
        guard let profile = SessionManager.shared.currentUser else { return }
        
        isLoading.accept(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            
            try? self.realm.write {
                profile.name = username
                profile.email = email
                profile.password = password
            }

            self.loadProfile()
            self.isLoading.accept(false)
            self.didUpdateProfile.accept(())
        }
    }
    
    func getUserProfile() -> UserModel? {
        return SessionManager.shared.currentUser
    }
}
