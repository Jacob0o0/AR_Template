//
//  Home.swift
//  AR-DevApp
//
//  Created by CEDAM21 on 15/04/24.
//

import SwiftUI

struct Home: View {
    var body: some View {
        ZStack{
            VStack{
                Text("¡Hola, gran placer tenerte aquí!")
                    .font(.title)
                Text("Te doy la bienvenida a mi aplicación de realidad aumentada")
            }
        }
    }
}

#Preview {
    Home()
}
