//
// Created by p4rtiz4n on 14/03/2021.
//

import SwiftUI

struct ChartView: View {
    
    @State var viewModel: ChartViewModel = .mock()

    var body: some View {
        GeometryReader { geometry in
            let candles = viewModel.candleViewModels(in: geometry.size)
            ZStack {
                ForEach(0..<candles.count) { idx in
                    let candle = candles[idx]
                    
                    Path { path in
                        path.move(to: candle.wick.midXminY)
                        path.addLine(to: candle.wick.midXmaxY)
                    }
                    .stroke(candle.color, lineWidth: 1)

                    Path { path in
                        path.move(to: candle.body.minXminY)
                        path.addLine(to: candle.body.maxXminY)
                        path.addLine(to: candle.body.maxXmaxY)
                        path.addLine(to: candle.body.minXmaxY)
                        path.closeSubpath()
                    }
                    .fill(candle.color)
                }
            }
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
            ChartView()
                .preferredColorScheme(.dark)
                .previewLayout(PreviewLayout.fixed(width: 250, height: 250))
                .padding()
                .previewDisplayName("Chart")
    }
}
