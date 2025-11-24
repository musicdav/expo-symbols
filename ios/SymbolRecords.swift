import ExpoModulesCore

enum SymbolScale: String, Enumerable {
  case `default`
  case unspecified
  case small
  case medium
  case large

  func imageSymbolScale() -> UIImage.SymbolScale {
    switch self {
    case .default:
      return .default
    case .small:
      return .small
    case .medium:
      return .medium
    case .large:
      return .large
    case .unspecified:
      return .unspecified
    }
  }
}

enum SymbolWeight: String, Enumerable {
  case unspecified
  case ultraLight
  case thin
  case light
  case regular
  case medium
  case semibold
  case bold
  case heavy
  case black

  func imageSymbolWeight() -> UIImage.SymbolWeight {
    switch self {
    case .unspecified:
      return .unspecified
    case .ultraLight:
      return .ultraLight
    case .thin:
      return .thin
    case .light:
      return .light
    case .regular:
      return .regular
    case .medium:
      return .medium
    case .semibold:
      return .semibold
    case .bold:
      return .bold
    case .heavy:
      return .heavy
    case .black:
      return .black
    }
  }
}

enum SymbolContentMode: String, Enumerable {
  case scaleToFill
  case scaleAspectFit
  case scaleAspectFill
  case redraw
  case center
  case top
  case bottom
  case left
  case right
  case topLeft
  case topRight
  case bottomLeft
  case bottomRight

  func toContentMode() -> UIView.ContentMode {
    switch self {
    case .scaleToFill:
      return .scaleToFill
    case .scaleAspectFit:
      return .scaleAspectFit
    case .scaleAspectFill:
      return .scaleAspectFill
    case .redraw:
      return .redraw
    case .center:
      return .center
    case .top:
      return .top
    case .bottom:
      return .bottom
    case .left:
      return .left
    case .right:
      return .right
    case .topLeft:
      return .topLeft
    case .topRight:
      return .topRight
    case .bottomLeft:
      return .bottomLeft
    case .bottomRight:
      return .bottomRight
    }
  }
}

enum SymbolType: String, Enumerable {
  case monochrome
  case hierarchical
  case palette
  case multicolor
}

enum AnimationDirection: String, Enumerable {
  case up
  case down
}

enum ReplaceTransition: String, Enumerable {
  case downUp
  case offUp
  case upUp
}

enum RotationDirection: String, Enumerable {
  case clockwise
  case counterClockwise
}

enum BreatheStyle: String, Enumerable {
  case plain
  case pulse
}

enum WiggleAxis: String, Enumerable {
  case up
  case down
  case left
  case right
  case forward
  case backward
}

enum AnimationType: String, Enumerable {
  case bounce
  case pulse
  case scale
  case replace
  case rotate
  case breathe
  case wiggle
}

internal struct AnimationSpec: Record {
  @Field var effect: AnimationEffect?
  @Field var repeating: Bool?
  @Field var repeatCount: Int?
  @Field var speed: Double?
  @Field var variableAnimationSpec: VariableColorSpec?
}

internal struct AnimationEffect: Record {
  @Field var type: AnimationType = .bounce
  @Field var wholeSymbol: Bool?
  @Field var direction: AnimationDirection?
  @Field var byLayer: Bool?
  @Field var replaceTransition: ReplaceTransition?
  @Field var useMagicReplace: Bool?
  @Field var magicFallbackTransition: ReplaceTransition?
  @Field var rotateDirection: RotationDirection?
  @Field var breatheStyle: BreatheStyle?
  @Field var wiggleAxis: WiggleAxis?
  @Field var wiggleRotation: RotationDirection?
  @Field var wiggleCustomAngle: Double?

  @available(iOS 17.0, tvOS 17.0, *)
  func toEffect() -> EffectAdding {
    switch type {
    case .bounce:
      return BounceEffect(wholeSymbol: wholeSymbol, byLayer: byLayer, direction: direction)
    case .pulse:
      return PulseEffect(wholeSymbol: wholeSymbol, byLayer: byLayer)
    case .scale:
      return ScaleEffect(wholeSymbol: wholeSymbol, byLayer: byLayer, direction: direction)
    case .replace:
      return ReplaceEffect(
        wholeSymbol: wholeSymbol,
        byLayer: byLayer,
        transition: replaceTransition,
        useMagicReplace: useMagicReplace ?? false,
        magicFallbackTransition: magicFallbackTransition
      )
    case .rotate:
      return RotateEffect(
        wholeSymbol: wholeSymbol,
        byLayer: byLayer,
        direction: rotateDirection
      )
    case .breathe:
      return BreatheEffect(
        wholeSymbol: wholeSymbol,
        byLayer: byLayer,
        style: breatheStyle
      )
    case .wiggle:
      return WiggleEffect(
        wholeSymbol: wholeSymbol,
        byLayer: byLayer,
        axis: wiggleAxis,
        rotation: wiggleRotation,
        customAngle: wiggleCustomAngle
      )
    }
  }
}

internal struct VariableColorSpec: Record {
  @Field var reversing: Bool?
  @Field var nonReversing: Bool?
  @Field var cumulative: Bool?
  @Field var iterative: Bool?
  @Field var hideInactiveLayers: Bool?
  @Field var dimInactiveLayers: Bool?

  @available(iOS 17.0, tvOS 17.0, *)
  func toVariableEffect() -> VariableColorSymbolEffect {
    var effect: VariableColorSymbolEffect = .variableColor

    if cumulative == true {
      effect = effect.cumulative
    }

    if iterative == true {
      effect = effect.iterative
    }

    if hideInactiveLayers == true {
      effect = effect.hideInactiveLayers
    }

    if dimInactiveLayers == true {
      effect = effect.dimInactiveLayers
    }

    if reversing == true {
      effect = effect.reversing
    }

    if nonReversing == true {
      effect = effect.nonReversing
    }

    return effect
  }
}
