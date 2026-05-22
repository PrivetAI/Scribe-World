import SwiftUI

// All icons are custom SwiftUI Shapes — no SF Symbols, no emoji.

// Scribe / feather pen.
struct ScribeIcon: View {
    var color: Color = Scribe.brass
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                // feather shaft
                Path { p in
                    p.move(to: CGPoint(x: w*0.18, y: h*0.86))
                    p.addCurve(to: CGPoint(x: w*0.78, y: h*0.16),
                               control1: CGPoint(x: w*0.40, y: h*0.62),
                               control2: CGPoint(x: w*0.62, y: h*0.34))
                }
                .stroke(color, style: StrokeStyle(lineWidth: max(1.4, w*0.05), lineCap: .round))
                // feather body
                Path { p in
                    p.move(to: CGPoint(x: w*0.30, y: h*0.74))
                    p.addCurve(to: CGPoint(x: w*0.82, y: h*0.12),
                               control1: CGPoint(x: w*0.30, y: h*0.42),
                               control2: CGPoint(x: w*0.58, y: h*0.18))
                    p.addCurve(to: CGPoint(x: w*0.46, y: h*0.62),
                               control1: CGPoint(x: w*0.74, y: h*0.34),
                               control2: CGPoint(x: w*0.60, y: h*0.50))
                    p.closeSubpath()
                }
                .fill(color.opacity(0.85))
                // nib drop
                Path { p in
                    p.move(to: CGPoint(x: w*0.18, y: h*0.86))
                    p.addLine(to: CGPoint(x: w*0.10, y: h*0.96))
                }
                .stroke(color, style: StrokeStyle(lineWidth: max(1.2, w*0.045), lineCap: .round))
            }
        }
    }
}

// Open book.
struct BookIcon: View {
    var color: Color = Scribe.brass
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: w*0.5, y: h*0.26))
                    p.addCurve(to: CGPoint(x: w*0.10, y: h*0.20),
                               control1: CGPoint(x: w*0.34, y: h*0.16),
                               control2: CGPoint(x: w*0.20, y: h*0.16))
                    p.addLine(to: CGPoint(x: w*0.10, y: h*0.78))
                    p.addCurve(to: CGPoint(x: w*0.5, y: h*0.84),
                               control1: CGPoint(x: w*0.22, y: h*0.74),
                               control2: CGPoint(x: w*0.36, y: h*0.74))
                    p.addCurve(to: CGPoint(x: w*0.90, y: h*0.78),
                               control1: CGPoint(x: w*0.64, y: h*0.74),
                               control2: CGPoint(x: w*0.78, y: h*0.74))
                    p.addLine(to: CGPoint(x: w*0.90, y: h*0.20))
                    p.addCurve(to: CGPoint(x: w*0.5, y: h*0.26),
                               control1: CGPoint(x: w*0.80, y: h*0.16),
                               control2: CGPoint(x: w*0.66, y: h*0.16))
                    p.closeSubpath()
                }
                .stroke(color, lineWidth: max(1.4, w*0.05))
                Path { p in
                    p.move(to: CGPoint(x: w*0.5, y: h*0.26))
                    p.addLine(to: CGPoint(x: w*0.5, y: h*0.84))
                }
                .stroke(color, lineWidth: max(1.2, w*0.04))
            }
        }
    }
}

// Check mark.
struct CheckIcon: View {
    var color: Color = Scribe.correctTint
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            Path { p in
                p.move(to: CGPoint(x: w*0.18, y: h*0.52))
                p.addLine(to: CGPoint(x: w*0.42, y: h*0.76))
                p.addLine(to: CGPoint(x: w*0.84, y: h*0.24))
            }
            .stroke(color, style: StrokeStyle(lineWidth: max(1.8, w*0.10), lineCap: .round, lineJoin: .round))
        }
    }
}

// Eye (reveal).
struct EyeIcon: View {
    var color: Color = Scribe.brass
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: w*0.08, y: h*0.5))
                    p.addQuadCurve(to: CGPoint(x: w*0.92, y: h*0.5), control: CGPoint(x: w*0.5, y: h*0.12))
                    p.addQuadCurve(to: CGPoint(x: w*0.08, y: h*0.5), control: CGPoint(x: w*0.5, y: h*0.88))
                    p.closeSubpath()
                }
                .stroke(color, lineWidth: max(1.4, w*0.05))
                Circle()
                    .fill(color)
                    .frame(width: w*0.26, height: w*0.26)
            }
        }
    }
}

// Gear (settings).
struct GearIcon: View {
    var color: Color = Scribe.brass
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            let c = CGPoint(x: geo.size.width/2, y: geo.size.height/2)
            ZStack {
                ForEach(0..<8, id: \.self) { i in
                    Rectangle()
                        .fill(color)
                        .frame(width: s*0.16, height: s*0.22)
                        .offset(y: -s*0.40)
                        .rotationEffect(.degrees(Double(i) * 45))
                }
                Circle().stroke(color, lineWidth: s*0.12)
                    .frame(width: s*0.5, height: s*0.5)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .position(c)
        }
    }
}

// Lock (privacy).
struct LockIcon: View {
    var color: Color = Scribe.brass
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                RoundedRectangle(cornerRadius: w*0.10)
                    .stroke(color, lineWidth: max(1.4, w*0.06))
                    .frame(width: w*0.62, height: h*0.46)
                    .offset(y: h*0.16)
                Path { p in
                    p.addArc(center: CGPoint(x: w*0.5, y: h*0.42), radius: w*0.18,
                             startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                }
                .stroke(color, lineWidth: max(1.4, w*0.06))
            }
        }
    }
}

