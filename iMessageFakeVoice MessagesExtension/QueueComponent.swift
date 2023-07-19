import SwiftUI

struct QueueComponent: View{
    
    let backendObj : backendAPI
    
    @State private(set) var queue : Int = 0
    
    let timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
    
    private func getQueue(){
        Task{
            do{
                queue = try await backendObj.getQueue()
            }
            catch{
                print("404 queue not found")
            }
        }
    }
    
    var body: some View{
        RoundedRectangle(cornerRadius: 12)
            .foregroundStyle(
                queue <= 60 ? Color(red: 0, green: 200/255, blue: 83/255) :
                    queue <= 120 ? Color(red: 204/255, green: 172/255, blue: 2/255) :
                    Color(red:221/255, green: 44/255, blue: 0)
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
                        Color.white
                    )
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .padding(.horizontal,5)
            }
            .padding([.top, .leading], 10)
    }
}
