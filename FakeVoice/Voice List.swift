import Foundation
import AVFoundation

struct voice : Codable, Hashable{
    var model_token: String
    var title: String
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
    
    func getVoices() async throws -> [voice]? {
        let (data, _) = try await URLSession.shared.data(from: listUrl)
        let decodedResponse = try? JSONDecoder().decode(voices.self, from: data)
        return decodedResponse?.models
    }
    
    func ttsRequest(tts_model: String, textToConvert: String, uuid: String) async throws -> String?{
        
        print("Model: ", tts_model)
        
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
        
        print(decodedResponse?.inference_job_token)
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
        }
        print(decodedResponse?.state)
        return decodedResponse?.state
    }
    
    func playVoice(url: String){
        let soundUrl = URL(string: ("https://storage.googleapis.com/vocodes-public" + url))!
        print("booobies",soundUrl)
        let player = AVPlayer(url: soundUrl)
        player.play()
    }
}

//Hello! What’s up! Hope you are doing great!
//Hello Nation. I’m the president of the United States.
