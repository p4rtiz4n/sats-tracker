//
// Created by p4rtiz4n on 02/01/2021.
//

import UIKit

protocol AssetDetailView: class {

    func update(with viewModel: AssetDetailViewModel)
}

class DefaultAssetDetailView: UIViewController {

    @IBOutlet weak var candlesView: CandlesView!
            
    @IBOutlet weak var navigationTitleImageView: UIImageView!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var pctLabel: UILabel!
    
    @IBOutlet weak var marketCapLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var vwapLabel: UILabel!
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var supplyLabel: UILabel!
    @IBOutlet weak var maxSupplyLabel: UILabel!

    @IBOutlet weak var favButton: UIBarButtonItem!
    
    var presenter: DefaultAssetDetailPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.present()
    }
}

// MARK: - DefaultAssetDetailView

extension DefaultAssetDetailView: AssetDetailView {

    func update(with viewModel: AssetDetailViewModel) {
        let asset = viewModel.asset()
        navigationTitleLabel.text = "\(asset.name) | \(asset.symbol)"
        navigationTitleImageView.setImage(
            url: asset.imageURL,
            placeholder: .image(UIImage(named: "icon")!)
        )

        candlesView.update(asset.candlesViewModel)
        iconImageView.setImage(
            url: asset.imageURL,
            placeholder: .image(UIImage(named: "icon")!)
        )

        let isUp = asset.priceDirection == .up

        priceLabel.text = asset.price
        directionLabel.text = asset.priceDirection.rawValue
        directionLabel.textColor = isUp ? .candleGreen : .candleRed
        pctLabel.text = asset.pricePctChange

        marketCapLabel.text = asset.marketCapUsd
        volumeLabel.text = asset.volumeUsd24Hr
        vwapLabel.text = asset.vwap24Hr

        rankLabel.text = "\(asset.rank)"
        supplyLabel.text = asset.supply
        maxSupplyLabel.text = asset.maxSupply

        favButton.image = UIImage(
            systemName: asset.isFavourite ? "star.fill" : "star"
        )
    }

    // MARK: - Actions

    @IBAction func toggleFavoriteAction(_ sender: Any?) {
        presenter.handleEvent(.toggleFavourite)
    }
}
