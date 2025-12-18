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
  func toEffect() -> EffectAdding? {
    switch type {
    case .bounce:
      return BounceEffect(wholeSymbol: wholeSymbol, byLayer: byLayer, direction: direction)
    case .pulse:
      return PulseEffect(wholeSymbol: wholeSymbol, byLayer: byLayer)
    case .scale:
      return ScaleEffect(wholeSymbol: wholeSymbol, byLayer: byLayer, direction: direction)
    case .replace:
      return nil
    case .rotate:
      if #available(iOS 18.0, tvOS 18.0, *) {
        return RotateEffect(
          wholeSymbol: wholeSymbol,
          byLayer: byLayer,
          direction: rotateDirection
        )
      }
      return nil
    case .breathe:
      if #available(iOS 18.0, tvOS 18.0, *) {
        return BreatheEffect(
          wholeSymbol: wholeSymbol,
          byLayer: byLayer,
          style: breatheStyle
        )
      }
      return nil
    case .wiggle:
      if #available(iOS 18.0, tvOS 18.0, *) {
        return WiggleEffect(
          wholeSymbol: wholeSymbol,
          byLayer: byLayer,
          axis: wiggleAxis,
          rotation: wiggleRotation,
          customAngle: wiggleCustomAngle
        )
      }
      return nil
    }
  }

  @available(iOS 17.0, tvOS 17.0, *)
  func toContentTransitionEffect() -> (any SymbolEffect & ContentTransitionSymbolEffect)? {
    guard type == .replace else {
      return nil
    }

    func applyScope(_ effect: ReplaceSymbolEffect) -> ReplaceSymbolEffect {
      var scopedEffect = effect
      if byLayer ?? false {
        scopedEffect = scopedEffect.byLayer
      } else if wholeSymbol ?? false {
        scopedEffect = scopedEffect.wholeSymbol
      }
      return scopedEffect
    }

    func configuredEffect(for transition: ReplaceTransition) -> ReplaceSymbolEffect {
      var effect: ReplaceSymbolEffect = .replace
      switch transition {
      case .downUp:
        effect = effect.downUp
      case .offUp:
        effect = effect.offUp
      case .upUp:
        effect = effect.upUp
      }
      return applyScope(effect)
    }

    let defaultTransition: ReplaceTransition = .downUp
    let transitionEffect = configuredEffect(for: replaceTransition ?? defaultTransition)

    if useMagicReplace ?? false, #available(iOS 18.0, tvOS 18.0, *) {
      let fallbackTransition = magicFallbackTransition ?? replaceTransition ?? defaultTransition
      let fallbackEffect = configuredEffect(for: fallbackTransition)
      let magicBase = applyScope(.replace)
      return magicBase.magic(fallback: fallbackEffect)
    }

    return transitionEffect
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
