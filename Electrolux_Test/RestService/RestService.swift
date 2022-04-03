//
//  RestService.swift
//  Electrolux_Test
//
//  Created by koh kar heng on 29/03/2022.
//

import Foundation
import Combine
import Alamofire

// MARK: - Handle error
struct NetworkError: Error {
    let initialError: AFError
    let backendError: BackendError?
}

struct BackendError: Codable, Error {
    var status: String
    var message: String
}

// MARK: - RestService
struct RestService {
    // MARK: fetchPhotos
    
    
    /// - Parameters:
    ///   - api_key: https://www.flickr.com/services/api/misc.api_keys.html
    ///   - extras: get Url
    func fetchPhotos(hashtag: String, page: Int) -> AnyPublisher<DataResponse<FlickerPhotos, NetworkError>, Never> {
        let url = "https://api.flickr.com/services/rest?"
        var params: [String: Any] = [:]
        params["api_key"] = "a6ad2fc7ae4b6a4ea6e9853fca66a223"
        params["method"] = "flickr.photos.search"
        params["tags"] = hashtag
        params["nojsoncallback"] = true
        params["format"] = "json"
        params["extras"] = "url_m"
        params["per_page"] = 20
        params["page"] = page
        return AF.request(url, method: .get, parameters: params)
            .response(completionHandler: { response in
                if let data = response.data {
                    let result = String(data: data, encoding: .utf8)!
//                    print(result)
                }
            })
            .validate()
            .publishDecodable(type: FlickerPhotos.self)
            .map { response in
                response.mapError { error in
                    let backendError = response.data.flatMap { try? JSONDecoder().decode(BackendError.self, from: $0)}
                    return NetworkError(initialError: error, backendError: backendError)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
