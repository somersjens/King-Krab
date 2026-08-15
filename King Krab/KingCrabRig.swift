//
//  KingCrabRig.swift
//  King Krab
//
//  Every character, drawn from their own limbs rather than from one flat
//  picture.
//
//  The parts of a character are exported on a single square canvas and are
//  registered to each other pixel for pixel, so stacking them at the same frame
//  — limbs down first, body last — rebuilds the character exactly as drawn.
//  Nothing here scales or nudges a part: the artwork's own placement *is* the
//  rest pose.
//
//  Each limb tapers into a connector that runs on past the joint and disappears
//  behind the shell. That buried tail is what buys the movement: a limb turns
//  around the far end of its own connector, so the end itself never moves and
//  the shaft still emerges from behind the body however far the limb has swung.
//
//  The two sides of a limb are the same drawing, so all but the King's own legs
//  ship once and the other side is that picture mirrored. `nudge` is the only
//  thing separating the two: the shift that puts the mirrored copy back where
//  its own export sat, which is how a deliberately lopsided pose survives being
//  drawn from half the artwork.
//
//  Every number below is measured off the exported alpha as a share of the
//  square, by Tools/build_rigs.py: each joint is the deep end of that limb's
//  connector, the tips are the pincers, and the ground line is the lowest foot.
//  The parts are also moved as a set until the assembled animal sits in the
//  middle of its square, so all ten stand in the same place inside their frame.
//

import SwiftUI

// MARK: - The parts

/// One limb: its image, the joint it turns around, and how it is laid down.
struct CharacterRigLimb {
    let imageName: String
    /// The joint, in the artwork square's own coordinates. Measured from the
    /// asset: the far end of the connector, where it is deepest under the shell.
    let joint: UnitPoint
    /// True when this side reuses the other side's drawing, mirrored across the
    /// middle of the square.
    var flipped: Bool = false
    /// Where that mirrored copy has to land, as a share of the square. It is
    /// zero whenever the artwork is symmetrical about the exact middle.
    var nudge: CGSize = .zero

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
    /// Non-zero for the two characters who hold their arms *across* their own
    /// ears rather than behind them. Those claws are laid down twice: once
    /// under the body, which is what buries the connector, and again over it
    /// with this much cut away around the joint. The cut is a circle centred on
    /// the joint, so it does not move when the claw swings, and it is kept
    /// inside the body's own outline, so the seam is never on screen.
    let clawFrontRadius: CGFloat

    var bodyImage: Image { Image(body) }

    /// How far out of his middle a pincer sits, averaged over the two claws.
    /// The arena throws sand from here, so the handful leaves the claw that
    /// swung rather than the middle of the animal.
    var clawReach: CGSize {
        CGSize(width: (abs(leftClawTip.x - 0.5) + abs(rightClawTip.x - 0.5)) / 2,
               height: ((leftClawTip.y - 0.5) + (rightClawTip.y - 0.5)) / 2)
    }

    /// The rig for a character. Every character in the catalog has one, so the
    /// arena animates all ten the same way.
    static func rig(for characterID: String) -> CharacterRig? {
        all[characterID]
    }

