//
// Created by p4rtiz4n on 23/12/2020.
//

import UIKit

protocol AssetDetailWireframe {
    func present()
}

// MARK: - DefaultAssetDetailWireframe

class DefaultAssetDetailWireframe {

    private let interactor: AssetDetailInteractor
    private let asset: Asset

    private weak var container: UIViewController?

    init(
        interactor: AssetDetailInteractor,
        asset: Asset,
        container: UIViewController?
    ) {
        self.interactor = interactor
        self.asset = asset
        self.container = container
    }
}

// MARK: - AssetDetailWireframe

extension DefaultAssetDetailWireframe: AssetDetailWireframe {

    func present() {
        let vc = wireUp()
        container?.show(vc, sender: self)
    }
}

extension DefaultAssetDetailWireframe {

    private func wireUp() -> UIViewController {
        let vc: DefaultAssetDetailView = UIStoryboard(.main).instantiate()
        let presenter = DefaultAssetDetailPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            asset: asset
        )

        vc.presenter = presenter
        return vc
    }
}