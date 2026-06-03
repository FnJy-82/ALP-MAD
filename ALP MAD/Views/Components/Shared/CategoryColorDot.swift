//
//  CategoryColorDot.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct CategoryColorDot: View {
    let colorHex: String
    var size: CGFloat = 10

    var body: some View {
        Circle()
            .fill(Color(hex: colorHex))
            .frame(width: size, height: size)
    }
}

//#Preview {
//    CategoryColorDot()
//}
