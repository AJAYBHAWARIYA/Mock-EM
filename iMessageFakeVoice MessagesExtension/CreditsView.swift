//
//  CreditsView.swift
//  iMessageFakeVoice MessagesExtension
//
//  Created by Mayank Tamakuwala and Ajay Singh Bhawariya on 6/4/23.

import SwiftUI

struct CreditsView: View {
    
    var goBack: () -> Void
    var iosPotrait: Bool
    
    var body: some View {
        ScrollView(){
            VStack{
                Group{
                    HStack{
                        Spacer()
                        Text("Usage Instructions")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.top, 12)
                    .overlay(alignment: .leadingFirstTextBaseline){
                        Button{
                            goBack()
                        }
                        label: {
                            HStack{
                                Image(systemName: "chevron.backward")
                                    .font(.title2)
                                if(!iosPotrait){
                                    Text("Back")
                                        .font(.system(.title2, design: .rounded))
                                }
                            }
                            .foregroundStyle(
                                Color(red: 204/255, green: 194/255, blue: 220/255)
                            )
                        }
                    }
                    Divider()
                    VStack(alignment: .leading){
                        Text("1. Using proper punctuations helps with the tone of voice.")
                        Text("2. Sometimes adding \"!\" helps to increase surpizing tones.")
                        Text("3. Adding a \".\" after a text is good practice and some voice generators produce better results.")
                        Text("4. The generated voice are only limited to 12 seconds at the moment.")
                        Text("5. Due to high amount of users some requests take longer to produce resuls.")
                        Text("6. Users are not able to make any request once the queue reaches 200 count.")
                        Text("7. For bug reports! please reachout to the develops through the email listed below.")
                    }
                    .padding(.leading,10)
                    .font(.system(.title2, design: .rounded))
                    .foregroundColor(Color("Secondary"))
                    
                }
                Group{
                    Divider()
                    Text("Developer Information")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                    Divider()
                    VStack(alignment: .leading){
                        HStack(alignment:.top){
                            //TODO: Memojies
                            Image("Mayank")
                                .resizable()
                                .scaledToFill()
                                .clipShape( Circle())
                                .frame(maxWidth:100,maxHeight: 100)
                                .padding([.trailing,.top], 10)
                                .shadow(color: .purple, radius: 10)
                                .overlay(
                                    Circle()
                                        .stroke(Color(red:230/255, green: 225/255, blue: 229/255), style:StrokeStyle(lineWidth:3))
                                        .padding([.trailing,.top],10)
                                )
                            VStack(alignment:.leading){
                                Spacer(minLength: 0)
                                Text("Mayank Devangkumar Tamakuwala")
                                HStack{
                                    Link(destination: URL(string: "https://github.com/MayankTamakuwala")!, label: {
                                        Image("GithubDark")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                    })
                                    
                                    Link(destination: URL(string: "http://www.linkedin.com/in/mayanktamakuwala")!, label: {
                                        Image("LinkedIn")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                    })
                                }
                                Spacer(minLength: 0)
                            }
                        }.padding(.bottom,10)
                        HStack(alignment:.top){
                            Image("Ajay")
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(maxWidth:100,maxHeight: 100)
                                .padding([.trailing,.top],10)
                                .shadow(color: .purple, radius: 10)
                                .overlay(
                                    Circle()
                                        .stroke(Color(red:230/255, green: 225/255, blue: 229/255), style:StrokeStyle(lineWidth:3))
                                        .padding([.trailing,.top],10)
                                )
                            VStack(alignment:.leading){
                                Spacer(minLength: 0)
                                Text("Ajay Singh Bhawariya")
                                HStack{
                                    Link(destination: URL(string: "https://github.com/AJAYBHAWARIYA")!, label: {
                                        Image("GithubDark")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                    })
                                    
                                    Link(destination: URL(string: "https://www.linkedin.com/in/ajaybhawariya")!, label: {
                                        Image("LinkedIn")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                    })
                                }
                                Spacer(minLength: 0)
                            }
                            
                        }
                        Text("Email: mayjaydevs@gmail.com")
                    }
                    .font(.system(.title2, design: .rounded))
                    .foregroundColor(Color("Secondary"))
                }
                Group{
                    Divider()
                    Text("Service Provider")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                    Divider()
                    VStack(alignment: .leading){
                        HStack(alignment: .top){
                            Image("FakeYou")
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(maxWidth:100,maxHeight: 100)
                                .padding(.trailing,10)
                            VStack(alignment: .leading){
                                Text("FakeYou")
                                Text("www.fakeyou.com")
                            }
                        }
                        
                        Text("Special Thanks to @echalon for creating FakeYou that provides data crucial for this application")
                    }
                    .font(.system(.title2, design: .rounded))
                    .foregroundColor(Color("Secondary"))
                    
                }
            }.padding([.horizontal,.bottom], 10)
        }
        .foregroundColor(.purple)
    }
}
