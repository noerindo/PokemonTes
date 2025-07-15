//
//  UpdateViewController.swift
//  PokemonTes
//
//  Created by Phincon on 13/07/25.
//

import UIKit
import SnapKit
import MBProgressHUD
import RxSwift
import RxCocoa

class UpdateViewController: UIViewController {
    
    private let viewModel: ProfileViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "pokeball")
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 40
        image.clipsToBounds = true
        return image
    }()
    
    private let usernameField: UITextField = {
        let text = UITextField()
        text.placeholder = "Username"
        return text
    }()
    
    private let emailField: UITextField = {
        let text = UITextField()
        text.placeholder = "Email"
        return text
    }()
    
    private let passwordField: UITextField = {
        let text = UITextField()
        text.placeholder = "Password"
        text.isSecureTextEntry = true
        text.enablePasswordToggle()
        return text
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fillExistingData()
        bindViewModel()
    }
    
    private func setupView() {
        view.backgroundColor = .white
    
        view.addSubview(imageView)
        [usernameField, emailField, passwordField].forEach {
            $0.borderStyle = .roundedRect
            view.addSubview($0)
        }
        
        saveButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
        view.addSubview(saveButton)
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        
        usernameField.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
        
        emailField.snp.makeConstraints {
            $0.top.equalTo(usernameField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
        
        passwordField.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(passwordField.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func fillExistingData() {
        guard let profile = viewModel.getUserProfile() else { return }
        usernameField.text = profile.name
        emailField.text = profile.email
        passwordField.text = profile.password
    }
    
    private func bindViewModel() {
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self else { return }
                if isLoading {
                    LoadingHUD.show(in: self.view, text: "Updating...")
                } else {
                    LoadingHUD.hide(from: self.view)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.didUpdateProfile
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func saveChanges() {
        let username = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""
        
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            SnackBarWarning.make(in: view, message: "Data tidak boleh kosong", duration: .lengthShort).show()
            return
        }
        
        viewModel.updateProfile(username: username, email: email, password: password)
    }
}

