//
//  LoginViewModel.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import RxSwift
import RxCocoa
import RealmSwift

protocol LoginViewModelProtocol {
    var email: BehaviorRelay<String> { get }
    var password: BehaviorRelay<String> { get }
    var loginTapped: PublishRelay<Void> { get }
    var successMessage: PublishRelay<String> { get }
    var errorMessage: PublishRelay<String> { get }
    var loginSuccess: PublishRelay<Void> { get }
}

final class LoginViewModel: LoginViewModelProtocol {
    
    let email = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let loginTapped = PublishRelay<Void>()
    
    let successMessage = PublishRelay<String>()
    let errorMessage = PublishRelay<String>()
    let loginSuccess = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        bindLogin()
    }
    
    private func bindLogin() {
        loginTapped
            .withLatestFrom(Observable.combineLatest(email, password))
            .subscribe(onNext: { [weak self] email, password in
                self?.handleLogin(email: email, password: password)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleLogin(email: String, password: String) {
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage.accept("Email dan Password wajib diisi")
            return
        }
        
        guard CheckInput.validEmail(email) else {
            errorMessage.accept("Format email tidak valid")
            return
        }
        
        do {
            let realm = try Realm()
            if let user = realm.objects(UserModel.self).filter("email == %@", email).first {
                if user.password == password {
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(user.id.stringValue, forKey: "userId")

                    
                    successMessage.accept("Login berhasil!")
                    loginSuccess.accept(())
                } else {
                    errorMessage.accept("Password salah")
                }
            } else {
                
                errorMessage.accept("Akun belum terdaftar")
            }
        } catch {
            errorMessage.accept("Gagal membaca database")
        }
    }
}

