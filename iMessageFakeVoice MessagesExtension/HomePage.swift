import SwiftUI
import AVFoundation


struct HomePage: View {
    
    var viewRequest : () -> Void
//    @State var geometry : CGSize
    
    @StateObject private var voiceObj = voiceClass()
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
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @FocusState private var nameIsFocused: Bool
    
    var body: some View {
        let iosPotrait = (horizontalSizeClass == .compact && verticalSizeClass == .regular)
        let iosLandscape = (horizontalSizeClass == .regular && verticalSizeClass == .compact)
        VStack{
            if(inferenceToken == ""){
                
                if(!(showTextInput || showRecordAnim)){
                    HStack{
                        
                        QueueComponent(voiceObj: voiceObj)
                        
                        ZStack{
                            Capsule().frame(maxHeight: 40)
                                .foregroundStyle(Color.blue)
                                .padding(.horizontal, 8)
                                .opacity(0.5)
                            ZStack(alignment: .trailing){
                                TextField("Voices", text: $searchText)
                                    .padding(.horizontal,30)
                                    .padding(.trailing, 10)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .searchable(text: $searchText)
                                    .focused($nameIsFocused)
                                    .submitLabel(.search)
                                    .onTapGesture {
                                        viewRequest()
                                    }
                                
                                if !searchText.isEmpty{
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                        .onTapGesture {
                                            searchText = ""
                                            nameIsFocused = false
                                        }
                                        .padding(.trailing, 17)
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    
                    // Picker View
                    VStack{
                        
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
                                .foregroundStyle(Color.blue)
                                .opacity(0.5)
                            TextField("Text to Speech", text: $tts)
                                .padding(.horizontal,30)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .searchable(text: $tts)
                                .onChange(of: tts, perform: {_ in inferenceToken = ""; pollObj.maybe_public_bucket_wav_audio_path! = "" })
                                .submitLabel(.send)
                                .onTapGesture {
                                    viewRequest()
                                }
                        }
                        Button("Cancel"){
                            tts = ""
                            showTextInput.toggle()
                        }.padding(.trailing, 30)
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
                            .foregroundColor(.blue)
                            .font(.system(size: 45))
                            .padding(.horizontal, 40)
                            .onTapGesture {
                                showTextInput.toggle()
                            }
                        
                        Spacer()
                        
                        Image(systemName: "mic.square.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 40))
                            .padding(.horizontal, 40)
                            .onTapGesture{
                                showRecordAnim.toggle()
                            }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                //Buttons for request and play
                Button{
                    Task{
                        do{
                            inferenceToken = try await voiceObj.ttsRequest(tts_model: pickerSelect.model_token, textToConvert: tts, uuid: UUID().uuidString)!
                            pollObj = try await voiceObj.pollRequest(inference_job_token: inferenceToken)!
                        } catch {
                            print("500 Internal Server Error")
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size:60))
                }
                .disabled(tts.isEmpty)
            }
            else if( voiceObj.isDisabled){
                ProgressAnim()
            }
            else {
                PlayBack(link: "https://storage.googleapis.com/vocodes-public" + (pollObj.maybe_public_bucket_wav_audio_path!))
                
                HStack{
                    Spacer()
                    
                    Button{
                        inferenceToken = ""
                        tts = ""
                        pollObj = pollParams()
//                        voiceObj = voiceClass()
                        showTextInput.toggle()
                    } label: {
                        HStack{
                            Image(systemName: "arrow.clockwise")
                            Text("New Request")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(10)
                    
                    Spacer()
                    
                    Button{
                        let link = URL(string: "https://storage.googleapis.com/vocodes-public" + (pollObj.maybe_public_bucket_wav_audio_path!))!
                    } label: {
                        HStack{
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                    }
                    .buttonStyle(.borderedProminent)
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
    }
    
    var searchResults: [voice] {
        if searchText.isEmpty {
            return names
        } else {
            return names.filter { name in name.title.contains(searchText) }
        }
    }
}


struct QueueComponent: View{
    
    let voiceObj : voiceClass
    
    @State private var queue : Int = 0
    
    let timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
    
    func getQueue(){
        Task{
            do{
                queue = try await voiceObj.getQueue()
            }
            catch{
                print("404 queue not found")
            }
        }
    }
    
    var body: some View{
        RoundedRectangle(cornerRadius: 12)
            .foregroundStyle(
                queue <= 60 ? Color.blue :
                    queue <= 120 ? Color(red: 255, green: 214, blue: 0) :
                    Color.red
            )
            .frame(maxWidth: 120, maxHeight: 40)
            .overlay{
                Text("Queue: \(queue)")
                    .onAppear{
                        getQueue()
                    }
                    .onReceive(timer, perform: { _ in
                        getQueue()
                    })
                    .foregroundStyle(
                        queue <= 60 ? Color.white :
                            queue <= 120 ? Color.black :
                            Color.white
                    )
                    .font(.system(size: 17, weight: .bold))
                    .padding(.horizontal,5)
            }
            .padding([.top, .leading], 10)
    }
}
