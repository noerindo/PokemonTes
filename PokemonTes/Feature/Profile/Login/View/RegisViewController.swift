//
//  RegisViewController.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import UIKit
import SnapKit
import RxSwift
import MBProgressHUD

class RegisViewController: UIViewController {
    
    private let viewModel = RegisViewModel()
    private let disposeBag = DisposeBag()
    
    private let pokeImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "pokeball")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.font = UIFont.boldSystemFont(ofSize: 15)
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.font = UIFont.boldSystemFont(ofSize: 15)
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.font = UIFont.boldSystemFont(ofSize: 15)
        textField.borderStyle = .roundedRect
        textField.textContentType = .oneTimeCode
        textField.enablePasswordToggle()
        return textField
    }()
    
    private let regisButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Daftar", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraint()
        bindViewModel()
    }
    
    private func setupViews() {
        self.title = "Registrasi"
        view.backgroundColor = .systemBackground
        
        view.addSubview(pokeImage)
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(regisButton)
        
    }
    
    private func setupConstraint() {
        pokeImage.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(90)
        }
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(pokeImage.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(24)
        }
        
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(12)
            $0.left.right.equalTo(nameTextField)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(12)
            $0.left.right.equalTo(emailTextField)
        }
        
        regisButton.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func clearForm() {
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    private func bindViewModel() {
        
        nameTextField.rx.text.orEmpty
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)
        
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        regisButton.rx.tap
            .bind(to: viewModel.registerTapped)
            .disposed(by: disposeBag)
        
        viewModel.successMessage
            .subscribe(onNext: { [weak self] msg in
                guard let self = self, let view = self.view else { return }
                
                SnackBarSuccess.make(in: view, message: msg, duration: .lengthShort).show()
                
                LoadingHUD.show(in: view, text: "Mendaftarkan...")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    LoadingHUD.hide(from: view)
                    self.navigateToLogin()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .subscribe(onNext: { [weak self] msg in
                guard let view = self?.view else { return }
                SnackBarWarning.make(in: view, message: msg, duration: .lengthShort).show()
            })
            .disposed(by: disposeBag)
    }
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
}


