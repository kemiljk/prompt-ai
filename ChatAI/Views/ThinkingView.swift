//
//  ThinkingView.swift
//  Prompt
//
//  Created by Karl Koch on 05/01/2023.
//

import SwiftUI

struct ThinkingView: View {
    @State private var scaleYLeft = false
    @State private var scaleXLeft = false
    @State private var scaleYCenter = false
    @State private var scaleXCenter = false
    @State private var scaleYRight = false
    @State private var scaleXRight = false

    var body: some View {
        HStack {
            HStack {
                HStack {
                    ZStack {
                        Circle()
                            .frame(width: 14, height: 14)
                            .opacity(0.3)
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.secondary)
                            .opacity(scaleXLeft ? 1 : 0.3)
                            .scaleEffect(x: scaleXLeft ? 1 : 0, y: scaleYLeft ? 1 : 0, anchor: .center)
                            .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: scaleXLeft)
                            .onAppear() {
                                self.scaleXLeft.toggle()
                                self.scaleYLeft.toggle()
                            }
                    }
                    ZStack {
                        Circle()
                            .frame(width: 14, height: 14)
                            .opacity(0.3)
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.secondary)
                            .opacity(scaleXCenter ? 1 : 0.3)
                            .scaleEffect(x: scaleXCenter ? 1 : 0, y: scaleYCenter ? 1 : 0, anchor: .center)
                            .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true).delay(0.2), value: scaleXCenter)
                            .onAppear() {
                                self.scaleXCenter.toggle()
                                self.scaleYCenter.toggle()
                            }
                    }
                    ZStack {
                        Circle()
                            .frame(width: 14, height: 14)
                            .opacity(0.3)
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.secondary)
                            .opacity(scaleXRight ? 1 : 0.3)
                            .scaleEffect(x: scaleXRight ? 1 : 0, y: scaleYRight ? 1 : 0, anchor: .center)
                            .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true).delay(0.4), value: scaleXRight)
                            .onAppear() {
                                self.scaleXRight.toggle()
                                self.scaleYRight.toggle()
                            }
                    }
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(24)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct ThinkingView_Previews: PreviewProvider {
    static var previews: some View {
        ThinkingView()
            .padding(.horizontal)
    }
}
