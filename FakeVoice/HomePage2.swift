//
//  HomePage.swift
//  Fake your Voice
//
//  Created by Mayank Tamakuwala on 5/21/23.
//
// Wow!! What an awesome pair of Boobies!

import SwiftUI
import AVFoundation


struct HomePage2: View {
    private var voiceObj = voiceClass()
    @State var names: [voice] = []
    @State private var searchText = ""
    @State private var pickerSelect: voice = voice(model_token: "", title: "")
    @State var tts: String = ""
    @State var val = false
    @State var chut: String = ""
    @State var pollObj: pollParams = pollParams()
    @State var player: AVPlayer = AVPlayer()
    @State var showTextInput : Bool = false
    @State var showRecordAnim : Bool = false

    
    var body: some View {
        
        VStack{
            
            // Voice search Input
            ZStack{
                Capsule().frame(maxHeight: 40)
                    .padding()
                    .foregroundStyle(Color.blue)
                    .opacity(0.5)
                TextField("Voices", text: $searchText)
                    .padding(.leading,30)
                    .foregroundColor(.black)
                    .searchable(text: $searchText)
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
                .onChange(of: pickerSelect, perform: {_ in chut = ""; pollObj.maybe_public_bucket_wav_audio_path! = "" })
            }
            
            // Choice Button
            HStack{
                
                //Write
                ZStack{
                    if showTextInput{
                        // Text input bar
                        ZStack{
                            Capsule().frame(maxHeight: 40)
                                .padding()
                                .foregroundStyle(Color.blue)
                                .opacity(0.5)
                            TextField("Text to Speech", text: $tts)
                                .padding(.leading,30)
                                .foregroundColor(.black)
                                .onChange(of: tts, perform: {_ in chut = ""; pollObj.maybe_public_bucket_wav_audio_path! = "" })
                            
                        }
                    }else{
                        Button{
                            showTextInput.toggle()
                        }label: {
                            Image(systemName: "keyboard.fill")
                                .font(.largeTitle)
                        }
                        .padding(.leading, 30)
                        
                    }
                }
                
                Spacer()
                
                //Record
                ZStack{
                    if showRecordAnim{
                        Canvas{_,_ in
                            
                        }
                    }else{
                        Button{
                            
                        }label: {
                            Image(systemName: "mic.fill")
                                .font(.largeTitle)
                        }.padding(.trailing, 30)
                    }
                }
                
                
            }
            
            
            //Buttons for request and play
            if(chut == ""){
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
            }
            else if(pollObj.maybe_public_bucket_wav_audio_path! == ""){
                ProgressView().progressViewStyle(.circular)
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

struct MyPreviewProvider2_Previews: PreviewProvider {
    static var previews: some View {
        HomePage2()
    }
}
