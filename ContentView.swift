//
//  ContentView.swift
//  AR-DevApp
//
//  Created by CEDAM21 on 19/03/24.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    var body: some View {

        TabView {
            Home()
                .tabItem {
                    Image(systemName: "house")
                        .foregroundColor(.white)
                    Text("Other")
                        .foregroundStyle(Color.white)
                }
            OtherView()
                .tabItem {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.white)
                    Text("Other")
                        .foregroundStyle(Color.white)
                }
            SecondaryPage()
                .tabItem {
                    Image(systemName: "fan")
                        .foregroundColor(.white)
                    Text("Other")
                        .foregroundStyle(Color.white)
                }
            ARViewContainer()
                .ignoresSafeArea(.all)
                .tabItem {
                    Image(systemName: "arkit")
                        .foregroundColor(Color.white)
                    Text("AR")
                        .foregroundStyle(Color.white)
                }
        }
//          ACTIVA ESTO Y VERÁS LA MAGIA :0
//        }.tabViewStyle(PageTabViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
