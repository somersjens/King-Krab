//
//  KingCrabRig.swift
//  King Krab
//
//  The King, drawn from his own limbs rather than from one flat picture.
//
//  The five parts are exported on a single square canvas and are registered to
//  each other pixel for pixel, so stacking them at the same frame — limbs down
//  first, body last — rebuilds the character exactly as drawn. Nothing here
//  scales or nudges a part: the artwork's own placement *is* the rest pose.
//
//  Each limb tapers into a connector that runs on past the joint and disappears
//  behind the shell. That buried tail is what buys the movement: a limb turns
//  around the far end of its own connector, so the end itself never moves and
//  the shaft still emerges from behind the body however far the limb has swung.
//  Measured on the artwork, the claws hold together past ±50°, well beyond
//  anything the animation asks for.
//
//  Only the crab is cut into parts. Every other character still draws from its
//  one square portrait, so `CharacterRig.rig(for:)` returning nil is a normal,
//  fully supported case rather than a missing asset.
//

import SwiftUI

// MARK: - The parts

/// One limb: its image and the joint it turns around.
struct CharacterRigLimb {
    let imageName: String
    /// The joint, in the artwork square's own coordinates. Measured from the
    /// asset: the far end of the connector, where it is deepest under the shell.
    let joint: UnitPoint

    var image: Image { Image(imageName) }
}

/// A character cut into a body and four limbs.
struct CharacterRig {
    let body: String
    let leftClaw: CharacterRigLimb
    let rightClaw: CharacterRigLimb
    let leftLegs: CharacterRigLimb
    let rightLegs: CharacterRigLimb
    /// Where each pincer sits at rest, in the same square. The thrown sand
    /// leaves from here, so it comes out of the claw rather than out of the
    /// middle of the animal.
    let leftClawTip: UnitPoint
    let rightClawTip: UnitPoint
    /// Where the feet come down, as a fraction of the square from its top. The
    /// legs hang past the bottom of the artwork once they are seated, so this
    /// — not the frame's own edge — is the line he stands on: his shadow, his
    /// lean and his squash all work from it.
    let groundLine: CGFloat

    var bodyImage: Image { Image(body) }

    /// How far out of his middle a pincer sits, averaged over the two claws.
    /// The arena throws sand from here, so the handful leaves the claw that
    /// swung rather than the middle of the animal.
    var clawReach: CGSize {
        CGSize(width: (abs(leftClawTip.x - 0.5) + abs(rightClawTip.x - 0.5)) / 2,
               height: ((leftClawTip.y - 0.5) + (rightClawTip.y - 0.5)) / 2)
    }

    /// The rig for a character, or nil for one that is drawn from its portrait.
    static func rig(for characterID: String) -> CharacterRig? {
        characterID == "crab" ? crab : nil
    }

    /// Every value here is measured off the exported alpha, as a fraction of
    /// the 1339-point square the five parts share. Each joint is the deep end
    /// of that limb's connector; the tips are the pincers; the ground line is
    /// the lowest foot.
    private static let crab = CharacterRig(
        body: "1_body_only_2",
        leftClaw: CharacterRigLimb(imageName: "1_left_claw_2",
                                   joint: UnitPoint(x: 0.377, y: 0.587)),
        rightClaw: CharacterRigLimb(imageName: "1_right_claw_2",
                                    joint: UnitPoint(x: 0.622, y: 0.596)),
        leftLegs: CharacterRigLimb(imageName: "1_left_legs_2",
                                   joint: UnitPoint(x: 0.415, y: 0.630)),
        rightLegs: CharacterRigLimb(imageName: "1_right_legs_2",
                                    joint: UnitPoint(x: 0.610, y: 0.631)),
        leftClawTip: UnitPoint(x: 0.073, y: 0.372),
        rightClawTip: UnitPoint(x: 0.925, y: 0.381),
        groundLine: 0.866
    )
}

// MARK: - The pose

/// What the rig is doing this frame. Everything the King can do — breathing,
/// scuttling on, throwing sand, hopping, running off — is expressed as one of
/// these, so the view itself holds no state and no animation of its own.
struct KingRigPose {
    /// Whole-body tilt, degrees clockwise.
    var lean: Double = 0
    /// Vertical bob, as a share of the King's own size.
    var rise: CGFloat = 0
    /// Above 1 he is stretched tall, below 1 squashed wide. Volume is kept.
    var stretch: CGFloat = 1
    var leftClaw: Double = 0
    var rightClaw: Double = 0
    var leftLegs: Double = 0
    var rightLegs: Double = 0

    /// The resting pose: a slow breath and legs that shift their weight.
    /// `effort` lifts the same gait into a scuttle without ever changing its
    /// rate mid-stride, which is what keeps a walk-on from snapping.
    static func idle(clock: Double, stride: Double, effort: Double) -> KingRigPose {
        let swing = sin(stride)
        let amount = 2.8 + 13 * effort
        return KingRigPose(
            lean: sin(clock * 1.4) * 1.6 + swing * 4.5 * effort,
            rise: CGFloat(abs(sin(stride))) * CGFloat(0.034 * effort),
            stretch: 1 + CGFloat(sin(clock * 1.9)) * 0.012,
            // The claws ride the body rather than hanging off it, so they lag
            // the stride a quarter turn.
            leftClaw: sin(clock * 1.1) * 3.2 + sin(stride - 0.8) * 7 * effort,
            rightClaw: -sin(clock * 1.1 + 0.9) * 3.2 - sin(stride - 0.8) * 7 * effort,
            // Opposite sides carry the weight in turn: that alternation is the
            // whole of what makes a row of legs read as walking.
            leftLegs: swing * amount,
            rightLegs: -swing * amount
        )
    }
}

// MARK: - The view

/// Draws a rigged character. Limbs go down first and the body last, so every
/// joint is covered by the shell however far its limb has turned.
struct RiggedCharacterView: View {
    let rig: CharacterRig
    let pose: KingRigPose
    let size: CGFloat

    var body: some View {
        ZStack {
            limb(rig.leftLegs, degrees: pose.leftLegs)
            limb(rig.rightLegs, degrees: pose.rightLegs)
            limb(rig.leftClaw, degrees: pose.leftClaw)
            limb(rig.rightClaw, degrees: pose.rightClaw)
            rig.bodyImage
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
        .frame(width: size, height: size)
        // Squashing and stretching around the feet rather than the middle is
        // what makes a landing land: he compresses onto the sand, not into it.
        .scaleEffect(x: 1 / pose.stretch, y: pose.stretch, anchor: ground)
        .rotationEffect(.degrees(pose.lean), anchor: ground)
        .offset(y: -size * pose.rise)
    }

    /// The line his feet come down on, which is what all of him pivots around.
    private var ground: UnitPoint { UnitPoint(x: 0.5, y: rig.groundLine) }

    private func limb(_ limb: CharacterRigLimb, degrees: Double) -> some View {
        limb.image
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .rotationEffect(.degrees(degrees), anchor: limb.joint)
    }
}
