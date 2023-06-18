import SwiftUI

struct QueueComponent: View{
    
    let voiceObj : voiceClass
    
    @State private(set) var queue : Int = 0
    
    let timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
    
    func getQueue(){
        Task{
            do{
                queue = try await voiceObj.getQueue()
            }
            catch{
                print("404 queue not found")
            }
        }
    }
    
    var body: some View{
        RoundedRectangle(cornerRadius: 12)
            .foregroundStyle(
                queue <= 60 ? Color.blue :
                    queue <= 120 ? Color(red: 255/255, green: 214/255, blue: 0) :
                    Color.red
            )
            .frame(maxWidth: 120, maxHeight: 40)
            .overlay{
                Text("Queue: \(queue)")
                    .onAppear{
                        getQueue()
                    }
                    .onReceive(timer, perform: { _ in
                        getQueue()
                    })
                    .foregroundStyle(
                        queue <= 60 ? Color.white :
                            queue <= 120 ? Color.black :
                            Color.white
                    )
                    .font(.system(size: 17, weight: .bold))
                    .padding(.horizontal,5)
            }
            .padding([.top, .leading], 10)
    }
}
