import SwiftUI

struct PetAvatarView: View {
    let pet: Pet
    var size: CGFloat = 56

    var body: some View {
        Group {
            if let data = pet.avatarData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    AppTheme.warmGradient
                    Image(systemName: pet.species.symbol)
                        .font(.system(size: size * 0.45, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: 1))
    }
}
