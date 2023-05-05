//
//  Rx+Extension.swift
//  ChatDemo
//
//  Created by Duc Canh on 18/04/2023.
//

import RxSwift
import RxCocoa

extension Observable {
    func mapGetMessageError() -> Observable<String> {
        self.map { $0 as? Result<Void, String> }
            .compactMap({ $0 })
            .map { result -> String? in
                switch result {
                case .success:
                    return nil
                case .failed(let messageError):
                    return messageError
                }
            }
            .compactMap({ $0 })
    }

    func mapGetResultSuccess() -> Observable<Bool> {
        self.map { $0 as? Result<Void, String> }
            .compactMap({ $0 })
            .map { result -> Bool in
                switch result {
                case .success:
                    return true
                case .failed:
                    return false
                }
            }
    }

    func mapGetResultValue<V>() -> Observable<V> {
        self.map({ $0 as? Result<V, String> })
            .compactMap({ $0 })
            .map { result -> V? in
                switch result {
                case .success(let value):
                    return value
                case .failed:
                    return nil
                }
            }
            .compactMap({ $0 })
    }

    func mapToVoid() -> Observable<Void> {
        self.map { _ -> Void in () }
    }
}

extension ObservableType {

    public func catchErrorJustComplete() -> Observable<Element> {
        `catch` { _ in
            Observable.empty()
        }
    }

    public func asDriverOnErrorJustComplete() -> Driver<Element> {
        asDriver { _ in
            Driver.empty()
        }
    }
}
