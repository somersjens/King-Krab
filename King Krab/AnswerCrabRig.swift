//
//  AnswerCrabRig.swift
//  King Krab
//
//  The crabs that carry the answers, drawn from their own parts.
//
//  Each is a body, one claw, one run of legs and two loose pupils. The other
//  side's claw and legs are the same drawing mirrored — pixel for pixel, which
//  is why only one of each ships — so the sprite flips them back at draw time.
//
//  The drawing is made for a crab standing on the King's left. One on his right
//  is the whole sprite flipped, which is what keeps the near claw on the side
//  facing him and the far one tucked behind the shell.
//
//  Layering, for a crab on the left: the near claw goes on top of everything,
//  the body under it, and the far claw and both runs of legs under that. The
//  answer shell is laid in between, so it falls behind the near claw and in
//  front of the far one — a shell held *in* the claws rather than pasted over
//  them. The near claw's own mouth is cut back out down at the joint, the same
//  way the King's arms are, so nothing of the buried end shows.
//
//  Every number is measured off the artwork by Tools/build_answer_crabs.py: the
//  shoulder each claw turns around, the mouth of the claw the shell is held in,
//  the hips, the line the feet stand on, and the two eye whites the pupils have
//  to stay inside.
//

import SwiftUI

// MARK: - The parts

struct AnswerCrabRig {
    /// One limb: its picture and the joint it turns around, plus how it is laid
    /// down when it is the other side's copy of the same drawing.
    struct Limb {
        let imageName: String
        let joint: UnitPoint
        var flipped: Bool = false
        var nudge: CGSize = .zero
    }

    /// One eye: the white the pupil has to stay inside, and the pupil itself,
    /// both as rectangles on the artwork square.
    struct Eye {
        let imageName: String
        let white: CGRect
        let pupil: CGRect

        /// How far the pupil has to move to sit in the corner of its own white
        /// on `side` (-1 looking left, +1 looking right). Only the horizontal
        /// moves: the artwork already has the pupils at the right height, and a
        /// crab walking sideways looks along the way it is going.
        func offset(looking side: CGFloat) -> CGSize {
            let slack = white.width - pupil.width
            let inset = slack * 0.12
            let x = side < 0 ? white.minX + inset
                             : white.maxX - inset - pupil.width
            return CGSize(width: x - pupil.minX, height: 0)
        }
    }

    let body: String
    let leftClaw: Limb
    let rightClaw: Limb
    let leftLegs: Limb
    let rightLegs: Limb
    /// The mouth of each claw: where the rim of the answer shell is held.
    let leftPincer: UnitPoint
    let rightPincer: UnitPoint
    /// Where the feet come down, as a share of the square from its top.
    let groundLine: CGFloat
    /// The shell's own width as a share of the square. It is what ties the
    /// artwork to the size the arena asks for, which is a body width.
    let bodyWidth: CGFloat
    let leftEye: Eye
    let rightEye: Eye

    /// The square the artwork is drawn on, for a crab of the given body width.
    func square(bodyWidth width: CGFloat) -> CGFloat { width / bodyWidth }

    /// A point on the square, in the sprite's own coordinates: from the middle,
    /// in points, which is what every offset in the arena is measured in.
    func point(_ unit: UnitPoint, square: CGFloat) -> CGPoint {
        CGPoint(x: (unit.x - 0.5) * square, y: (unit.y - 0.5) * square)
    }

    /// How far apart the two pincers are. The shell is gripped this far in from
    /// its corners, so a claw closes on the rim instead of reaching past it.
    func pincerSpan(square: CGFloat) -> CGFloat {
        (rightPincer.x - leftPincer.x) * square
    }

