import SwiftUI

struct Data{
    var x : [String] = []
    
    init(){
        for _ in 0...22 {
            x.append(String(Int.random(in: 0...1)))
        }
    }
}

struct ProgressAnim: View {
    var data  = Data()
    
    var body: some View {
        HStack{
            VStack{
                BinaryTextView(value: data.x[0], font: Font.title3, delay: 0.0)
            }
            
            VStack{
                ForEach(1...3, id: \.self){
                    i in
                    BinaryTextView(value: data.x[i], font: Font.title2, delay: 0.1)
                }
            }
            
            VStack{
                ForEach(4...8, id: \.self){
                    i in
                    if(i == 4 || i == 8){BinaryTextView(value: data.x[i], font: Font.title3, delay: 0.2)}
                    else if(i == 5 || i == 7){BinaryTextView(value: data.x[i], font: Font.title2, delay: 0.2)}
                    else{BinaryTextView(value: data.x[i], font: Font.title, delay: 0.2)}
                }
            }
            
            VStack{
                ForEach(9...13, id: \.self){
                    i in
                    if(i == 9 || i == 13){BinaryTextView(value: data.x[i], font: Font.title2, delay: 0.3)}
                    else if(i == 10 || i == 12){BinaryTextView(value: data.x[i], font: Font.title, delay: 0.3)}
                    else{BinaryTextView(value: data.x[i], font: Font.largeTitle, delay: 0.3)}
                }
            }
            
            VStack{
                ForEach(14...18, id: \.self){
                    i in
                    if(i == 14 || i == 18){BinaryTextView(value: data.x[i], font: Font.title3, delay: 0.4)}
                    else if(i == 15 || i == 17){BinaryTextView(value: data.x[i], font: Font.title2, delay: 0.4)}
                    else{BinaryTextView(value: data.x[i], font: Font.title, delay: 0.4)}
                }
            }
            
            VStack{
                ForEach(19...21, id: \.self){
                    i in
                    BinaryTextView(value: data.x[i], font: Font.title2, delay: 0.5)
                }
            }
            
            VStack{
                BinaryTextView(value: data.x[22], font: Font.title3, delay: 0.6)
            }
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

//struct GradientLoader : View{
//    var body: some View{
//        
//    }
//}
