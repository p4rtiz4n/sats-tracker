//
// Created by p4rtiz4n on 23/12/2020.
//

import UIKit

enum AssetsPresenterEvent {
    case didBeginScrolling
    case didComeToRest(_ visibleIndexPaths: [IndexPath])
    case refreshAction
    case viewDidAppear
    case viewDidDisAppear
    case search(_ term: String?)
    case favourite(_ idxPath: IndexPath)
    case didSelect(_ idxPath: IndexPath)
}

protocol AssetsPresenter {

    func present()
    func handleEvent(_ event: AssetsPresenterEvent)
}

// MARK: - DefaultAssetsPresenter

class DefaultAssetsPresenter {

    private let wireframe: AssetsWireframe
    private let interactor: AssetsInteractor

    private weak var view: AssetsView?

    private var currentAssets: [Asset] = []
    private var currentCandles: [String: CandleState] = [:]
    private var currentFavouriteAssets: [Asset] = []
    private var candleProcessingAssets: [Asset] = []
    private var refreshTimer: Timer? = nil
    private var searchTerm: String? = nil

    init(
        view: AssetsView,
        wireframe: AssetsWireframe,
        interactor: AssetsInteractor
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
    }
}

// MARK: - AssetsPresenter

extension DefaultAssetsPresenter: AssetsPresenter {

    func present() {
        view?.update(with: .loading)
        interactor.load(
            pageLoadedHandler: { [weak self] assets in
                DispatchQueue.main.async {
                    self?.updateCurrentAssets(assets)
                    let viewModels = self?.makeSectionViewModels() ?? []
                    self?.view?.update(with: .partialLoad(viewModels)
                    )
                }
            },
            completionHandler: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(assets):
                        self?.updateCurrentAssets(assets)
                        let viewModels = self?.makeSectionViewModels() ?? []
                        self?.view?.update(with: .loaded(viewModels))
                    case let .failure(error):
                        self?.view?.update(with: .failedToLoad(error))
                    }
                }
            }
        )
    }

    func handleEvent(_ event: AssetsPresenterEvent) {
        switch event {
        case .didBeginScrolling:
            cancelCandleLoading()
        case let .didComeToRest(visibleIndexPaths):
            loadCandles(for: visibleIndexPaths)
        case .refreshAction:
            refresh()
        case .viewDidAppear:
            startAppStateNotifications()
            startDataRefreshingIfNecessary()
            updateCurrentAssets(currentAssets)
            view?.update(with: .loaded(makeSectionViewModels()))
        case .viewDidDisAppear:
            stopAppStateNotifications()
            stopDataRefreshing()
        case let .search(term):
            handleSearch(term)
        case let .favourite(idxPath):
            handleFavourite(idxPath)
        case let .didSelect(idxPath):
            if let asset = self.asset(at: idxPath) {
                wireframe.navigateToAssetDetail(with: asset)
            }
        }
    }
}

// MARK: - ViewModel utilities

private extension DefaultAssetsPresenter {

    func makeSectionViewModels() -> [AssetsViewModel.Section] {
        let isSearching = !(searchTerm?.isEmpty ?? true)
        let hasFavourite = !interactor.favoriteAssets().isEmpty

        var sections: [AssetsViewModel.Section] = [
            .init(
                title: hasFavourite ? "USD quote | daily candles" : "",
                assets: assetViewModels(from: displayingAssets())
            )
        ]

        if !isSearching && hasFavourite {
            let assets = assetViewModels(from: currentFavouriteAssets)
            sections = [.init(title: "Favourite", assets: assets)] + sections
        }

        return sections
    }

    func assetViewModels(from assets: [Asset]) -> [AssetsViewModel.Asset] {
        return assets.map {
            .init(
                asset: $0,
                candles: currentCandles[$0.id]?.viewModel(Constant.candleLim) ??
                    .loading(Constant.candleLim)
            )
        }
    }

    func updateCurrentAssets(_ assets: [Asset]) {
        currentAssets = assets
        currentFavouriteAssets = interactor.favoriteAssets()
            .compactMap { fav in assets.first(where: { $0.id == fav.id }) }
    }

    func asset(at idxPath: IndexPath) -> Asset? {
        if currentFavouriteAssets.count > 0 &&
            searchTerm?.isEmpty ?? true &&
            idxPath.section == 0 {
            return currentFavouriteAssets[idxPath.row]
        }
        return displayingAssets()[safe: idxPath.row]
    }

    func isFavouritesIndexPath(_ idxPath: IndexPath) -> Bool {
        return currentFavouriteAssets.count > 0 && idxPath.section == 0
    }
}

// MARK: - Search

private extension DefaultAssetsPresenter {

    func handleSearch(_ term: String?) {
        searchTerm = term
        view?.update(with: .loaded(makeSectionViewModels()))
    }

    func displayingAssets() -> [Asset] {
        return filteredAssets() ?? currentAssets
    }

    func filteredAssets() -> [Asset]? {
        guard let term = searchTerm, !term.isEmpty else {
            return nil
        }

        let terms = [term, term.uppercased(), term.lowercased()]

        return currentAssets.filter { asset in
            for term in terms {
                if asset.symbol.fuzzyMatch(term) {
                    return true
                }
                if asset.name.fuzzyMatch(term) {
                    return true
                }
            }
            return false
        }
    }
}

