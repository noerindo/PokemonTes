//
//  DetailViewController.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import UIKit
import XLPagerTabStrip
import SnapKit

class DetailViewController: ButtonBarPagerTabStripViewController, UICollectionViewDelegateFlowLayout {
    private let viewModel: DetailViewModelProtocol
    var isFirstLoad: Bool = true
    
    private let headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.isSkeletonable = true
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .white
        return label
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.isSkeletonable = true
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .white
        return label
    }()
    
    private let typeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private let pokemonImage: UIImageView = UIImageView.imagePokemon()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    init(viewModel: DetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        settings.style.selectedBarBackgroundColor = .clear
        settings.style.selectedBarHeight = 0
        super.viewDidLoad()
        buttonBarView.delegate = self
        self.containerView.backgroundColor = .white
        self.view.backgroundColor = .white
        self.view.bringSubviewToFront(containerView)
        setupBar()
        setupConstrain()
        setupHeader(viewModel.getData[2])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        buttonBarView.frame.origin.y = headerView.frame.maxY
        containerView.frame.origin.y = buttonBarView.frame.maxY + 10
        containerView.frame.size.height = view.frame.height - containerView.frame.origin.y
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return viewModel.getData.map {
            DetailTabViewController(detailPokemon: $0)
        }
    }
    
    @nonobjc
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width
        return CGSize(width: (cellWidth - 32) / 3, height: 32)
    }
    
    func setupBar() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarItemTitleColor = .clear
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarMinimumInteritemSpacing = 0
        settings.style.buttonBarItemLeftRightMargin = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        
        buttonBarView.layer.shadowOpacity = 0
        buttonBarView.layer.borderWidth = 0
        buttonBarView.layer.borderColor = UIColor.clear.cgColor
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.backgroundColor = .white
            oldCell?.layer.cornerRadius = 16
            oldCell?.label.textColor = .darkGray
            
            newCell?.backgroundColor = .white
            newCell?.layer.cornerRadius = 16
            newCell?.label.textColor = .systemBlue
        }
    }
    
    @objc private func backHome() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupConstrain() {
        
        view.addSubview(headerView)
        headerView.addSubview(nameLabel)
        headerView.addSubview(numberLabel)
        headerView.addSubview(typeStack)
        headerView.addSubview(pokemonImage)
        headerView.addSubview(backButton)
        
        backButton.addTarget(self, action: #selector(backHome), for: .touchUpInside)
        
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(260)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(50)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.leading.equalToSuperview().offset(16)
        }
        
        numberLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(nameLabel)
        }
        
        typeStack.snp.makeConstraints {
            $0.top.equalTo(numberLabel.snp.bottom).offset(12)
            $0.leading.equalTo(nameLabel)
        }
        
        pokemonImage.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview().offset(10)
            $0.bottom.equalTo(headerView.snp.bottom).offset(-20)
            $0.top.equalTo(nameLabel.snp.top)
            $0.width.height.equalTo(200)
        }
        
        containerView.snp.remakeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
    func setupHeader(_ detailPokemon: DetailTabViewItem) {
        pokemonImage.kf.setImage(with: PokemonUtils.getPokemonImageURL(from: detailPokemon.id, isGif: true), placeholder: UIImage(named: "Pokeball"))
        nameLabel.text = detailPokemon.title.capitalized
        numberLabel.text = String(format: "#%03d", detailPokemon.id)
        let typeName = detailPokemon.typeNameValue
        buttonBarView.backgroundColor = UIColor.backgroundColorForType(typeName, isBlur: true)
        headerView.backgroundColor = UIColor.backgroundColorForType(typeName, isBlur: true)
        typeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let types = detailPokemon.typesList {
            for type in types {
                let label = PokemonUtils.createTypeLabel(
                    text: "\(type.type.name?.capitalized ?? "Pokédex")",
                    bgColor: UIColor.backgroundColorForType(type.type.name ?? "normal")
                )
                typeStack.addArrangedSubview(label)
            }
        }
    }
    
}


