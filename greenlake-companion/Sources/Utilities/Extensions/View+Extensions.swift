import SwiftUI

extension View {
  @ViewBuilder func `if`<Value, TrueContent: View>(
    _ value: Value?,
    then trueContent: (Self, Value) -> TrueContent
  ) -> some View {
    if let value = value {
      trueContent(self, value)
    } else {
      self
    }
  }
}
