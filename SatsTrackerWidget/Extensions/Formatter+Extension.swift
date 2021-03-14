//
// Created by p4rtiz4n on 14/03/2021.
//

import Foundation

enum WidgetFormatter {
    
    static let price: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.generatesDecimalNumbers = true
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let pctChange: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .percent
        formatter.generatesDecimalNumbers = true
        formatter.negativePrefix = nil
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }()
}
