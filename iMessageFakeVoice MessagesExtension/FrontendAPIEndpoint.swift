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
//    private var backendObj : backendAPI
//    private var inferenceToken : String
//    private var pollObj : pollParams
//    
//    init(backendObj : backendAPI, inferenceToken: inout String, pollObj: inout pollParams){
//        self.backendObj = backendObj
//        self.inferenceToken = inferenceToken
//        self.pollObj = pollObj
//    }
//    
//    func getQueue(){
//        Task{
//            do{
//                queue = try await self.backendObj.getQueue()
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
//                inferenceToken = try await self.backendObj.ttsRequest(tts_model: model_token, textToConvert: tts, uuid: UUID().uuidString)!
//                pollObj = try await self.backendObj.pollRequest(inference_job_token: inferenceToken)!
//            } catch {
//                print("500 Internal Server Error")
//            }
//        }
//    }
//}
