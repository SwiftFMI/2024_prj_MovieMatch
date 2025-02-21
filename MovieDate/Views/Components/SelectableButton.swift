//
//  SelectableButton.swift
//  MovieDate
//
//  Created by Mark Titorenkov on 17.02.25.
//


import SwiftUI

struct SelectableButton<Icon: View>: View {
    let icon: Icon
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                icon
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.white.opacity(0.7) : Color.white.opacity(0.2))
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }
}

extension SelectableButton where Icon == EmptyView {
    init(text: String, isSelected: Bool = false, action: @escaping () -> Void) {
        self.init(icon: EmptyView(), text: text, isSelected: isSelected, action: action)
    }
}
