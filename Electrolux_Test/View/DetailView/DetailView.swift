//
//  DetailView.swift
//  Electrolux_Test
//
//  Created by koh kar heng on 03/04/2022.
//

import SwiftUI
import Kingfisher
struct DetailView: View {
    @StateObject var viewModel: DetailViewModel
    var body: some View {
        if let photo = viewModel.photo {
            VStack(alignment: .leading) {
                KFImage(URL(string: photo.url_m ?? "") ?? URL(string: ""))
                    .resizable()
                    .scaledToFit()
                    .clipped()
                InfoView(title: "Owner", desc: photo.owner ?? "")
                InfoView(title: "Title", desc: photo.title ?? "")
                InfoView(title: "Url", desc: photo.url_m ?? "")
                Spacer()
            }.padding(.spacing_2)
        }
    }
    
    fileprivate struct InfoView: View {
        var title: String
        var desc: String
        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .bold()
                    .padding(.bottom, .spacing_1)
                Text(desc)
                    .font(.system(size: 15))
                Divider()
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(viewModel: DetailViewModel(photo: nil))
    }
}
