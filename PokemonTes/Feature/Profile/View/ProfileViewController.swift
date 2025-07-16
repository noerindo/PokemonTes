//
//  ProfileViewController.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import UIKit
import SnapKit
import XLPagerTabStrip
import RxSwift
import RxCocoa
import MBProgressHUD

class ProfileViewController: UIViewController {
    
    private let viewModel: ProfileViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private let imageView: UIImageView = UIImageView.imagePokemon()
    
    private let nameTitleLabel: UILabel = UILabel.labelGeneral(text: "Name")
    
    private let emailTitleLabel: UILabel = UILabel.labelGeneral(text: "Email")
    
    private let usernameLabel: UILabel = UILabel.labelGeneral()
    
    private let emailLabel: UILabel =  UILabel.labelGeneral()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let updateButton: UIButton = {
        let button = UIButton()
        button.setTitle("Update Profile", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    init(viewModel: ProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
    }
    
    func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        view.addSubview(containerView)
        view.addSubview(updateButton)
        view.addSubview(logoutButton)
        
        containerView.addSubview(nameTitleLabel)
        containerView.addSubview(usernameLabel)
        containerView.addSubview(emailTitleLabel)
        containerView.addSubview(emailLabel)
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        nameTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(50)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.centerY.equalTo(nameTitleLabel)
            $0.leading.equalTo(nameTitleLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        emailTitleLabel.snp.makeConstraints {
            $0.top.equalTo(nameTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(50)
        }
        
        emailLabel.snp.makeConstraints {
            $0.centerY.equalTo(emailTitleLabel)
            $0.leading.equalTo(emailTitleLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        updateButton.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        logoutButton.snp.makeConstraints {
            $0.top.equalTo(updateButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        updateButton.addTarget(self, action: #selector(didTapUpdate), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
    }
    
    func bindViewModel() {
        viewModel.username
            .bind(to: usernameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.email
            .bind(to: emailLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    @objc func didTapUpdate() {
        LoadingHUD.show(in: self.view, text: "Loading..")
        let updateVC = UpdateViewController(viewModel: viewModel as! ProfileViewModel)
        self.navigationController?.pushViewController(updateVC, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            LoadingHUD.hide(from: self.view)
        }
    }
    
    @objc func didTapLogout() {
        LoadingHUD.show(in: self.view, text: "Logging out...")
        viewModel.logout()
        
        let loginVC = LoginViewController()
        moveViewController(to: loginVC)
    }
    
    func moveViewController(to viewController: UIViewController, after delay: TimeInterval = 1.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if let currentView = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController?.view {
                LoadingHUD.hide(from: currentView)
            }
            
            let nav = UINavigationController(rootViewController: viewController)
            
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                window.rootViewController = nav
                window.makeKeyAndVisible()
            }
        }
    }
}

extension ProfileViewController : IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Profile")
    }
}
