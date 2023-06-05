import SwiftUI
import AVFoundation


struct HomePage: View {
    private var voiceObj = voiceClass()
    
    @State private var names: [voice] = []
    @State private var searchText = ""
    @State private var pickerSelect: voice = voice(model_token: "", title: "", user_ratings: rating(positive_count: 0, total_count: 0))
    @State var tts: String = ""
    @State var val = false
    @State var inferenceToken: String = ""
    @State var pollObj: pollParams = pollParams()
    @State var player: AVPlayer = AVPlayer()
    @State var showTextInput : Bool = false
    @State var showRecordAnim : Bool = false
    @State private var isRecording : Bool = false
    
    @StateObject var record = Recording()
    
    var body: some View {
        
        VStack{
            // Voice search Input
            HStack{
                ZStack{
                    Capsule().frame(maxHeight: 40)
                        .foregroundStyle(Color.blue)
                        .padding(.horizontal, 8)
                        .opacity(0.5)
                    TextField("Voices", text: $searchText)
                        .padding(.horizontal,30)
                        .foregroundColor(.black)
                        .searchable(text: $searchText)
                    
                }
                if searchText != ""{
                    Button("Cancel"){
                        searchText = ""
                    }.padding(.trailing, 30)
                    
                }
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
                            .foregroundColor(.black)
                            .searchable(text: $tts)
                            .onChange(of: tts, perform: {_ in inferenceToken = ""; pollObj.maybe_public_bucket_wav_audio_path! = "" })
                    }
                    Button("Cancel"){
                        showTextInput.toggle()
                    }.padding(.trailing, 30)
                }
                else if(showRecordAnim){
                    
                    Button(action: {
                        isRecording = false
                        record.handleRecording(start: isRecording )
                        tts = record.transcript
                        print("DONE WITH THE PRESS")
                        showRecordAnim.toggle()
                    }) {
                        ZStack{
                            Circle()
                                .frame(maxWidth: 60, maxHeight:60)
                                .scaleEffect(isRecording ? 2.0 : 1.0)
                                .foregroundColor( Color.red )
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
                }
                else{
                    Image(systemName: "keyboard.fill")
                        .foregroundColor(.blue)
                    //.border(.black)
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
                    
                }
            }
            
            Spacer()
            //Buttons for request and play
            if(inferenceToken == ""){
                Button{
                Task{
                    do{
                        inferenceToken = try await voiceObj.ttsRequest(tts_model: pickerSelect.model_token, textToConvert: tts, uuid: UUID().uuidString)!
                        pollObj = try await voiceObj.pollRequest(inference_job_token: inferenceToken)!
                    } catch {
                        print("tts failed")
                    }
                }} label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size:60))
                }
            }
            else if(pollObj.maybe_public_bucket_wav_audio_path! == ""){
                ProgressView().progressViewStyle(.circular)
                    .font(.system(size: 60))
            }
            else {
                Button{
                    player = AVPlayer(url: URL(string: ("https://storage.googleapis.com/vocodes-public" + (pollObj.maybe_public_bucket_wav_audio_path!)))!)
                    player.play()
                }label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 60))
                }
//                Text("\(player.currentItem?.duration.seconds ?? 0)")
                
            }
//            let link = URL(string: ("https://storage.googleapis.com/vocodes-public" + (pollObj.maybe_public_bucket_wav_audio_path!)))!
            
//            ShareLink(item: link, message: Text("Learn Swift here!"))
//                .font(.largeTitle)
            
        }.onAppear(perform: {
            Task{
                do{
                    names = try await voiceObj.getVoices()!
                    pickerSelect = names[0]
                }
                catch{
                    print("Mayank is here")
                }
            }
        })
    }
    
    var searchResults: [voice] {
        if searchText.isEmpty {
            return names
        } else {
            return names.filter { name in name.title.contains(searchText) }
        }
    }
}

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
