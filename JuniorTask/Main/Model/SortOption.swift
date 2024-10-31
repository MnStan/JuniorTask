//
//  Untitled.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 31/10/2024.
//

import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case nameASC = "name,asc"
    case nameDESC = "name,desc"
    case dateASC = "date,asc"
    case dateDESC = "date,desc"
    case relevanceASC = "relevance,asc"
    case relevanceDESC = "relevance,desc"
    case venueNameASC = "venueName,asc"
    case venueNameDESC = "venueName,desc"
    case onSaleStartDateASC = "onSaleStartDate,asc"
    case random = "random"
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .nameASC: return "Nazwa rosnąco"
        case .nameDESC: return "Nazwa malejąco"
        case .dateASC: return "Data rosnąco"
        case .dateDESC: return "Data malejąco"
        case .relevanceASC: return "Znaczenie rosnąco"
        case .relevanceDESC: return "Znaczenie malejąco"
        case .venueNameASC: return "Nazwa miejsca rosnąco"
        case .venueNameDESC: return "Nazwa miejsca malejąco"
        case .onSaleStartDateASC: return "Rozpoczęcie sprzedaży rosnąco"
        case .random: return "Losowo"
        }
    }
}
