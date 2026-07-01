import SwiftUI

struct PetStatusBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color.white.opacity(0.95)))
            .overlay(Capsule().stroke(Color.primary.opacity(0.12), lineWidth: 1))
            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
    }
}
