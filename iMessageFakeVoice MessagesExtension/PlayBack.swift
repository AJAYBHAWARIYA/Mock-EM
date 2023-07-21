//
//  PlayBack.swift
//  iMessageFakeVoice MessagesExtension
//
//  Created by Mayank Tamakuwala and Ajay Singh Bhawariya on 6/4/23.

import SwiftUI
import AVFoundation
import Messages
import Accelerate

struct PlayBack: View {
    
    static private let tempPath = NSTemporaryDirectory()
    static private let directoryName = "VoiceHistory"

    var link : String
    var presentationStyle: MSMessagesAppPresentationStyle
    var voice: String
    var tts: String
    
    @State private var linesCompleted = 0
    @State private var timer = Timer.publish(every: .infinity, on: .main, in: .common).autoconnect()
    @State private var player : AVAudioPlayer?
    @State private var currentTime : Double = 0.0
    @State private var isPlaying = false
    @State private var spectogramData : [DataPoint] = []
    
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    init?(message: MSMessage?, presentationStyle: MSMessagesAppPresentationStyle) {
        guard let messageURL = message?.url else { return nil }
        guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }
        self.init(
            link: (queryItems[0].value)!,
            presentationStyle: presentationStyle,
            voice: (queryItems[1].value)!,
            tts: (queryItems[2].value)!
        )
    }
    
    init(link: String, presentationStyle: MSMessagesAppPresentationStyle, voice: String, tts: String){
        self.link = link
        self.presentationStyle = presentationStyle
        self.voice = voice
        self.tts = tts
    }
    
    func retrieveAudio(){
        let cacheURL : URL
        var url : URL
        do {
            cacheURL = URL(fileURLWithPath: PlayBack.tempPath).appendingPathComponent(PlayBack.directoryName, conformingTo: .folder)
            try FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError("Unable to create cache URL: \(error)")
        }
        
        let fileName = voice + tts.lowercased()
        
        url = cacheURL.appendingPathComponent(fileName, conformingTo: .wav)
        
        if(!FileManager.default.fileExists(atPath: url.absoluteString)){
            URLSession.shared.dataTask(with: URL(string: link)!) {
                data, response, error in
                
                //TODO: CHECK ERROR HANDLING (custom downloaded voice)
                if let error = error {
                    print("Error:", error)
                }
                let data = data!
                do {
                    try data.write(to: url, options: .atomic)
                    print("Writing the data")
                } catch {
                    print("Can't write the audio data to the given URL")
                    print(error)
                }
                player = {
                    do{
                        return try AVAudioPlayer(contentsOf: url)
                    }
                    catch{
                        print("Can't retrieve new block")
                        return AVAudioPlayer()
                    }
                }()
                spectogramData = {
                    let x = SpectrogramGenerator().getSpectogramData(url: url)
                    var myPoints = [DataPoint]()
                    for i in 0 ..< x.count {
                        myPoints.append(DataPoint(magnitude: ((x[i]*(-1.0))*10.0).truncatingRemainder(dividingBy: 10.0)))
                        
                    }
                    return myPoints
                }()
            }.resume()
        }
        else{
            player = {
                do{
                    return try AVAudioPlayer(contentsOf: url)
                }
                catch{
                    print("Can't retrieve completion block")
                    return AVAudioPlayer()
                }
            }()
        }
    }
    
    func togglePlayPause(){
        if let player = player{
            let fraction = player.duration / Double(spectogramData.count)
            if player.isPlaying{
                timer  = Timer.publish(every: .infinity, on: .main, in: .common).autoconnect()
                player.pause()
                isPlaying = false
            }
            else{
                timer  = Timer.publish(every: fraction, on: .main, in: .common).autoconnect()
                player.play()
                isPlaying = true
            }
        }
    }
    
    private func MMSSTimeFormattor(seconds: Double) -> String {
        if(seconds > 0){
            let mins = floor(seconds/60)
            let secs = Int(floor(seconds)) % 60
            if(mins == 0){
                if(String(secs).count == 1){
                    return "00:0" + String(secs)
                }
                else{
                    return "00:" + String(secs)
                }
            }
            else{
                if(String(secs).count == 1 && String(mins).count == 1){
                    return "0" + String(mins) + ":0" + String(secs)
                }
                else if(String(secs).count == 1){
                    return String(mins) + ":0" + String(secs)
                }
                else if(String(mins).count == 1){
                    return "0" + String(mins) + ":" + String(secs)
                }
                else{
                    return String(mins) + ":" + String(secs)
                }
            }
        }
        else{
            return "00:00"
        }
    }

    var body: some View {
        if networkMonitor.isConnected{
            VStack{
                if(presentationStyle == .transcript){
                    Spacer()
                }
                HStack{
                    Button{
                        togglePlayPause()
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill").font(.system(size: 40)).foregroundStyle(Color.purple)
                    }
                    
                    if !(spectogramData.isEmpty){
                        HStack(spacing: 1){
                            ForEach(spectogramData){ data in
                                Capsule()
                                    .foregroundStyle(Color.purple)
                                    .frame(width: 3, height: CGFloat(data.magnitude*5), alignment: .center)
                                    .opacity((data.visibility) ? 1 : 0.5)
                            }
                        }
                    }
                    
                    if let player = player {
                        
                        let totatTime = player.duration
                        
                        if(totatTime.isNaN || player.currentTime.isNaN){
                            Text("00:00/00:00").padding(10)
                        }
                        else if (player.currentTime < 0){
                            Text("00:00/\(MMSSTimeFormattor(seconds: totatTime))").padding(10)
                        }
                        else{
                            Text(
                                "\(MMSSTimeFormattor(seconds: currentTime*totatTime))/\(MMSSTimeFormattor(seconds: totatTime))"
                            ).padding(10)
                        }
                    }
                }
                if(presentationStyle == .transcript){
                    HStack{
                        Text("Voice:").fontWeight(.bold)
                        Text(voice)
                    }
                    .frame(maxWidth: 540, maxHeight: 30, alignment: .leading)
                    .padding(.horizontal, 7)
                    .padding(.leading, 5)
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text("Transcript:").fontWeight(.bold)
                        Text(tts)
                    }
                    .frame(maxWidth: 540, maxHeight: 50, alignment: .leading)
                    .padding(.horizontal, 7)
                    .padding(.leading, 5)
                    
                    Spacer()
                }
            }
            .onAppear{
                retrieveAudio()
            }
            .onReceive(timer, perform: { _ in
                if let player = player{
                    currentTime = player.currentTime/player.duration
                    isPlaying = player.isPlaying
                }
                withAnimation(.snappy){
                    spectogramData[linesCompleted].visibility = true
                    linesCompleted += 1
                    if linesCompleted >= spectogramData.count{
                        timer  = Timer.publish(every: .infinity, on: .main, in: .common).autoconnect()
                        linesCompleted = 0
                        currentTime = 0
                        isPlaying = false
                        for i in 0..<spectogramData.count {
                            spectogramData[i].visibility = false
                        }
                    }
                }
            })
            .background(Color("AppBackground"))
        }
        else{
            VStack{
                Spacer()
                
                HStack{
                    Spacer()
                    Image(systemName: "wifi.slash")
                        .foregroundStyle(Color("Warning"))
                        .padding(10)
                        .font(.title)
                    
                    Text("Network connection seems to be offline.\nPlease check your connectivity.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(white: 0.4745))
                        .font(.system(.title3, design: .rounded))
                    Spacer()
                }
                
                Spacer()
            }.background(Color("AppBackground"))
        }
    }

}