    static let gold = AnswerCrabRig(
        body: "answer_gold_body",
        leftClaw: Limb(imageName: "answer_gold_claw",
                       joint: UnitPoint(x: 0.3736, y: 0.5092)),
        rightClaw: Limb(imageName: "answer_gold_claw",
                        joint: UnitPoint(x: 0.655, y: 0.5092),
                        flipped: true,
                        nudge: CGSize(width: 0.0347, height: 0.0)),
        leftLegs: Limb(imageName: "answer_gold_legs",
                       joint: UnitPoint(x: 0.4085, y: 0.5764)),
        rightLegs: Limb(imageName: "answer_gold_legs",
                        joint: UnitPoint(x: 0.5909, y: 0.5719),
                        flipped: true,
                        nudge: CGSize(width: 0.0056, height: -0.0045)),
        leftPincer: UnitPoint(x: 0.3914, y: 0.3055),
        rightPincer: UnitPoint(x: 0.6372, y: 0.3055),
        groundLine: 0.7298,
        bodyWidth: 0.3376,
        leftEye: Eye(imageName: "answer_eye_left",
                     white: CGRect(x: 0.423, y: 0.3742, width: 0.0898, height: 0.0898),
                     pupil: CGRect(x: 0.4535, y: 0.3939, width: 0.0549, height: 0.0621)),
        rightEye: Eye(imageName: "answer_eye_right",
                      white: CGRect(x: 0.5558, y: 0.3703, width: 0.0859, height: 0.0898),
                      pupil: CGRect(x: 0.5722, y: 0.39, width: 0.0527, height: 0.0593))
    )

    static let red = AnswerCrabRig(
        body: "answer_red_body",
        leftClaw: Limb(imageName: "answer_red_claw",
                       joint: UnitPoint(x: 0.3729, y: 0.5076)),
        rightClaw: Limb(imageName: "answer_red_claw",
                        joint: UnitPoint(x: 0.654, y: 0.5076),
                        flipped: true,
                        nudge: CGSize(width: 0.0353, height: 0.0)),
        leftLegs: Limb(imageName: "answer_red_legs",
                       joint: UnitPoint(x: 0.4089, y: 0.5767)),
        rightLegs: Limb(imageName: "answer_red_legs",
                        joint: UnitPoint(x: 0.5905, y: 0.5705),
                        flipped: true,
                        nudge: CGSize(width: 0.0078, height: -0.0062)),
        leftPincer: UnitPoint(x: 0.3859, y: 0.3122),
        rightPincer: UnitPoint(x: 0.641, y: 0.3122),
        groundLine: 0.727,
        bodyWidth: 0.3309,
        leftEye: Eye(imageName: "answer_eye_left",
                     white: CGRect(x: 0.4258, y: 0.3825, width: 0.082, height: 0.086),
                     pupil: CGRect(x: 0.4524, y: 0.3945, width: 0.0549, height: 0.0621)),
        rightEye: Eye(imageName: "answer_eye_right",
                      white: CGRect(x: 0.5547, y: 0.3747, width: 0.082, height: 0.086),
                      pupil: CGRect(x: 0.5711, y: 0.3905, width: 0.0526, height: 0.0594))
    )
}

// MARK: - The view

/// One answer crab, with whatever it is carrying laid in between its claws.
///
/// The crab is drawn in two halves with the load between them, so the shell
/// falls behind the near claw and in front of the far one. Both halves are
/// flipped together for a crab on the King's right; the load is not, because it
/// carries a number and moves in the arena's own left and right.
struct AnswerCrabSprite<Carried: View>: View {
    let rig: AnswerCrabRig
    /// The shell's width, which is the size the arena thinks in.
    let bodyWidth: CGFloat
    /// The body's own roll and bob this frame. The legs stay out of both: a
    /// planted foot has to stay where it was put.
    let roll: Double
    let bob: CGFloat
    /// True for a crab on the King's right, whose whole drawing is flipped.
    let mirrored: Bool
    /// Which way it is looking, in the arena's terms.
    let gaze: CGFloat
    /// The two points on the load the pincers are closed on, in the sprite's
    /// own coordinates. Nil for a crab holding nothing, whose claws simply ride
    /// its body.
    var grip: (left: CGPoint, right: CGPoint)?
    @ViewBuilder let carried: () -> Carried

    private var square: CGFloat { rig.square(bodyWidth: bodyWidth) }