// Chevron, pointing right by default.
struct ChevronIcon: View {
    var color: Color = Scribe.inkSoft
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            Path { p in
                p.move(to: CGPoint(x: w*0.36, y: h*0.22))
                p.addLine(to: CGPoint(x: w*0.66, y: h*0.5))
                p.addLine(to: CGPoint(x: w*0.36, y: h*0.78))
            }
            .stroke(color, style: StrokeStyle(lineWidth: max(1.6, w*0.10), lineCap: .round, lineJoin: .round))
        }
    }
}

// Star (clean-solve).
struct StarIcon: View {
    var filled: Bool = true
    var color: Color = Scribe.star
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let path = Path { p in
                let cx = w/2, cy = h/2
                let outer = min(w, h) * 0.48
                let inner = outer * 0.42
                for i in 0..<10 {
                    let r = i % 2 == 0 ? outer : inner
                    let a = Double(i) * .pi / 5 - .pi/2
                    let pt = CGPoint(x: cx + r * CGFloat(cos(a)), y: cy + r * CGFloat(sin(a)))
                    if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                }
                p.closeSubpath()
            }
            if filled {
                path.fill(color)
            } else {
                path.stroke(color, lineWidth: max(1.4, w*0.05))
            }
        }
    }
}

// Clock (timer).
struct ClockIcon: View {
    var color: Color = Scribe.inkSoft
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                Circle().stroke(color, lineWidth: max(1.4, s*0.07))
                    .frame(width: s*0.82, height: s*0.82)
                Path { p in
                    p.move(to: CGPoint(x: geo.size.width/2, y: geo.size.height/2))
                    p.addLine(to: CGPoint(x: geo.size.width/2, y: geo.size.height/2 - s*0.26))
                    p.move(to: CGPoint(x: geo.size.width/2, y: geo.size.height/2))
                    p.addLine(to: CGPoint(x: geo.size.width/2 + s*0.18, y: geo.size.height/2 + s*0.06))
                }
                .stroke(color, style: StrokeStyle(lineWidth: max(1.4, s*0.06), lineCap: .round))
            }
        }
    }
}

// Pause bars.
struct PauseIcon: View {
    var color: Color = Scribe.ink
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            HStack(spacing: w*0.16) {
                RoundedRectangle(cornerRadius: w*0.05).fill(color).frame(width: w*0.20)
                RoundedRectangle(cornerRadius: w*0.05).fill(color).frame(width: w*0.20)
            }
            .frame(width: w, height: h*0.6)
            .position(x: w/2, y: h/2)
        }
    }
}

// Play triangle.
struct PlayIcon: View {
    var color: Color = Scribe.panel
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            Path { p in
                p.move(to: CGPoint(x: w*0.30, y: h*0.22))
                p.addLine(to: CGPoint(x: w*0.78, y: h*0.5))
                p.addLine(to: CGPoint(x: w*0.30, y: h*0.78))
                p.closeSubpath()
            }
            .fill(color)
        }
    }
}

// Trash / clear.
struct ClearIcon: View {
    var color: Color = Scribe.inkSoft
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: w*0.24, y: h*0.30))
                    p.addLine(to: CGPoint(x: w*0.30, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*0.70, y: h*0.82))
                    p.addLine(to: CGPoint(x: w*0.76, y: h*0.30))
                }
                .stroke(color, style: StrokeStyle(lineWidth: max(1.4, w*0.06), lineJoin: .round))
                Path { p in
                    p.move(to: CGPoint(x: w*0.16, y: h*0.30))
                    p.addLine(to: CGPoint(x: w*0.84, y: h*0.30))
                }
                .stroke(color, style: StrokeStyle(lineWidth: max(1.4, w*0.06), lineCap: .round))
            }
        }
    }
}

// Delete / backspace key glyph.
struct BackspaceIcon: View {
    var color: Color = Scribe.ink
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: w*0.36, y: h*0.22))
                    p.addLine(to: CGPoint(x: w*0.86, y: h*0.22))
                    p.addLine(to: CGPoint(x: w*0.86, y: h*0.78))
                    p.addLine(to: CGPoint(x: w*0.36, y: h*0.78))
                    p.addLine(to: CGPoint(x: w*0.14, y: h*0.5))
                    p.closeSubpath()
                }
                .stroke(color, style: StrokeStyle(lineWidth: max(1.4, w*0.05), lineJoin: .round))
                Path { p in
                    p.move(to: CGPoint(x: w*0.50, y: h*0.38))
                    p.addLine(to: CGPoint(x: w*0.72, y: h*0.62))
                    p.move(to: CGPoint(x: w*0.72, y: h*0.38))
                    p.addLine(to: CGPoint(x: w*0.50, y: h*0.62))
                }
                .stroke(color, style: StrokeStyle(lineWidth: max(1.4, w*0.05), lineCap: .round))
            }
        }
    }
}

// Inkwell (decorative).
struct InkwellIcon: View {
    var color: Color = Scribe.scribeBlue
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: w*0.24, y: h*0.46))
                    p.addLine(to: CGPoint(x: w*0.30, y: h*0.80))
                    p.addLine(to: CGPoint(x: w*0.70, y: h*0.80))
                    p.addLine(to: CGPoint(x: w*0.76, y: h*0.46))
                    p.closeSubpath()
                }
                .fill(color.opacity(0.85))
                Ellipse().stroke(color, lineWidth: max(1.2, w*0.045))
                    .frame(width: w*0.56, height: h*0.16)
                    .position(x: w*0.5, y: h*0.46)
            }
        }
    }
}
