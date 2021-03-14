//
// Created by p4rtiz4n on 14/03/2021.
//

import SwiftUI
import WidgetKit

struct WidgetView: View {
    
    @State var viewModel: WidgetViewModel
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        VStack {
            ForEach(0..<min(4, viewModel.assets.count)) { idx in
                AssetView(viewModel: viewModel.assets[idx])
                if idx < (viewModel.assets.count - 1) {
                    Divider()
                }
            }
        }
        .padding()
    }
}

struct AssetView: View {

    @State var viewModel: WidgetViewModel.AssetViewModel
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.price)
                    .font(.footnote)
                    .scaledToFit()
                    .minimumScaleFactor(0.81)
                HStack {
                    Text(viewModel.title)
                        .font(.caption2)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: 25)
                        .scaledToFit()
                        .foregroundColor(Color.secondary)
                    Text(viewModel.pctChange)
                        .font(.caption2)
                        .minimumScaleFactor(0.6)
                        .frame(maxWidth: 35)
                        .scaledToFit()
                        .foregroundColor(viewModel.pctColor)
                }
            }
            .frame(maxWidth: 50)
            
            ChartView(viewModel: viewModel.chart)
        }
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(viewModel: .mock())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
