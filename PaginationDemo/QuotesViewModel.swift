//
//  QuotesViewModel.swift
//  PaginationDemo
//
//  Created by Arpit iOS Dev. on 28/06/24.
//

import Foundation

class QuotesViewModel {
    private var currentPage = 1
    private var isFetching = false
    var quotes: [QuoteResult] = []
    var error: Error?

    func fetchQuotes(completion: @escaping (Bool, Error?) -> Void) {
        guard !isFetching else {
            completion(false, nil)
            return
        }

        isFetching = true
        NetworkManager.shared.fetchQuotes(page: currentPage) { result in
            self.isFetching = false
            switch result {
            case .success(let welcome):
                self.quotes.append(contentsOf: welcome.results)
                self.currentPage += 1
                completion(true, nil)
            case .failure(let error):
                self.error = error
                completion(false, error)
            }
        }
    }
}

