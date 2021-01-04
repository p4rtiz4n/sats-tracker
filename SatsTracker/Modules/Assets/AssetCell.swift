//
// Created by p4rtiz4n on 26/12/2020.
//

import UIKit

class AssetCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceDirectionLabel: UILabel!
    @IBOutlet weak var pricePctLabel: UILabel!
    @IBOutlet weak var candleView: CandlesView!
    
    func update(with viewModel: AssetsViewModel.Asset) {
        let isUp = viewModel.priceDirection == .up
        titleLabel.text = viewModel.name
        rankLabel.text = "\(viewModel.rank)"
        symbolLabel.text = "\(viewModel.symbol)"
        priceLabel.text = viewModel.price
        priceDirectionLabel.text = viewModel.priceDirection.rawValue
        priceDirectionLabel.textColor = isUp ? .candleGreen : .candleRed
        pricePctLabel.text = viewModel.pricePctChange
        candleView.update(viewModel.candlesViewModel)
        iconView.setImage(
            url: viewModel.imageURL,
            placeholder: .image(UIImage(named: "icon")!)
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.cancelImageLoad()
        candleView.update(.loading(Constant.candleLim))
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if window == nil {
            iconView.cancelImageLoad()
        }
    }
}

// MARK: - Constants

extension AssetCell {

    enum Constant {
        static let candleLim: Int = 30
    }

}