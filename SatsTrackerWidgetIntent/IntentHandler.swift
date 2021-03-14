//
// Created by p4rtiz4n on 14/03/2021.
//

import Intents

class IntentHandler: INExtension {
    
    let service: WidgetsService = {
        let assetsService = DefaultAssetsService(network: DefaultNetwork())
        return DefaultWidgetsService(
            assetsService: assetsService,
            candleCacheService: DefaultCandlesCacheService(
                assetsService: assetsService
            )
        )
    }()
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
    
}

extension IntentHandler: ConfigurationIntentHandling {
    
    func provideAssetsOptionsCollection(
        for intent: ConfigurationIntent,
        with completion: @escaping (INObjectCollection<AssetOption>?, Error?) -> ()
    ) {
        service.fetchAssets(
            handler: { result in
                switch result {
                case let .success(assets):
                    completion(
                        INObjectCollection(
                            items: assets.map { AssetOption(asset: $0) }
                        ),
                        nil
                    )
                case let .failure(err):
                    completion(nil, err)
                }
            }
        )
    }

    func defaultAssets(for intent: ConfigurationIntent) -> [AssetOption]? {
        return service.defaultAssets().map { AssetOption(asset: $0) }
    }
}
