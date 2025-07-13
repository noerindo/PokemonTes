//
//  LoginViewController.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import MBProgressHUD

class LoginViewController: UIViewController {
    
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    
    private let pokeImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "pokeball")
        image.contentMode = .scaleAspectFit
        return image
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
        textField.enablePasswordToggle()
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Belum punya akun?"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    
    private let regisButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Daftar", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        return button
    }()
    
    private lazy var regisStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [infoLabel, regisButton])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        bindViewModel()
    }
    
    private func setupViews() {
        view.addSubview(contentStack)
        [pokeImage, emailTextField, passwordTextField, loginButton, regisStack].forEach {
            contentStack.addArrangedSubview($0)
            if $0 is UITextField {
                $0.snp.makeConstraints { $0.width.equalToSuperview().inset(24) }
            }
            
            contentStack.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.right.equalToSuperview().inset(24)
            }
            
            pokeImage.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.height.equalTo(200)
            }
            
            loginButton.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
            regisButton.addTarget(self, action: #selector(goToRegister), for: .touchUpInside)
        }
    }
    
    private func bindViewModel() {
        
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .bind(to: viewModel.loginTapped)
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                SnackBarWarning.make(in: self.view, message: message, duration: .lengthShort).show()
            })
            .disposed(by: disposeBag)
        
        viewModel.successMessage
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                LoadingHUD.show(in: self.view, text: message)
            })
            .disposed(by: disposeBag)
        
        viewModel.loginSuccess
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    LoadingHUD.hide(from: self.view)
                    self.navigateToHome()
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func goToLogin() {
        guard
            let emailUser = emailTextField.text,
            let passwordUser = passwordTextField.text
        else { return }
        
    }
    
    @objc private func goToRegister() {
        let registerVC = RegisViewController()
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    private func navigateToHome() {
        let tabVC = MainTabViewController()
        let nav = UINavigationController(rootViewController: tabVC)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = scene.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = nav
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
}


