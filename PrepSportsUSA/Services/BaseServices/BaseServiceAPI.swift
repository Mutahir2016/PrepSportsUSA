//
//  BaseServiceAPI.swift//
//

import Foundation
import Alamofire

protocol BaseServiceAPIProtocol {
    var path: String { get }
}

class BaseServiceClass {
    func buildURLRequest(baseUrl: String = Environment.baseURL,
                         path: String,
                         httpMethod: HTTPMethod,
                         parameters: Parameters = [:],
                         parameterEncoding: ParameterEncoding? = nil,
                         httpHeaders: HTTPHeaders? = nil,
                         body: Data? = nil) -> URLRequest {

        let requestUrl = "\(baseUrl)\(path)"
        guard let percentEscapeUrl = requestUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let urlString = URL(string: percentEscapeUrl) else {  preconditionFailure("") }
        
        var urlReq = URLRequest(url: urlString)
        urlReq.httpMethod = httpMethod.rawValue
        urlReq.httpBody = body
        if let  headers = httpHeaders {
          urlReq.headers = headers
        }
        urlReq.timeoutInterval = 30

        let encode: ParameterEncoding = {
            switch httpMethod {
            case .get: return URLEncoding.default
            case .post: return URLEncoding.default
            default: return JSONEncoding.default
            }
        }()
      if !parameters.isEmpty {
        do { urlReq = try (parameterEncoding ?? encode).encode(urlReq,
                                  with: parameters) } catch {
                      print("Error while ParameterEncoding") }
      }
        return urlReq
    }

  func reqToDic<T: Encodable>(request: T) -> [String: Any] {
    guard let data =  try? JSONEncoder().encode(request),
          let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [:] }
    return dictionary
  }

  func reqToData<T: Encodable>(request: T) -> Data {
    guard let data =  try? JSONEncoder().encode(request) else { return Data() }
    return data
  }

}
