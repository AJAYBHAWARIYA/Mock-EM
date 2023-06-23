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
    
    fileprivate func loadContentView(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
         os_log("loadContentView()...", log: .default, type: .debug)
        let childViewCtrl = ContentViewHostController(for: conversation, with: presentationStyle) {x in
            self.requestPresentationStyle(x)
        }
        
        childViewCtrl.delegate = self
        childViewCtrl.view.layoutIfNeeded() // avoids snapshot warning?
        
//        NSLayoutConstraint.activate([
//            controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
//            controller.view.rightAnchor.constraint(equalTo: view.rightAnchor),
//            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
//            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
        
        if let window = self.view.window {
            childViewCtrl.myWindow = window
            window.rootViewController = childViewCtrl
        }
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        loadContentView(for: conversation, with: self.presentationStyle)
    }
    
//    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
//        super.didTransition(to: presentationStyle)
//        guard let conversation = activeConversation else { fatalError("Expected an active converstation") }
//        loadContentView(for: conversation, with: self.presentationStyle)
//    }
    
    override func didResignActive(with conversation: MSConversation) {
         os_log("didResignActive()...", log: .default, type: .debug)
    }
}

final class ContentViewHostController: UIHostingController<ContentView> {
    var delegate: ContentViewHostControllerDelegate?
    weak var myWindow: UIWindow?
    var requestPresentationStyle : (MSMessagesAppPresentationStyle) -> Void
    var conversation: MSConversation
    var presentationStyle: MSMessagesAppPresentationStyle
    
    init(
        for conversation: MSConversation,
        with presentationStyle: MSMessagesAppPresentationStyle,
        requestPresentationStyle: @escaping (MSMessagesAppPresentationStyle) -> Void
    ) {
        self.requestPresentationStyle = requestPresentationStyle
        self.conversation = conversation
        self.presentationStyle = presentationStyle
        super.init(rootView: ContentView(
            requestPresentationStyle: requestPresentationStyle,
            conversation: conversation,
            presentationStyle: presentationStyle
        ))
        rootView.submitMessage = submitMessage(link: )
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder, rootView: ContentView())
//    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }
    
    func submitMessage(link: String) {
         os_log("ContentViewHostController::submitMessage(): submit message...", log: .default, type: .debug)
        delegate?.contentViewHostControllerSubmitMessage(self, link: link)
    }
}

struct ContentView: View {
    var requestPresentationStyle: (MSMessagesAppPresentationStyle) -> Void
    var submitMessage: ((String) -> Void)?
    var conversation: MSConversation
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
            PlayBack(message: conversation.selectedMessage)
        }
    }
}


extension MessagesViewController: ContentViewHostControllerDelegate {
    // MARK: - ContenHost delegate
    
    func contentViewHostControllerSubmitMessage(_ controller: ContentViewHostController, link: String) {
         os_log("delegateSubmitMessage:...")
        submitMessage(link: link)
    }
    
}

protocol ContentViewHostControllerDelegate {
    func contentViewHostControllerSubmitMessage( _ controller: ContentViewHostController, link: String)
}
