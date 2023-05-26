//
//  Anim.swift
//  FakeVoice
//
//  Created by Ajay Singh Bhawariya on 5/25/23.
//

import SwiftUI

struct WaveAnim : Shape {
    var strenght : Double
    var frequency : Double
    var phase : Double
    
    var animatableData: Double{
        get{phase}
        set{self.phase=newValue}
    
    }
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()
        
        let width = Double(rect.width)
        let height = Double(rect.height)
        let minWidth = width/2
        let midHeight = height/2
        
        let wavelength = width / frequency
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 3){
            let relativeX = x/wavelength
            let sine = sin(relativeX + phase)
            let y = strenght * sine + midHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return Path(path.cgPath)
    }
}

struct startAnim:View{
    
    @State private var phase = 0.0
    @State private var frequency = 0.0
    
    var body: some View{
        ZStack{
            
            WaveAnim(strenght: 30, frequency: 25, phase: phase+10)
                .stroke(Color.red, lineWidth: 5)
            
            WaveAnim(strenght: 50, frequency: 30, phase: phase)
                .stroke(Color.blue, lineWidth: 5)
            
        }.onAppear{
            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)){
                self.phase = .pi * 2
            }
        }
    }
    
}

struct Anim_Previews: PreviewProvider {
    
    static var previews: some View {
        startAnim()
    }
}
