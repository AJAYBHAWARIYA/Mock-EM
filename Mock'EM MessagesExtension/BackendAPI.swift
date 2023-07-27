//
//  BackendAPI.swift
//  Mock'EM MessagesExtension
//
//  Created by Mayank Tamakuwala and Ajay Singh Bhawariya on 6/4/23.

import Foundation
import AVFoundation


public struct rating: Codable, Hashable {
    let positive_count: Double
    let total_count: Double
}

public struct voice : Codable, Hashable{
    let model_token: String
    let title: String
    let user_ratings: rating
}

public struct voices: Codable {
    var models: [voice] = []
}

public struct generateTtsAudio: Codable {
    var success: Bool = false
    var inference_job_token: String = ""
}

public struct pollParams : Codable{
    var maybe_result_token: String? = ""
    var maybe_public_bucket_wav_audio_path: String? = ""
    var status: String = ""
}

public struct pollRes: Codable {
    
    var success: Bool = false
    var state: pollParams = pollParams()
}

public struct queueData: Codable {
    let pending_job_count: Int
}

class backendAPI {
    
    private let listUrl = URL(string:"https://api.fakeyou.com/tts/list")!
    private let ttsUrl = URL(string:"https://api.fakeyou.com/tts/inference")!
    private let pollBaseUrl = "https://api.fakeyou.com/tts/job/"
    private let queueUrl = URL(string: "https://api.fakeyou.com/tts/queue_length")!
//    private let loginUrl = URL(string: "https://api.fakeyou.com/login")!
    private let WAIT_COUNT = 30
    private var sessionCookie = "session=eyJhbGciOiJIUzI1NiJ9.eyJjb29raWVfdmVyc2lvbiI6IjIiLCJzZXNzaW9uX3Rva2VuIjoiU0VTU0lPTjpiaHQ3cmYwdGt0d2g3d2JjN3ZkMGZoYTYiLCJ1c2VyX3Rva2VuIjoiVTo3UlZaS0tTRDkxUFhNIn0.B6BAAI9fzCPKob3SUVkA-O5vdCmmcPFiY_HyIsNEL98"
    
    private func getRatings(_ voice: voice) -> Double{
        if (voice.user_ratings.total_count == 0){
            return 0
        }
        
        else if (
            voice.user_ratings.positive_count == voice.user_ratings.total_count &&
            voice.user_ratings.positive_count < 10
        ){
            return 0
        }
        
        let rating = (voice.user_ratings.positive_count/voice.user_ratings.total_count)*5
        return (round(rating*10.0))/10.0
    }
    
//    func login() async throws{
//        let params = ["username_or_email": "MayJayDevs", "password": "cymVom-qukdih-2tyjsu"]
//        guard let encoded = try? JSONEncoder().encode(params) else {
//            return
//        }
//        
//        var request = URLRequest(url: loginUrl)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "POST"
//        
//        let (_, res) = try await URLSession.shared.upload(for: request, from: encoded)
//        var response = res as! HTTPURLResponse
//        if(response.statusCode == 200 || response.statusCode == 201){
//            sessionCookie = response.value(forHTTPHeaderField: "set-cookie")!
//        }
//        else{
//            sessionCookie = "Cookies not found"
//        }
//    }
    
    func getVoices() async throws -> [voice]? {
        var request = URLRequest(url: listUrl)
        request.setValue(sessionCookie, forHTTPHeaderField: "cookie")
        request.setValue("include", forHTTPHeaderField: "credentials")
        request.httpMethod = "GET"
        
        var (data, res) = try await URLSession.shared.data(for: request)
        var response = res as! HTTPURLResponse
        while (!(response.statusCode == 200 || response.statusCode == 201)){
            try await Task.sleep(nanoseconds: 2_000_000_000)
            (data, res) = try await URLSession.shared.data(from: listUrl)
            response = res as! HTTPURLResponse
        }
        let decodedResponse = try? JSONDecoder().decode(voices.self, from: data)
        let filteredByRating = (decodedResponse?.models.filter { voice in getRatings(voice) >= 3.2 })!
        var filteredByName = (filteredByRating.filter {
            voice in
            !(voice.title.contains("test") ||
            voice.title.contains("Test") ||
            voice.title.contains("Testing") ||
            voice.title.contains("testing"))
        })
        filteredByName.sort{(s1, s2) in getRatings(s1) > getRatings(s2)}
        return filteredByName
    }
    
    func getQueue() async throws -> Int {
        var request = URLRequest(url: queueUrl)
        request.setValue(sessionCookie, forHTTPHeaderField: "cookie")
        request.setValue("include", forHTTPHeaderField: "credentials")
        request.httpMethod = "GET"
        
        var (data, res) = try await URLSession.shared.data(for: request)
        var response = res as! HTTPURLResponse
        while (!(response.statusCode == 200 || response.statusCode == 201)){
            try await Task.sleep(nanoseconds: 2_000_000_000)
            (data, res) = try await URLSession.shared.data(from: queueUrl)
            response = res as! HTTPURLResponse
        }
        let decodedResponse = try? JSONDecoder().decode(queueData.self, from: data)
        return (decodedResponse?.pending_job_count)!
    }
    
    func ttsRequest(tts_model: String, textToConvert: String, uuid: String) async throws -> String?{
        let params = ["tts_model_token": tts_model, "inference_text": textToConvert, "uuid_idempotency_token": uuid]
        
        print("tts: ", textToConvert)
        
        guard let encoded = try? JSONEncoder().encode(params) else {
            return ""
        }
        
        var request = URLRequest(url: ttsUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(sessionCookie, forHTTPHeaderField: "cookie")
        request.setValue("include", forHTTPHeaderField: "credentials")
//        request.setValue("Basic SAPI:AK_C04F7EF9060205", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        var (data, res) = try await URLSession.shared.upload(for: request, from: encoded)
        var response = res as! HTTPURLResponse
        while (!(response.statusCode == 200 || response.statusCode == 201)){
            try await Task.sleep(nanoseconds: 2_000_000_000)
            (data, res) = try await URLSession.shared.upload(for: request, from: encoded)
            response = res as! HTTPURLResponse
        }
        let decodedResponse = try? JSONDecoder().decode(generateTtsAudio.self, from: data)

        return decodedResponse?.inference_job_token
    }
    
    func pollRequest(inference_job_token: String) async throws -> pollParams?{
        
        print("inference_token: ", inference_job_token)
        
        let pollUrl = URL(string: (pollBaseUrl + inference_job_token))!
        
        var request = URLRequest(url: pollUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(sessionCookie, forHTTPHeaderField: "cookie")
        request.setValue("include", forHTTPHeaderField: "credentials")
//        request.setValue("Basic SAPI:AK_C04F7EF9060205", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        var (data, res) = try await URLSession.shared.data(for: request)
        var response = res as! HTTPURLResponse
        
        while (!(response.statusCode == 200 || response.statusCode == 201)){
            try await Task.sleep(nanoseconds: 2_000_000_000)
            (data, res) = try await URLSession.shared.data(for: request)
            response = res as! HTTPURLResponse
        }
        var decodedResponse = try? JSONDecoder().decode(pollRes.self, from: data)
        
        while (decodedResponse?.state.status != "complete_success") {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            (data, res) = try await URLSession.shared.data(for: request)
            decodedResponse = try? JSONDecoder().decode(pollRes.self, from: data)
        }
        return decodedResponse?.state
    }
}
