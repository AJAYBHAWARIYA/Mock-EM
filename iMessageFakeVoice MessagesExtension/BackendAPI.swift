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
    private let WAIT_COUNT = 30
    
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
    
    func getVoices() async throws -> [voice]? {
        var (data, res) = try await URLSession.shared.data(from: listUrl)
        var response = res as! HTTPURLResponse
        while (!(response.statusCode == 200 || response.statusCode == 201)){
            try await Task.sleep(nanoseconds: 2_000_000_000)
            (data, res) = try await URLSession.shared.data(from: listUrl)
            response = res as! HTTPURLResponse
        }
        let decodedResponse = try? JSONDecoder().decode(voices.self, from: data)
        var filteredVoices = (decodedResponse?.models.filter { voice in getRatings(voice) >= 3.2 })!
        filteredVoices.sort{(s1, s2) in getRatings(s1) > getRatings(s2)}
        print(filteredVoices.count)
        return filteredVoices
    }
    
    func getQueue() async throws -> Int {
        var (data, res) = try await URLSession.shared.data(from: queueUrl)
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
        request.setValue("Basic SAPI:AK_C04F7EF9060205", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        var (data, res) = try await URLSession.shared.upload(for: request, from: encoded)
        var response = res as! HTTPURLResponse
        print("ttsRequest() response: \(response.statusCode)")
        while (!(response.statusCode == 200 || response.statusCode == 201)){
            try await Task.sleep(nanoseconds: 2_000_000_000)
            (data, res) = try await URLSession.shared.upload(for: request, from: encoded)
            response = res as! HTTPURLResponse
        }
        let decodedResponse = try? JSONDecoder().decode(generateTtsAudio.self, from: data)
//        return "JTINF:an0mwvjabc0ebe6xf7n5hqaab8"
        return decodedResponse?.inference_job_token
    }
    
    func pollRequest(inference_job_token: String) async throws -> pollParams?{
        
        print("inference_token: ", inference_job_token)

        let pollUrl = URL(string: (pollBaseUrl + inference_job_token))!

        var request = URLRequest(url: pollUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic SAPI:AK_C04F7EF9060205", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        var (data, res) = try await URLSession.shared.data(for: request)
        var response = res as! HTTPURLResponse
        print("pollRequest() response: \(response.statusCode)")
        
        var c1 = 0
        var c2 = 0
        while (!(response.statusCode == 200 || response.statusCode == 201)){
            print("c1: \(c1)")
            try await Task.sleep(nanoseconds: 2_000_000_000)
            (data, res) = try await URLSession.shared.data(for: request)
            response = res as! HTTPURLResponse
            c1 += 1
        }
        var decodedResponse = try? JSONDecoder().decode(pollRes.self, from: data)
        
        while (decodedResponse?.state.status != "complete_success") {
            print("c2: \(c2)")
            try await Task.sleep(nanoseconds: 2_000_000_000)
            (data, res) = try await URLSession.shared.data(for: request)
            decodedResponse = try? JSONDecoder().decode(pollRes.self, from: data)
            c2 += 1
            
//            if(count == WAIT_COUNT){
//                decodedResponse?.state = pollParams(maybe_result_token: "OOps", maybe_public_bucket_wav_audio_path: "/tts_inference_output/9/c/d/vocodes_9cdd9865-0e10-48f0-9a23-861118ec3286.wav",status: "complete_success")
//                break;
//            }
        }
        return decodedResponse?.state
    }
}