    var body: some View {
        ZStack {
            // Under the load: the far claw and both runs of legs.
            sideOfTheCrab {
                claw(rig.rightClaw, pincer: rig.rightPincer, grip: designGrip?.right)
                limb(rig.leftLegs)
                limb(rig.rightLegs)
                ZStack {
                    image(rig.body)
                    pupil(rig.leftEye)
                    pupil(rig.rightEye)
                }
                .rotationEffect(.degrees(roll))
                .offset(y: bob)
            }

            carried()

            // …and the near claw closes over it.
            sideOfTheCrab {
                claw(rig.leftClaw, pincer: rig.leftPincer, grip: designGrip?.left)
            }
        }
        .frame(width: bodyWidth * 1.7, height: bodyWidth * 1.5)
    }

    /// Both halves are flipped the same way and framed the same way, so the two
    /// of them stay one animal with the load threaded through it.
    private func sideOfTheCrab<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ZStack { content() }
            .frame(width: bodyWidth * 1.7, height: bodyWidth * 1.5)
            .scaleEffect(x: mirrored ? -1 : 1, y: 1)
    }

    /// The load's grip points as the drawing sees them. A flipped crab holds
    /// the same shell, but its own left is the arena's right.
    private var designGrip: (left: CGPoint, right: CGPoint)? {
        guard let grip else { return nil }
        guard mirrored else { return grip }
        return (left: CGPoint(x: -grip.right.x, y: grip.right.y),
                right: CGPoint(x: -grip.left.x, y: grip.left.y))
    }

    /// Looking left in the drawing's own terms, which is the other way round
    /// once the whole sprite has been flipped.
    private var lookSide: CGFloat {
        let side: CGFloat = gaze < 0 ? -1 : 1
        return mirrored ? -side : side
    }

    /// A point carried through the body's own roll and bob, which is how a limb
    /// stays hinged to a shell it is drawn outside of.
    private func onBody(_ point: CGPoint) -> CGPoint {
        let radians = roll * .pi / 180
        return CGPoint(x: point.x * cos(radians) - point.y * sin(radians),
                       y: point.x * sin(radians) + point.y * cos(radians) + bob)
    }

    private func image(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: square, height: square)
    }

    /// A limb, laid down where its own export sat — mirroring and nudging leave
    /// the layout square alone, so the joint still means the same point on
    /// screen whichever side's drawing it came from.
    private func limb(_ limb: AnswerCrabRig.Limb) -> some View {
        image(limb.imageName)
            .scaleEffect(x: limb.flipped ? -1 : 1, y: 1)
            .offset(x: square * limb.nudge.width, y: square * limb.nudge.height)
    }

    /// A claw turns around its own buried end until its mouth is on the edge it
    /// is holding, and the shoulder itself rides the body — so the arm stays
    /// attached to the animal while the pincer stays on a shell that is swinging
    /// independently of it.
    private func claw(_ limb: AnswerCrabRig.Limb,
                      pincer: UnitPoint,
                      grip: CGPoint?) -> some View {
        let rest = rig.point(limb.joint, square: square)
        let moved = onBody(rest)
        var degrees = roll
        if let grip {
            let mouth = rig.point(pincer, square: square)
            let held = atan2(grip.y - moved.y, grip.x - moved.x)
            let drawn = atan2(mouth.y - rest.y, mouth.x - rest.x)
            degrees = (held - drawn) * 180 / .pi
        }
        return self.limb(limb)
            .rotationEffect(.degrees(degrees), anchor: limb.joint)
            .offset(x: moved.x - rest.x, y: moved.y - rest.y)
    }

    /// A pupil, moved into the corner of its own white on the side the crab is
    /// heading. The four placements are all different because the two whites
    /// are — the artwork is a face, not a diagram.
    private func pupil(_ eye: AnswerCrabRig.Eye) -> some View {
        let shift = eye.offset(looking: lookSide)
        return image(eye.imageName)
            .offset(x: square * shift.width, y: square * shift.height)
    }
}
