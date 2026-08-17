import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
extension ImageResource {

    /// The "10_body" asset catalog image resource.
    static let _10Body = ImageResource(name: "10_body", bundle: resourceBundle)

    /// The "10_full" asset catalog image resource.
    static let _10Full = ImageResource(name: "10_full", bundle: resourceBundle)

    /// The "10_left_claw" asset catalog image resource.
    static let _10LeftClaw = ImageResource(name: "10_left_claw", bundle: resourceBundle)

    /// The "10_left_leg" asset catalog image resource.
    static let _10LeftLeg = ImageResource(name: "10_left_leg", bundle: resourceBundle)

    /// The "10_thumb" asset catalog image resource.
    static let _10Thumb = ImageResource(name: "10_thumb", bundle: resourceBundle)

    /// The "1_body_only_2" asset catalog image resource.
    static let _1BodyOnly2 = ImageResource(name: "1_body_only_2", bundle: resourceBundle)

    /// The "1_left_claw_2" asset catalog image resource.
    static let _1LeftClaw2 = ImageResource(name: "1_left_claw_2", bundle: resourceBundle)

    /// The "1_left_legs_2" asset catalog image resource.
    static let _1LeftLegs2 = ImageResource(name: "1_left_legs_2", bundle: resourceBundle)

    /// The "1_main" asset catalog image resource.
    static let _1Main = ImageResource(name: "1_main", bundle: resourceBundle)

    /// The "1_right_legs_2" asset catalog image resource.
    static let _1RightLegs2 = ImageResource(name: "1_right_legs_2", bundle: resourceBundle)

    /// The "1_thumb" asset catalog image resource.
    static let _1Thumb = ImageResource(name: "1_thumb", bundle: resourceBundle)

    /// The "2_body" asset catalog image resource.
    static let _2Body = ImageResource(name: "2_body", bundle: resourceBundle)

    /// The "2_full" asset catalog image resource.
    static let _2Full = ImageResource(name: "2_full", bundle: resourceBundle)

    /// The "2_left_claw" asset catalog image resource.
    static let _2LeftClaw = ImageResource(name: "2_left_claw", bundle: resourceBundle)

    /// The "2_left_leg" asset catalog image resource.
    static let _2LeftLeg = ImageResource(name: "2_left_leg", bundle: resourceBundle)

    /// The "2_thumb" asset catalog image resource.
    static let _2Thumb = ImageResource(name: "2_thumb", bundle: resourceBundle)

    /// The "2x_body" asset catalog image resource.
    static let _2XBody = ImageResource(name: "2x_body", bundle: resourceBundle)

    /// The "2x_left_claw" asset catalog image resource.
    static let _2XLeftClaw = ImageResource(name: "2x_left_claw", bundle: resourceBundle)

    /// The "2x_left_leg" asset catalog image resource.
    static let _2XLeftLeg = ImageResource(name: "2x_left_leg", bundle: resourceBundle)

    /// The "3_body" asset catalog image resource.
    static let _3Body = ImageResource(name: "3_body", bundle: resourceBundle)

    /// The "3_full" asset catalog image resource.
    static let _3Full = ImageResource(name: "3_full", bundle: resourceBundle)

    /// The "3_left_claw" asset catalog image resource.
    static let _3LeftClaw = ImageResource(name: "3_left_claw", bundle: resourceBundle)

    /// The "3_left_leg" asset catalog image resource.
    static let _3LeftLeg = ImageResource(name: "3_left_leg", bundle: resourceBundle)

    /// The "3_thumb" asset catalog image resource.
    static let _3Thumb = ImageResource(name: "3_thumb", bundle: resourceBundle)

    /// The "4_body" asset catalog image resource.
    static let _4Body = ImageResource(name: "4_body", bundle: resourceBundle)

    /// The "4_full" asset catalog image resource.
    static let _4Full = ImageResource(name: "4_full", bundle: resourceBundle)

    /// The "4_left_claw" asset catalog image resource.
    static let _4LeftClaw = ImageResource(name: "4_left_claw", bundle: resourceBundle)

