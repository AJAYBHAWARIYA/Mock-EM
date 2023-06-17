import Foundation
import AVFoundation


struct rating: Codable, Hashable {
    let positive_count: Double
    let total_count: Double
}

struct voice : Codable, Hashable{
    let model_token: String
    let title: String
    let user_ratings: rating
}

struct voices: Codable {
    var models: [voice] = []
}

struct generateTtsAudio: Codable {
    var success: Bool = false
    var inference_job_token: String = ""
}

struct pollParams : Codable{
    var maybe_result_token: String? = ""
    var maybe_public_bucket_wav_audio_path: String? = ""
    var status: String = ""
}

struct pollRes: Codable {
    
    var success: Bool = false
    var state: pollParams = pollParams()
}

struct queueData: Codable {
    let pending_job_count: Int
}

class voiceClass : ObservableObject{
    
    private let listUrl = URL(string:"https://api.fakeyou.com/tts/list")!
    private let ttsUrl = URL(string:"https://api.fakeyou.com/tts/inference")!
    private let pollBaseUrl = "https://api.fakeyou.com/tts/job/"
    private let queueUrl = URL(string: "https://api.fakeyou.com/tts/queue_length")!
    private let WAIT_COUNT = 30
    @Published var isDisabled : Bool = false
    
    private func getRatings(_ voice: voice) -> Double{
        if (voice.user_ratings.total_count == 0){
            return 0
        }
        
        else if (
            voice.user_ratings.positive_count == voice.user_ratings.total_count &&
            voice.user_ratings.positive_count < 5
        ){
            return 0
        }

        let rating = (voice.user_ratings.positive_count/voice.user_ratings.total_count)*5
        return (round(rating*10.0))/10.0
    }
    
    func getVoices() async throws -> [voice]? {
        let (data, _) = try await URLSession.shared.data(from: listUrl)
        let decodedResponse = try? JSONDecoder().decode(voices.self, from: data)
        var filteredVoices = (decodedResponse?.models.filter { voice in getRatings(voice) >= 3.0 })!
        filteredVoices.sort{(s1, s2) in getRatings(s1) > getRatings(s2)}
        print(filteredVoices.count)
        return filteredVoices
    }
    
    func getQueue() async throws -> Int {
        let (data, _) = try await URLSession.shared.data(from: queueUrl)
        let decodedResponse = try? JSONDecoder().decode(queueData.self, from: data)
        return (decodedResponse?.pending_job_count)!
    }
    
    func ttsRequest(tts_model: String, textToConvert: String, uuid: String) async throws -> String?{
        isDisabled = true
        let params = ["tts_model_token": tts_model, "inference_text": textToConvert, "uuid_idempotency_token": uuid]
        
        print("tts: ", textToConvert)
        
        guard let encoded = try? JSONEncoder().encode(params) else {
            return ""
        }
        
        var request = URLRequest(url: ttsUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic SAPI:AK_C04F7EF9060205", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        var (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
        var decodedResponse = try? JSONDecoder().decode(generateTtsAudio.self, from: data)
        /* TODO (inference decoding nil)*/
//        while (decodedResponse?.inference_job_token)! == nil {
//            (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
//            decodedResponse = try? JSONDecoder().decode(generateTtsAudio.self, from: data)
//        }
        return decodedResponse?.inference_job_token
    }
    
    func pollRequest(inference_job_token: String) async throws -> pollParams?{
        
        print("inference_token: ", inference_job_token)

        let pollUrl = URL(string: (pollBaseUrl + inference_job_token))!

        var request = URLRequest(url: pollUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic SAPI:AK_C04F7EF9060205", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        var (data, _) = try await URLSession.shared.data(for: request)
        var decodedResponse = try? JSONDecoder().decode(pollRes.self, from: data)
        var count = 0
        while (decodedResponse?.state.status != "complete_success") {
            print(count)
            try await Task.sleep(nanoseconds: 2_000_000_000)
            (data, _) = try await URLSession.shared.data(from: pollUrl)
            decodedResponse = try? JSONDecoder().decode(pollRes.self, from: data)
            count += 1
            
            //Test Voice Output
            
            if(count == WAIT_COUNT){
                decodedResponse?.state = pollParams(maybe_result_token: "OOps", maybe_public_bucket_wav_audio_path: "/tts_inference_output/9/c/d/vocodes_9cdd9865-0e10-48f0-9a23-861118ec3286.wav",status: "complete_success")
                break;
            }
        }
        isDisabled = false
        return decodedResponse?.state
    }
}
