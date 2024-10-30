//
//  Untitled.swift
//  JuniorTask
//
//  Created by Maksymilian Stan on 30/10/2024.
//

import Foundation

enum JTError: Error, Equatable {
    case unownedError
    case urlError
    case requestFailed(description: String)
    case responseError(description: String)
    case networkError(description: String)
    
    var description: String {
        switch self {
        case .unownedError:
            return "Coś poszło nie tak"
        case .urlError:
            return "Wystąpił problem z tworzeniem adresu zapytania. Skontaktuj się z deweloperem."
        case .requestFailed(let description):
            return "Wystąpił problem z zapytaniem do serwera. Skontaktuj się z deweloperem.\n\(description)"
        case .responseError(let description):
            return "Wystąpił problem z połączeniem z serwerem. Skontaktuj się z deweloperem\n\(description)"
        case .networkError(description: let description):
            return "Wystąpił problem z połączeniem sieciowym.\n\(description)"
        }
    }
}