    /// The "4_left_leg" asset catalog image resource.
    static let _4LeftLeg = ImageResource(name: "4_left_leg", bundle: resourceBundle)

    /// The "4_thumb" asset catalog image resource.
    static let _4Thumb = ImageResource(name: "4_thumb", bundle: resourceBundle)

    /// The "5_body" asset catalog image resource.
    static let _5Body = ImageResource(name: "5_body", bundle: resourceBundle)

    /// The "5_full" asset catalog image resource.
    static let _5Full = ImageResource(name: "5_full", bundle: resourceBundle)

    /// The "5_left_claw" asset catalog image resource.
    static let _5LeftClaw = ImageResource(name: "5_left_claw", bundle: resourceBundle)

    /// The "5_left_leg" asset catalog image resource.
    static let _5LeftLeg = ImageResource(name: "5_left_leg", bundle: resourceBundle)

    /// The "5_thumb" asset catalog image resource.
    static let _5Thumb = ImageResource(name: "5_thumb", bundle: resourceBundle)

    /// The "6_body" asset catalog image resource.
    static let _6Body = ImageResource(name: "6_body", bundle: resourceBundle)

    /// The "6_full" asset catalog image resource.
    static let _6Full = ImageResource(name: "6_full", bundle: resourceBundle)

    /// The "6_left_claw" asset catalog image resource.
    static let _6LeftClaw = ImageResource(name: "6_left_claw", bundle: resourceBundle)

    /// The "6_left_leg" asset catalog image resource.
    static let _6LeftLeg = ImageResource(name: "6_left_leg", bundle: resourceBundle)

    /// The "6_thumb" asset catalog image resource.
    static let _6Thumb = ImageResource(name: "6_thumb", bundle: resourceBundle)

    /// The "7_body" asset catalog image resource.
    static let _7Body = ImageResource(name: "7_body", bundle: resourceBundle)

    /// The "7_full" asset catalog image resource.
    static let _7Full = ImageResource(name: "7_full", bundle: resourceBundle)

    /// The "7_left_claw" asset catalog image resource.
    static let _7LeftClaw = ImageResource(name: "7_left_claw", bundle: resourceBundle)

    /// The "7_left_leg" asset catalog image resource.
    static let _7LeftLeg = ImageResource(name: "7_left_leg", bundle: resourceBundle)

    /// The "7_thumb" asset catalog image resource.
    static let _7Thumb = ImageResource(name: "7_thumb", bundle: resourceBundle)

    /// The "8_body" asset catalog image resource.
    static let _8Body = ImageResource(name: "8_body", bundle: resourceBundle)

    /// The "8_full" asset catalog image resource.
    static let _8Full = ImageResource(name: "8_full", bundle: resourceBundle)

    /// The "8_left_claw" asset catalog image resource.
    static let _8LeftClaw = ImageResource(name: "8_left_claw", bundle: resourceBundle)

    /// The "8_left_leg" asset catalog image resource.
    static let _8LeftLeg = ImageResource(name: "8_left_leg", bundle: resourceBundle)

    /// The "8_thumb" asset catalog image resource.
    static let _8Thumb = ImageResource(name: "8_thumb", bundle: resourceBundle)

    /// The "9_body" asset catalog image resource.
    static let _9Body = ImageResource(name: "9_body", bundle: resourceBundle)

    /// The "9_full" asset catalog image resource.
    static let _9Full = ImageResource(name: "9_full", bundle: resourceBundle)

    /// The "9_left_claw" asset catalog image resource.
    static let _9LeftClaw = ImageResource(name: "9_left_claw", bundle: resourceBundle)

    /// The "9_left_leg" asset catalog image resource.
    static let _9LeftLeg = ImageResource(name: "9_left_leg", bundle: resourceBundle)

    /// The "9_thumb" asset catalog image resource.
    static let _9Thumb = ImageResource(name: "9_thumb", bundle: resourceBundle)

    /// The "PromoAppIcon" asset catalog image resource.
    static let promoAppIcon = ImageResource(name: "PromoAppIcon", bundle: resourceBundle)

