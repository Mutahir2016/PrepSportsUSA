//  APIClient.swift

import Foundation
import Alamofire
import RxSwift
import AuthenticationServices

// always conform to this protocol for every responses handle multi-successes status codes
// ex : 200 , 201 , 202
protocol RKCodeObject: Codable {
    var code: Int? { get set }
}

struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet: Bool {
        return self.sharedInstance.isReachable
    }
}

enum RKInternetCheckResult {
    case internetOK
    case internetNO
    case internetUnknown
}

typealias RKInternetCheckResultCallback = (RKInternetCheckResult) -> Void

class RKAPIClient {
    
    static let shared = RKAPIClient()
    let networkManager = Alamofire.NetworkReachabilityManager(host: Environment.baseURL)
    
    private var acceptableStatusCodes: Range<Int> { 200..<300 }

    
    var sessionAsWebAuth: ASWebAuthenticationSession?
    let sessionManager: Alamofire.Session = Alamofire.Session()
    
    func requestData(_ urlConvertible: URLRequestConvertible) -> Observable<Data> {
        return Observable.create { observer -> Disposable in
            AF.request(urlConvertible)
                .response { response in
                    self.handleResponse(response, observer: observer)
                }
            return Disposables.create()
        }
    }

    private func handleResponse(_ response: AFDataResponse<Data?>, observer: AnyObserver<Data>) {
        switch response.result {
        case .success(let data):
            let statusCode = response.response?.statusCode ?? 500
            switch statusCode {
            case 200...299, 409:
                observer.onNext(data ?? Data())
            default:
                handleNonSuccessStatusCode(statusCode: statusCode, observer: observer)
            }
        case .failure(let error):
            handleRequestFailure(response: response, error: error, observer: observer)
        }
    }
    
    private func handleNonSuccessStatusCode(statusCode: Int, observer: AnyObserver<Data>) {
        if statusCode == 401 {
            observer.onError(CustomError.sessionExpired) // Emit session expired error
        } else if statusCode == 409 {
            observer.onNext(Data())
        } else {
            observer.onError(CustomError.serverError)
        }
    }

    private func handleRequestFailure(response: AFDataResponse<Data?>, error: AFError, observer: AnyObserver<Data>) {
        let statusCode = response.response?.statusCode ?? 500
        switch statusCode {
        case 200...299:
            observer.onNext(Data())
        default:
            observer.onError(error)
        }
    }

    private func handleResponse(_ response: AFDataResponse<Data?>, observer: AnyObserver<(Data, String?)>) {
        switch response.result {
        case .success(let data):
            let statusCode = response.response?.statusCode ?? 500
            switch statusCode {
            case 200...299:
                observer.onNext((data ?? Data(), ""))
            default:
                handleServerError(statusCode: statusCode, data: data, observer: observer)
            }
        case .failure(let error):
            handleRequestFailure(response: response, error: error, observer: observer)
        }
    }

    private func handleServerError(statusCode: Int, data: Data?, observer: AnyObserver<(Data, String?)>) {
        if statusCode == 409 {
            let str = String(decoding: data ?? Data(), as: UTF8.self)
            observer.onNext((data ?? Data(), str))
        } else {
            observer.onError(CustomError.serverError)
        }
    }

    private func handleRequestFailure(response: AFDataResponse<Data?>, error: AFError, observer: AnyObserver<(Data, String?)>) {
        let statusCode = response.response?.statusCode ?? 500
        switch statusCode {
        case 200...299:
            observer.onNext((Data(), ""))
        default:
            handleServerError(statusCode: statusCode, data: response.data, observer: observer)
        }
    }
    
    public func parseData<T: Decodable> (type: T.Type, data: Data) -> T? {
        do { let result =  try JSONDecoder().decode(type, from: data)
            return result } catch {
                print("Failed to Parsing API response data to Object")
            }
        return nil
    }
    
    func checkIntetnetReachability(handler: @escaping (RKInternetCheckResult) -> Void) {
        if Connectivity.isConnectedToInternet {
            handler(.internetOK)
        } else {
            handler(.internetNO)
        }
    }
    
    private func config() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        config.httpShouldUsePipelining = true
        return config
    }
}

extension RKAPIClient {
    func request<T: Decodable>(_ urlConvertible: URLRequestConvertible, decoder: Alamofire.DataDecoder = JSONDecoder(),
                               allowEmptyResponseCodes: Set<Int> = [200, 201, 204, 205],
                               completion: @escaping (Result<T, AFError>) -> Void) {
        AF.request(urlConvertible)
            .validate(statusCode: acceptableStatusCodes)
            .responseDecodable(of: T.self, decoder: decoder, emptyResponseCodes: allowEmptyResponseCodes) { completion($0.result) }
    }
    
    func request(_ urlConvertible: URLRequestConvertible,
                 completion: @escaping (Result<Int, AFError>) -> Void) {
        AF.request(urlConvertible)
            .response(completionHandler: { response in
                completion(response.result.map { _ in (response.response?.statusCode ?? 0) })
            })
    }
}

struct NoReply: Codable {}
extension NoReply: Alamofire.EmptyResponse {
    static let value = NoReply()
    static func emptyValue() -> NoReply {
        value
    }
}

extension Alamofire.AFError {
    var isOffline: Bool {
        if case .sessionTaskFailed(let e) = self, let urlError = e as? URLError, urlError.code  == .notConnectedToInternet {
            return true
        } else {
            return false
        }
    }
}


