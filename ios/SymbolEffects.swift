@available(iOS 17.0, tvOS 17.0, *)
internal protocol EffectAdding {
  func add(to view: UIImageView, with options: SymbolEffectOptions)
}

@available(iOS 17.0, tvOS 17.0, *)
internal struct BounceEffect: EffectAdding {
  private let effect: BounceSymbolEffect = .bounce
  let wholeSymbol: Bool?
  let byLayer: Bool?
  let direction: AnimationDirection?

  func add(to view: UIImageView, with options: SymbolEffectOptions) {
    var finalEffect = applyScope(effect)

    if let direction {
      finalEffect = direction == .up ? finalEffect.up : finalEffect.down
    }

    view.addSymbolEffect(finalEffect, options: options, animated: true)
  }

  private func applyScope(_ effect: BounceSymbolEffect) -> BounceSymbolEffect {
    var scopedEffect = effect
    if byLayer ?? false {
      scopedEffect = scopedEffect.byLayer
    } else if wholeSymbol ?? false {
      scopedEffect = scopedEffect.wholeSymbol
    }
    return scopedEffect
  }
}

@available(iOS 17.0, tvOS 17.0, *)
internal struct PulseEffect: EffectAdding {
  private let effect: PulseSymbolEffect = .pulse
  let wholeSymbol: Bool?
  let byLayer: Bool?

  func add(to view: UIImageView, with options: SymbolEffectOptions) {
    let finalEffect = applyScope(effect)
    view.addSymbolEffect(finalEffect, options: options, animated: true)
  }

  private func applyScope(_ effect: PulseSymbolEffect) -> PulseSymbolEffect {
    var scopedEffect = effect
    if byLayer ?? false {
      scopedEffect = scopedEffect.byLayer
    } else if wholeSymbol ?? false {
      scopedEffect = scopedEffect.wholeSymbol
    }
    return scopedEffect
  }
}

@available(iOS 17.0, tvOS 17.0, *)
internal struct ScaleEffect: EffectAdding {
  private let effect: ScaleSymbolEffect = .scale
  let wholeSymbol: Bool?
  let byLayer: Bool?
  let direction: AnimationDirection?

  func add(to view: UIImageView, with options: SymbolEffectOptions) {
    var finalEffect = applyScope(effect)

    if let direction {
      finalEffect = direction == .up ? finalEffect.up : finalEffect.down
    }

    view.addSymbolEffect(finalEffect, options: options, animated: true)
  }

  private func applyScope(_ effect: ScaleSymbolEffect) -> ScaleSymbolEffect {
    var scopedEffect = effect
    if byLayer ?? false {
      scopedEffect = scopedEffect.byLayer
    } else if wholeSymbol ?? false {
      scopedEffect = scopedEffect.wholeSymbol
    }
    return scopedEffect
  }
}

@available(iOS 17.0, tvOS 17.0, *)
internal struct ReplaceEffect: EffectAdding {
  private let defaultTransition: ReplaceTransition = .downUp
  let wholeSymbol: Bool?
  let byLayer: Bool?
  let transition: ReplaceTransition?
  let useMagicReplace: Bool
  let magicFallbackTransition: ReplaceTransition?

  func add(to view: UIImageView, with options: SymbolEffectOptions) {
    if useMagicReplace, #available(iOS 18.0, tvOS 18.0, *) {
      let fallbackEffect = configuredEffect(for: magicFallbackTransition ?? transition ?? defaultTransition)
      let magicEffect = ReplaceSymbolEffect.magic(fallback: fallbackEffect)
      view.addSymbolEffect(magicEffect, options: options, animated: true)
      return
    }