// MARK: - Candles handling

private extension DefaultAssetsPresenter {

    typealias CandleResult = Result<[Candle], Error>

    enum CandleState {
        case unavailable
        case loading
        case loaded(_ candles: [Candle])
    }

    func loadCandles(for indexPaths: [IndexPath]) {
        for idxPath in indexPaths {
            guard let asset = asset(at: idxPath) else {
                continue
            }

            guard !candleProcessingAssets.contains(asset) &&
                currentCandles[asset.id] == nil else {
                continue
            }
            guard let _ = asset.changePercent24Hr else {
                currentCandles[asset.id] = .unavailable
                view?.update(with: .loaded(makeSectionViewModels()), at: idxPath)
                continue
            }
            candleProcessingAssets.append(asset)
            interactor.candles(
                for: asset,
                lim: Constant.candleLim,
                handler: { [weak self] result in
                    DispatchQueue.main.async {
                        self?.handleCandle(
                            result: result,
                            asset: asset,
                            idxPath: idxPath
                        )
                    }
                }
            )
        }
    }

    func handleCandle(result: CandleResult, asset: Asset, idxPath: IndexPath) {
        switch result {
        case var .success(candles):
            let cnt = candles.count
            if cnt > Constant.candleLim {
                candles = Array(candles[(cnt - Constant.candleLim)..<cnt])
            }
            currentCandles[asset.id] = .loaded(candles)
            candleProcessingAssets.removeAll(where: { $0 == asset })
            guard asset == self.asset(at: idxPath) else {
                return
            }

            view?.update(with: .loaded(makeSectionViewModels()), at: idxPath)
            updateFavouriteCandlesIfNeeded(asset, idxPath: idxPath)
        case let .failure(err):
            if (err as? CandleCacheError) == CandleCacheError.unavailable {
                currentCandles[asset.id] = .unavailable
                view?.update(with: .loaded(makeSectionViewModels()), at: idxPath)
            }
            print("\(type(of: self).self), \(type(of: err).self)", err)
        }
    }

    func updateFavouriteCandlesIfNeeded(_ asset: Asset, idxPath: IndexPath) {
        guard isFavouritesIndexPath(idxPath) else {
            return
        }
        guard let idx = currentAssets.firstIndex(where: { $0 == asset }) else {
            return
        }
        view?.update(
            with: .loaded(makeSectionViewModels()),
            at: IndexPath(item: idx, section: 1)
        )
    }

    func cancelCandleLoading() {
        candleProcessingAssets.forEach {
            interactor.candlesCancel($0.id, nil)
        }
        candleProcessingAssets = []
    }
}

// MARK: - UIApplication state notifications

private extension DefaultAssetsPresenter {

    func startAppStateNotifications() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(
            self,
            sel: #selector(handleDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification
        )
        NotificationCenter.default.addObserver(
            self,
            sel: #selector(handleDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification
        )
    }

    func stopAppStateNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleDidBecomeActive(_ notification: NSNotification) {
        refresh()
        startDataRefreshingIfNecessary()
    }

    @objc func handleDidEnterBackground(_ notification: NSNotification) {
        stopDataRefreshing()
    }
}

// MARK: - Data refresh handling

private extension DefaultAssetsPresenter {

    func startDataRefreshingIfNecessary() {
        guard refreshTimer == nil else {
            return
        }
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: Constant.refreshInterval,
            repeats: true,
            block: { [weak self] _ in self?.refresh() }
        )
    }

    func stopDataRefreshing() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    func refresh() {
        interactor.load(
            pageLoadedHandler: { _ in ()},
            completionHandler: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(assets):
                        self?.updateCurrentAssets(assets)
                        let viewModels = self?.makeSectionViewModels() ?? []
                        self?.view?.update(with: .loaded(viewModels))
                        self?.cancelCandleLoading()
                        self?.currentCandles = [:]
                    case let .failure(error):
                        self?.view?.update(with: .failedToLoad(error))
                    }
                }
            }
        )
    }
}

// MARK: - Favourite handling

private extension DefaultAssetsPresenter {

    func handleFavourite(_ idxPath: IndexPath) {
        guard let asset = self.asset(at: idxPath) else {
            return
        }
        interactor.toggleFavourite(asset)
        updateCurrentAssets(currentAssets) // to trigger favourites refresh
        view?.update(with: .loaded(makeSectionViewModels()))
    }
}

// MARK: - CandleState utilities

private extension DefaultAssetsPresenter.CandleState {

    func viewModel(_ lim: Int) -> CandlesViewModel {
        switch self {
        case .unavailable:
            return .unavailable(lim)
        case .loading:
            return .loading(lim)
        case let .loaded(candles):
            return .loaded(candles.map { .init($0) })
        }
    }
}

// MARK: - Constants

private extension DefaultAssetsPresenter {

    enum Constant {
        static let candleLim: Int = 30
        static let refreshInterval: TimeInterval = 60
    }
}
