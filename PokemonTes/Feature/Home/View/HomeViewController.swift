//
//  HomeViewController.swift
//  PokemonTes
//
//  Created by Phincon on 12/07/25.
//

import UIKit
import RxSwift
import SkeletonView
import SnapKit
import XLPagerTabStrip
import MBProgressHUD

class HomeViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    
    private var pokemons: [DetailPokemonModel] = []
    private var imageLoadCounter = 0
    private var filteredPokemons: [DetailPokemonModel] = []
    var searchActive: Bool = false
    private var isFetchingMore = false
    private var isFirstLoad = true
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.isSkeletonable = true
        label.text = "Pokédex"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.isSkeletonable = true
        label.text = "Search for Pokémon by name Pokédex"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = 2
        return label
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.isSkeletonable = true
        button.setImage(UIImage(systemName: "square.grid.2x2"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.isSkeletonable = true
        sb.placeholder = "What Pokémon are you looking for?"
        sb.searchBarStyle = .minimal
        sb.returnKeyType = .search
        return sb
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private var isGrid = false {
        didSet {
            collectionView.reloadData()
            updateLayout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        configObservable()
        setupViews()
        setupLayout()
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CardPokemonCell.self, forCellWithReuseIdentifier: "CardPokemonCell")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.collectionView.stopSkeletonAnimation()
            [self.titleLabel, self.subtitleLabel, self.toggleButton, self.searchBar, self.collectionView].forEach {
                $0.hideSkeleton()
            }
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoad {
            viewModel.fetchPokemon()
            isFirstLoad = false
            [titleLabel, subtitleLabel, toggleButton, searchBar, collectionView].forEach {
                $0.isSkeletonable = true
                $0.showAnimatedGradientSkeleton()
                $0.showAnimatedSkeleton(usingColor: .concrete, transition: .crossDissolve(0.25))
            }
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(toggleButton)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
    }
    
    @objc private func toggleTapped() {
        isGrid.toggle()
        let icon = isGrid ? "list.bullet" : "square.grid.2x2"
        toggleButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let query = textField.text?.lowercased(), !query.isEmpty else {
            searchActive = false
            filteredPokemons = []
            collectionView.reloadData()
            return
        }
        
        searchActive = true
        filteredPokemons = pokemons.filter { pokemon in
            return pokemon.name?.lowercased().contains(query) ?? false ||
            "\(pokemon.id ?? 0)".contains(query)
        }
        collectionView.reloadData()
    }
    
    
    private func setupLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(16)
        }
        
        toggleButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(toggleButton)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.leading.equalTo(subtitleLabel)
            make.trailing.equalTo(toggleButton)
            make.height.equalTo(36)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
        
        
    }
    
    private func updateLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func configObservable() {
        viewModel.pokemons
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                
                self.pokemons = data
                self.filteredPokemons = []
                self.searchActive = false
                self.imageLoadCounter = 0
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
            })
            .disposed(by: disposeBag)
        
        viewModel.onLoadingDetail = { [weak self] isLoading in
            guard let self = self else { return }
            if isLoading {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
    
    private func fetchMorePokemons() {
        viewModel.fetchPokemon()
        viewModel.isLoading
            .filter { !$0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.isFetchingMore = false
            })
            .disposed(by: disposeBag)
    }
    
}


extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return "CardPokemonCell"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.sk.isSkeletonActive {
            return 6
        }
        
        let currentData = searchActive ? filteredPokemons : pokemons
        return currentData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.sk.isSkeletonActive {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardPokemonCell", for: indexPath) as! CardPokemonCell
            return cell
        }
        
        let currentData = searchActive ? filteredPokemons : pokemons
        
        return getCardCell(collectionView, cellForItemAt: indexPath, data: currentData)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        if indexPath.item == pokemons.count {
            return CGSize(width: width, height: 60)
        }
        return isGrid ? CGSize(width: (width / 2) - 8, height: 150)
        : CGSize(width: width, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentData = searchActive ? filteredPokemons : pokemons
        let selectedPokemon = currentData[indexPath.item]
        
        viewModel.didSelectPokemon(selectedPokemon) { [weak self] detail in
            guard let self = self else { return }
            let detailVC = DetailViewController(data: detail)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !searchActive else { return }
        guard !viewModel.isLoadingValue else { return }
        guard !isFetchingMore else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - frameHeight - 100 {
            isFetchingMore = true
            fetchMorePokemons()
        }
    }
    
}

extension HomeViewController {
    private func getCardCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, data: [DetailPokemonModel]) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardPokemonCell", for: indexPath) as! CardPokemonCell
        
        let pokemon = data[indexPath.item]
        
        cell.configure(
            id: pokemon.id ?? 0,
            name: pokemon.name ?? "Labubu",
            types: pokemon.types,
            mode: self.isGrid ? .grid : .list
        )
        
        self.imageLoadCounter += 1
        if self.imageLoadCounter == self.pokemons.count {
            [self.titleLabel, self.subtitleLabel, self.toggleButton, self.searchBar, self.collectionView].forEach {
                $0.hideSkeleton()
            }
            self.collectionView.stopSkeletonAnimation()
        }
        
        return cell
        
    }
    
}

// MARK: search bar delegate
extension HomeViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchActive = false
            filteredPokemons = pokemons
        } else {
            searchActive = true
            filteredPokemons = pokemons.filter {
                $0.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        
        collectionView.reloadData()
    }
}

// MARK: tabbar
extension HomeViewController : IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Home")
    }
}

