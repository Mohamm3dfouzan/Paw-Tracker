import SwiftUI

/// A hand-drawn SwiftUI portrait of Bagheera — jet-black coat,
/// broad face, and luminous golden-yellow eyes. Based on the real
/// Bagheera, not a stock cat.
struct BagheeraAvatarView: View {
    var size: CGFloat = 80
    var animatedEyes: Bool = false
    /// Adds the little AirTag-style collar disc at the chin — Bagheera's signature accessory.
    var showsCollar: Bool = true

    @State private var blink = false

    var body: some View {
        ZStack {
            // Soft warm background to make the gold eyes pop
            RadialGradient(
                colors: [
                    Color(red: 0.20, green: 0.17, blue: 0.14),
                    Color(red: 0.06, green: 0.05, blue: 0.04),
                ],
                center: .center,
                startRadius: 0,
                endRadius: size * 0.55
            )

            CatFace()
                .frame(width: size * 0.92, height: size * 0.92)

            // Eyes on top so they always read clean
            HStack(spacing: size * 0.16) {
                eye
                eye
            }
            .offset(y: -size * 0.04)

            if showsCollar && size >= 36 {
                airTagCollar
                    .offset(y: size * 0.40)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(.white.opacity(0.15), lineWidth: 0.5))
        .onAppear {
            guard animatedEyes else { return }
            Task { @MainActor in
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 2_500_000_000...5_500_000_000))
                    withAnimation(.easeInOut(duration: 0.12)) { blink = true }
                    try? await Task.sleep(nanoseconds: 140_000_000)
                    withAnimation(.easeInOut(duration: 0.12)) { blink = false }
                }
            }
        }
    }

    /// A small AirTag-style disc hanging at the chin —
    /// stylized so we're not depicting Apple branding.
    private var airTagCollar: some View {
        ZStack {
            // Soft collar strap arcs
            Capsule()
                .fill(Color(white: 0.22))
                .frame(width: size * 0.55, height: size * 0.05)
                .offset(y: -size * 0.04)
            // The disc
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(white: 0.95), Color(white: 0.78)],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.10
                    )
                )
                .frame(width: size * 0.16, height: size * 0.16)
                .overlay(
                    Circle()
                        .strokeBorder(Color(white: 0.55), lineWidth: 0.6)
                )
                .overlay(
                    // A tiny paw glyph in the center
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: size * 0.07, weight: .bold))
                        .foregroundStyle(Color(white: 0.25))
                )
                .shadow(color: .black.opacity(0.4), radius: 1, y: 0.5)
        }
    }

    private var eye: some View {
        ZStack {
            // Outer amber ring
            Circle()
                .fill(Color(red: 0.78, green: 0.45, blue: 0.05))
                .frame(width: size * 0.16, height: blink ? size * 0.02 : size * 0.16)
                .shadow(color: Color(red: 1.0, green: 0.75, blue: 0.2).opacity(0.6), radius: 3)

            // Inner golden iris
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1.0, green: 0.88, blue: 0.35),
                            Color(red: 0.95, green: 0.65, blue: 0.10),
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.07
                    )
                )
                .frame(width: size * 0.13, height: blink ? 0 : size * 0.13)

            // Vertical slit pupil
            Capsule()
                .fill(Color.black)
                .frame(width: size * 0.025, height: blink ? 0 : size * 0.11)

            // Catchlight
            Circle()
                .fill(Color.white.opacity(blink ? 0 : 0.95))
                .frame(width: size * 0.024, height: size * 0.024)
                .offset(x: -size * 0.025, y: -size * 0.03)
        }
    }
}