    /// The "answer_eye_left" asset catalog image resource.
    static let answerEyeLeft = ImageResource(name: "answer_eye_left", bundle: resourceBundle)

    /// The "answer_eye_right" asset catalog image resource.
    static let answerEyeRight = ImageResource(name: "answer_eye_right", bundle: resourceBundle)

    /// The "answer_gold_body" asset catalog image resource.
    static let answerGoldBody = ImageResource(name: "answer_gold_body", bundle: resourceBundle)

    /// The "answer_gold_claw" asset catalog image resource.
    static let answerGoldClaw = ImageResource(name: "answer_gold_claw", bundle: resourceBundle)

    /// The "answer_gold_leg1" asset catalog image resource.
    static let answerGoldLeg1 = ImageResource(name: "answer_gold_leg1", bundle: resourceBundle)

    /// The "answer_gold_leg2" asset catalog image resource.
    static let answerGoldLeg2 = ImageResource(name: "answer_gold_leg2", bundle: resourceBundle)

    /// The "answer_gold_leg3" asset catalog image resource.
    static let answerGoldLeg3 = ImageResource(name: "answer_gold_leg3", bundle: resourceBundle)

    /// The "answer_gold_legs" asset catalog image resource.
    static let answerGoldLegs = ImageResource(name: "answer_gold_legs", bundle: resourceBundle)

    /// The "answer_red_body" asset catalog image resource.
    static let answerRedBody = ImageResource(name: "answer_red_body", bundle: resourceBundle)

    /// The "answer_red_claw" asset catalog image resource.
    static let answerRedClaw = ImageResource(name: "answer_red_claw", bundle: resourceBundle)

    /// The "answer_red_leg1" asset catalog image resource.
    static let answerRedLeg1 = ImageResource(name: "answer_red_leg1", bundle: resourceBundle)

    /// The "answer_red_leg2" asset catalog image resource.
    static let answerRedLeg2 = ImageResource(name: "answer_red_leg2", bundle: resourceBundle)

    /// The "answer_red_leg3" asset catalog image resource.
    static let answerRedLeg3 = ImageResource(name: "answer_red_leg3", bundle: resourceBundle)

    /// The "answer_red_legs" asset catalog image resource.
    static let answerRedLegs = ImageResource(name: "answer_red_legs", bundle: resourceBundle)

    /// The "life_body" asset catalog image resource.
    static let lifeBody = ImageResource(name: "life_body", bundle: resourceBundle)

    /// The "life_left_claw" asset catalog image resource.
    static let lifeLeftClaw = ImageResource(name: "life_left_claw", bundle: resourceBundle)

    /// The "life_left_leg" asset catalog image resource.
    static let lifeLeftLeg = ImageResource(name: "life_left_leg", bundle: resourceBundle)

    /// The "life_leg1" asset catalog image resource.
    static let lifeLeg1 = ImageResource(name: "life_leg1", bundle: resourceBundle)

    /// The "life_leg2" asset catalog image resource.
    static let lifeLeg2 = ImageResource(name: "life_leg2", bundle: resourceBundle)

    /// The "life_leg3" asset catalog image resource.
    static let lifeLeg3 = ImageResource(name: "life_leg3", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "10_body" asset catalog image.
    static var _10Body: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._10Body)
#else
        .init()
#endif
    }

    /// The "10_full" asset catalog image.
    static var _10Full: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._10Full)
#else
        .init()
#endif
    }

    /// The "10_left_claw" asset catalog image.
    static var _10LeftClaw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._10LeftClaw)
#else
        .init()
#endif
    }

    /// The "10_left_leg" asset catalog image.
    static var _10LeftLeg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._10LeftLeg)
#else
        .init()
#endif
    }

    /// The "10_thumb" asset catalog image.
    static var _10Thumb: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._10Thumb)
#else
        .init()
#endif
    }

    /// The "1_body_only_2" asset catalog image.
    static var _1BodyOnly2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._1BodyOnly2)
#else
        .init()
#endif
    }

    /// The "1_left_claw_2" asset catalog image.
    static var _1LeftClaw2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._1LeftClaw2)
