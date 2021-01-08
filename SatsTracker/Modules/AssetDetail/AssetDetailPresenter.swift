//
// Created by p4rtiz4n on 02/01/2021.
//

import Foundation

enum AssetDetailPresenterEvent {
    case toggleFavourite
}

protocol AssetDetailPresenter {

    func present()
    func handleEvent(_ event: AssetDetailPresenterEvent)
}

class DefaultAssetDetailPresenter {

    private let wireframe: AssetDetailWireframe
    private let interactor: AssetDetailInteractor
    private let asset: Asset

    private weak var view: AssetDetailView?

    private var candlesState: CandleState = .loading

    init(
        view: AssetDetailView,
        wireframe: AssetDetailWireframe,
        interactor: AssetDetailInteractor,
        asset: Asset
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
        self.asset = asset
    }
}

// MARK: - AssetsPresenter

extension DefaultAssetDetailPresenter: AssetDetailPresenter {

    func present() {
        view?.update(with: makeViewModel())
        let lim = Constant.candleLim
        interactor.candles(for: asset, lim: lim) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleCandle(result: result)
            }
        }
    }

    func handleEvent(_ event: AssetDetailPresenterEvent) {
        switch event {
        case .toggleFavourite:
            interactor.toggleFavourite(asset)
            view?.update(with: makeViewModel())
        }
    }
}

// MARK: - ViewModel Utils

private extension DefaultAssetDetailPresenter {

    func makeViewModel() -> AssetDetailViewModel {
        let candlesViewModel = candlesState.viewModel(Constant.candleLim)
        let fav = interactor.favoriteAssets().contains(.init(asset: asset))

        switch candlesState {
        case .unavailable:
            return .failed(.init(asset, fav: fav, candles: candlesViewModel))
        case .loading:
            return .loading(.init(asset, fav: fav, candles: candlesViewModel))
        case let .loaded(candles):
            return .loaded(.init(asset, fav: fav, candles: candlesViewModel))
        }
    }
}

// MARK: - Candle handling

private extension DefaultAssetDetailPresenter {

    typealias CandleResult = Result<[Candle], Error>

    enum CandleState {
        case unavailable
        case loading
        case loaded(_ candles: [Candle])

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

    func handleCandle(result: CandleResult) {
        switch result {
        case var .success(candles):
            candlesState = .loaded(candles)
            view?.update(with: makeViewModel())
        case let .failure(err):
            candlesState = .unavailable
            view?.update(with: makeViewModel())
        }
    }
}

// MARK: - Constant

private extension DefaultAssetDetailPresenter {

    enum Constant {
        static let candleLim = 90
    }
}