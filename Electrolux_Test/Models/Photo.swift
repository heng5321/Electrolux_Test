//
//  Photo.swift
//  Electrolux_Test
//
//  Created by koh kar heng on 04/04/2022.
//

import Foundation

struct FlickerPhotos: Decodable {
    var photos: Photos
}

struct Photos: Decodable {
    var photo: [PhotosModel]
}

struct PhotosModel: Identifiable, Decodable, Hashable {
    var id: String
    var url_m: String?
    var owner: String?
    var title: String?
    var isFailLoad: Bool
    var isSelected: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case url_m
        case owner
        case title
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.url_m = try values.decodeIfPresent(String.self, forKey: .url_m)
        self.owner = try values.decodeIfPresent(String.self, forKey: .owner)
        self.title = try values.decodeIfPresent(String.self, forKey: .title)
        self.isFailLoad = false
        self.isSelected = false
        
    }
}