class SpectrogramGenerator {
    
    func getSpectogramData(url: URL) -> [Double]{
        return downsample(convertAudioFileToPCMInt16(url: url), decimationFactor: 4000)
    }
    
    private func convertAudioFileToPCMInt16(url: URL) -> [Int16] {
        
        let file = try! AVAudioFile(forReading: url)
        
        let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
        let buf = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: AVAudioFrameCount(file.length))
        
        do {
            try file.read(into: buf!)
            
            let channelCount = Int(buf!.format.channelCount)
            let length = Int(buf!.frameLength)
            
            var pcmData: [Int16] = []
            
            for channel in 0..<channelCount {
                for frame in 0..<length {
                    let sample = buf!.int16ChannelData![channel][frame]
                    pcmData.append(sample)
                }
            }
            return pcmData
        } catch {
            print("Error reading audio file: \(error)")
            return []
        }
    }
    
    private func downsample(_ audioSamples:[Int16], decimationFactor:Int) -> [Double] {
        let noiseFloor = -50.0
        
        var audioSamplesD = [Double](repeating: 0, count: audioSamples.count)
        
        vDSP.convertElements(of: audioSamples, to: &audioSamplesD)
        
        vDSP.absolute(audioSamplesD, result: &audioSamplesD)
        
        vDSP.convert(amplitude: audioSamplesD, toDecibels: &audioSamplesD, zeroReference: Double(Int16.max))
        
        audioSamplesD = vDSP.clip(audioSamplesD, to: noiseFloor...0)
        
        let filter = [Double](repeating: 1.0 / Double(decimationFactor), count:decimationFactor)
        
        let downsamplesLength = Int(audioSamplesD.count / decimationFactor)
        var downsamples = [Double](repeating: 0.0, count:downsamplesLength)
        
        vDSP_desampD(audioSamplesD, vDSP_Stride(decimationFactor), filter, &downsamples, vDSP_Length(downsamplesLength), vDSP_Length(filter.count))
        
        return downsamples
    }
}

struct DataPoint : Identifiable{
    let magnitude : Double
    var visibility : Bool = false
    let id = UUID()
}
