//
//  MainTabViewController.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import UIKit
import XLPagerTabStrip

class MainTabViewController: ButtonBarPagerTabStripViewController {
    private lazy var homeVC = HomeViewController(viewModel: HomeViewModel())
    private lazy var profileVC = ProfileViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        view.backgroundColor = .white
        buttonBarView.backgroundColor = .white
        containerView.backgroundColor = .white
    }
    
    func setupView() {
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = .clear
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 0.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .gray
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, _, _, _) in
            oldCell?.label.textColor = .gray
            newCell?.label.textColor = .systemBlue
        }
        
        buttonBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(buttonBarView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [homeVC, profileVC]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

