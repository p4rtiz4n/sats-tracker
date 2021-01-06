//
// Created by p4rtiz4n on 06/01/2021.
//

import UIKit

// MARK: - Catalist windows sizing

extension UIApplication {
    
    var isCatalist: Bool {
    #if targetEnvironment(macCatalyst)
        return true
    #endif
        return false
    }
    
    /// Hacking around to get sensible value for default size of the UIWindowScene.
    func setupWindows() {
        guard isCatalist else {
            return
        }
        
        setSizeRestrictions(
            min: Constant.minWindowSize,
            max: Constant.defaultWindowSize
        )
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.setSizeRestrictions()
        }
    }
    
    func setSizeRestrictions(
        min: CGSize = Constant.minWindowSize,
        max: CGSize = Constant.maxWindowSize,
        default: CGSize = Constant.defaultWindowSize
    ) {
        guard isCatalist else {
            return
        }
        
        UIApplication.shared.connectedScenes
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .forEach {
                $0.sizeRestrictions?.minimumSize =  min
                $0.sizeRestrictions?.maximumSize = max
            }
    }
    
    enum Constant {
        static let minWindowSize = CGSize(width: 320, height: 320)
        static let defaultWindowSize = CGSize(width: 375, height: 667)
        static let maxWindowSize = CGSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
    }
}
