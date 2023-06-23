import SwiftUI
import AVFoundation
import Messages

struct HomePage: View {
    
    var requestPresentationStyle : (MSMessagesAppPresentationStyle) -> Void
    var submitMessage: (String, String, String) -> Void
    var presentationStyle: MSMessagesAppPresentationStyle
    
    @StateObject private var voiceObj = voiceClass()
//    @StateObject private var API = FrontendAPIEndpoint(voiceObj: voiceClass(), inferenceToken: &self.s, pollObj: &pollParams())
    @StateObject var record = Recording()
    
    @State private var names: [voice] = []
    @State private var searchText = ""
    @State private var pickerSelect: voice = voice(model_token: "", title: "", user_ratings: rating(positive_count: 0, total_count: 0))
    @State var tts: String = ""
    @State var inferenceToken: String = ""
    @State var pollObj: pollParams = pollParams()
    @State var showTextInput : Bool = false
    @State var showRecordAnim : Bool = false
    @State private var isRecording : Bool = false
    @State private var pageState : PageViewState = .home
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
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
                            
                            QueueComponent(voiceObj: voiceObj)
                            
                            ZStack{
                                Capsule().frame(maxHeight: 40)
                                    .foregroundStyle(Color.purple)
                                    .padding(.horizontal, 8)
                                    .opacity(0.5)
                                ZStack(alignment: .trailing){
                                    TextField("Voices", text: $searchText)
                                        .padding(.horizontal,30)
                                        .padding(.trailing, 10)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .searchable(text: $searchText)
                                        .focused($voiceIsFocused)
                                        .submitLabel(.search)
                                        .onTapGesture {
                                            requestPresentationStyle(.expanded)
                                        }
                                    
                                    if !searchText.isEmpty{
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
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
                            if(names.isEmpty){
                                GradientLoader()
                                    .padding(10)
                            }
                            else{
                                Picker("name", selection: $pickerSelect) {
                                    ForEach(searchResults, id: \.self) { name in
                                        Text(name.title)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .onChange(of: searchResults, perform: {searchResults in if (!searchResults.isEmpty) {pickerSelect = searchResults[0]}})
                                .onChange(of: pickerSelect, perform: {_ in inferenceToken = ""; pollObj.maybe_public_bucket_wav_audio_path! = "" })
                            }
                        }
                    }
                    else{
                        if (iosPotrait || iosLandscape){
                            VStack{
                                
                                QueueComponent(voiceObj: voiceObj)
                                
                                
                                VStack{
                                    Text("Voice Selected:" )
                                        .fontWeight(.bold)
                                        .font(.title2)
                                    
                                    Text("\(pickerSelect.title)")
                                        .font(.title3)
                                        .opacity(0.8)
                                        .frame(maxHeight: 20)
                                        .padding(.vertical, 10)
                                }
                            }
                        }
                        else{
                            HStack{
                                QueueComponent(voiceObj: voiceObj)
                                
                                Spacer()
                                
                                HStack{
                                    Text("Voice Selected:" )
                                        .fontWeight(.bold)
                                        .font(.title2)
                                    Text("\(pickerSelect.title)")
                                        .font(.title3)
                                        .opacity(0.8)
                                }
                                .frame(maxHeight: 30)
                                .padding(.top, 10)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Choice Buttons
                    // New Button Set
                    HStack{
                        
                        if(showTextInput){
                            ZStack{
                                Capsule().frame(maxHeight: 40)
                                    .padding()
                                    .foregroundStyle(Color.purple)
                                    .opacity(0.5)
                                ZStack(alignment: .trailing){
                                    TextField("Text to Speech", text: $tts)
                                        .padding(.horizontal,30)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .searchable(text: $tts)
                                        .onChange(of: tts, perform: {_ in inferenceToken = ""; pollObj.maybe_public_bucket_wav_audio_path! = "" })
                                        .submitLabel(.send)
                                        .onTapGesture {
                                            requestPresentationStyle(.expanded)
                                        }
                                        .focused($ttsIsFocused)
                                    
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                            .onTapGesture {
                                                tts = ""
                                                ttsIsFocused = false
                                                showTextInput.toggle()
                                            }
                                            .padding(.trailing, 25)
                                }
                            }
                        }
                        else if(showRecordAnim){
                            
                            VStack{
                                Text("Hold to record/Drag to Cancel")
                                    .italic()
                                    .opacity(0.8)
                                    .padding(.bottom, 5)
                                
                                Button(action: {
                                    isRecording = false
                                    record.handleRecording(start: isRecording )
                                    tts = record.transcript
                                    print("DONE WITH THE PRESS")
                                }) {
                                    ZStack{
                                        Circle()
                                            .frame(maxWidth: 60, maxHeight:60)
                                            .scaleEffect(isRecording ? 1.5 : 1.0)
                                            .foregroundColor(Color.red)
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
                                            print("ENDED")
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
                                            print("ENDED1")
                                        }
                                )
                                
                                Text("TRANSCRIPT")
                                    .fontWeight(.bold)
                                    .font(.title2)
                                    .padding(.bottom,2)
                                
                                ScrollView{
                                    Text(record.transcript)
                                        .multilineTextAlignment(.center)
                                        .padding(10)
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
                                    showTextInput.toggle()
                                }
                            
                            Spacer()
                            
                            Image(systemName: "mic.square.fill")
                                .foregroundColor(.purple)
                                .font(.system(size: 40))
                                .padding(.horizontal, 40)
                                .onTapGesture{
                                    showRecordAnim.toggle()
                                }
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    //TODO: Check the QueueComponent object, as its not printing the text on screen
                    if(QueueComponent(voiceObj: voiceObj).queue >= 200){
                        Text("Server is Loaded. Cannot process the request at the moment")
                            .font(.title2)
                            .foregroundStyle(Color.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    Button{
                        pageState = .progress
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size:60))
                    }
                    //TODO: Check the QueueComponent object, as its not disabling the button and foregroundStyle on screen
                    .disabled(tts.isEmpty || QueueComponent(voiceObj: voiceObj).queue >= 200 || names.isEmpty)
                    .foregroundStyle(
                        tts.isEmpty || QueueComponent(voiceObj: voiceObj).queue >= 200 || names.isEmpty ?
                        Color(red:104/255, green: 104/255, blue: 104/255, opacity: 0.8):
                            Color.purple
                    )
                }
                else if(pageState == .progress){
                    if(QueueComponent(voiceObj: voiceObj).queue >= 120 && QueueComponent(voiceObj: voiceObj).queue < 200){
                        Text("Server is Loaded. Might take a while to serve your request")
                            .font(.title2)
                            .foregroundStyle(Color.red)
                            .padding(.bottom, 10)
                    }
                    ProgressAnim()
                        .onAppear{
                            Task{
                                do{
                                    inferenceToken = try await voiceObj.ttsRequest(tts_model: pickerSelect.model_token, textToConvert: tts, uuid: UUID().uuidString)!
                                    pollObj = try await voiceObj.pollRequest(inference_job_token: inferenceToken)!
                                    pageState = .playback
                                } catch {
                                    print("500 Internal Server Error")
                                }
                            }
                        }
                }
                else if(pageState == .playback){
                    PlayBack(
                        link: "https://storage.googleapis.com/vocodes-public" + (pollObj.maybe_public_bucket_wav_audio_path!),
                        presentationStyle: presentationStyle,
                        voice: pickerSelect.title,
                        tts: tts
                    )
                    
                    HStack{
                        Spacer()
                        
                        Button{
                            inferenceToken = ""
                            tts = ""
                            pollObj = pollParams()
                            pageState = .home
                            showTextInput.toggle()
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
                            submitMessage("https://storage.googleapis.com/vocodes-public" + (pollObj.maybe_public_bucket_wav_audio_path!), pickerSelect.title, tts)
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
                }
            }
            .onAppear {
                Task{
                    do{
                        names = try await voiceObj.getVoices()!
                        pickerSelect = names[0]
                    }
                    catch{
                        print("Mayank is here")
                    }
                }
            }
//            .foregroundStyle(Color(red:29/255, green: 29/255, blue: 31/255))
        }
        else{
            NoNetworkView()
//                .foregroundStyle(Color(red:29/255, green: 29/255, blue: 31/255))
        }
    }
    
    var searchResults: [voice] {
        if searchText.isEmpty {
            return names
        } else {
            return names.filter { name in name.title.contains(searchText) }
        }
    }
}

enum PageViewState {
    case home, progress, playback
}
