//
//  DetailTabViewController.swift
//  PokemonTes
//
//  Created by Phincon on 13/07/25.
//

import UIKit
import XLPagerTabStrip
import SnapKit

class DetailTabViewController: UIViewController {
    
    private let viewModel: DetailTabViewModel
    
    private let pokemonImage: UIImageView = {
        let image =  UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()
    
    init(viewModel: DetailTabViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        configureView()
    }
    
    private func setupViews() {
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        stackView.spacing = 10
        
        view.addSubview(pokemonImage)
        view.addSubview(stackView)
        
        pokemonImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(180)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(pokemonImage.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        pokemonImage.kf.setImage(with: PokemonUtils.getPokemonImageURL(from: viewModel.id ))
    }
    
    private func configureView() {
        switch viewModel.contentType {
        case .abilities(let abilities):
            for ability in abilities {
                let abilityName = ability.ability.name?.capitalized
                let label = PokemonUtils.createTypeLabel(
                    text: "\(abilityName?.capitalized ?? "Pokédex")",
                    bgColor: ability.is_hidden ? .lightGray : .systemRed, height: 50
                )
                stackView.addArrangedSubview(label)
                label.snp.makeConstraints {
                    $0.leading.trailing.equalTo(stackView).inset(0)
                }
            }
        case .baseXP(let xp):
            let label = UILabel()
            label.text = "\(xp) XP"
            label.font = .boldSystemFont(ofSize: 50)
            label.textColor = .systemRed
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        case .types(let types):
            for type in types {
                let typeName = type.type.name
                let label = PokemonUtils.createTypeLabel(
                    text: "\(typeName?.capitalized ?? "Pokédex")",
                    bgColor: UIColor.backgroundColorForType(typeName ?? "normal"), height: 50
                )
                stackView.addArrangedSubview(label)
                label.snp.makeConstraints {
                    $0.leading.trailing.equalTo(stackView).inset(0)
                }
            }
        }
    }
}

extension DetailTabViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: viewModel.title)
    }
}
