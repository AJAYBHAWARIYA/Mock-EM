//
//  FrontendAPIEndpoint.swift
//  Mock'EM MessagesExtension
//
//  Created by Mayank Tamakuwala and Ajay Singh Bhawariya on 6/4/23.

import SwiftUI

@MainActor
class FrontendAPIEndpoint : ObservableObject {
    
    private var backendObj = backendAPI()
    @Published private(set) var names: [voice] = []
    @Published var pickerSelect: voice = voice(model_token: "", title: "", user_ratings: rating(positive_count: 0, total_count: 0))
    @Published var inferenceToken: String = ""
    @Published var pollObj: pollParams = pollParams()
    @Published private(set) var queue: Int = 0
    
    func getVoices(){
        Task{
            do{
                names = try await backendObj.getVoices()!
                pickerSelect = names[0]
            }
            catch{
                print("Voice List canot be retrieved")
            }
        }
    }
    
    func makeVoiceRequest(tts: String) async{
        do{
            inferenceToken = try await backendObj.ttsRequest(tts_model: pickerSelect.model_token, textToConvert: tts, uuid: UUID().uuidString)!
            pollObj = try await backendObj.pollRequest(inference_job_token: inferenceToken)!
        }
        catch{
            print("500 Internal Server Error")
        }
    }
    
    func getQueue(){
        Task{
            do{
                queue = try await backendObj.getQueue()
            }
            catch{
                print("Queue not retrieved")
            }
        }
    }
}
