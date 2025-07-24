//
//  LoginViewModelTest.swift
//  PokemonTes
//
//  Created by Phincon on 21/07/25.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RealmSwift
@testable import PokemonTes

final class LoginViewModelTest: XCTestCase {
    var viewModel: LoginViewModelProtocol!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        viewModel = LoginViewModel()
        
        let config = Realm.Configuration(inMemoryIdentifier: self.name)
        Realm.Configuration.defaultConfiguration = config
    }
    
    override func tearDown() {
        disposeBag = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testLoginWithEmptyEmailAndPassword_shouldEmitError() {
        let expectation = XCTestExpectation(description: "Error emitted for empty email and Passsword")
        var emittedError: String?
        
        viewModel.errorMessage.subscribe(onNext: { error in
            emittedError = error
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        viewModel.email.accept("")
        viewModel.password.accept("")
        viewModel.loginTapped.accept(())
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(emittedError, "Email dan Password wajib diisi")
    }
    
    func testLoginWithInvalidEmailFormat_shouldEmitError() {
        let expectation = XCTestExpectation(description: "Error emitted for invalid email")
        var emittedError: String?
        
        viewModel.errorMessage.subscribe (onNext:{ error in
            emittedError = error
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        viewModel.email.accept("Invalid Email")
        viewModel.password.accept("IndahNurindo@11")
        viewModel.loginTapped.accept(())
        
        wait(for:[expectation], timeout: 1.0)
        XCTAssertEqual(emittedError, "Format email tidak valid")
    }
    
    func testLoginWithWrongPassword_shouldEmitError() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
            let user = UserModel()
            user.email = "test@gmail.com"
            user.password = "test12345"
            realm.add(user)
        }
        
        let expectation = XCTestExpectation(description: "Error Emitted for wrong passsword")
        var emittedError: String?
        
        viewModel.errorMessage.subscribe(onNext: { error in
            emittedError = error
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        viewModel.email.accept("test@gmail.com")
        viewModel.password.accept("wrongpassword")
        viewModel.loginTapped.accept(())
        
        wait(for:[expectation], timeout: 1.0)
        XCTAssertEqual(emittedError, "Password salah")
    }
    
    func testLoginWithUserNohaveAccount_shouldEmitError() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
            let user = UserModel()
            user.email = "test@gmail.com"
            user.password = "test12345"
            realm.add(user)
        }
        
        let expectation = XCTestExpectation(description: "Error Emitted for wrong passsword")
        var emittedError: String?
        
        viewModel.errorMessage.subscribe(onNext: { error in
            emittedError = error
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        viewModel.email.accept("test123@gmail.com")
        viewModel.password.accept("wrongpassword")
        viewModel.loginTapped.accept(())
        
        wait(for:[expectation], timeout: 1.0)
        XCTAssertEqual(emittedError, "Akun belum terdaftar")
    }
    
    func testLoginSuccesWithData_shouldEmitSuccess() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
            let user = UserModel()
            user.email = "test@gmail.com"
            user.password = "test12345"
            realm.add(user)
        }
        
        let expectation = XCTestExpectation(description: "Error Emitted for wrong passsword")
        var emittedSucces: String?
        
        viewModel.successMessage.subscribe(onNext: { succes in
            emittedSucces = succes
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        viewModel.email.accept("test@gmail.com")
        viewModel.password.accept("test12345")
        viewModel.loginTapped.accept(())
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(emittedSucces, "Login berhasil!")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "isLoggedIn"))
    }
    
    
}