#else
        .init()
#endif
    }

    /// The "1_left_legs_2" asset catalog image.
    static var _1LeftLegs2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._1LeftLegs2)
#else
        .init()
#endif
    }

    /// The "1_main" asset catalog image.
    static var _1Main: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._1Main)
#else
        .init()
#endif
    }

    /// The "1_right_legs_2" asset catalog image.
    static var _1RightLegs2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._1RightLegs2)
#else
        .init()
#endif
    }

    /// The "1_thumb" asset catalog image.
    static var _1Thumb: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._1Thumb)
#else
        .init()
#endif
    }

    /// The "2_body" asset catalog image.
    static var _2Body: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._2Body)
#else
        .init()
#endif
    }

    /// The "2_full" asset catalog image.
    static var _2Full: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._2Full)
#else
        .init()
#endif
    }

    /// The "2_left_claw" asset catalog image.
    static var _2LeftClaw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._2LeftClaw)
#else
        .init()
#endif
    }

    /// The "2_left_leg" asset catalog image.
    static var _2LeftLeg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._2LeftLeg)
#else
        .init()
#endif
    }

    /// The "2_thumb" asset catalog image.
    static var _2Thumb: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._2Thumb)
#else
        .init()
#endif
    }

    /// The "2x_body" asset catalog image.
    static var _2XBody: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._2XBody)
#else
        .init()
#endif
    }

    /// The "2x_left_claw" asset catalog image.
    static var _2XLeftClaw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._2XLeftClaw)
#else
        .init()
#endif
    }

    /// The "2x_left_leg" asset catalog image.
    static var _2XLeftLeg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._2XLeftLeg)
#else
        .init()
#endif
    }

    /// The "3_body" asset catalog image.
    static var _3Body: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._3Body)
#else
        .init()
#endif
    }

    /// The "3_full" asset catalog image.
    static var _3Full: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._3Full)
#else
        .init()
#endif
    }

    /// The "3_left_claw" asset catalog image.
    static var _3LeftClaw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._3LeftClaw)
#else
        .init()
#endif
    }

    /// The "3_left_leg" asset catalog image.
    static var _3LeftLeg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._3LeftLeg)
#else
        .init()
#endif
    }

    /// The "3_thumb" asset catalog image.
    static var _3Thumb: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._3Thumb)
#else
        .init()
#endif
    }

    /// The "4_body" asset catalog image.
    static var _4Body: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._4Body)
#else
        .init()
#endif
    }

    /// The "4_full" asset catalog image.
    static var _4Full: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._4Full)
#else
        .init()
#endif
    }

    /// The "4_left_claw" asset catalog image.
    static var _4LeftClaw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._4LeftClaw)
#else
        .init()
#endif
    }

    /// The "4_left_leg" asset catalog image.
    static var _4LeftLeg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._4LeftLeg)
#else
        .init()
#endif
    }

    /// The "4_thumb" asset catalog image.
    static var _4Thumb: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._4Thumb)
#else
        .init()
#endif
    }

    /// The "5_body" asset catalog image.
    static var _5Body: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._5Body)
#else
        .init()
#endif
    }

    /// The "5_full" asset catalog image.
    static var _5Full: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._5Full)
#else
        .init()
#endif
    }

    /// The "5_left_claw" asset catalog image.
    static var _5LeftClaw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._5LeftClaw)
#else
        .init()
#endif
    }

    /// The "5_left_leg" asset catalog image.
    static var _5LeftLeg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._5LeftLeg)
#else
        .init()
#endif
    }

    /// The "5_thumb" asset catalog image.
    static var _5Thumb: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._5Thumb)
#else
        .init()
#endif
    }

    /// The "6_body" asset catalog image.
    static var _6Body: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._6Body)
#else
        .init()
#endif
    }

    /// The "6_full" asset catalog image.
    static var _6Full: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._6Full)
#else
        .init()
#endif
    }

    /// The "6_left_claw" asset catalog image.
    static var _6LeftClaw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._6LeftClaw)
#else
        .init()
#endif
    }

    /// The "6_left_leg" asset catalog image.
    static var _6LeftLeg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._6LeftLeg)
