//
// Created by p4rtiz4n on 01/01/2021.
//

import Foundation

protocol FavouriteAssetsService {

    func favouriteAssets() -> [FavouriteAsset]
    func addToFavorite(_ asset: FavouriteAsset)
    func removerFromFavorite(_ asset: FavouriteAsset)
}

class DefaultFavoriteAssetsService: FavouriteAssetsService {

    func favouriteAssets() -> [FavouriteAsset] {
        let obj = UserDefaults.standard.object(forKey: Constant.favouriteKey)
        guard let assetDicts = obj as? [[String: String]] else {
            return []
        }
        return decode(assetDicts)
    }

    func addToFavorite(_ asset: FavouriteAsset) {
        let assets = favouriteAssets() + [asset]
        UserDefaults.standard.set(encode(assets), forKey: Constant.favouriteKey)
        UserDefaults.standard.synchronize()
    }

    func removerFromFavorite(_ asset: FavouriteAsset) {
        let assets = favouriteAssets().filter { $0 != asset }
        UserDefaults.standard.set(encode(assets), forKey: Constant.favouriteKey)
        UserDefaults.standard.synchronize()
    }
    
    func encode(_ assets: [FavouriteAsset]) -> [[String: String]] {
        return (try? JSONDecoder().decode(
            [[String: String]].self,
            from: JSONEncoder().encode(assets)
        )) ?? []
    }
    
    func decode(_ assetDicts: [[String: String]]) -> [FavouriteAsset] {
        return (try? JSONDecoder().decode(
            [FavouriteAsset].self,
            from: JSONEncoder().encode(assetDicts)
        )) ?? []
    }
}

// MARK: - DefaultFavoriteAssetService

extension DefaultFavoriteAssetsService {

    enum Constant {
        static let favouriteKey = "favoriteAssets"
    }
}
