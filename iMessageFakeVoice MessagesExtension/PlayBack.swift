import SwiftUI
import AVFoundation
import Messages


struct PlayBack: View {

    var link : String
    var presentationStyle: MSMessagesAppPresentationStyle
    var voice: String
    var tts: String
    
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    @State var player : AVAudioPlayer?
    @State private var currentTime : Double = 0.0
    @State private var isPlaying = false
    
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
        let url = URL(string: link)!
        URLSession.shared.dataTask(with: url){
            (data, response, error) in
            if let error = error{
                print(error)
            }
            DispatchQueue.main.async {
                do{
                    player = try AVAudioPlayer(data: data!)
                    player?.prepareToPlay()
                }
                catch{
                    print("can't retrieve")
                }
            }
        }.resume()
    }
    
    func togglePlayPause(){
        if let player = player{
            if player.isPlaying{
                player.pause()
                isPlaying = false
            }
            else{
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
                HStack{
                    Button{
                        togglePlayPause()
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill").font(.system(size: 40)).foregroundStyle(Color.purple)
                    }
                    
                    ProgressView(value: currentTime).progressViewStyle(.linear).frame(maxWidth: 300).padding(10)
                    
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
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text("Transcript:").fontWeight(.bold)
                        Text(tts)
                    }
                    .frame(maxWidth: 540, maxHeight: 50, alignment: .leading)
                    .padding(.horizontal, 7)
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
            })
        }
        else{
            HStack{
                Image(systemName: "wifi.slash")
                    .foregroundStyle(Color.red)
                    .padding(10)
                    .font(.title)
                
                Text("Network connection seems to be offline.\nPlease check your connectivity.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(white: 0.4745))
                    .font(.system(.title3, design: .rounded))
            }
        }
    }

}