#else
        .init()
#endif
    }

    /// The "6_thumb" asset catalog image.
    static var _6Thumb: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._6Thumb)
#else
        .init()
#endif
    }

    /// The "7_body" asset catalog image.
    static var _7Body: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._7Body)
#else
        .init()
#endif
    }

    /// The "7_full" asset catalog image.
    static var _7Full: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._7Full)
#else
        .init()
#endif
    }

    /// The "7_left_claw" asset catalog image.
    static var _7LeftClaw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._7LeftClaw)
#else
        .init()
#endif
    }

    /// The "7_left_leg" asset catalog image.
    static var _7LeftLeg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._7LeftLeg)
#else
        .init()
#endif
    }

    /// The "7_thumb" asset catalog image.
    static var _7Thumb: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._7Thumb)
#else
        .init()
#endif
    }

    /// The "8_body" asset catalog image.
    static var _8Body: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._8Body)
#else
        .init()
#endif
    }

    /// The "8_full" asset catalog image.
    static var _8Full: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._8Full)
#else
        .init()
#endif
    }

    /// The "8_left_claw" asset catalog image.
    static var _8LeftClaw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._8LeftClaw)
#else
        .init()
#endif
    }

    /// The "8_left_leg" asset catalog image.
    static var _8LeftLeg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._8LeftLeg)
#else
        .init()
#endif
    }

    /// The "8_thumb" asset catalog image.
    static var _8Thumb: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._8Thumb)
#else
        .init()
#endif
    }

    /// The "9_body" asset catalog image.
    static var _9Body: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._9Body)
#else
        .init()
#endif
    }

    /// The "9_full" asset catalog image.
    static var _9Full: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._9Full)
#else
        .init()
#endif
    }

    /// The "9_left_claw" asset catalog image.
    static var _9LeftClaw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._9LeftClaw)
#else
        .init()
#endif
    }

    /// The "9_left_leg" asset catalog image.
    static var _9LeftLeg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._9LeftLeg)
#else
        .init()
#endif
    }

    /// The "9_thumb" asset catalog image.
    static var _9Thumb: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._9Thumb)
#else
        .init()
#endif
    }

    /// The "PromoAppIcon" asset catalog image.
    static var promoAppIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .promoAppIcon)
#else
        .init()
#endif
    }

    /// The "answer_eye_left" asset catalog image.
    static var answerEyeLeft: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerEyeLeft)
#else
        .init()
#endif
    }

    /// The "answer_eye_right" asset catalog image.
    static var answerEyeRight: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerEyeRight)
#else
        .init()
#endif
    }

    /// The "answer_gold_body" asset catalog image.
    static var answerGoldBody: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerGoldBody)
#else
        .init()
#endif
    }

    /// The "answer_gold_claw" asset catalog image.
    static var answerGoldClaw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerGoldClaw)
#else
        .init()
#endif
    }

    /// The "answer_gold_leg1" asset catalog image.
    static var answerGoldLeg1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerGoldLeg1)
#else
        .init()
#endif
    }

    /// The "answer_gold_leg2" asset catalog image.
    static var answerGoldLeg2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerGoldLeg2)
#else
        .init()
#endif
    }

    /// The "answer_gold_leg3" asset catalog image.
    static var answerGoldLeg3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerGoldLeg3)
#else
        .init()
#endif
    }

    /// The "answer_gold_legs" asset catalog image.
    static var answerGoldLegs: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerGoldLegs)
#else
        .init()
#endif
    }

    /// The "answer_red_body" asset catalog image.
    static var answerRedBody: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerRedBody)
#else
        .init()
#endif
    }

    /// The "answer_red_claw" asset catalog image.
    static var answerRedClaw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerRedClaw)
#else
        .init()
#endif
    }

    /// The "answer_red_leg1" asset catalog image.
    static var answerRedLeg1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerRedLeg1)
#else
        .init()
#endif
    }

    /// The "answer_red_leg2" asset catalog image.
    static var answerRedLeg2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerRedLeg2)
#else
        .init()
