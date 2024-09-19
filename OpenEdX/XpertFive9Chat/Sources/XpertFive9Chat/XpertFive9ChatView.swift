//
//  XpertFive9ChatView.swift
//  XpertFive9Chat
//
//  Created by Anton Yarmolenka on 19/09/2024.
//

import SwiftUI

public struct XpertFive9ChatView: View {
    @StateObject var model: XpertFive9ChatViewModel
    
    public init(configuration: XpertFive9ChatConfiguration) {
        self._model = .init(wrappedValue: XpertFive9ChatViewModel(configuration: configuration))
    }
    
    public var body: some View {
        VStack {
            XpertFive9HTMLWebViewRepresentable(html: model.html, baseURL: nil)
        }
    }
}

#if DEBUG
struct XpertFive9ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let config = XpertFive9ChatConfiguration(appId: "", xpertKey: "", configID: "", useCase: "", segmentKey: "")
        XpertFive9ChatView(configuration: config)
    }
}
#endif
