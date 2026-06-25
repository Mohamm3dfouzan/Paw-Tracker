import SwiftUI

/// A welcome banner shown once per session when Bagheera decides
/// it's been long enough. Dismisses automatically or on tap.
struct BagheeraGreetingView: View {
    let message: String
    var onDismiss: () -> Void

    @State private var visible = false

    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .top, spacing: 14) {
                BagheeraAvatarView(size: 64, animatedEyes: true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(Bagheera.name).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    Text(message).font(.body).fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.2), radius: 18, y: 6)
            .padding(.horizontal, 18)
            .padding(.bottom, 24)
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) { visible = true }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 6_500_000_000)
                if visible { dismiss() }
            }
        }
        .onTapGesture { dismiss() }
        .allowsHitTesting(true)
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.25)) { visible = false }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 260_000_000)
            onDismiss()
        }
    }
}

#Preview {
    ZStack {
        Color(white: 0.06).ignoresSafeArea()
        BagheeraGreetingView(message: "*purrs* Welcome home. The kingdom is intact.") {}
    }
}
