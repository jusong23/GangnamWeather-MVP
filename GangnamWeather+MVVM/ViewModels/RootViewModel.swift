//
//  RootViewModel.swift
//  MVVM+Rx
//
//  Created by mobile on 2023/02/09.
//

import Foundation
import RxSwift
import RxCocoa

class RootViewModel {
    let title = "강남역 좌표로 날씨 가져오기(MVVM)"

    let networkService: NetworkProtocol

    init(networkService: NetworkProtocol) {
        self.networkService = networkService
    }
    
    func fetchGangnamWeather() -> Observable<([Document], OpenWeather)> {
        networkService.getMapInfo(of: "%EC%84%9C%EC%9A%B8%ED%8A%B9%EB%B3%84%EC%8B%9C%20%EA%B0%95%EB%82%A8%EA%B5%AC%20%EA%B0%95%EB%82%A8%EB%8C%80%EB%A1%9C%20396")
    } 

}

