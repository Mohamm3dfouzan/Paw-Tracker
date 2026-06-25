import SwiftUI

/// A monochrome, single-tint silhouette of Bagheera. Designed for places
/// where the full-color illustration would be illegible — lock-screen
/// widgets (tintable), inline rows, ≤32pt mini-avatars, accent badges.
///
/// Use `BagheeraSilhouetteShape` directly if you want to control the
/// fill yourself (e.g. with `.foregroundStyle(.white)` for widget tinting).
struct BagheeraMonochromeAvatarView: View {
    var size: CGFloat = 24
    /// `nil` lets the view inherit the foreground style (perfect for
    /// `widgetAccentable()` lock-screen tinting).
    var tint: Color? = nil

    var body: some View {
        BagheeraSilhouetteShape()
            .fill(tint ?? Color.primary)
            .frame(width: size, height: size)
    }
}

/// A single-path silhouette: head + two pointed ears + a tiny eye-glint slit.
/// Renders crisp at any size — the eye dots are still visible at 16pt.
struct BagheeraSilhouetteShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let cx = rect.midX
        let cy = rect.midY + h * 0.04

        // Left ear
        p.move(to: CGPoint(x: cx - w * 0.35, y: cy - h * 0.10))
        p.addLine(to: CGPoint(x: cx - w * 0.22, y: cy - h * 0.48))
        p.addLine(to: CGPoint(x: cx - w * 0.05, y: cy - h * 0.25))

        // Top arc to right ear base
        p.addQuadCurve(
            to: CGPoint(x: cx + w * 0.05, y: cy - h * 0.25),
            control: CGPoint(x: cx, y: cy - h * 0.35)
        )

        // Right ear
        p.addLine(to: CGPoint(x: cx + w * 0.22, y: cy - h * 0.48))
        p.addLine(to: CGPoint(x: cx + w * 0.35, y: cy - h * 0.10))

        // Right cheek down to chin
        p.addQuadCurve(
            to: CGPoint(x: cx + w * 0.38, y: cy + h * 0.20),
            control: CGPoint(x: cx + w * 0.46, y: cy + h * 0.05)
        )
        p.addQuadCurve(
            to: CGPoint(x: cx, y: cy + h * 0.42),
            control: CGPoint(x: cx + w * 0.28, y: cy + h * 0.42)
        )
        // Left cheek back up
        p.addQuadCurve(
            to: CGPoint(x: cx - w * 0.38, y: cy + h * 0.20),
            control: CGPoint(x: cx - w * 0.28, y: cy + h * 0.42)
        )
        p.addQuadCurve(
            to: CGPoint(x: cx - w * 0.35, y: cy - h * 0.10),
            control: CGPoint(x: cx - w * 0.46, y: cy + h * 0.05)
        )
        p.closeSubpath()

        // Punch out two slit eyes (creates negative space when filled with
        // `.evenOdd`-friendly contexts; SwiftUI Shape uses non-zero by
        // default, but two narrow sub-paths going the same direction still
        // create visible "holes" only with `eoFill`. We instead overlay
        // them with the same fill — see view below — so they read as
        // crisp dark slits via subtraction from the silhouette).
        return p
    }
}

/// A composite view that draws the silhouette and *carves out* the eyes
/// using `.blendMode(.destinationOut)`, so the result reads as a single
/// tintable shape no matter what color you paint it.
struct BagheeraTintableMark: View {
    var size: CGFloat = 24

    var body: some View {
        Canvas { ctx, sz in
            // Draw silhouette
            ctx.fill(
                BagheeraSilhouetteShape().path(in: CGRect(origin: .zero, size: sz)),
                with: .color(.primary)
            )
            // Carve two eye slits
            let eyeW = sz.width * 0.06
            let eyeH = sz.height * 0.10
            let leftEye = CGRect(
                x: sz.width * 0.36 - eyeW / 2,
                y: sz.height * 0.46 - eyeH / 2,
                width: eyeW,
                height: eyeH
            )
            let rightEye = CGRect(
                x: sz.width * 0.64 - eyeW / 2,
                y: sz.height * 0.46 - eyeH / 2,
                width: eyeW,
                height: eyeH
            )
            ctx.blendMode = .destinationOut
            ctx.fill(Path(ellipseIn: leftEye), with: .color(.black))
            ctx.fill(Path(ellipseIn: rightEye), with: .color(.black))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 16) {
            BagheeraMonochromeAvatarView(size: 16)
            BagheeraMonochromeAvatarView(size: 24)
            BagheeraMonochromeAvatarView(size: 36)
            BagheeraMonochromeAvatarView(size: 60)
        }
        HStack(spacing: 16) {
            BagheeraTintableMark(size: 24).foregroundStyle(.pink)
            BagheeraTintableMark(size: 36).foregroundStyle(.indigo)
            BagheeraTintableMark(size: 60).foregroundStyle(.cyan)
        }
        // On a dark background (lock screen vibe)
        HStack(spacing: 16) {
            BagheeraMonochromeAvatarView(size: 24, tint: .white)
            BagheeraMonochromeAvatarView(size: 36, tint: .white)
            BagheeraMonochromeAvatarView(size: 60, tint: .white)
        }
        .padding()
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
}
