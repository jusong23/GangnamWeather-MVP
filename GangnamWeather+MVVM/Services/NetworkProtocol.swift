//
//  NetworkProtocol.swift
//  GangnamWeather+MVVM
//
//  Created by mobile on 2023/02/13.
//

import Foundation
import RxSwift

protocol NetworkProtocol {
    func getMapInfo(of fetchedLocation: String) -> Observable<([Document], OpenWeather)>
    func getWeatherInfo(lat: Double, lon: Double) -> Observable<OpenWeather>
}
