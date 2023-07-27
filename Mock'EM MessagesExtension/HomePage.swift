//
//  HomePage.swift
//  Mock'EM MessagesExtension
//
//  Created by Mayank Tamakuwala and Ajay Singh Bhawariya on 6/4/23.

import SwiftUI
import AVFoundation
import Messages

struct HomePage: View {
    
    var requestPresentationStyle : (MSMessagesAppPresentationStyle) -> Void
    var submitMessage: (String, String, String) -> Void
    var presentationStyle: MSMessagesAppPresentationStyle
    
    var backendObj = backendAPI()
    @StateObject private var FrontendObj = FrontendAPIEndpoint()
    @StateObject var record = Recording()
    
    @State private var searchText = ""
    @State var tts: String = ""
    @State var showTextInput : Bool = false
    @State var showRecordAnim : Bool = false
    @State private var isRecording : Bool = false
    @State private var pageState : PageViewState = .home
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @FocusState private var voiceIsFocused: Bool
    @FocusState private var ttsIsFocused: Bool
    
    var body: some View {
        let iosPotrait = (horizontalSizeClass == .compact && verticalSizeClass == .regular)
        let iosLandscape = (horizontalSizeClass == .regular && verticalSizeClass == .compact)
        
        if networkMonitor.isConnected{
            VStack{
                if(pageState == .home){
                    
                    if(!(showTextInput || showRecordAnim)){
                        HStack{
                            
                            QueueComponent(frontendObj: FrontendObj)
                            
                            ZStack{
                                Capsule().frame(maxHeight: 40)
                                    .foregroundStyle(Color.purple)
                                    .padding(.horizontal, 8)
                                    .opacity(0.5)
                                ZStack(alignment: .trailing){
                                    ZStack(alignment: .leading){
                                        if (searchText.isEmpty){
                                            Text("Voices")
                                                .foregroundStyle(Color("Beige"))
                                                .padding(.leading, 25)
                                                .opacity(0.5)
                                        }
                                        TextField("", text: $searchText)
                                            .padding(.horizontal, 25)
                                            .padding(.trailing, 20)
                                            .foregroundStyle(Color("Beige"))
                                            .searchable(text: $searchText)
                                            .focused($voiceIsFocused)
                                            .submitLabel(.search)
                                            .onTapGesture {
                                                requestPresentationStyle(.expanded)
                                            }
                                    }
                                    if !searchText.isEmpty{
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Color("Beige"))
                                            .font(.title2)
                                            .onTapGesture {
                                                searchText = ""
                                                voiceIsFocused = false
                                            }
                                            .padding(.trailing, 17)
                                    }
                                }
                            }
                            .padding(.top, 10)
                        }
                        
                        // Picker View
                        VStack{
                            if(FrontendObj.names.isEmpty){
                                GradientLoader()
                                    .padding(10)
                            }
                            else{
                                Picker("name", selection: $FrontendObj.pickerSelect) {
                                    ForEach(searchResults, id: \.self) { name in
                                        Text(name.title)
                                            .font(.system(.title2, design: .rounded))
                                            .foregroundStyle(Color("Beige"))
                                    }
                                }
                                .pickerStyle(.wheel)
                                .onChange(of: searchResults, perform: {searchResults in if (!searchResults.isEmpty) {FrontendObj.pickerSelect = searchResults[0]}})
                                .onChange(of: FrontendObj.pickerSelect, perform: {_ in FrontendObj.inferenceToken = ""; FrontendObj.pollObj.maybe_public_bucket_wav_audio_path! = "" })
                            }
                        }
                    }
                    else{
                        if (iosPotrait || iosLandscape){
                            VStack{
                                
                                QueueComponent(frontendObj: FrontendObj)
                                
                                VStack{
                                    Text("Voice Selected:" )
                                        .fontWeight(.bold)
                                        .font(.system(.title2, design: .rounded))
                                    
                                    Text("\(FrontendObj.pickerSelect.title)")
                                        .font(.system(.title3, design: .rounded))
                                        .opacity(0.8)
                                        .frame(maxHeight: 20)
                                        .padding(.vertical, 10)
                                    
                                }.foregroundStyle(Color("Beige"))
                            }
                        }
                        else{
                            HStack{
                                QueueComponent(frontendObj: FrontendObj)
                                
                                Spacer()
                                
                                HStack{
                                    Text("Voice Selected:" )
                                        .fontWeight(.bold)
                                        .font(.system(.title2, design: .rounded))
                                    Text("\(FrontendObj.pickerSelect.title)")
                                        .font(.system(.title3, design: .rounded))
                                        .opacity(0.8)
                                }
                                .frame(maxHeight: 30)
                                .foregroundStyle(Color("Beige"))
                                .padding(.top, 10)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Choice Buttons
                    HStack{
                        
                        if(showTextInput){
                            ZStack{
                                Capsule().frame(maxHeight: 40)
                                    .foregroundStyle(Color.purple)
                                    .padding(.horizontal, 8)
                                    .opacity(0.5)
                                ZStack(alignment: .trailing){
                                    ZStack(alignment: .leading){
                                        if (tts.isEmpty){
                                            Text("Text to Speech")
                                                .foregroundStyle(Color("Beige"))
                                                .padding(.leading, 25)
                                                .opacity(0.5)
                                        }
                                        TextField("", text: $tts)
                                            .padding(.horizontal, 25)
                                            .padding(.trailing, 20)
                                            .foregroundStyle(Color("Beige"))
                                            .searchable(text: $tts)
                                            .onChange(of: tts, perform: {_ in FrontendObj.inferenceToken = ""; FrontendObj.pollObj.maybe_public_bucket_wav_audio_path! = "" })
                                            .submitLabel(.send)
                                            .onTapGesture {
                                                requestPresentationStyle(.expanded)
                                            }
                                            .focused($ttsIsFocused)
                                    }
                                    
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color("Beige"))
                                        .font(.title2)
                                        .onTapGesture {
                                            tts = ""
                                            ttsIsFocused = false
                                            showTextInput.toggle()
                                        }
                                        .padding(.trailing, 20)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        else if(showRecordAnim){
                            
                            VStack{
                                Text("Hold to record/Drag to Cancel")
                                    .italic()
                                    .opacity(0.8)
                                    .padding(.bottom, 5)
                                    .foregroundStyle(Color("Beige"))
                                
                                Button(action: {
                                    isRecording = false
                                    record.handleRecording(start: isRecording )
                                    tts = record.transcript
                                }) {
                                    ZStack{
                                        Circle()
                                            .frame(maxWidth: 60, maxHeight:60)
                                            .scaleEffect(isRecording ? 1.5 : 1.0)
                                            .foregroundColor(Color("MEWarning"))
                                            .animation(.easeIn(duration: 2), value: isRecording)
                                        
                                        Image(systemName: "mic.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.primary)
                                            .padding()
                                    }
                                }
                                .simultaneousGesture(
                                    LongPressGesture(minimumDuration: 0.2)
                                        .onEnded {_ in
                                            isRecording = true
                                            record.handleRecording(start: isRecording )
                                        }
                                )
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 100)
                                        .onEnded{_ in
                                            isRecording = false
                                            record.handleRecording(start: isRecording)
                                            tts = ""
                                            showRecordAnim.toggle()
                                            record.transcript = ""
                                        }
                                )
                                
                                Text("TRANSCRIPT")
                                    .fontWeight(.bold)
                                    .font(.system(.title2, design: .rounded))
                                    .padding(.bottom,2)
                                    .foregroundStyle(Color("Beige"))
                                
                                ScrollView{
                                    Text(record.transcript)
                                        .multilineTextAlignment(.center)
                                        .padding(10)
                                        .foregroundStyle(Color("Beige"))
                                }
                                .frame(maxWidth: 300, maxHeight: 100)
                            }
                        }
                        else{
                            Spacer()
                            
                            Image(systemName: "keyboard.fill")
                                .foregroundColor(.purple)
                                .font(.system(size: 45))
                                .padding(.horizontal, 40)
                                .onTapGesture {
                                    requestPresentationStyle(.expanded)
                                    showTextInput.toggle()
                                }
                            
                            Spacer()
                            
                            Image(systemName: "mic.square.fill")
                                .foregroundColor(.purple)
                                .font(.system(size: 40))
                                .padding(.horizontal, 40)
                                .onTapGesture{
                                    requestPresentationStyle(.expanded)
                                    showRecordAnim.toggle()
                                }
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    if(FrontendObj.queue >= 6000 || FrontendObj.queue < 0){
                        Text("Server is Loaded. Cannot process the request at the moment")
                            .font(.system(.title2, design: .rounded))
                            .foregroundStyle(Color("MEWarning"))
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    HStack{
                        Spacer()
                        
                        Button{
                            requestPresentationStyle(.expanded)
                            pageState = .progress
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size:60))
                        }
                        .disabled(tts.isEmpty || FrontendObj.queue >= 6000 || FrontendObj.queue < 0 || FrontendObj.names.isEmpty)
                        .foregroundStyle(
                            tts.isEmpty || FrontendObj.queue >= 6000 || FrontendObj.queue < 0 || FrontendObj.names.isEmpty ?
                            Color("Disabled"):
                                Color.purple
                        )
                        
                        Spacer()
                    }
                    .overlay(alignment: .bottomTrailing){
                        HStack{
                            Image(systemName: "info.circle.fill")
                                .font(.title3)
                            Text("Credits")
                        }
                        .foregroundStyle(Color(white: 0.7))
                        .offset(x: 0, y: 5)
                        .padding(.trailing, 10)
                        .onTapGesture{
                            withAnimation(.easeIn){
                                pageState = .credits
                            }
                        }
                    }
                }
                else if(pageState == .progress){
                    if(FrontendObj.queue >= 3000 && FrontendObj.queue < 6000){
                        Text("Server is Loaded. Might take a while to serve your request")
                            .font(.system(.title2, design: .rounded))
                            .foregroundStyle(Color("MEWarning"))
                            .padding(.vertical, 10)
                            .multilineTextAlignment(.center)
                    }
                    ProgressAnim()
                        .onAppear{
                            Task{
                                await FrontendObj.makeVoiceRequest(tts: tts)
                                pageState = .playback
                            }
                        }
                }
                else if(pageState == .playback){
                    Spacer()
                    PlayBack(
                        link: "https://storage.googleapis.com/vocodes-public" + (FrontendObj.pollObj.maybe_public_bucket_wav_audio_path!),
                        presentationStyle: presentationStyle,
                        voice: FrontendObj.pickerSelect.title,
                        tts: tts
                    )
                    
                    HStack{
                        Spacer()
                        
                        Button{
                            FrontendObj.inferenceToken = ""
                            tts = ""
                            FrontendObj.pollObj = pollParams()
                            pageState = .home
                            showTextInput = false
                            showRecordAnim = false
                        } label: {
                            HStack{
                                Image(systemName: "arrow.clockwise")
                                Text("New Request")
                            }
                        }
                        .foregroundStyle(Color.purple)
                        .padding(10)
                        
                        Spacer()
                        
                        Button{
                            submitMessage("https://storage.googleapis.com/vocodes-public" + (FrontendObj.pollObj.maybe_public_bucket_wav_audio_path!), FrontendObj.pickerSelect.title, tts)
                            requestPresentationStyle(.compact)
                        } label: {
                            HStack{
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                        }
                        .foregroundStyle(Color.purple)
                        .padding(10)
                        
                        Spacer()
                    }
                    Spacer()
                }
                else if(pageState == .credits){
                    CreditsView(goBack: {
                        withAnimation(.easeOut){
                            pageState = .home
                        }
                    }, iosPotrait: iosPotrait)
                    .onAppear{
                        requestPresentationStyle(.expanded)
                    }
                }
            }
            .onAppear {
                FrontendObj.getVoices()
            }
            .background(Color("AppBackground"))
        }
        else{
            NoNetworkView().background(Color("AppBackground"))
        }
    }
    
    var searchResults: [voice] {
        if searchText.isEmpty {
            return FrontendObj.names
        } else {
            return FrontendObj.names.filter { name in name.title.contains(searchText) }
        }
    }
}

enum PageViewState {
    case home, progress, playback, credits
}
