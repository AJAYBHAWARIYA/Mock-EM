import SwiftUI
import AVFoundation


struct PlayBack: View {
    var link : String
    @State private var player = AVPlayer()
    @State private var currentTime : Double = 0.0
    @State private var isPlaying = false
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    private func playPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
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
        
        HStack{
            
            Button{
                if (
                    player.currentItem?.duration.seconds == nil ||
                    player.currentTime().seconds >= ((player.currentItem?.duration.seconds)!)
                ){
                    player = AVPlayer(url: URL(string: link)!)
                    player.play()
                    isPlaying = true
                }
                else{
                    self.playPause()
                }
            }label: {
                if(isPlaying){
                    Image(systemName: "pause.fill").font(.system(size: 40))
                        .foregroundStyle(Color.purple)
                }
                else{
                    Image(systemName: "play.fill").font(.system(size: 40))
                        .foregroundStyle(Color.purple)
                }
            }
            .onReceive(timer, perform: { _ in
                
                if(player.currentItem?.duration.seconds != nil){
                    if (player.currentTime().seconds < 0){
                        currentTime = 0.0
                    }
                    else{
                        currentTime = player.currentTime().seconds/((player.currentItem?.duration.seconds)!)
                    }
                }
                
                if(
                    player.currentItem?.duration.seconds != nil &&
                    player.currentTime().seconds >= ((player.currentItem?.duration.seconds)!)
                ){
                    isPlaying = false
                }
            })
            .padding(10)
            
            ProgressView(value: currentTime).progressViewStyle(.linear).frame(maxWidth: 300).padding(10)
            
            if(player.currentItem?.duration.seconds == nil){
                Text("00:00/0:00")
            }
            
            else{
                
                let totatTime = (player.currentItem?.duration.seconds)!
                
                if(totatTime.isNaN || player.currentTime().seconds.isNaN){
                    Text("00:00/0:00").padding(10)
                }
                else if (player.currentTime().seconds < 0){
                    Text("00:00/\(MMSSTimeFormattor(seconds: totatTime))").padding(10)
                }
                else{
                    Text(
                        "\(MMSSTimeFormattor(seconds: currentTime*totatTime))/\(MMSSTimeFormattor(seconds: totatTime))"
                    ).padding(10)
                }
                
            }
        }
    }

}