#endif
    }

    /// The "answer_red_leg3" asset catalog image.
    static var answerRedLeg3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerRedLeg3)
#else
        .init()
#endif
    }

    /// The "answer_red_legs" asset catalog image.
    static var answerRedLegs: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answerRedLegs)
#else
        .init()
#endif
    }

    /// The "life_body" asset catalog image.
    static var lifeBody: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .lifeBody)
#else
        .init()
#endif
    }

    /// The "life_left_claw" asset catalog image.
    static var lifeLeftClaw: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .lifeLeftClaw)
#else
        .init()
#endif
    }

    /// The "life_left_leg" asset catalog image.
    static var lifeLeftLeg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .lifeLeftLeg)
#else
        .init()
#endif
    }

    /// The "life_leg1" asset catalog image.
    static var lifeLeg1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .lifeLeg1)
#else
        .init()
#endif
    }

    /// The "life_leg2" asset catalog image.
    static var lifeLeg2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .lifeLeg2)
#else
        .init()
#endif
    }

    /// The "life_leg3" asset catalog image.
    static var lifeLeg3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .lifeLeg3)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "10_body" asset catalog image.
    static var _10Body: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._10Body)
#else
        .init()
#endif
    }

    /// The "10_full" asset catalog image.
    static var _10Full: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._10Full)
#else
        .init()
#endif
    }

    /// The "10_left_claw" asset catalog image.
    static var _10LeftClaw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._10LeftClaw)
#else
        .init()
#endif
    }

    /// The "10_left_leg" asset catalog image.
    static var _10LeftLeg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._10LeftLeg)
#else
        .init()
#endif
    }

    /// The "10_thumb" asset catalog image.
    static var _10Thumb: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._10Thumb)
#else
        .init()
#endif
    }

    /// The "1_body_only_2" asset catalog image.
    static var _1BodyOnly2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._1BodyOnly2)
#else
        .init()
#endif
    }

    /// The "1_left_claw_2" asset catalog image.
    static var _1LeftClaw2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._1LeftClaw2)
#else
        .init()
#endif
    }

    /// The "1_left_legs_2" asset catalog image.
    static var _1LeftLegs2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._1LeftLegs2)
#else
        .init()
#endif
    }

    /// The "1_main" asset catalog image.
    static var _1Main: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._1Main)
#else
        .init()
#endif
    }

    /// The "1_right_legs_2" asset catalog image.
    static var _1RightLegs2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._1RightLegs2)
#else
        .init()
#endif
    }

    /// The "1_thumb" asset catalog image.
    static var _1Thumb: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._1Thumb)
#else
        .init()
#endif
    }

    /// The "2_body" asset catalog image.
    static var _2Body: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._2Body)
#else
        .init()
#endif
    }

    /// The "2_full" asset catalog image.
    static var _2Full: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._2Full)
#else
        .init()
#endif
    }

    /// The "2_left_claw" asset catalog image.
    static var _2LeftClaw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._2LeftClaw)
#else
        .init()
#endif
    }

    /// The "2_left_leg" asset catalog image.
    static var _2LeftLeg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._2LeftLeg)
#else
        .init()
#endif
    }

    /// The "2_thumb" asset catalog image.
    static var _2Thumb: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._2Thumb)
#else
        .init()
#endif
    }

    /// The "2x_body" asset catalog image.
    static var _2XBody: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._2XBody)
#else
        .init()
#endif
    }

    /// The "2x_left_claw" asset catalog image.
    static var _2XLeftClaw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._2XLeftClaw)
#else
        .init()
#endif
    }

    /// The "2x_left_leg" asset catalog image.
    static var _2XLeftLeg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._2XLeftLeg)
#else
        .init()
#endif
    }

    /// The "3_body" asset catalog image.
    static var _3Body: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._3Body)
#else
        .init()
#endif
    }

    /// The "3_full" asset catalog image.
    static var _3Full: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._3Full)
#else
        .init()
#endif
    }

    /// The "3_left_claw" asset catalog image.
    static var _3LeftClaw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._3LeftClaw)
#else
        .init()
