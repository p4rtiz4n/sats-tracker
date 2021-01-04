//
// Created by p4rtiz4n on 23/12/2020.
//

import UIKit

protocol AssetsWireframe {
    func present()
    func navigateToAssetDetail(with model: Asset)
}

// MARK: - DefaultAssetsWireframe

class DefaultAssetsWireframe {

    private let interactor: AssetsInteractor
    private let assetDetailWireframeFactory: AssetDetailWireframeFactory

    private weak var window: UIWindow?

    init(
        interactor: AssetsInteractor,
        assetDetailWireframeFactory: AssetDetailWireframeFactory,
        window: UIWindow?
    ) {
        self.interactor = interactor
        self.assetDetailWireframeFactory = assetDetailWireframeFactory
        self.window = window
    }
}

// MARK: - AssetsWireframe

extension DefaultAssetsWireframe: AssetsWireframe {

    func present() {
        let vc = wireUp()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func navigateToAssetDetail(with model: Asset) {
        assetDetailWireframeFactory.makeWireframe(
            model,
            container: window?.rootViewController
        ).present()
    }
}

extension DefaultAssetsWireframe {

    private func wireUp() -> UIViewController {
        let vc: DefaultAssetsView = UIStoryboard(.main).instantiate()
        let presenter = DefaultAssetsPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor
        )

        vc.presenter = presenter
        return UINavigationController(rootViewController: vc)
    }
}