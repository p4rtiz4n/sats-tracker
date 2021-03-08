//
//  IntentHandler.swift
//  SatsTrackerWidgetIntent
//
//  Created by stringcode on 08/03/2021.
//

import Intents

class IntentHandler: INExtension {
    
    let service: AssetsService = DefaultAssetsService(network: DefaultNetwork())
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
    
}

extension IntentHandler: ConfigurationIntentHandling {
    
    func provideAssetsOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<AssetOption>?, Error?) -> Swift.Void) {
        
        service.assets(
            pageHandler: { _ in () },
            completionHandler: { result in
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
        return nil
    }
}
