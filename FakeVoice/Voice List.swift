import Foundation
import AVFoundation


struct rating: Codable, Hashable {
    var positive_count: Double
    var total_count: Double
}

struct voice : Codable, Hashable{
    var model_token: String
    var title: String
    var user_ratings: rating
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

class voiceClass{
    
    private let listUrl = URL(string:"https://api.fakeyou.com/tts/list")!
    private let ttsUrl = URL(string:"https://api.fakeyou.com/tts/inference")!
    private let pollBaseUrl = "https://api.fakeyou.com/tts/job/"
    
    private func getRatings(_ voice: voice) -> Double{
        let rating = (voice.user_ratings.positive_count/voice.user_ratings.total_count)*5
        return (round(rating*10.0))/10.0
    }
    
    func getVoices() async throws -> [voice]? {
        let (data, _) = try await URLSession.shared.data(from: listUrl)
        let decodedResponse = try? JSONDecoder().decode(voices.self, from: data)
        var filteredVoices = (decodedResponse?.models.filter { voice in getRatings(voice) >= 3.0 })!
        filteredVoices.sort{(s1, s2) in getRatings(s1) > getRatings(s2)}
        return filteredVoices
    }
    
    func ttsRequest(tts_model: String, textToConvert: String, uuid: String) async throws -> String?{
        let params = ["tts_model_token": tts_model, "inference_text": textToConvert, "uuid_idempotency_token": uuid]
        
        guard let encoded = try? JSONEncoder().encode(params) else {
            return ""
        }
        
        var request = URLRequest(url: ttsUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic SAPI:AK_C04F7EF9060205", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
        let decodedResponse = try? JSONDecoder().decode(generateTtsAudio.self, from: data)
        
        return decodedResponse?.inference_job_token
    }
    
    func pollRequest(inference_job_token: String) async throws -> pollParams?{

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
            try await Task.sleep(for: .seconds(2))
            (data, _) = try await URLSession.shared.data(from: pollUrl)
            decodedResponse = try? JSONDecoder().decode(pollRes.self, from: data)
            count += 1
            
            //Test Voice Output
            if(count == 30){
                decodedResponse?.state = pollParams(maybe_result_token: "OOps", maybe_public_bucket_wav_audio_path: "/tts_inference_output/9/c/d/vocodes_9cdd9865-0e10-48f0-9a23-861118ec3286.wav",status: "complete_success")
                break;
            }
        }
        return decodedResponse?.state
    }
    
    func playVoice(url: String){
        let soundUrl = URL(string: ("https://storage.googleapis.com/vocodes-public" + url))!
        let player = AVPlayer(url: soundUrl)
        player.play()
    }
}

//Hello! What’s up! Hope you are doing great!
//Hello Nation. I’m the president of the United States.
