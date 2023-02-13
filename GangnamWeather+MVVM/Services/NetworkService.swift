//
//  GetOpenWeather.swift
//  GangNamWeather
//
//  Created by mobile on 2023/02/06.
//

import Foundation
import RxSwift
import RxCocoa

class NetworkService: NetworkProtocol {
    //MARK: - GetMapInfo
    func getMapInfo(of fetchedLocation: String) -> Observable<([Document], OpenWeather)> {
        return Observable.from([fetchedLocation])
            .map { fetchedLocation -> URL in
            return URL(string: "https://dapi.kakao.com/v2/local/search/address.json?query=\(fetchedLocation)")! }
            .map { url -> URLRequest in
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("KakaoAK 4e78ea35cffb481201121cd3d09455a6", forHTTPHeaderField: "Authorization")
            return request }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
            return URLSession.shared.rx.response(request: request) }
            .filter { response, _ in
            return 200..<300 ~= response.statusCode
        }
            .map { _, data -> GangNamRoad in
            let decoder = JSONDecoder()
            if let json = try? decoder.decode(GangNamRoad.self, from: data) {
                return json
            }
            throw SimpleError()
        }
            .map { jsonObjects -> [Document] in
            return jsonObjects.documents
        }
            .flatMap { arrDocument -> Observable<([Document], OpenWeather)> in
            let lat = Double(arrDocument.first!.y)!
            let lon = Double(arrDocument.first!.x)!

            return self.getWeatherInfo(lat: lat, lon: lon)
            .map { openWeather -> ([Document], OpenWeather) in
            return (arrDocument, openWeather)
            }
        }
    }

    func fetchedLocationToURL(from fetchedLocation: String) -> URL {
        return URL(string: "https://dapi.kakao.com/v2/local/search/address.json?query=\(fetchedLocation)")!
    }

    func urlToURLRequest(what url: URL) -> URLRequest {
        print("url: \(url) thread in url: \(Thread.isMainThread)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK 4e78ea35cffb481201121cd3d09455a6", forHTTPHeaderField: "Authorization")
        return request
    }

    func requestToObservable(what request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)> {
        return URLSession.shared.rx.response(request: request)
    }

    //MARK: - GetWeatherInfo
    func getWeatherInfo(lat: Double, lon: Double) -> Observable<OpenWeather> { // 🔩 model struct name
        return Observable.create { (emitter) in
            let weatherUrlStr = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=hourly&appid=70712209ed38b3c9995cdcdd87bda250&units=metric" // 🔩 url

            // [1st] URL instance 작성
            guard let url = URL(string: weatherUrlStr) else {
                emitter.onError(SimpleError())
                return Disposables.create()
            }

            // [2nd] Task 작성(.resume)
            let session = URLSession.shared
            let task = session.dataTask(with: url) { data, response, error in
                // error: 에러처리
                if let error = error { return }
                // response: 서버 응답 정보
                guard let httpResponse = response as? HTTPURLResponse else { return }
                guard (200 ... 299).contains(httpResponse.statusCode) else { return }

                // data: 서버가 읽을 수 있는 Binary 데이터
                guard let data = data else { fatalError("Invalid Data") }

                do {
                    let decoder = JSONDecoder()
                    let weatherInfo = try decoder.decode(OpenWeather.self, from: data) // 🔩 model struct name
                    emitter.onNext(weatherInfo)
                    emitter.onCompleted()
                } catch {
                    emitter.onError(SimpleError())
                }
            }
            task.resume() // suspend 상태의 task 깨우기

            return Disposables.create()
        }
    }
}

