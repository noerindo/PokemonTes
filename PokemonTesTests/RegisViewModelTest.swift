//
//  RegisViewModelTest.swift
//  PokemonTesTests
//
//  Created by Phincon on 23/07/25.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RealmSwift
@testable import PokemonTes

final class RegisViewModelTest: XCTestCase {
    var viewModel: RegisViewModelProtocol!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        let config = Realm.Configuration(inMemoryIdentifier: "TestRealm")
        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        disposeBag = DisposeBag()
        viewModel = RegisViewModel()
    }

    
    override func tearDown() {
        disposeBag = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testRegister_InvalidUserName_shouldEmitError() {
        let expectation = XCTestExpectation(description:  "Emit error for invalid username")
        var emitError: String?
        
        viewModel.errorMessage.subscribe(onNext: { message in
            emitError = message
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        viewModel.name.accept("a")
        viewModel.email.accept("test@gmail.com")
        viewModel.password.accept("test123451234")
        viewModel.registerTapped.accept(())
        
        wait(for: [expectation], timeout: 3.0)
        XCTAssertEqual(emitError, "Username harus 7–18 karakter (huruf, angka, atau underscore).")
    }
    
    func testRegister_withInvalidEmail_shouldEmitError() {
        let expectation = XCTestExpectation(description: "Emit error for invalid email")
        var emitError: String?
        
        viewModel.errorMessage.subscribe(onNext: { message in
            emitError = message
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        viewModel.name.accept("Indah Nurindo")
        viewModel.email.accept("invalid-email")
        viewModel.password.accept("Valid123!")
        
        viewModel.registerTapped.accept(())
        
        wait(for:[expectation], timeout: 3.0)
        XCTAssertEqual(emitError, "Format email tidak valid.")
    }
    
    func testRegister_withInvalidPassword_shouldEmitError() {
        let expectation = XCTestExpectation(description: "Emit error for invalid password")
        var emitError: String?
        
        viewModel.errorMessage.subscribe(onNext: { message in
            emitError = message
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        viewModel.name.accept("Indah Nurinbdo")
        viewModel.email.accept("valid@email.com")
        viewModel.password.accept("123")
        
        viewModel.registerTapped.accept(())
        
        wait(for:[expectation], timeout: 7.0)
        XCTAssertEqual(emitError, "Password minimal 8 karakter, kombinasi huruf, angka, dan simbol.")
    }
    
    func testRegister_withDuplicateEmail_shouldEmitError() {
        
        let realm = try! Realm()
        try! realm.write {
            let existingUser = UserModel()
            existingUser.name = "Indah Nurindo"
            existingUser.email = "existing@email.com"
            existingUser.password = "Valid123!"
            realm.add(existingUser)
        }
        
        let expectation = XCTestExpectation(description: "Emit error for duplicate email")
        var emitError: String?
        
        viewModel.errorMessage.subscribe(onNext: { message in
            emitError = message
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        viewModel.name.accept("Indah Nurindo")
        viewModel.email.accept("existing@email.com")
        viewModel.password.accept("Valid123!")
        
        viewModel.registerTapped.accept(())
        
        wait(for:[expectation], timeout: 8.0)
        XCTAssertEqual(emitError, "Email sudah terdaftar.")
    }
    
    func testRegister_withValidInputs_shouldEmitSuccess() {
        let expectation = XCTestExpectation(description: "Emit success for valid registration")
        var emitSuccess: String?
        
        viewModel.successMessage.subscribe(onNext: { message in
            emitSuccess = message
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        viewModel.name.accept("Indah Nurindo")
        viewModel.email.accept("newuser@email.com")
        viewModel.password.accept("Password123!")
        
        viewModel.registerTapped.accept(())
        
        wait(for:[expectation], timeout: 3.0)
        XCTAssertEqual(emitSuccess, "Registrasi berhasil!")
        
        let realm = try! Realm()
        let savedUser = realm.objects(UserModel.self).filter("email == %@", "newuser@email.com").first
        XCTAssertNotNil(savedUser)
        XCTAssertEqual(savedUser?.name, "Indah Nurindo")
    }
    
}

