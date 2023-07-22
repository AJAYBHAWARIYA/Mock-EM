//
//  QueueComponent.swift
//  Mock'EM MessagesExtension
//
//  Created by Mayank Tamakuwala and Ajay Singh Bhawariya on 6/4/23.

import SwiftUI

struct QueueComponent: View{
    
    let frontendObj : FrontendAPIEndpoint
    
    let timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
    
    var body: some View{
        RoundedRectangle(cornerRadius: 12)
            .stroke(frontendObj.queue <= 60 ? Color("MEGreen") :
                        frontendObj.queue <= 120 ? Color("MEYellow") :
                        Color("MEWarning"), style:StrokeStyle(lineWidth:3))
            .foregroundStyle(Color("AppBackground"))
            .frame(maxWidth: 120, maxHeight: 40)
            .overlay{
                Text("Queue: \(frontendObj.queue)")
                    .onAppear{
                        frontendObj.getQueue()
                    }
                    .onReceive(timer, perform: { _ in
                        frontendObj.getQueue()
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
