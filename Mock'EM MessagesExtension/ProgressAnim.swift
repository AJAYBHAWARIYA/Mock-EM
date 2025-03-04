//
//  ProgressAnim.swift
//  Mock'EM MessagesExtension
//
//  Created by Mayank Tamakuwala and Ajay Singh Bhawariya on 6/4/23.

import SwiftUI

struct ProgressAnim: View {
    var data : [String] = []
    
    init(){
        for _ in 0...22 {
            data.append(String(Int.random(in: 0...1)))
        }
    }
    
    var body: some View {
        HStack{
            Spacer()
            VStack{
                BinaryTextView(value: data[0], font: Font.title3, delay: 0.0)
            }
            
            VStack{
                ForEach(1...3, id: \.self){
                    i in
                    BinaryTextView(value: data[i], font: Font.title2, delay: 0.1)
                }
            }
            
            VStack{
                ForEach(4...8, id: \.self){
                    i in
                    if(i == 4 || i == 8){BinaryTextView(value: data[i], font: Font.title3, delay: 0.2)}
                    else if(i == 5 || i == 7){BinaryTextView(value: data[i], font: Font.title2, delay: 0.2)}
                    else{BinaryTextView(value: data[i], font: Font.title, delay: 0.2)}
                }
            }
            
            VStack{
                Spacer()
                ForEach(9...13, id: \.self){
                    i in
                    if(i == 9 || i == 13){BinaryTextView(value: data[i], font: Font.title2, delay: 0.3)}
                    else if(i == 10 || i == 12){BinaryTextView(value: data[i], font: Font.title, delay: 0.3)}
                    else{BinaryTextView(value: data[i], font: Font.largeTitle, delay: 0.3)}
                }
                Spacer()
            }
            
            VStack{
                ForEach(14...18, id: \.self){
                    i in
                    if(i == 14 || i == 18){BinaryTextView(value: data[i], font: Font.title3, delay: 0.4)}
                    else if(i == 15 || i == 17){BinaryTextView(value: data[i], font: Font.title2, delay: 0.4)}
                    else{BinaryTextView(value: data[i], font: Font.title, delay: 0.4)}
                }
            }
            
            VStack{
                ForEach(19...21, id: \.self){
                    i in
                    BinaryTextView(value: data[i], font: Font.title2, delay: 0.5)
                }
            }
            
            VStack{
                BinaryTextView(value: data[22], font: Font.title3, delay: 0.6)
            }
            Spacer()
        }
    }
}

struct BinaryTextView : View{
    
    @State var value : String
    var font: Font
    var delay: Double
    
    @State private var visible : Bool = false
    private let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    
    var body: some View{
        Text(value)
            .fontWeight(.bold)
            .font(font)
            .opacity(visible ? 1 : 0)
            .foregroundStyle(Color.purple)
            .onAppear{
                withAnimation(
                    .easeIn
                        .repeatForever(autoreverses: false)
                        .speed(0.3)
                        .delay(delay)
                ) {
                    visible.toggle()
                }
            }
            .onReceive(timer) { _ in
                value = String(Int.random(in: 0...1))
            }
    }
}

struct GradientLoader : View{
    @State var transition1 = -1.0
    @State var transition2 = 1.0
    private var timer = Timer.publish(every: 0.025, on: .main, in: .common).autoconnect()
    
    var body: some View{
        Rectangle()
            .cornerRadius(10)
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.purple
                    ]),
                    startPoint: UnitPoint(x: CGFloat(transition1), y: 1),
                    endPoint: UnitPoint(x: CGFloat(transition2), y: 1)
                )
            )
            .opacity(0.3)
            .onReceive(timer, perform: { _ in
                if(transition1 == 1.0){
                    transition2 = round((transition2 + 0.025)*1000)/1000
                    if(transition2 == 1.0){
                        transition1 = -1.0
                    }
                }
                if(transition2 == 1.0){
                    transition1 = round((transition1 + 0.025)*1000)/1000
                    if(transition1 == 1.0){
                        transition2 = -1.0
                    }
                }
            })
    }
}
