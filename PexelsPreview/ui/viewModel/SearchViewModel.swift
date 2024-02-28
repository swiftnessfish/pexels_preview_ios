//
//  SearchViewModel.swift
//  PexelsPreview
//
//  Created by tatsuki on 2024/02/27.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    
    static let locale = "ja-JP"
    static let perPage = 30
    
    private var disposeBag = DisposeBag()
    private var page = 1
    private var lastSearchText = ""

    
    var isLoading = BehaviorRelay<Bool>(value: false)
    var searchResults = BehaviorRelay<[SearchItemViewModel]>(value: [])
    var errorMessage = PublishRelay<String>()

    func pexelsSearch(query: String) {
        isLoading.accept(true)
        var urlComponents = URLComponents(string: "https://api.pexels.com/v1/search")!
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "locale", value: SearchViewModel.locale),
            URLQueryItem(name: "page", value: page.description),
            URLQueryItem(name: "per_page", value: SearchViewModel.perPage.description)
        ]
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.setValue("fPY1Crh5axtAfHw3hGDsn0bBGxGUVGey1p8IdNKhdUNU82cXDbOBHZeV", forHTTPHeaderField: "Authorization")

        URLSession.shared.rx.response(request: urlRequest)
            .subscribe { [weak self] response, data in
                
                if (response.statusCode != 200) {
                    self?.errorMessage.accept("画像の取得に失敗しました")
                    self?.isLoading.accept(false)
                    return
                }
                
                guard let responseModel = try? JSONDecoder().decode(PexelsSearchResponseModel.self, from: data) else { return }
                
                var itemList: [SearchItemViewModel] = []
                if (self?.page != 1) {
                    itemList = self?.searchResults.value ?? []
                }
                responseModel.photos.forEach { photo in
                    itemList.append(
                        SearchItemViewModel(small: photo.src.small, medium: photo.src.medium, photographer: photo.photographer)
                    )
                }

                print("api called")
                self?.searchResults.accept(itemList)
                self?.isLoading.accept(false)
            } onError: { error in
                print("onError")
                self.errorMessage.accept(error.localizedDescription)
                self.isLoading.accept(false)
            }
            .disposed(by: disposeBag)
    }
    
    func load(query: String) {
        page = 1
        lastSearchText = query
        pexelsSearch(query: lastSearchText)
    }
    
    func loadMore() {
        print("loadMore: isLoading=\(isLoading.value) searchResults.value.count=\(searchResults.value.count)")
        if (isLoading.value || searchResults.value.count < page * SearchViewModel.perPage) { return }
        
        page += 1
        pexelsSearch(query: lastSearchText)
    }
}
