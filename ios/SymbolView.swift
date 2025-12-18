import ExpoModulesCore

class SymbolView: ExpoView {
  let imageView = UIImageView()

  // MARK: Properties
  var name: String = ""
  var weight: UIImage.SymbolWeight = .unspecified
  var scale: UIImage.SymbolScale = .default
  var imageContentMode: UIView.ContentMode = .scaleToFill
  var symbolType: SymbolType = .monochrome
  var tint: UIColor?
  var animationSpec: AnimationSpec?
  var palette = [UIColor]()
  var animated = false
  var variableValue: Double?

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    addSubview(imageView)
  }

  override func layoutSubviews() {
    imageView.frame = bounds
  }

  func reloadSymbol() {
    let image: UIImage?
    
    if let variableValue = variableValue {
      // 传入了 variableValue，使用可变值 API
      image = UIImage(systemName: name, variableValue: min(1.0, max(0.0, variableValue)))
    } else {
      // 没有传入，使用普通 API
      image = UIImage(systemName: name)
    }
    
    guard let image = image else {
      return
    }
    imageView.contentMode = imageContentMode
    imageView.preferredSymbolConfiguration = getSymbolConfig()

    let finalImage: UIImage
    if let tint, symbolType != .hierarchical {
      finalImage = image.withTintColor(tint, renderingMode: .alwaysOriginal)
    } else {
      finalImage = image
    }

    // Effects need to be added last
    if #available(iOS 17.0, tvOS 17.0, *) {
      imageView.removeAllSymbolEffects()
      if animated {
        addSymbolEffects(using: finalImage)
        return
      }
    }

    imageView.image = finalImage
  }

  @available(iOS 17.0, tvOS 17.0, *)
  private func addSymbolEffects(using image: UIImage) {
    if let animationSpec {
      let repeating = animationSpec.repeating ?? false
      var options: SymbolEffectOptions = repeating ? .repeating : .nonRepeating

      if let repeatCount = animationSpec.repeatCount {
        options = options.repeat(abs(repeatCount))
      }

      if let speed = animationSpec.speed {
        options = options.speed(speed)
      }

      if let contentTransition = animationSpec.effect?.toContentTransitionEffect() {
        imageView.setSymbolImage(image, contentTransition: contentTransition, options: options)
        return
      }

      imageView.image = image

      if let variableAnimationSpec = animationSpec.variableAnimationSpec {
        imageView.addSymbolEffect(variableAnimationSpec.toVariableEffect())
        return
      }

      if let animation = animationSpec.effect, let effect = animation.toEffect() {
        effect.add(to: imageView, with: options)
      }
    } else {
      imageView.image = image
    }
  }

  private func getSymbolConfig() -> UIImage.SymbolConfiguration {
    #if os(tvOS)
    var config = UIImage.SymbolConfiguration(pointSize: 18.0, weight: weight, scale: scale)
    #else
    var config = UIImage.SymbolConfiguration(pointSize: UIFont.systemFontSize, weight: weight, scale: scale)
    #endif

    switch symbolType {
    case .monochrome:
      if #available(iOS 16.0, tvOS 16.0, *) {
        config = config.applying(UIImage.SymbolConfiguration.preferringMonochrome())
      }
    case .hierarchical:
      config = config.applying(UIImage.SymbolConfiguration(hierarchicalColor: tint ?? .systemBlue))
    case .palette:
      if palette.count > 1 {
        config = config.applying(UIImage.SymbolConfiguration(paletteColors: palette))
      }
    case .multicolor:
      config = config.applying(UIImage.SymbolConfiguration.preferringMulticolor())
    }

    return config
  }
}