    private static let all: [String: CharacterRig] = [
        "crab": CharacterRig(
            body: "1_body_only_2",
            leftClaw: CharacterRigLimb(imageName: "1_left_claw_2",
                                       joint: UnitPoint(x: 0.3784, y: 0.6052)),
            rightClaw: CharacterRigLimb(imageName: "1_left_claw_2",
                                        joint: UnitPoint(x: 0.6201, y: 0.6142),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0007, height: 0.009)),
            leftLegs: CharacterRigLimb(imageName: "1_left_legs_2",
                                       joint: UnitPoint(x: 0.4094, y: 0.6465)),
            rightLegs: CharacterRigLimb(imageName: "1_right_legs_2",
                                        joint: UnitPoint(x: 0.6099, y: 0.6491)),
            leftClawTip: UnitPoint(x: 0.058, y: 0.3412),
            rightClawTip: UnitPoint(x: 0.9405, y: 0.3502),
            groundLine: 0.8842,
            clawFrontRadius: 0.0,),
        "elephant": CharacterRig(
            body: "2_body",
            leftClaw: CharacterRigLimb(imageName: "2_left_claw",
                                       joint: UnitPoint(x: 0.3636, y: 0.597)),
            rightClaw: CharacterRigLimb(imageName: "2_left_claw",
                                        joint: UnitPoint(x: 0.6349, y: 0.5787),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0092, height: -0.0183)),
            leftLegs: CharacterRigLimb(imageName: "2_left_leg",
                                       joint: UnitPoint(x: 0.379, y: 0.65)),
            rightLegs: CharacterRigLimb(imageName: "2_left_leg",
                                        joint: UnitPoint(x: 0.6243, y: 0.6342),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0092, height: -0.0183)),
            leftClawTip: UnitPoint(x: 0.0909, y: 0.3602),
            rightClawTip: UnitPoint(x: 0.9076, y: 0.3419),
            groundLine: 0.8612,
            clawFrontRadius: 0.0249,),
        "bear": CharacterRig(
            body: "3_body",
            leftClaw: CharacterRigLimb(imageName: "3_left_claw",
                                       joint: UnitPoint(x: 0.3618, y: 0.5823)),
            rightClaw: CharacterRigLimb(imageName: "3_left_claw",
                                        joint: UnitPoint(x: 0.6374, y: 0.5823),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0206, height: 0.0)),
            leftLegs: CharacterRigLimb(imageName: "3_left_leg",
                                       joint: UnitPoint(x: 0.3696, y: 0.6411)),
            rightLegs: CharacterRigLimb(imageName: "3_left_leg",
                                        joint: UnitPoint(x: 0.6264, y: 0.6408),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0206, height: 0.0)),
            leftClawTip: UnitPoint(x: 0.0646, y: 0.3282),
            rightClawTip: UnitPoint(x: 0.9346, y: 0.3282),
            groundLine: 0.8581,
            clawFrontRadius: 0.0,),
        "fox": CharacterRig(
            body: "4_body",
            leftClaw: CharacterRigLimb(imageName: "4_left_claw",
                                       joint: UnitPoint(x: 0.3599, y: 0.6118)),
            rightClaw: CharacterRigLimb(imageName: "4_left_claw",
                                        joint: UnitPoint(x: 0.6394, y: 0.6118),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0023, height: 0.0)),
            leftLegs: CharacterRigLimb(imageName: "4_left_leg",
                                       joint: UnitPoint(x: 0.3665, y: 0.6692)),
            rightLegs: CharacterRigLimb(imageName: "4_left_leg",
                                        joint: UnitPoint(x: 0.6321, y: 0.6692),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0023, height: 0.0)),
            leftClawTip: UnitPoint(x: 0.0692, y: 0.3607),
            rightClawTip: UnitPoint(x: 0.93, y: 0.3607),
            groundLine: 0.8955,
            clawFrontRadius: 0.0,),
        "frog": CharacterRig(
            body: "5_body",
            leftClaw: CharacterRigLimb(imageName: "5_left_claw",
                                       joint: UnitPoint(x: 0.372, y: 0.5586)),
            rightClaw: CharacterRigLimb(imageName: "5_left_claw",
                                        joint: UnitPoint(x: 0.6273, y: 0.5571),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0008, height: -0.0015)),
            leftLegs: CharacterRigLimb(imageName: "5_left_leg",
                                       joint: UnitPoint(x: 0.3832, y: 0.6448)),
            rightLegs: CharacterRigLimb(imageName: "5_left_leg",
                                        joint: UnitPoint(x: 0.6163, y: 0.6434),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0008, height: -0.0015)),
            leftClawTip: UnitPoint(x: 0.0657, y: 0.287),
            rightClawTip: UnitPoint(x: 0.9335, y: 0.2855),
            groundLine: 0.8688,
            clawFrontRadius: 0.0,),
        "penguin": CharacterRig(
            body: "6_body",
            leftClaw: CharacterRigLimb(imageName: "6_left_claw",
                                       joint: UnitPoint(x: 0.3453, y: 0.5771)),
            rightClaw: CharacterRigLimb(imageName: "6_left_claw",
                                        joint: UnitPoint(x: 0.654, y: 0.5771),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0175, height: 0.0)),
            leftLegs: CharacterRigLimb(imageName: "6_left_leg",
                                       joint: UnitPoint(x: 0.3638, y: 0.6488)),
            rightLegs: CharacterRigLimb(imageName: "6_left_leg",
                                        joint: UnitPoint(x: 0.6359, y: 0.6488),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0175, height: 0.0)),
            leftClawTip: UnitPoint(x: 0.0697, y: 0.3115),
            rightClawTip: UnitPoint(x: 0.9295, y: 0.3115),
            groundLine: 0.8802,
            clawFrontRadius: 0.0,),
        "bunny": CharacterRig(
            body: "7_body",
            leftClaw: CharacterRigLimb(imageName: "7_left_claw",
                                       joint: UnitPoint(x: 0.3623, y: 0.6488)),
            rightClaw: CharacterRigLimb(imageName: "7_left_claw",
                                        joint: UnitPoint(x: 0.6362, y: 0.6488),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0061, height: 0.0)),
            leftLegs: CharacterRigLimb(imageName: "7_left_leg",
                                       joint: UnitPoint(x: 0.3797, y: 0.7237)),
            rightLegs: CharacterRigLimb(imageName: "7_left_leg",
                                        joint: UnitPoint(x: 0.6201, y: 0.7237),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0061, height: 0.0)),
            leftClawTip: UnitPoint(x: 0.0584, y: 0.3948),
            rightClawTip: UnitPoint(x: 0.9401, y: 0.3948),
            groundLine: 0.9458,
            clawFrontRadius: 0.0,),
        "dog": CharacterRig(
            body: "8_body",
            leftClaw: CharacterRigLimb(imageName: "8_left_claw",
                                       joint: UnitPoint(x: 0.3461, y: 0.5887)),
            rightClaw: CharacterRigLimb(imageName: "8_left_claw",
                                        joint: UnitPoint(x: 0.6524, y: 0.5887),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0092, height: 0.0)),
            leftLegs: CharacterRigLimb(imageName: "8_left_leg",
                                       joint: UnitPoint(x: 0.3744, y: 0.6639)),
            rightLegs: CharacterRigLimb(imageName: "8_left_leg",
                                        joint: UnitPoint(x: 0.6234, y: 0.6638),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0092, height: 0.0)),
            leftClawTip: UnitPoint(x: 0.1052, y: 0.3604),
            rightClawTip: UnitPoint(x: 0.8933, y: 0.3604),
            groundLine: 0.8787,
            clawFrontRadius: 0.0218,),
        "lion": CharacterRig(
            body: "9_body",
            leftClaw: CharacterRigLimb(imageName: "9_left_claw",
                                       joint: UnitPoint(x: 0.3608, y: 0.5916)),
            rightClaw: CharacterRigLimb(imageName: "9_left_claw",
                                        joint: UnitPoint(x: 0.6377, y: 0.5916),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0275, height: 0.0)),
            leftLegs: CharacterRigLimb(imageName: "9_left_leg",
                                       joint: UnitPoint(x: 0.383, y: 0.6461)),
            rightLegs: CharacterRigLimb(imageName: "9_left_leg",
                                        joint: UnitPoint(x: 0.6141, y: 0.646),
                                        flipped: true,
                                        nudge: CGSize(width: -0.0275, height: 0.0)),
            leftClawTip: UnitPoint(x: 0.0743, y: 0.3502),
            rightClawTip: UnitPoint(x: 0.9242, y: 0.3502),
            groundLine: 0.8581,
            clawFrontRadius: 0.0,),
        "octopus": CharacterRig(
            body: "10_body",
            leftClaw: CharacterRigLimb(imageName: "10_left_claw",
                                       joint: UnitPoint(x: 0.3438, y: 0.5934)),
            rightClaw: CharacterRigLimb(imageName: "10_left_claw",
                                        joint: UnitPoint(x: 0.6554, y: 0.5934),
                                        flipped: true,
                                        nudge: CGSize(width: 0.0099, height: 0.0)),
            leftLegs: CharacterRigLimb(imageName: "10_left_leg",
                                       joint: UnitPoint(x: 0.3634, y: 0.6341)),
            rightLegs: CharacterRigLimb(imageName: "10_left_leg",
                                        joint: UnitPoint(x: 0.6358, y: 0.634),
                                        flipped: true,
                                        nudge: CGSize(width: 0.0099, height: 0.0)),
            leftClawTip: UnitPoint(x: 0.0626, y: 0.3366),
            rightClawTip: UnitPoint(x: 0.9367, y: 0.3366),
            groundLine: 0.8551,
            clawFrontRadius: 0.0,),
    ]
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
/// joint is covered by the shell however far its limb has turned. A character
/// who carries his arms in front of himself gets those two claws a second time
/// on top, with the joint itself cut back out of that copy.
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
            if rig.clawFrontRadius > 0 {
                limb(rig.leftClaw, degrees: pose.leftClaw, cutAtJoint: true)
                limb(rig.rightClaw, degrees: pose.rightClaw, cutAtJoint: true)
            }
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

    @ViewBuilder
    private func limb(_ limb: CharacterRigLimb,
                      degrees: Double,
                      cutAtJoint: Bool = false) -> some View {
        // Mirroring and nudging come first and leave the layout square alone,
        // so the joint below still means the same point on screen for a limb
        // drawn from its own artwork and for one drawn from the other side's.
        let laid = limb.image
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .scaleEffect(x: limb.flipped ? -1 : 1, y: 1)
            .offset(x: size * limb.nudge.width, y: size * limb.nudge.height)

        Group {
            if cutAtJoint {
                laid.mask {
                    JointCutout(joint: limb.joint, radius: rig.clawFrontRadius)
                        .fill(style: FillStyle(eoFill: true))
                }
            } else {
                laid
            }
        }
        .rotationEffect(.degrees(degrees), anchor: limb.joint)
    }
}

/// The square with a hole punched in it at a limb's joint. Filled even-odd, it
/// masks away everything the shell is meant to be hiding.
private struct JointCutout: Shape {
    let joint: UnitPoint
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path(rect)
        let centre = CGPoint(x: rect.minX + joint.x * rect.width,
                             y: rect.minY + joint.y * rect.height)
        let r = radius * rect.width
        path.addEllipse(in: CGRect(x: centre.x - r, y: centre.y - r,
                                   width: r * 2, height: r * 2))
        return path
    }
}