#endif
    }

    /// The "3_left_leg" asset catalog image.
    static var _3LeftLeg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._3LeftLeg)
#else
        .init()
#endif
    }

    /// The "3_thumb" asset catalog image.
    static var _3Thumb: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._3Thumb)
#else
        .init()
#endif
    }

    /// The "4_body" asset catalog image.
    static var _4Body: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._4Body)
#else
        .init()
#endif
    }

    /// The "4_full" asset catalog image.
    static var _4Full: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._4Full)
#else
        .init()
#endif
    }

    /// The "4_left_claw" asset catalog image.
    static var _4LeftClaw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._4LeftClaw)
#else
        .init()
#endif
    }

    /// The "4_left_leg" asset catalog image.
    static var _4LeftLeg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._4LeftLeg)
#else
        .init()
#endif
    }

    /// The "4_thumb" asset catalog image.
    static var _4Thumb: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._4Thumb)
#else
        .init()
#endif
    }

    /// The "5_body" asset catalog image.
    static var _5Body: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._5Body)
#else
        .init()
#endif
    }

    /// The "5_full" asset catalog image.
    static var _5Full: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._5Full)
#else
        .init()
#endif
    }

    /// The "5_left_claw" asset catalog image.
    static var _5LeftClaw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._5LeftClaw)
#else
        .init()
#endif
    }

    /// The "5_left_leg" asset catalog image.
    static var _5LeftLeg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._5LeftLeg)
#else
        .init()
#endif
    }

    /// The "5_thumb" asset catalog image.
    static var _5Thumb: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._5Thumb)
#else
        .init()
#endif
    }

    /// The "6_body" asset catalog image.
    static var _6Body: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._6Body)
#else
        .init()
#endif
    }

    /// The "6_full" asset catalog image.
    static var _6Full: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._6Full)
#else
        .init()
#endif
    }

    /// The "6_left_claw" asset catalog image.
    static var _6LeftClaw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._6LeftClaw)
#else
        .init()
#endif
    }

    /// The "6_left_leg" asset catalog image.
    static var _6LeftLeg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._6LeftLeg)
#else
        .init()
#endif
    }

    /// The "6_thumb" asset catalog image.
    static var _6Thumb: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._6Thumb)
#else
        .init()
#endif
    }

    /// The "7_body" asset catalog image.
    static var _7Body: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._7Body)
#else
        .init()
#endif
    }

    /// The "7_full" asset catalog image.
    static var _7Full: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._7Full)
#else
        .init()
#endif
    }

    /// The "7_left_claw" asset catalog image.
    static var _7LeftClaw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._7LeftClaw)
#else
        .init()
#endif
    }

    /// The "7_left_leg" asset catalog image.
    static var _7LeftLeg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._7LeftLeg)
#else
        .init()
#endif
    }

    /// The "7_thumb" asset catalog image.
    static var _7Thumb: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._7Thumb)
#else
        .init()
#endif
    }

    /// The "8_body" asset catalog image.
    static var _8Body: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._8Body)
#else
        .init()
#endif
    }

    /// The "8_full" asset catalog image.
    static var _8Full: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._8Full)
#else
        .init()
#endif
    }

    /// The "8_left_claw" asset catalog image.
    static var _8LeftClaw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._8LeftClaw)
#else
        .init()
#endif
    }

    /// The "8_left_leg" asset catalog image.
    static var _8LeftLeg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._8LeftLeg)
#else
        .init()
#endif
    }

    /// The "8_thumb" asset catalog image.
    static var _8Thumb: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._8Thumb)
#else
        .init()
#endif
    }

    /// The "9_body" asset catalog image.
    static var _9Body: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._9Body)
#else
        .init()
#endif
    }

    /// The "9_full" asset catalog image.
    static var _9Full: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._9Full)
#else
        .init()
#endif
    }

    /// The "9_left_claw" asset catalog image.
    static var _9LeftClaw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._9LeftClaw)
#else
        .init()
#endif
    }

    /// The "9_left_leg" asset catalog image.
    static var _9LeftLeg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._9LeftLeg)
#else
        .init()
