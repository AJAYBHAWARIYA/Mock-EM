//
//  Recording.swift
//  iMessageFakeVoice MessagesExtension
//
//  Created by Mayank Tamakuwala and Ajay Singh Bhawariya on 6/4/23.

import Foundation
import Speech

class Recording:  NSObject, ObservableObject, AVAudioPlayerDelegate {
    private let audioEngine = AVAudioEngine()
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    @Published var transcript: String = ""
    
    func handleRecording(start: Bool) {
        
        if (start){
            recognitionTask?.cancel()
            self.recognitionTask = nil
            
            let audioSession = AVAudioSession.sharedInstance()
            do{
                try audioSession.setCategory(.playAndRecord)
                try audioSession.overrideOutputAudioPort(.speaker)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("CANNOT SETUP THE AUDIO SESSION")
            }
            
            let inputNode = audioEngine.inputNode
            
            self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                
                if let result = result {
                    let tempTranscript = result.bestTranscription.formattedString
                    if tempTranscript.count != 0 {
                        self.transcript = tempTranscript
                    }
                    isFinal = result.isFinal
                    
                    print("Text \(result.bestTranscription.formattedString)")
                }
                
                if error != nil || isFinal {
                    // Stop recognizing speech if there is a problem.
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            do{
                try audioEngine.start()
                self.transcript = "(Go ahead, I'm listening)"
            } catch {
                print("Audio engine failed to start")
            }
        } else {
            recognitionTask?.cancel()
            recognitionRequest?.endAudio()
            audioEngine.stop()
        }
    }
}
