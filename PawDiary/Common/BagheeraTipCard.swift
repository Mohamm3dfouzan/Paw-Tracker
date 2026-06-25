import SwiftUI

/// A daily fun-fact card hosted by Bagheera. Tap to roll a new fact.
struct BagheeraTipCard: View {
    @Environment(Bagheera.self) private var bagheera
    @State private var fact: String = ""

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            BagheeraAvatarView(size: 48)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("\(Bagheera.name) says")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "sparkles").foregroundStyle(.indigo)
                }
                Text(fact)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCorner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCorner, style: .continuous)
                .strokeBorder(.indigo.opacity(0.25), lineWidth: 0.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                bagheera.rerollFact()
                fact = bagheera.dailyFact
            }
        }
        .onAppear { fact = bagheera.dailyFact }
    }
}