#endif
    }

    /// The "9_thumb" asset catalog image.
    static var _9Thumb: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._9Thumb)
#else
        .init()
#endif
    }

    /// The "PromoAppIcon" asset catalog image.
    static var promoAppIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .promoAppIcon)
#else
        .init()
#endif
    }

    /// The "answer_eye_left" asset catalog image.
    static var answerEyeLeft: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerEyeLeft)
#else
        .init()
#endif
    }

    /// The "answer_eye_right" asset catalog image.
    static var answerEyeRight: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerEyeRight)
#else
        .init()
#endif
    }

    /// The "answer_gold_body" asset catalog image.
    static var answerGoldBody: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerGoldBody)
#else
        .init()
#endif
    }

    /// The "answer_gold_claw" asset catalog image.
    static var answerGoldClaw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerGoldClaw)
#else
        .init()
#endif
    }

    /// The "answer_gold_leg1" asset catalog image.
    static var answerGoldLeg1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerGoldLeg1)
#else
        .init()
#endif
    }

    /// The "answer_gold_leg2" asset catalog image.
    static var answerGoldLeg2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerGoldLeg2)
#else
        .init()
#endif
    }

    /// The "answer_gold_leg3" asset catalog image.
    static var answerGoldLeg3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerGoldLeg3)
#else
        .init()
#endif
    }

    /// The "answer_gold_legs" asset catalog image.
    static var answerGoldLegs: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerGoldLegs)
#else
        .init()
#endif
    }

    /// The "answer_red_body" asset catalog image.
    static var answerRedBody: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerRedBody)
#else
        .init()
#endif
    }

    /// The "answer_red_claw" asset catalog image.
    static var answerRedClaw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerRedClaw)
#else
        .init()
#endif
    }

    /// The "answer_red_leg1" asset catalog image.
    static var answerRedLeg1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerRedLeg1)
#else
        .init()
#endif
    }

    /// The "answer_red_leg2" asset catalog image.
    static var answerRedLeg2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerRedLeg2)
#else
        .init()
#endif
    }

    /// The "answer_red_leg3" asset catalog image.
    static var answerRedLeg3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerRedLeg3)
#else
        .init()
#endif
    }

    /// The "answer_red_legs" asset catalog image.
    static var answerRedLegs: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .answerRedLegs)
#else
        .init()
#endif
    }

    /// The "life_body" asset catalog image.
    static var lifeBody: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .lifeBody)
#else
        .init()
#endif
    }

    /// The "life_left_claw" asset catalog image.
    static var lifeLeftClaw: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .lifeLeftClaw)
#else
        .init()
#endif
    }

    /// The "life_left_leg" asset catalog image.
    static var lifeLeftLeg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .lifeLeftLeg)
#else
        .init()
#endif
    }

    /// The "life_leg1" asset catalog image.
    static var lifeLeg1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .lifeLeg1)
#else
        .init()
#endif
    }

    /// The "life_leg2" asset catalog image.
    static var lifeLeg2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .lifeLeg2)
#else
        .init()
#endif
    }

    /// The "life_leg3" asset catalog image.
    static var lifeLeg3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .lifeLeg3)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

// MARK: - Backwards Deployment Support -

/// A color resource.
struct ColorResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog color resource name.
    fileprivate let name: Swift.String

    /// An asset catalog color resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize a `ColorResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

/// An image resource.
struct ImageResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog image resource name.
    fileprivate let name: Swift.String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize an `ImageResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// Initialize a `NSColor` with a color resource.
    convenience init(resource: ColorResource) {
        self.init(named: NSColor.Name(resource.name), bundle: resource.bundle)!
    }

}

protocol _ACResourceInitProtocol {}
extension AppKit.NSImage: _ACResourceInitProtocol {}

@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension _ACResourceInitProtocol {

    /// Initialize a `NSImage` with an image resource.
    init(resource: ImageResource) {
        self = resource.bundle.image(forResource: NSImage.Name(resource.name))! as! Self
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: ColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}

@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: ImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {

    /// Initialize an `Image` with an image resource.
    init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif