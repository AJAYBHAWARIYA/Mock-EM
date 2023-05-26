//
//  HomePage.swift
//  Fake your Voice
//
//  Created by Mayank Tamakuwala on 5/21/23.
//
// Wow!! What an awesome pair of Boobies!

import SwiftUI
import AVFoundation

struct HomePage: View {
    private var voiceObj = voiceClass()
    @State var names: [voice] = []
    @State private var searchText = ""
    @State private var pickerSelect: voice = voice(model_token: "", title: "")
    @State var tts: String = ""
    @State var val = false
    @State var chut: String = ""
    @State var pollObj: pollParams = pollParams()
    @State var player: AVPlayer = AVPlayer()

    var body: some View {
        NavigationStack {
                Picker("name", selection: $pickerSelect) {
                    ForEach(searchResults, id: \.self) { name in
                        Text(name.title)
                    }
                }
                .pickerStyle(.wheel)
            
                ZStack{
                    Capsule().frame(maxHeight: 40)
                        .padding()
                        .foregroundStyle(Color.blue)
                        .opacity(0.5)
                    TextField("Text to Speech", text: $tts)
                        .padding(.leading,30)
                        .foregroundColor(.black)
                }
                
           //Buttons for request and play
            if(pollObj.maybe_public_bucket_wav_audio_path! == ""){
                Button{
                    if(pickerSelect.title == ""){
                        val = true
                    }
                    else{
                        Task{
                            do{
                                chut = try await voiceObj.ttsRequest(tts_model: pickerSelect.model_token, textToConvert: tts, uuid: UUID().uuidString)!
                                pollObj = try await voiceObj.pollRequest(inference_job_token: chut)!
                                
                                
                            } catch {
                                print("tts failed")
                            }
                        }
                    }
                } label: {
                    
                        Image(systemName: "arrow.up.circle.fill")
                        .font(.largeTitle)
                    
                }
                .alert(isPresented: $val) {
                    Alert(title: Text("Pick a voice"))
                }
            }else{
                Button{
                    player = AVPlayer(url: URL(string: ("https://storage.googleapis.com/vocodes-public" + (pollObj.maybe_public_bucket_wav_audio_path!)))!)
                    player.play()
                }label: {
                    Image(systemName: "play.fill")
                        .font(.largeTitle)
                }
                
                //video duration for playtime progress view
                Text("\(player.currentItem?.duration.seconds ?? 0)")

            }

        }
        .searchable(text: $searchText)
        .onChange(of: searchResults, perform: {searchResults in if (!searchResults.isEmpty) {pickerSelect = searchResults[0]}})
        .onAppear(perform: {
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