/// The face: broad head, dark inner ears with a light tuft, black nose,
/// soft cheek fluff. No colorpoint — Bagheera is solid black.
private struct CatFace: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // Head — wider than tall, more like Bagheera's broad face
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color(white: 0.12), .black],
                            center: UnitPoint(x: 0.5, y: 0.4),
                            startRadius: 0,
                            endRadius: w * 0.55
                        )
                    )
                    .frame(width: w * 1.02, height: h * 0.95)
                    .offset(y: h * 0.04)

                // Ears (outer = black, sharper triangles)
                EarShape()
                    .fill(Color.black)
                    .frame(width: w * 0.30, height: h * 0.36)
                    .rotationEffect(.degrees(-10))
                    .offset(x: -w * 0.27, y: -h * 0.30)
                EarShape()
                    .fill(Color.black)
                    .frame(width: w * 0.30, height: h * 0.36)
                    .rotationEffect(.degrees(10))
                    .offset(x: w * 0.27, y: -h * 0.30)

                // Inner ears — light/fluffy tuft (matches real Bagheera)
                EarShape()
                    .fill(Color(white: 0.55).opacity(0.85))
                    .frame(width: w * 0.13, height: h * 0.20)
                    .rotationEffect(.degrees(-10))
                    .offset(x: -w * 0.27, y: -h * 0.24)
                EarShape()
                    .fill(Color(white: 0.55).opacity(0.85))
                    .frame(width: w * 0.13, height: h * 0.20)
                    .rotationEffect(.degrees(10))
                    .offset(x: w * 0.27, y: -h * 0.24)

                // Cheek fluff — subtle highlight where the muzzle puffs out
                Ellipse()
                    .fill(Color(white: 0.18).opacity(0.55))
                    .frame(width: w * 0.78, height: h * 0.34)
                    .offset(y: h * 0.22)

                // Nose — BLACK, not pink (real Bagheera)
                NoseTriangle()
                    .fill(Color(white: 0.02))
                    .frame(width: w * 0.10, height: h * 0.07)
                    .offset(y: h * 0.18)
                    .overlay(
                        NoseTriangle()
                            .stroke(Color(white: 0.15), lineWidth: 0.5)
                            .frame(width: w * 0.10, height: h * 0.07)
                            .offset(y: h * 0.18)
                    )

                // Mouth — small Y shape from the nose
                Path { p in
                    let topY = h * 0.27
                    let mid = CGPoint(x: w * 0.5, y: topY)
                    p.move(to: mid)
                    p.addLine(to: CGPoint(x: w * 0.5, y: topY + h * 0.05))
                    p.move(to: CGPoint(x: w * 0.5, y: topY + h * 0.05))
                    p.addQuadCurve(to: CGPoint(x: w * 0.42, y: topY + h * 0.10), control: CGPoint(x: w * 0.46, y: topY + h * 0.10))
                    p.move(to: CGPoint(x: w * 0.5, y: topY + h * 0.05))
                    p.addQuadCurve(to: CGPoint(x: w * 0.58, y: topY + h * 0.10), control: CGPoint(x: w * 0.54, y: topY + h * 0.10))
                }
                .stroke(Color(white: 0.35), lineWidth: 0.9)

                // Whiskers — very faint, dark on dark like the real photo
                ForEach(0..<3) { i in
                    let yOff = h * (0.36 + 0.035 * CGFloat(i))
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.38, y: yOff))
                        p.addLine(to: CGPoint(x: w * 0.08, y: yOff - 3 + CGFloat(i) * 4))
                    }
                    .stroke(Color(white: 0.45).opacity(0.6), lineWidth: 0.6)
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.62, y: yOff))
                        p.addLine(to: CGPoint(x: w * 0.92, y: yOff - 3 + CGFloat(i) * 4))
                    }
                    .stroke(Color(white: 0.45).opacity(0.6), lineWidth: 0.6)
                }
            }
        }
    }
}

private struct EarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // Slightly rounded triangle ear
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                       control: CGPoint(x: rect.maxX * 0.9, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY),
                       control: CGPoint(x: rect.minX + rect.width * 0.1, y: rect.midY))
        p.closeSubpath()
        return p
    }
}

private struct NoseTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // Rounded inverted triangle
        let radius: CGFloat = 1.5
        p.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX - radius * 2, y: rect.minY + radius * 2),
                       control: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX + 1, y: rect.maxY - radius))
        p.addQuadCurve(to: CGPoint(x: rect.midX - 1, y: rect.maxY - radius),
                       control: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + radius * 2, y: rect.minY + radius * 2))
        p.addQuadCurve(to: CGPoint(x: rect.minX + radius, y: rect.minY),
                       control: CGPoint(x: rect.minX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

#Preview {
    HStack(spacing: 20) {
        BagheeraAvatarView(size: 60)
        BagheeraAvatarView(size: 100, animatedEyes: true)
        BagheeraAvatarView(size: 140)
    }
    .padding()
    .background(Color(white: 0.05))
}
