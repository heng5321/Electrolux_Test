//
//  DetailViewModel.swift
//  Electrolux_Test
//
//  Created by koh kar heng on 03/04/2022.
//

import Foundation

class DetailViewModel: ObservableObject {
    var photo: PhotosModel?
    init(photo: PhotosModel?) {
        self.photo = photo
    }
}
