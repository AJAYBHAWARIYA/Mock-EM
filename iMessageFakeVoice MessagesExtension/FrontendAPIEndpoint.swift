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
//    private var inferenceToken : String
//    private var pollObj : pollParams
//    
//    init(voiceObj : voiceClass, inferenceToken: inout String, pollObj: inout pollParams){
//        self.voiceObj = voiceObj
//        self.inferenceToken = inferenceToken
//        self.pollObj = pollObj
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