    let finalEffect = configuredEffect(for: transition ?? defaultTransition)
    view.addSymbolEffect(finalEffect, options: options, animated: true)
  }

  private func configuredEffect(for transition: ReplaceTransition) -> ReplaceSymbolEffect {
    var effect: ReplaceSymbolEffect
    switch transition {
    case .downUp:
      effect = .downUp
    case .offUp:
      effect = .offUp
    case .upUp:
      effect = .upUp
    }

    if byLayer ?? false {
      effect = effect.byLayer
    } else if wholeSymbol ?? false {
      effect = effect.wholeSymbol
    }

    return effect
  }
}

@available(iOS 17.0, tvOS 17.0, *)
internal struct RotateEffect: EffectAdding {
  private let effect: RotateSymbolEffect = .rotate
  let wholeSymbol: Bool?
  let byLayer: Bool?
  let direction: RotationDirection?

  func add(to view: UIImageView, with options: SymbolEffectOptions) {
    var finalEffect = applyScope(effect)

    if let direction {
      switch direction {
      case .clockwise:
        finalEffect = finalEffect.clockwise
      case .counterClockwise:
        finalEffect = finalEffect.counterClockwise
      }
    }

    view.addSymbolEffect(finalEffect, options: options, animated: true)
  }

  private func applyScope(_ effect: RotateSymbolEffect) -> RotateSymbolEffect {
    var scopedEffect = effect
    if byLayer ?? false {
      scopedEffect = scopedEffect.byLayer
    } else if wholeSymbol ?? false {
      scopedEffect = scopedEffect.wholeSymbol
    }
    return scopedEffect
  }
}

@available(iOS 17.0, tvOS 17.0, *)
internal struct BreatheEffect: EffectAdding {
  private let effect: BreatheSymbolEffect = .breathe
  let wholeSymbol: Bool?
  let byLayer: Bool?
  let style: BreatheStyle?

  func add(to view: UIImageView, with options: SymbolEffectOptions) {
    var finalEffect = applyScope(effect)

    if let style {
      switch style {
      case .plain:
        finalEffect = finalEffect.plain
      case .pulse:
        finalEffect = finalEffect.pulse
      }
    }

    view.addSymbolEffect(finalEffect, options: options, animated: true)
  }

  private func applyScope(_ effect: BreatheSymbolEffect) -> BreatheSymbolEffect {
    var scopedEffect = effect
    if byLayer ?? false {
      scopedEffect = scopedEffect.byLayer
    } else if wholeSymbol ?? false {
      scopedEffect = scopedEffect.wholeSymbol
    }
    return scopedEffect
  }
}

@available(iOS 17.0, tvOS 17.0, *)
internal struct WiggleEffect: EffectAdding {
  private let effect: WiggleSymbolEffect = .wiggle
  let wholeSymbol: Bool?
  let byLayer: Bool?
  let axis: WiggleAxis?
  let rotation: RotationDirection?
  let customAngle: Double?

  func add(to view: UIImageView, with options: SymbolEffectOptions) {
    var finalEffect = applyScope(effect)

    if let axis {
      finalEffect = applyAxis(axis, to: finalEffect)
    }

    if let rotation {
      switch rotation {
      case .clockwise:
        finalEffect = finalEffect.clockwise
      case .counterClockwise:
        finalEffect = finalEffect.counterClockwise
      }
    }

    if let customAngle {
      finalEffect = finalEffect.custom(angle: customAngle)
    }

    view.addSymbolEffect(finalEffect, options: options, animated: true)
  }

  private func applyScope(_ effect: WiggleSymbolEffect) -> WiggleSymbolEffect {
    var scopedEffect = effect
    if byLayer ?? false {
      scopedEffect = scopedEffect.byLayer
    } else if wholeSymbol ?? false {
      scopedEffect = scopedEffect.wholeSymbol
    }
    return scopedEffect
  }

  private func applyAxis(_ axis: WiggleAxis, to effect: WiggleSymbolEffect) -> WiggleSymbolEffect {
    switch axis {
    case .up:
      return effect.up
    case .down:
      return effect.down
    case .left:
      return effect.left
    case .right:
      return effect.right
    case .forward:
      return effect.forward
    case .backward:
      return effect.backward
    }
  }
}
