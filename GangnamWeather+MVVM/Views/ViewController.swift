//
//  ViewController.swift
//  GangnamWeather+MVVM
//
//  Created by mobile on 2023/02/13.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {

    //MARK: - Propeties
    let safeArea = UIView()
    let disposeBag = DisposeBag()
    let viewModel: RootViewModel
    var document = BehaviorSubject<[Document]>(value: [])
    var openWeather = PublishSubject<OpenWeather>()

    var latitude = UILabel() // 위도
    var longitude = UILabel() // 경도
    
    var temperature = UILabel() // 현재기온
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setUpNavigationBar()
    }

    init(viewModel: RootViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configures
    func setUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(safeArea)
        title = viewModel.title

        safeArea.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func setUIComponets(temp: Double) {
        [latitude, longitude, temperature].forEach {
            safeArea.addSubview($0)
        }
        
        latitude.text = try? "위도: " + document.value().first!.y
        latitude.snp.makeConstraints { make in
            make.top.equalTo(safeArea.snp.top).inset(20)
            make.leading.equalTo(safeArea.snp.leading).inset(20)
        }

        longitude.text = try? "경도: " + document.value().first!.x
        longitude.snp.makeConstraints { make in
            make.top.equalTo(latitude.snp.bottom).offset(10)
            make.leading.equalTo(latitude.snp.leading)
        }

        temperature.text = "온도: " + String(temp)
        temperature.snp.makeConstraints { make in
            make.top.equalTo(longitude.snp.bottom).offset(50)
            make.leading.equalTo(longitude.snp.leading)
        }
        
        view.setNeedsUpdateConstraints()
    }
    
    func setUpNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = .gray
        view.backgroundColor = .white

        let rightButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(getData))
        self.navigationItem.rightBarButtonItem = rightButton
        navigationItem.rightBarButtonItem = rightButton
    }

    //MARK: - Helpers
    @objc func getData() {
        viewModel.networkService.getMapInfo(of: "%EC%84%9C%EC%9A%B8%ED%8A%B9%EB%B3%84%EC%8B%9C%20%EA%B0%95%EB%82%A8%EA%B5%AC%20%EA%B0%95%EB%82%A8%EB%8C%80%EB%A1%9C%20396")
            .retry(3) // 에러처리까지 할 수 있음
            .subscribe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
            .observe(on: MainScheduler.instance)
            .subscribe { event in // MARK: 에러처리에 용이한 subscribe 트릭
            switch event {
            case .next(let (newGangNamRoad, openWeather)):
                print("\(newGangNamRoad)의 응답을")
                print("\(openWeather)의 요청으로")
                self.document.onNext(newGangNamRoad)
                self.openWeather.onNext(openWeather)
                
                self.setUIComponets(temp: openWeather.current.temp!)
                
            case .error(let error):
                print("error: \(error), thread: \(Thread.isMainThread)")
            case .completed:
                print("completed")
            }
        }.disposed(by: disposeBag)
    }
}

