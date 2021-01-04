//
// Created by p4rtiz4n on 28/12/2020.
//

import UIKit

class CandlesView: UIView {

    struct Attributes {

        let path: CGPath
        let bounds: CGRect
        let center: CGPoint
        let color: CGColor
        let alpha: Float
    }
    
    private var candles: [CAShapeLayer] = []
    private var candleWidth: CGFloat = 4
    private var previousViewModel: CandlesViewModel = .loading(30)
    private var previousUpdate: Date = Date()
    private var previousBounds: CGRect = .zero

    func update(_ viewModel: CandlesViewModel) {
        switch viewModel {
        case let .unavailable(cnt):
            updateForUnavailable(cnt)
        case let .loading(cnt):
            updateForLoading(cnt)
        case let .loaded(candles):
            let tDelta = previousUpdate.distance(to: Date())
            let animated = tDelta > 0.1 && previousViewModel.isLoading()
            DispatchQueue.main.async {
                self.updateCandles(candles, animated: animated)
            }
        }
        previousViewModel = viewModel
        previousUpdate = Date()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard previousBounds != bounds else {
            return
        }
        previousBounds = bounds
        update(previousViewModel)
    }
}

// MARK: - Candles layout

private extension CandlesView {

    func updateForUnavailable(_ cnt: Int) {
        adjustCountIfNecessary(cnt)
        candles.enumerated().forEach {
            let attr = loadingAttributes(at: $0.0, alpha: 0.5)
            apply(attributes: attr, to: $0.1)
        }
    }

    func updateForLoading(_ cnt: Int) {
        candleWidth = ceil(bounds.width / CGFloat(cnt))
        adjustCountIfNecessary(cnt)
        candles.enumerated().forEach {
            apply(attributes: loadingAttributes(at: $0.0), to: $0.1)
            $0.1.removeAllAnimations()
        }
    }

    func updateCandles(
        _ newCandles: [CandlesViewModel.Candle],
        animated: Bool = true
    ) {
        var candlesToRemove: [CAShapeLayer] = []
        var candlesToAdd: [CAShapeLayer] = []
        var candlesToUpdate: [CAShapeLayer] = []
        var newCandles = newCandles

        candleWidth = ceil(bounds.width / CGFloat(newCandles.count))
        let newCnt = newCandles.count
        let range = newCnt - Int(floor(bounds.width / candleWidth))..<newCnt
        newCandles = Array(newCandles[range])

        if candles.count > newCandles.count {
            candlesToRemove = Array(candles[newCandles.count..<candles.count])
            candles = Array(candles[0..<newCandles.count])
        }

        if candles.count > 0 {
            candlesToUpdate = candles
        }

        if newCandles.count > candles.count {
            candlesToAdd = newCandles[candles.count..<newCandles.count]
                .map { _ in makeCandleLayer() }
        }

        let attributes = self.attributes(for: newCandles)

        candlesToRemove.forEach { $0.removeFromSuperlayer() }

        candlesToUpdate.enumerated().forEach { (idx, shapeLayer) in
            apply(attributes: attributes[idx], to: shapeLayer)
            if !animated {
                shapeLayer.removeAllAnimations()
            }
        }

        let addingRange = candlesToUpdate.count..<attributes.count
        let addingAttrs = Array(attributes[addingRange])

        candlesToAdd.enumerated().forEach {
            self.layer.addSublayer($0.1)
            apply(attributes: addingAttrs[$0.0], to: $0.1)
            if !animated {
                $0.1.removeAllAnimations()
            }
        }

        candles = candlesToUpdate + candlesToAdd
    }
    
    func attributes(for candles: [CandlesViewModel.Candle]) -> [Attributes] {
        let sortCandles = candles.sorted(by: { $0.low < $1.low })

        guard let low = sortCandles.first?.low,
              let high = sortCandles.last?.high else {
            return []
        }

        let yLength = high - low

        return candles.enumerated().map { (idx, candle) in

            let (close, open) = (candle.close, candle.open)
            let isGreen = candle.close >= candle.open
            let color: UIColor = isGreen ? .candleGreen : .candleRed
            let bodyHigh = isGreen ? close : open
            let bodyLength = isGreen ? close - open : open - close
            let yRatio = bounds.height / (high - low)

            let candleFrame = CGRect(
                x: candleWidth * CGFloat(idx),
                y: (yLength - (candle.high - low)) * yRatio,
                width: candleWidth,
                height: (candle.high - candle.low) * yRatio
            )

            let candleBodyFrame = CGRect(
                x: candleWidth * CGFloat(idx),
                y: (yLength - (bodyHigh - low)) * yRatio,
                width: candleWidth,
                height: bodyLength * yRatio
            )

            let candleBounds = CGRect(origin: .zero, size: candleFrame.size)

            let candleBodyBounds = CGRect(
                origin: CGPoint(
                    x: 0,
                    y: candleBodyFrame.origin.y - candleFrame.origin.y
                ),
                size: candleBodyFrame.size
            )

            let path = UIBezierPath(
                rect: CGRect(
                    origin: CGPoint(x: candleWidth * 0.5 - 0.5, y: 0),
                    size: CGSize(width: 1, height: candleBounds.height)
                )
            )

            let bodyPath = UIBezierPath(rect: candleBodyBounds)
            bodyPath.usesEvenOddFillRule = false
            path.usesEvenOddFillRule = false
            path.append(bodyPath)

            return Attributes(
                path: path.cgPath,
                bounds: CGRect(origin: .zero, size: candleFrame.size),
                center: CGPoint(x: candleFrame.midX, y: candleFrame.midY),
                color: color.cgColor,
                alpha: 1
            )
        }
    }

    func makeCandleLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        return layer
    }

    func apply(attributes: Attributes, to layer: CAShapeLayer) {
        layer.path = attributes.path
        layer.bounds = attributes.bounds
        layer.position = attributes.center
        layer.fillColor = attributes.color
        layer.opacity = attributes.alpha
    }

    func loadingAttributes(
        at idx: Int,
        color: UIColor = .systemGray,
        alpha: Float = 0.1
    ) -> Attributes {
        let pathBounds = CGRect(x: 0, y: 0, width: candleWidth, height: 5)
        let path = UIBezierPath(
            rect: pathBounds.insetBy(dx: (candleWidth - 1) * 0.5, dy: 0)
        )
        let bodyPath = UIBezierPath(
            rect: pathBounds.insetBy(dx: 0, dy: pathBounds.height * 0.45)
        )
        bodyPath.usesEvenOddFillRule = false
        path.usesEvenOddFillRule = false
        path.append(bodyPath)

        let offset = CGFloat(sin(Double(idx * 60) * Double.pi / 180) * 3)

        return Attributes(
            path: path.cgPath,
            bounds: pathBounds,
            center: CGPoint(
                x: candleWidth * CGFloat(idx) + candleWidth * 0.5,
                y: bounds.height * 0.5 + offset
            ),
            color: color.cgColor,
            alpha: alpha
        )
    }

    func adjustCountIfNecessary(_ cnt: Int) {
        candleWidth = ceil(bounds.width / CGFloat(cnt))
        if candles.count > cnt {
            candles[cnt..<candles.count].forEach {
                $0.removeFromSuperlayer()
            }
            candles = Array(candles[0..<cnt])
        }
        if candles.count < cnt {
            let newCandles: [CAShapeLayer] = (0..<(cnt - candles.count)).map { _ in
                let candle = makeCandleLayer()
                layer.addSublayer(candle)
                return candle
            }
            candles = candles + newCandles
        }
    }
}
