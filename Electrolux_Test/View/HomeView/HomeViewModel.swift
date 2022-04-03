//
//  HomeViewModel.swift
//  Electrolux_Test
//
//  Created by koh kar heng on 29/03/2022.
//

import Foundation
import Combine
import UIKit
import Photos
class HomeViewModel: ObservableObject {
    private var cancellableSet: Set<AnyCancellable> = []
    @Published var searchText: String = ""
    @Published var photos: [PhotosModel] = []
    @Published var downloadingIndex: Int = 0
    @Published var isSaveMode = false
    @Published var showAletPermissionDenied = false
    @Published var navigateDetailView = false
    
    // reset all photo to unselect if download complete
    var isDownloading = false {
        didSet {
            if !isDownloading {
                resetSelectedPhoto()
                isSaveMode = false
            }
        }
    }
    
    var showAlertDownloadSuccess = false
    var isPermissionAllow = false
    var hashtag = ""
    var currentPage = 0
    private var timer = Timer()
    
    // return selected photo count
    var selectedPhotoCount: Int {
        return photos.filter({$0.isSelected}).count
    }
    
    // MARK: Init
    init() {
        // Search text as electrolux
        searchText = "Electrolux"
        // Timer for auto search
        $searchText
            .debounce(for: .seconds(0), scheduler: DispatchQueue.main)
            .sink { _ in
                if self.searchText.trimmingCharacters(in: .whitespacesAndNewlines).count > 2 {
                    self.timer.invalidate()
                    self.timer = Timer.scheduledTimer(
                        timeInterval: 1,
                        target: self,
                        selector: #selector(self.resetData),
                        userInfo: nil,
                        repeats: false)
                }
            }
            .store(in: &cancellableSet)
    }
    
    // MARK: Retrive data
    @objc func resetData() {
        self.photos = []
        self.currentPage = 1
        getData()
    }
    
    @objc func getData() {
        RestService().fetchPhotos(hashtag: searchText, page: currentPage)
            .sink { value in
                if let photos = value.value {
                    self.photos.append(contentsOf: photos.photos.photo)
                    self.currentPage += 1
                }
            }
            .store(in: &cancellableSet)
    }
    
    func resetSelectedPhoto() {
        photos.indices.forEach {
            photos[$0].isSelected = false
        }
    }
    
    // MARK: PhotoAlbum Permission
    func requestPermissionAndSaveSelectedPhotoToAlbum() {
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .notDetermined, .authorized:
            SaveSelectedPhotoToAlbum()
        case .restricted, .denied:
            self.showAletPermissionDenied = true
        case .limited:
            break
        @unknown default:
            return
        }
    }
    
    func SaveSelectedPhotoToAlbum() {
        let selectedPhotos = photos.filter({$0.isSelected})
        isDownloading = true
        downloadingIndex = selectedPhotos.count
        for index in 0...selectedPhotos.count - 1{
            let photo = selectedPhotos[index]
            
            // Download photo asynchoronous
            DispatchQueue.global(qos: .default).async {
                if let url = URL(string: photo.url_m ?? ""),
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                
                    // Completion for after saving photo to photos library
                    let responder = WriteImageToPhotosResponder()
                    responder.addCompletion { (image, error) in
                        if error == nil {
                            // To show number of downloading photos.
                            self.downloadingIndex = selectedPhotos.count - index
                            if index == selectedPhotos.count - 1 {
                                self.isDownloading = false
                                self.showAlertDownloadSuccess = true
                            }
                        }
                    }
                    // Bind image download finish completion
                    UIImageWriteToSavedPhotosAlbum(image, responder, #selector(WriteImageToPhotosResponder.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
                
            }
        }
    }
}

// MARK: - WriteImageToFileResponder
class WriteImageToPhotosResponder: NSObject {
    typealias WriteImageToPhotosResponderCompletion = ((UIImage?, Error?) -> Void)?
    var completion: WriteImageToPhotosResponderCompletion = nil
    
    override init() {
        super.init()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if (completion != nil) {
            //return completion
            error == nil ? completion?(image, error) : completion?(nil, error)
            completion = nil
        }
    }
    func addCompletion(completion: WriteImageToPhotosResponderCompletion) {
        self.completion = completion
    }
}
