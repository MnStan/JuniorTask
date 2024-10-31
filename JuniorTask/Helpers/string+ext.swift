//
//  string+ext.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 31/10/2024.
//

import Foundation

extension String {
    func convertToCorrectFormat() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: self) {
            
            dateFormatter.dateFormat = "dd.MM.yyyy"
            
            return dateFormatter.string(from: date)
        }
        
        return nil
    }
}
