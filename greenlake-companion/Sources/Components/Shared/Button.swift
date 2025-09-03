import SwiftUI

struct AnimatedButton: ButtonStyle {
  let backgroundColor: Color
  let foregroundColor: Color
  let pressedOpacity: Double
  let cornerRadius: CGFloat

  init(
    backgroundColor: Color,
    foregroundColor: Color = .white,
    pressedOpacity: Double = 0.8,
    cornerRadius: CGFloat = 8
  ) {
    self.backgroundColor = backgroundColor
    self.foregroundColor = foregroundColor
    self.pressedOpacity = pressedOpacity
    self.cornerRadius = cornerRadius
  }

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding()
      .foregroundStyle(foregroundColor)
      .background(
        configuration.isPressed ? backgroundColor.opacity(pressedOpacity) : backgroundColor
      )
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
      .scaleEffect(configuration.isPressed ? 0.98 : 1)
      .animation(.smooth(duration: 0.1), value: configuration.isPressed)
  }
}

extension ButtonStyle where Self == AnimatedButton {
  static var primary: AnimatedButton {
    return AnimatedButton(backgroundColor: Color(.systemBlue), foregroundColor: .white)
  }

  static var secondary: AnimatedButton {
    return AnimatedButton(backgroundColor: Color(.systemGray6), foregroundColor: .black)
  }
}
