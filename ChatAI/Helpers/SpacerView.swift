//
//  Spacer.swift
//  Prompt
//
//  Created by Karl Koch on 02/01/2023.
//

import SwiftUI

struct SpacerView: View {
    @State var width: CGFloat
    @State var height: CGFloat

    var body: some View {
        Spacer()
            .frame(width: width, height: height)
    }
}

struct SpacerView_Previews: PreviewProvider {
    static var previews: some View {
        SpacerView(width: 0, height: 24)
    }
}
