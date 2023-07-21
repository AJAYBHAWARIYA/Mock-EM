//
//  NoNetworkView.swift
//  iMessageFakeVoice MessagesExtension
//
//  Created by Mayank Tamakuwala and Ajay Singh Bhawariya on 6/4/23.

import SwiftUI
import Network

class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false
    
    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            Task {
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}

struct NoNetworkView: View {
    var body: some View {
        VStack{
            Image(systemName: "wifi.slash")
                .foregroundStyle(Color("Warning"))
                .padding(10)
                .font(.largeTitle)
            
            Text("Network connection\nseems to be offline.\nPlease check your\nconnectivity.")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(white: 0.4745))
                .font(.system(.title2, design: .rounded))
        }
    }
}
