////
////  FrontendAPIEndpoint.swift
////  iMessageFakeVoice MessagesExtension
////
////  Created by Mayank Tamakuwala on 6/17/23.
////
//
//import Foundation
//
//class FrontendAPIEndpoint: ObservableObject {
//    @Published private(set) var queue = 0
//    private var voiceObj : voiceClass
//    
//    init(voiceObj : voiceClass){
//        self.voiceObj = voiceObj
//    }
//    
//    func getQueue(){
//        Task{
//            do{
//                queue = try await self.voiceObj.getQueue()
//            }
//            catch{
//                print("404 queue not found")
//            }
//        }
//    }
//    
//    func textToSpeech(inferenceToken: inout String, pollObj: inout pollParams, model_token: String, tts: String){
//        Task{
//            do{
//                inferenceToken = try await self.voiceObj.ttsRequest(tts_model: model_token, textToConvert: tts, uuid: UUID().uuidString)!
//                pollObj = try await self.voiceObj.pollRequest(inference_job_token: inferenceToken)!
//            } catch {
//                print("500 Internal Server Error")
//            }
//        }
//    }
//}
