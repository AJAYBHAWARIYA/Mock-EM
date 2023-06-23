//
//  MessagesViewController.swift
//  iMessageFakeVoice MessagesExtension
//
//  Created by Mayank Tamakuwala on 6/4/23.

import UIKit
import Messages
import SwiftUI
import os

class MessagesViewController: MSMessagesAppViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Conversation Handling
    func composeSelectionMsg(in session: MSSession, link: String) -> MSMessage {
        
        var components = URLComponents()
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "link", value: link))
        
        let layout = MSMessageTemplateLayout()
        //        layout.caption = "Johnny Test"
        
        let layout1 = MSMessageLiveLayout(alternateLayout: layout)
        //        layout1.alternateLayout.caption = "Mayank"
        
        let message = MSMessage(session: session)
        message.layout = layout1
        //        message.summaryText = "summary text..."
        
        components.queryItems = queryItems
        message.url = components.url!
        
        return message
    }
    
    func submitMessage(link: String) {
        guard let conversation = activeConversation else {
            os_log("submitMessage(): guard on conversation falied!", log: .default, type: .debug)
            return
        }
        var session : MSSession
        if let tSess = conversation.selectedMessage?.session {
            session = tSess
            os_log("submitMessage() got a session!...", log: .default, type: .debug)
        } else {
            os_log("###### submitMessage() did NOT get a session, creating new MSSession() #####", log: .default, type: .debug)
            session = MSSession()
        }
        var message: MSMessage
        
        message = composeSelectionMsg(in: session, link: link)
        
        conversation.insert(message) { error in
            if let error = error {
                os_log("submitMessage(): initial send error: %@", log: .default, type: .debug, error.localizedDescription)
            } else {
                os_log("submitMessage(): initial send success!", log: .default, type: .debug)
            }
        }
    }
    
    fileprivate func loadContentView(
        for conversation: MSConversation,
        with presentationStyle: MSMessagesAppPresentationStyle
    ) {
        let vc = UIHostingController(
            rootView:
                ContentView(
                    requestPresentationStyle: {x in self.requestPresentationStyle(x)},
                    submitMessage: submitMessage,
                    selectedMessage: conversation.selectedMessage,
                    presentationStyle: presentationStyle
                )
        )
        
        let swiftuiView = vc.view!
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(swiftuiView)
        
        NSLayoutConstraint.activate([
            swiftuiView.leftAnchor.constraint(equalTo: view.leftAnchor),
            swiftuiView.rightAnchor.constraint(equalTo: view.rightAnchor),
            swiftuiView.topAnchor.constraint(equalTo: view.topAnchor),
            swiftuiView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        vc.didMove(toParent: self)
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        loadContentView(for: conversation, with: self.presentationStyle)
    }
}

struct ContentView: View {
    var requestPresentationStyle: (MSMessagesAppPresentationStyle) -> Void
    var submitMessage: ((String) -> Void)?
    var selectedMessage: MSMessage?
    var presentationStyle: MSMessagesAppPresentationStyle
    @StateObject var networkMonitor = NetworkMonitor()
    
    var body: some View {
        if(presentationStyle == .compact){
            HomePage(
                requestPresentationStyle: requestPresentationStyle,
                submitMessage: submitMessage!
            )
            .environmentObject(networkMonitor)
        }
        else{
            PlayBack(message: selectedMessage)
        }
    }
}
