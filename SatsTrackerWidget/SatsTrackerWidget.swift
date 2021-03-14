//
// Created by p4rtiz4n on 14/03/2021.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {

    let service: WidgetsService = {
        let assetsService = DefaultAssetsService(network: DefaultNetwork())
        return DefaultWidgetsService(
            assetsService: assetsService,
            candleCacheService: DefaultCandlesCacheService(
                assetsService: assetsService
            )
        )
    }()

    func placeholder(in context: Context) -> WidgetEntry {
        return WidgetEntry(assets: [], info: [:])
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        service.fetchAssetsAndCandles(
            for: configuration.assets ?? [],
            handler: { result in
                let entry: WidgetEntry
                switch result {
                case let .success((asset, info)):
                    entry = WidgetEntry(
                        assets: asset,
                        info: info,
                        config: configuration
                    )
                case let .failure(error):
                    print(error)
                    entry = placeholder(in: context)
                }
                DispatchQueue.main.async {
                    completion(entry)
                }
            }
        )
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(
            for: configuration,
            in: context,
            completion: { entry in
                let timeline = Timeline(
                    entries: [entry],
                    policy: .after(Date().adding(minutes: Constant.interval))
                )
                completion(timeline)
            }
        )
    }

    private enum Constant {
        static let interval: Double = 30
    }
}

struct WidgetEntry: TimelineEntry {
    let date: Date
    let viewModel: WidgetViewModel
    
    init(
        assets: [Asset],
        info: [String: [Candle]],
        config: ConfigurationIntent? = nil
    ) {
        guard assets.count > 0 else {
            date = Date()
            viewModel = .mock()
            return
        }

        date = Date()
        viewModel = WidgetViewModel(assets: assets, info: info, config: config)
    }
}

struct SatsTrackerWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if entry.viewModel.isMock {
            WidgetView(viewModel: entry.viewModel)
                .redacted(reason: .placeholder)
        } else {
            WidgetView(viewModel: entry.viewModel)
        }
    }
}

@main
struct SatsTrackerWidget: Widget {
    let kind: String = "SatsTrackerWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SatsTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SatsTracker")
        .description("List of crypto currencies")
        .supportedFamilies([.systemSmall])
    }
}

struct SatsTrackerWidget_Previews: PreviewProvider {
    static var previews: some View {
        SatsTrackerWidgetEntryView(entry: WidgetEntry(assets: [], info: [:]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
