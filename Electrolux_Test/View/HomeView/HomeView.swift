//
//  HomeView.swift
//  Electrolux_Test
//
//  Created by koh kar heng on 29/03/2022.
//

import SwiftUI
import Kingfisher
struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @State private var searchText = ""
    @State var alertTitle = ""
    @State var alertMsg = ""
    @State var selectedPhoto: PhotosModel?
    
    var isResultEnd: Bool = true
    var isLoading: Bool = false
    
    var gridItems: [GridItem] {
        GridItemConstant.columns
    }
    
    // MARK: Body
    var body: some View {
        NavigationView {
            VStack {
                if $viewModel.photos.count > 0 {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: gridItems, spacing: .scenePadding) {
                            ForEach(0 ..< $viewModel.photos.count, id: \.self) { index in
                                let photo = viewModel.photos[index]
                                if let failLoad = photo.isFailLoad, failLoad {
                                    // Show Placeholder if image fail to load
                                    Image("image-placeholder")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    ZStack {
                                        KFImage(URL(string: photo.url_m ?? "") ?? URL(string: ""))
                                            .cacheMemoryOnly()
                                            .placeholder {
                                                // Show loading indicator when loading
                                                ProgressView()
                                            }
                                            .onFailure { error in
                                                // Show Placeholder if image fail to load
                                                viewModel.photos[index].isFailLoad = true
                                            }
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .clipped()
                                            .onAppear() {
                                                // Infinity load
                                                if index == viewModel.photos.count - 1 {
                                                    viewModel.getData()
                                                }
                                            }
                                            .onTapGesture {
                                                // MARK: Action select photo
                                                selectedPhoto = viewModel.photos[index]
                                                viewModel.navigateDetailView = true
                                            }
                                        // MARK: SaveMode
                                        if viewModel.isSaveMode {
                                            ZStack {
                                                Color.black.opacity(0.3)
                                                if let selected = photo.isSelected {
                                                    Image(selected ? "Green_Checkbox" : "Gray_Checkbox")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 20, height: 20)
                                                }
                                            }
                                            .frame( alignment: .top)
                                            .onTapGesture {
                                                viewModel.photos[index].isSelected = !viewModel.photos[index].isSelected
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, .spacing_2)
                    }
                } else {
                    // MARK: Empty Data View
                    Text("No Items Found")
                }
                // MARK: Download Button
                if viewModel.photos.filter({$0.isSelected }).count > 0 {
                    Button(action: {
                        // MARK: Action Save Photo
                        viewModel.requestPermissionAndSaveSelectedPhotoToAlbum()
                    }) {
                        let text = viewModel.isDownloading ? "Downloading " + String(viewModel.downloadingIndex) + " photo" : "Download " + String(viewModel.selectedPhotoCount) + " photo"
                        Text(text)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                    .background(Color.blue)
                    .cornerRadius(25)
                    .padding(.horizontal, .scenePadding)
                }
            }
            // MARK: Alert Download Success
            .alert(isPresented: $viewModel.showAlertDownloadSuccess, title: "Download Success")
            // MARK: Action Navigation
            .navigate(to: DetailView(viewModel: DetailViewModel(photo: selectedPhoto)), when: $viewModel.navigateDetailView)
            // MARK: SearchBar
            .searchable(text: $viewModel.searchText)
            // MARK: Navigation Bar
            .navigationTitle("Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            // MARK: ToolBar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.isSaveMode = !viewModel.isSaveMode
                        if !viewModel.isSaveMode {
                            viewModel.resetSelectedPhoto()
                        }
                    }) {
                        Text(viewModel.isSaveMode ? "Cancel" : "Save")
                    }
                    // MARK: Alert Permission
                    .alert(isPresented: $viewModel.showAletPermissionDenied, title: "App does not have access to your Photos. To enable access, select Allow access at settings.", message: "", primaryButton: .default(Text("Cancel")) {
                    }, secondaryButton: .default(Text("Settings")) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    })
                }
            }
            
        }.navigationViewStyle(.stack)
    }
}
// MARK: - FirstView_Previews
struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel())
    }
}

// MARK: - GridItemConstant
struct GridItemConstant {
    static let columns:[GridItem] = Array(
        repeating: .init(
            spacing: .spacing_2,
            alignment: .leading
        ),
        count: 3
    )
}
