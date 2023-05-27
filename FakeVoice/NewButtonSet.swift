//
//  NewButtonSet.swift
//  FakeVoice
//
//  Created by Ajay Singh Bhawariya on 5/25/23.
//

import SwiftUI

struct NewButtonSet: View {
    @State var searchText: String = ""
    @State var keyBoard: Bool = false
    @State var micShow: Bool = false
    @GestureState var isRecording : Bool = false
    
    
    var body: some View {
        
        let longPress = LongPressGesture(minimumDuration: .infinity)
            .updating($isRecording) {
                currentState, gestureState, transaction in
                gestureState = currentState
                transaction = Transaction(animation: .spring( response: 0.5 , dampingFraction: 0.1, blendDuration: 1).speed(0.5))
                }
        
        
        VStack{
            HStack{
                
                if(keyBoard){
                    ZStack{
                        Capsule().frame(maxHeight: 40)
                            .padding()
                            .foregroundStyle(Color.blue)
                            .opacity(0.5)
                        TextField("Voices", text: $searchText)
                            .padding(.horizontal,30)
                            .foregroundColor(.black)
                            .searchable(text: $searchText)
                    }
                    Button("Cancel"){
                        keyBoard.toggle()
                    }.padding(.trailing, 30)
                }
                else if(micShow){
                    ZStack{
                        Circle()
                            .frame(maxWidth: 60,maxHeight:60)
                            .scaleEffect(isRecording ? 2.0 : 1.0)
                            .foregroundColor(Color.red)
                        
                        Image(systemName: "mic.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.primary)
                            .padding()
                    }
                    .gesture(longPress)
                    
                    
                }
                else{
                    Image(systemName: "keyboard.fill")
                        .foregroundColor(.blue)
                    //.border(.black)
                        .font(.system(size: 45))
                        .padding(.horizontal, 40)
                        .onTapGesture {
                            keyBoard.toggle()
                        }
                    
                    Spacer()
                    
                    Image(systemName: "mic.square.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 40))
                    //.border(.black)
                        .padding(.horizontal, 40)
                        .onTapGesture{
                            micShow.toggle()
                        }
                    
                }
            }
            
            Spacer()
            
            Button{
                //Send request for synthasis
            }label: {
                Text("Synthasis")
                    .font(.largeTitle)
            }.buttonStyle(.borderedProminent)
            
        }
    }
}

struct NewButtonSet_Previews: PreviewProvider {
    static var previews: some View {
        NewButtonSet()
    }
}
