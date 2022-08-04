//
//  SwiftUIStyle.swift
//  FSPlayer
//
//  Created by andy on 2022/8/4.
//

import Foundation
import SwiftUI

struct FSButton: ViewModifier
{
    var isDisable = false
    let padding: CGFloat = 7
    
    func body(content: Content) -> some View {
        if isDisable {
            return content
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.gray).padding(.top, padding).padding(.bottom, padding))
                .foregroundColor(.white)
                .font(.system(size: 15))
        } else {
            return content
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 255/255, green: 123/255, blue: 109/255)).padding(.top, padding).padding(.bottom, padding))
                .foregroundColor(.white)
                .font(.system(size: 15))
        }
    }
}
