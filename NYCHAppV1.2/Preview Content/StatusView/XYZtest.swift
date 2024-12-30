//
//  XYZtest.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/27/24.
//

import SwiftUI

struct XYZtest: View {
    @State var yAxis: Double = 0.0
    @State var xAxis: Double = 0.0
    @State var increments = 20.0
    var body: some View {
        VStack {
            
            
            RoundedRectangle(cornerRadius: 20)
                .fill(.blue)
                .offset(x: xAxis, y: yAxis)
                .frame(width: 50, height: 50)
        }.frame(width: 150, height: 150)
        
        VStack {
            Button("Up"){
                yAxis -= increments
                print(yAxis)
                print(xAxis)
                
            }
            
            HStack (spacing: 20){
                Button("Left") {
                    xAxis -= increments
                }
                
                Button("Right") {
                    xAxis += increments
                }
            }.padding()
            
            Button("Down") {
                yAxis += increments
            }
            
        }
        
        .padding(.horizontal)
            
    }

}

#Preview {
    XYZtest()
}
