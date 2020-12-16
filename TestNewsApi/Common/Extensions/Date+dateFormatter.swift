//
//  Date+dateFormatter.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 15.12.2020.
//

import Foundation

extension Date {
    static var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    static var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var timeStringDate: String {
        return Date.timeFormatter.string(from: self)
    }
    
    var dayStringDate: String {
        return Date.dayFormatter.string(from: self)
    }
    
}
