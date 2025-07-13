//
//  CardPokemonCell.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import UIKit
import SnapKit
import SkeletonView
import Kingfisher

class CardPokemonCell: UICollectionViewCell {
    
    enum DisplayMode {
        case grid
        case list
    }
    
    private let blurBackgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.5
        blurView.layer.cornerRadius = 12
        blurView.clipsToBounds = true
        return blurView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = false
        return view
    }()
    
    private let rootStack: UIStackView = {
        let stack = UIStackView()
        stack.isSkeletonable = true
        stack.spacing = 12
        return stack
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.isSkeletonable = true
        label.textColor = .black
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.isSkeletonable = true
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let pokemonImage: UIImageView = {
        let imageView = UIImageView()
        imageView.isSkeletonable = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var currentMode: DisplayMode = .list
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isSkeletonable = true
        contentView.isSkeletonable = true
        setupStyle()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
        setupLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pokemonImage.kf.cancelDownloadTask()
        pokemonImage.image = nil
        numberLabel.text = nil
        nameLabel.text = nil
        rootStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    private func setupStyle() {
        contentView.clipsToBounds = false
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.masksToBounds = false
    }
    
    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(blurBackgroundView)
        containerView.addSubview(rootStack)
        
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        blurBackgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        rootStack.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.lessThanOrEqualToSuperview().inset(12)
        }
    }
    
    func configure(id: Int, name: String, mode: DisplayMode) {
        currentMode = mode
        numberLabel.text = String(format: "#%03d", id)
        nameLabel.text = name.capitalized
        pokemonImage.kf.setImage(with: PokemonUtils.getPokemonImageURL(from: id))
        
        blurBackgroundView.backgroundColor = UIColor.backgroundColorForType("grass", isBlur: true)
        
        switch mode {
        case .grid:
            configureGrid()
        case .list:
            configureList()
        }
    }
    
    private func configureGrid() {
        rootStack.axis = .vertical
        rootStack.alignment = .center
        
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        
        rootStack.addArrangedSubview(pokemonImage)
        rootStack.addArrangedSubview(numberLabel)
        rootStack.addArrangedSubview(nameLabel)
        
        numberLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(10)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(20)
        }
        
        pokemonImage.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.top.equalTo(rootStack).offset(-30)
        }
    }
    
    private func configureList() {
        rootStack.axis = .horizontal
        rootStack.alignment = .center
        rootStack.distribution = .fillProportionally
        
        let infoStack = UIStackView(arrangedSubviews: [numberLabel, nameLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        infoStack.alignment = .leading
        
        rootStack.addArrangedSubview(infoStack)
        rootStack.addArrangedSubview(pokemonImage)
        
        pokemonImage.snp.makeConstraints { make in
            make.width.height.equalTo(120)
        }
    }
}

