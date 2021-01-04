//
// Created by p4rtiz4n on 20/12/2020.
//

import Foundation

/// Encapsulated all the data needed to create a request
protocol NetworkEndPoint {
    var url: URL { get }
    var method: HttpMethod { get }
    var queryItems: Dictionary<String, String>? { get }
    var headers: Dictionary<String, String>? { get }
    var body: Dictionary<String, Any>? { get }
    var caching: URLRequest.CachePolicy { get }
    var timeout: TimeInterval { get }
}

// Default implementation of protocol values
extension NetworkEndPoint {

    var method: HttpMethod {
        return .GET
    }

    var queryItems: Dictionary<String, String>? {
        return nil
    }

    var headers: Dictionary<String, String>? {
        return nil
    }

    var body: Dictionary<String, Any>? {
        return nil
    }

    var caching: URLRequest.CachePolicy {
        return .reloadIgnoringLocalAndRemoteCacheData
    }

    var timeout: TimeInterval {
        return 65
    }
}

/// Http methods
enum HttpMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

/// Simple network utility. Handles network calls and parsing responses to
/// types via JSONDecoder()
protocol Network {

    /// Executes data request and attempts to decode data to type `T`.
    func request<T: Decodable>(
        _ endPoint: NetworkEndPoint,
        handler: @escaping (Result<T, Error>)->()
    )

    /// Performs networks request with `URLSession.shared`
    func dataRequest(
        _ endPoint: NetworkEndPoint,
        handler: @escaping (Result<Data?, Error>)->()
    )
    
    var loggingEnabled: Bool { get set }
}

/// Simple network utility class. Handles network calls and parsing responses to
/// types via JSONDecoder().
class DefaultNetwork: Network {

    static var shared = DefaultNetwork()

    var decoder: JSONDecoder = JSONDecoder()
    var loggingEnabled: Bool = false

    class func request<T: Decodable>(
            _ endPoint: NetworkEndPoint,
            handler: @escaping (Result<T, Error>)->()
    ) {
        DefaultNetwork.shared.request(endPoint, handler: handler)
    }

    func request<T: Decodable>(
            _ endPoint: NetworkEndPoint,
            handler: @escaping (Result<T, Error>)->()
    ) {
        dataRequest(endPoint) { result in
            switch result {
            case let .success(data):
                guard let data = data else {
                    handler(.failure(NetworkError.noData))
                    return
                }
                do {
                    let result = try self.decoder.decode(T.self, from: data)
                    handler(.success(result))
                } catch {
                    handler(.failure(error))
                }
            case let .failure(error):
                handler(.failure(error))
            }
        }
    }

    func dataRequest(
            _ endPoint: NetworkEndPoint,
            handler: @escaping (Result<Data?, Error>)->()
    ) {
        let session = URLSession.shared
        let request = self.request(endPoint)
        session.dataTask(with: request) { [weak self] data, resp, err in
            self?.log(request, response: resp, data: data, error: err)
            if let err = err {
                handler(.failure(err))
                return
            }
            handler(.success(data))
        }.resume()
    }
    
    private func request(_ endPoint: NetworkEndPoint) -> URLRequest {
        let url = endPoint.url.appending(endPoint.queryItems)
        let caching = endPoint.caching
        let timeout = endPoint.timeout
        var request = URLRequest(
                url: url,
                cachePolicy: caching,
                timeoutInterval: timeout
        )
        request.httpMethod = endPoint.method.rawValue
        request.allHTTPHeaderFields = endPoint.headers
        if let body = endPoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        return request
    }

    private func log(
            _ request: URLRequest,
            response: URLResponse?,
            data: Data?,
            error: Error?
    ) {
        guard loggingEnabled else {
            return
        }
        print("Request: ", request)
        print("Headers: ", request.allHTTPHeaderFields ?? [])
        if let body = request.httpBody {
            print("Body: ", String(data: body, encoding: .utf8) ?? "")
        }
        if let response = response {
            print(response)
        }
        if let data = data {
            print(String(data: data, encoding: .utf8) ?? "")
        }
        if let error = error {
            print(error)
        }
    }
}

// MARK: - NetworkError

extension DefaultNetwork {

    /// /// Generic error message
    enum NetworkError: Error {
        case msg(_ msg: String)
        case noData
        case unknown
    }
}

// MARK: - URL query items extension

extension URL {

    /// Appends `queryItems` to `URL`. In case of failure returns `self`
    func appending(_ queryItems: Dictionary<String, String>?) -> URL {
        guard let queryItems = queryItems else {
            return self
        }
        guard var components = URLComponents(string: absoluteString) else {
            return self
        }
        var items = components.queryItems ?? []
        for (key, val) in queryItems {
            items.append(URLQueryItem(name: key, value: val))
        }
        components.queryItems = items
        return components.url ?? self
    }
}
