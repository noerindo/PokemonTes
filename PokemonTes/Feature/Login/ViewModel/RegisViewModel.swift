//
//  RegisViewModel.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import RxSwift
import RxCocoa
import RealmSwift

final class RegisViewModel {
    
    let name = BehaviorRelay<String>(value: "")
    let email = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let registerTapped = PublishRelay<Void>()
    
    let successMessage = PublishRelay<String>()
    let errorMessage = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        registerTapped
            .withLatestFrom(Observable.combineLatest(name, email, password))
            .subscribe(onNext: { [weak self] name, email, password in
                self?.register(name: name, email: email, password: password)
            })
            .disposed(by: disposeBag)
    }
    
    private func register(name: String, email: String, password: String) {
        guard CheckInput.validUsername(name) else {
            errorMessage.accept("Username harus 7–18 karakter (huruf, angka, atau underscore).")
            return
        }
        
        guard CheckInput.validEmail(email) else {
            errorMessage.accept("Format email tidak valid.")
            return
        }
        
        guard CheckInput.validPassword(password) else {
            errorMessage.accept("Password minimal 8 karakter, kombinasi huruf, angka, dan simbol.")
            return
        }
        
        do {
            let realm = try Realm()
            
            if realm.objects(UserModel.self).filter("email == %@", email).first != nil {
                errorMessage.accept("Email sudah terdaftar.")
                return
            }
            
            let user = UserModel()
            user.name = name
            user.email = email
            user.password = password
            
            try realm.write {
                realm.add(user)
            }
            
            successMessage.accept("Registrasi berhasil!")
        } catch {
            errorMessage.accept("Terjadi kesalahan saat menyimpan: \(error.localizedDescription)")
        }
    }
}
