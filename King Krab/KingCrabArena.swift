//
//  KingCrabArena.swift
//  King Krab
//
//  The playing surface's simulation: the sum stands at the top of the screen,
//  the King Crab holds the middle of the sea floor, and one small crab walks in
//  from each of the four corners carrying an answer card. Three of them are
//  wrong and are meant to be smashed with a tap; the fourth carries the right
//  answer and has to be let through.
//
//  This file holds the whole of the simulation and nothing else. Every rule
//  about scoring, lives, rounds and progress still lives in `MemoryGame`; the
//  arena only decides *when* something reaches the King or is smashed, and
//  hands that event over. The engine that owns the session has the final say on
//  every one of them.
//

import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Screen edges

/// The window's own safe area. The arena is laid out edge to edge, so it needs
/// the real insets to keep the sum clear of the HUD and the sea floor clear of
/// the home indicator — and a `GeometryReader` nested inside the playing field
/// reports zero for them, because its container has already been inset.
///
/// Sample this in `onAppear` and keep the value in state. Reading it from
/// inside a `body` wedges SwiftUI's update pass: the view renders once and then
/// stops receiving updates entirely, which shows up as a frozen playing field
/// with no sum on it.
struct ScreenSafeArea: Equatable {
    var top: CGFloat = 0
    var bottom: CGFloat = 0
    var leading: CGFloat = 0
    var trailing: CGFloat = 0

    @MainActor
    static var current: ScreenSafeArea {
#if canImport(UIKit)
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
        guard let insets = window?.safeAreaInsets else { return ScreenSafeArea() }
        return ScreenSafeArea(top: insets.top,
                              bottom: insets.bottom,
                              leading: insets.left,
                              trailing: insets.right)
#else
        return ScreenSafeArea()
#endif
    }
}

// MARK: - Tuning

/// A conservative decoration budget for older hardware and Low Power Mode.
/// Gameplay, taps and arrivals always retain their full step; only effects that
/// do not carry information become a little sparser.
enum ArenaPerformanceBudget {
    static let isConstrained: Bool = {
        ProcessInfo.processInfo.physicalMemory < 4_000_000_000
            || ProcessInfo.processInfo.isLowPowerModeEnabled
    }()

    static let moteCount = isConstrained ? 10 : 16
    static let maximumAmbientBubbles = isConstrained ? 10 : 18
    static let grainsPerBurst = isConstrained ? 7 : 12
    static let celebrationInterval = isConstrained ? 0.10 : 0.065
    /// Scenery sway: 20 Hz normally, 12 Hz where the frame budget is tightest.
    static let swayInterval = isConstrained ? 1.0 / 12.0 : 1.0 / 20.0
    static let driftInterval = isConstrained ? 1.0 / 4.0 : 1.0 / 6.0
}

/// Every tunable number of the arena, kept together the way `GameConfig` keeps
/// the session's. Timings that are *rules* rather than presentation — how long
/// a crab takes to cross, what a breach costs — live in `GameConfig`.
enum ArenaConfig {
    // MARK: Crabs

    /// Body width of a walking crab; everything about it is measured from this.
    static func crabSize(isPad: Bool) -> CGFloat { isPad ? 66 : 48 }
    /// The answer shell a crab carries over its head. It is deliberately wider
    /// than the crab itself: the number is the thing being read, and a small
    /// crab under a big shell is what makes it read as *carried*.
    static func cardWidth(isPad: Bool) -> CGFloat { isPad ? 106 : 77 }
    static func cardHeight(isPad: Bool) -> CGFloat { isPad ? 86 : 64 }
    /// How far the shell floats above the body's centre, as a share of its own
    /// height. The claws are placed from the same number. It clears the crab's
    /// head: the arms have to be visibly holding the shell *up*, not propping
    /// it on top of the animal.
    static let cardLift: CGFloat = 0.88

    /// A tap counts as a hit anywhere inside this radius of the crab, which is
    /// deliberately generous: the player is aiming at a moving target with a
    /// finger, and a near miss that costs a life would be unfair.
    static func tapRadius(isPad: Bool) -> CGFloat { isPad ? 88 : 66 }

    /// A crab comes on at a scurry and settles into its walk exactly as its
    /// answer becomes readable. Crabs scuttle in bursts anyway, and a wave that
    /// strolls into view keeps the player waiting on the numbers.
    static let approachRush: Double = 5.5
    /// Smashed: flung away, spinning, shrinking into the sand.
    static let smashDuration = 0.46
    /// The retreat every remaining crab makes when the attempt is over.
    static let burrowDuration = 0.42
    /// Swept aside by the King's own blow, which throws them much further.
    static let sweptDuration = 0.62

    // MARK: The King

    static func kingSize(isPad: Bool) -> CGFloat { isPad ? 185 : 136 }
    /// Where a walking crab stops: on a ring around the King, wide enough that
    /// four arrivals stand around him rather than on top of him.
    static let arrivalRingFactor: CGFloat = 0.98
    /// Arrivals inside this window are answered by a single sweep, so two crabs
    /// reaching the King together never produce two separate animations.
    static let sweepGather = 0.14
    /// A breather before the sea floor sends the same sum's answers around
    /// again, for any wave that ends without the right answer being settled.
    static let waveRefillGap = 0.9
    static let sweepDuration = 0.52
    /// The heal flash when the life crab gets through.
    static let healDuration = 1.0

    /// The King rises out of the sand before the first round.
    static let entranceDuration = 1.15
    /// The first wave sets off just before the King has settled, so the round
    /// opens into motion rather than into a held pose.
    static let entranceAnswerLead = 0.32

    // MARK: Carrier crabs

    /// The 2x crab scuttles across the arena rather than at the King.
    static func bonusCrabSize(isPad: Bool) -> CGFloat { isPad ? 70 : 52 }
    static let bonusCrabSpeed: ClosedRange<CGFloat> = 150...185
    /// After one of the preselected questions appears, this little extra delay
    /// keeps the exact arrival surprising and independent of the wave.
    static let bonusCrabQuestionDelay: ClosedRange<Double> = 2.0...5.0

    static func lifeCrabSize(isPad: Bool) -> CGFloat { isPad ? 78 : 58 }
    /// How long after being earned the comeback crab appears.
    static let lifeCrabDelay: ClosedRange<Double> = 1.2...2.6

    // MARK: Walkthrough

    /// How long the walkthrough's helper crab takes to come round, both the
    /// first time and after a miss.
    static let tutorialCrabArrival = 0.8
    /// Water the walkthrough keeps free below the HUD for its message card.
    static func tutorialMessageReserve(isPad: Bool) -> CGFloat { isPad ? 150 : 116 }

    // MARK: Level completion

    /// Gather, cheer, and let the shells fill the water. The result card follows
    /// motion rather than a frozen final frame.
    static let completionDuration = 2.6

    // MARK: Scenery

    /// How far the sea floor's crest sits below the sum.
    static func floorCrest(isPad: Bool) -> CGFloat { isPad ? 34 : 24 }
    /// How far the arena keeps clear of the bottom edge, on top of whatever the
    /// home indicator already reserves.
    static func floorInset(isPad: Bool) -> CGFloat { isPad ? 26 : 18 }
    static func sideInset(isPad: Bool) -> CGFloat { isPad ? 16 : 10 }

    /// The sum's banner at the top of the screen.
    static func bannerHeight(isPad: Bool) -> CGFloat { isPad ? 108 : 82 }

    // MARK: Rewards

    /// A collected answer leaves the King as a shell that reaches the HUD just
    /// after the next sum appears.
    static let shellFlightDuration = 0.92

    // MARK: Ambience

    static let ambientBubbleGap: ClosedRange<Double> = 0.32...0.72
    static let ambientBubbleSpeed: ClosedRange<CGFloat> = 28...54
    static let ambientBubbleRadius: ClosedRange<CGFloat> = 3.5...9
    static let maximumAmbientBubbles = ArenaPerformanceBudget.maximumAmbientBubbles
    static let ambientBubblePopDuration = 0.24

    static let moteCount = ArenaPerformanceBudget.moteCount
    static let moteSpeed: ClosedRange<CGFloat> = 8...22
    static let moteRadius: ClosedRange<CGFloat> = 1.5...4.5

    /// How often the swaying scenery is re-sampled. Coral and plants breathe at
    /// well under 1.2 Hz, so a fresh position 20 times a second is already
    /// smoother than the eye can follow — while a full 60 Hz rebuild of that
    /// whole sea floor is by far the most expensive thing in the frame.
    static let swayInterval = ArenaPerformanceBudget.swayInterval
    /// The sun shafts drift on a 35-second cycle and are the one full-screen
    /// blur in the scene, so they are re-sampled far more sparingly still.
    static let driftInterval = ArenaPerformanceBudget.driftInterval

    /// Simulation step used where no display link is available.
    static let tick = 1.0 / 60.0
}

// MARK: - Palette

/// The arena's colours. Each one starts from the player's own character colours
/// and is pulled toward the sea, so a fox arena and a penguin arena are still
/// recognisably theirs while both read as an underwater sea floor.
struct ReefPalette {
    let character: AnimalCharacter

    private static let surface = (0.60, 0.87, 0.95)
    private static let depth = (0.10, 0.45, 0.66)
    private static let sandTone = (0.96, 0.90, 0.74)
    private static let sandShadow = (0.80, 0.68, 0.46)

    var waterTop: Color { Self.mix(character.skyRGB, Self.surface, 0.72) }
    var waterDeep: Color { Self.mix(character.primaryRGB, Self.depth, 0.85) }
    var sand: Color { Self.mix(character.tintRGB, Self.sandTone, 0.72) }
    var sandDeep: Color { Self.mix(character.deepRGB, Self.sandShadow, 0.62) }

    /// The coral keeps the character's own colour: it is the one warm thing on
    /// the sea floor, and it frames the arena the King holds.
    var coral: Color { character.color }
    var coralDeep: Color { character.deepColor }
    var plant: Color { Color(red: 0.18, green: 0.56, blue: 0.34) }
    var plantLight: Color { Color(red: 0.43, green: 0.72, blue: 0.30) }

    /// A real reef is not one colour. These are the garden's own hues, each
    /// pulled a quarter of the way toward the character's, so a fox reef and a
    /// penguin reef are still recognisably theirs while both stay a reef.
    private static let reefHues: [(Double, Double, Double)] = [
        (0.86, 0.30, 0.62),   // magenta fan
        (0.98, 0.53, 0.18),   // orange branch
        (0.56, 0.36, 0.86),   // violet finger
        (0.20, 0.71, 0.73),   // teal cup
        (0.97, 0.42, 0.47)    // rose bud
    ]

    func reefAccent(_ index: Int) -> Color {
        let hue = Self.reefHues[abs(index) % Self.reefHues.count]
        return Self.mix(hue, character.primaryRGB, 0.26)
    }

    func reefAccentDeep(_ index: Int) -> Color {
        let hue = Self.reefHues[abs(index) % Self.reefHues.count]
        return Self.mix(Self.mix3(hue, 0.62), character.deepRGB, 0.24)
    }

    /// The stones the reef grows on: cool, desaturated, and always behind
    /// everything else.
    var rock: Color { Self.mix((0.52, 0.57, 0.66), character.primaryRGB, 0.18) }
    var rockDeep: Color { Self.mix((0.31, 0.36, 0.46), character.deepRGB, 0.18) }

    /// Darkens a hue toward its own shadow.
    private static func mix3(_ base: (Double, Double, Double),
                             _ amount: Double) -> (Double, Double, Double) {
        (base.0 * amount, base.1 * amount, base.2 * amount)
    }

    private static func mix(_ base: (Double, Double, Double),
                            _ target: (Double, Double, Double),
                            _ amount: Double) -> Color {
        let t = min(max(amount, 0), 1)
        return Color(red: base.0 + (target.0 - base.0) * t,
                     green: base.1 + (target.1 - base.1) * t,
                     blue: base.2 + (target.2 - base.2) * t)
    }
}

// MARK: - Model

/// One small crab on its way to the King, carrying an answer card.
struct AnswerCrab: Identifiable {
    /// The only states a crab can be in. Everything the arena decides — a tap,
    /// an arrival, the end of an attempt — is expressed as one of these, so a
    /// crab can never be smashed twice or arrive after it has been swept away.
    enum Phase: Equatable {
        /// Standing off the side of the screen, waiting for its turn to walk on.
        case waiting
        case walking
        /// Standing at the King's ring, waiting for the sweep that answers it.
        case arrived
        /// Hit by the player.
        case smashed
        /// Digging itself back into the sand: the attempt is over.
        case burrowing
        /// Thrown aside by the King's blow.
        case swept
    }

    let id = UUID()
    /// The session's option, which is what an arrival reports back.
    let optionID: UUID
    let text: String
    let isCorrect: Bool

    /// Off the side of the screen: a crab walks in rather than appearing.
    private(set) var start: CGPoint
    private(set) var target: CGPoint
    var position: CGPoint
    /// 0 → off screen, 1 → at the King.
    var progress: Double = 0
    /// The share of the walk that happens before the answer is fully in view.
    /// It is covered at a scurry, so the shell shows up early; everything after
    /// it is walked at the pace the game has always had.
    let entryProgress: Double
    /// Seconds this crab needs for the part of the walk that is on screen.
    let duration: Double
    /// Seconds it waits out of sight before setting off.
    var startDelay: Double

    /// Small honest differences, so four crabs never march as one shape.
    let waddleAmplitude: CGFloat
    let waddleRate: Double
    /// How long this crab's stride is, against the standard one. Together with
    /// `gaitOffset` it keeps four crabs from stepping in lockstep.
    let strideFactor: CGFloat
    let gaitOffset: Double
    /// Ground actually covered, in points. The walk cycle is measured off this
    /// rather than off time, so a foot that is planted never slides: when the
    /// crab hesitates mid-scuttle its legs hesitate with it.
    var walked: CGFloat = 0
    let cardLean: Double
    /// A crab does not glide: it scuttles a few steps, hesitates, and goes
    /// again. This is the rhythm of that, per crab.
    let scuttleRate: Double
    let scuttlePhase: Double
    /// Which way it is travelling across the screen, so it leads with the
    /// claw on that side and looks where it is going.
    let facing: CGFloat

    var phase: Phase = .waiting
    /// Time spent in the current phase, which drives every exit animation.
    var phaseAge: Double = 0
    var age: Double = 0
    /// Where a smashed or swept crab is being thrown, and how fast it tumbles.
    var flingVelocity: CGPoint = .zero
    var spin: Double = 0

    var isLive: Bool { phase == .waiting || phase == .walking }
    /// Whether a tap may still take this crab. A crab still waiting its turn is
    /// out of sight, so a tap near the edge must never take it blind.
    var isTappable: Bool { phase == .walking }

    /// Moves the whole walk when the arena itself moves under it.
    mutating func shift(by delta: CGPoint) {
        start.x += delta.x; start.y += delta.y
        target.x += delta.x; target.y += delta.y
        position.x += delta.x; position.y += delta.y
    }
}

/// The two crabs that carry something other than an answer: the 2x crab that
/// scuttles past, and the comeback crab that walks a life to the King.
struct CarrierCrab: Identifiable {
    enum Kind { case bonus, life }

    let id = UUID()
    let kind: Kind
    let size: CGFloat
    private(set) var start: CGPoint
    private(set) var target: CGPoint
    var position: CGPoint
    var progress: Double = 0
    let duration: Double
    /// True until its reward has been taken; a spent crab simply walks off.
    var isCarryingReward = true
    let waddleRate: Double
    let strideFactor: CGFloat
    /// Ground covered, for the same distance-driven gait the answer crabs use.
    var walked: CGFloat = 0
    /// Which way it is facing, for the sprite's mirror.
    var facing: CGFloat = 1

    mutating func shift(by delta: CGPoint) {
        start.x += delta.x; start.y += delta.y
        target.x += delta.x; target.y += delta.y
        position.x += delta.x; position.y += delta.y
    }
}

/// The shell a scored answer sends up to the HUD. It is deliberately separate
/// from anything the player can touch.
struct ShellReward: Identifiable {
    let id = UUID()
    let diameter: CGFloat
    let start: CGPoint
    let firstControl: CGPoint
    let secondControl: CGPoint
    let target: CGPoint
    var position: CGPoint
    var age: Double = 0
}

/// One grain of the sand kicked up by an emerging, smashed or burrowing crab.
struct SandGrain: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    let radius: CGFloat
    /// 0 → pale sand, 1 → the darker tone underneath.
    let tone: Double
    let lifetime: Double
    var age: Double = 0
}

/// A speck of drifting plankton. Decoration only.
struct ReefMote: Identifiable {
    let id = UUID()
    var position: CGPoint
    let radius: CGFloat
    let speed: CGFloat
    let sway: CGFloat
    let period: Double
    let phase: Double
    let baseX: CGFloat
    var age: Double = 0
}

/// A small, purely decorative air pocket rising off the sea floor.
struct ReefAmbientBubble: Identifiable {
    let id = UUID()
    let baseX: CGFloat
    var position: CGPoint
    let radius: CGFloat
    let speed: CGFloat
    let phase: Double
    var age: Double = 0
    var popAge: Double?
}

/// One decorative shell or bubble in the completed-level finale.
struct CelebrationSpeck: Identifiable {
    enum Kind { case bubble, shell }

    let id = UUID()
    var position: CGPoint
    let radius: CGFloat
    let speed: CGFloat
    let phase: Double
    let kind: Kind
    var age: Double = 0
}

/// Where the King is and what he is doing. He never moves off his spot: the
/// whole game is played around him.
struct KingState {
    var position: CGPoint = .zero
    /// Time since the current sweep started, or nil while he is simply waiting.
    var sweepAge: Double?
    /// Which way the sweep began, so two sweeps in a row are not identical.
    var sweepDirection: Double = 1
    /// Time since a life was handed back, which drives the heal glow.
    var healAge: Double?
    /// Time since he rose out of the sand, or nil once he has settled.
    var entranceAge: Double?
    /// Set while the finale is playing.
    var isCheering = false
}

// MARK: - Engine

/// Drives the crabs, the King and the sea floor. It owns exactly one timer,
/// holds no rules about scoring, and reports everything that happens through
/// its callbacks — each of which returns whether the session accepted it.
@MainActor
final class KingCrabArena: ObservableObject {
    // These values all advance together in `tick()`. Publishing each array
    // element mutation caused many redundant SwiftUI invalidations per frame.
    // `clock` is the single render signal for the completed simulation frame.
    private(set) var crabs: [AnswerCrab] = []
    private(set) var carriers: [CarrierCrab] = []
    private(set) var shells: [ShellReward] = []
    private(set) var grains: [SandGrain] = []
    private(set) var motes: [ReefMote] = []
    private(set) var ambientBubbles: [ReefAmbientBubble] = []
    private(set) var celebration: [CelebrationSpeck] = []
    private(set) var king = KingState()
    private(set) var hasBonusAura = false

    /// Seconds of running time. It stops when the game does, so nothing moves
    /// behind a pause. Everything the player reads timing from follows this at
    /// the display's full cadence (60 or 120 Hz).
    @Published private(set) var clock: Double = 0
    /// The same clock, held still between sway steps. The sea floor is a large
    /// pile of gradient, stroke and shadow nodes; rebuilding all of them 60
    /// times a second leaves no frame budget for the moments that actually
    /// matter. Because the scenery views are `Equatable` on their clock, an
    /// unchanged value here skips that entire rebuild.
    private(set) var swayClock: Double = 0
    /// Coarser still, for the drifting sun shafts and their full-screen blur.
    private(set) var driftClock: Double = 0

    // MARK: Callbacks

    /// The crab carrying the right answer reached the King. Returns whether the
    /// session took it, so an arrival it ignores leaves the arena as it was.
    var onGuardedArrival: ((UUID) -> Bool)?
    /// A wrong answer reached the King.
    var onBreach: (() -> Void)?
    /// The player smashed the crab carrying the right answer. Returns whether
    /// the session accepted it; only then is the attempt actually over.
    var onSmashedGuard: (() -> Bool)?
    /// Any crab the player smashed, right or wrong — for the sound and the
    /// small kick of feedback that goes with it.
    var onSmash: ((Bool) -> Void)?
    /// The King's blow, whether or not it scored.
    var onSweep: (() -> Void)?
    var onShellArrived: (() -> Void)?
    var onBonusCrabCaught: (() -> Void)?
    /// The comeback crab reached the King. Returns whether a life was restored.
    var onLifeCrabArrived: (() -> Bool)?
    var onTutorialEvent: ((CrabTutorialEvent) -> Void)?

    // MARK: Geometry, set from the view's layout

    private var size: CGSize = .zero
    /// The rectangle the crabs actually walk in: below the sum, above the very
    /// bottom edge.
    private var arena: CGRect = .zero
    private var isPad = false
    private var crabSize: CGFloat = 56
    private var kingSize: CGFloat = 124
    private var scoreTarget: CGPoint?

    // MARK: Round state

    private var round: GameRound?
    private var isLive = false
    private var speedMultiplier = 1.0
    /// Counts down while several arrivals are gathered into one sweep.
    private var sweepGather: Double?
    /// Set when the player smashed the guarded answer: the wave is over and a
    /// fresh one starts as soon as the session accepts input again.
    private var pendingWaveRestart = false
    /// Counts down while an empty arena waits for its next wave.
    private var refillDelay: Double?
    /// Guards the tap handler against a second touch landing in the same frame
    /// as the one that ended the attempt.
    private var isResolvingWave = false

    // At the start, one to three hidden question numbers are picked across the
    // whole board. This makes a 2x crab possible near the beginning or near the
    // end without tying it to how many seconds the player needs.
    private var maximumRounds = 1
    private var bonusTriggerRounds: [Int] = []
    private var nextBonusTrigger = 0
    private var pendingBonusDelays: [Double] = []

    // The comeback crab is scheduled by the rules engine once it is earned.
    // This scene only owns the short randomized arrival delay.
    private var isLifeCrabAvailable = false
    private var lifeCrabDelay: Double?

    // The walkthrough. While a plan is active it decides what may be in the
    // arena; the crabs walk, are smashed and arrive exactly as they otherwise
    // would. See `Tutorial.swift`.
    private var tutorialPlan = CrabTutorialPlan()
    private var tutorialCrabDelay: Double?

    // Entrance and finale.
    private var entranceCompletion: (() -> Void)?
    private var entranceDidOpenRound = false
    private var completionElapsed: Double?
    private var completionCallback: (() -> Void)?
    private var completionSpeckCountdown = 0.0
    private var reducesCompletionMotion = false
    private var ambientBubbleCountdown = Double.random(in: ArenaConfig.ambientBubbleGap)

#if canImport(UIKit)
    /// A display-linked driver avoids timer firings landing halfway through a
    /// screen refresh, which is visible as uneven motion on slower devices.
    private final class DisplayLinkTarget: NSObject {
        weak var owner: KingCrabArena?

        init(owner: KingCrabArena) {
            self.owner = owner
        }

        @objc func advance(_ displayLink: CADisplayLink) {
            guard let owner else {
                displayLink.invalidate()
                return
            }
            owner.advance(displayLink)
        }
    }

    private lazy var displayLinkTarget = DisplayLinkTarget(owner: self)
    private var displayLink: CADisplayLink?
    private var lastFrameTargetTimestamp: CFTimeInterval?
#else
    private var timer: Timer?
#endif

    deinit {
#if canImport(UIKit)
        displayLink?.invalidate()
#else
        timer?.invalidate()
#endif
    }

    // MARK: Layout

    /// Called from the view's geometry. Re-running it on a size change keeps the
    /// King and the crabs inside the new bounds.
    func layout(size: CGSize, arena: CGRect, isPad: Bool) {
        guard size.width > 0, size.height > 0, arena.height > 0 else { return }
        let isFirst = self.size == .zero
        self.size = size
        self.arena = arena
        self.isPad = isPad
        self.crabSize = ArenaConfig.crabSize(isPad: isPad)
        self.kingSize = ArenaConfig.kingSize(isPad: isPad)

        let previousKing = king.position
        king.position = CGPoint(x: arena.midX, y: arena.minY + arena.height * 0.54)
        if !isFirst {
            // A rotation, or the walkthrough's message card claiming the top of
            // the arena, moves the King. Everything already walking toward him
            // moves with him, so no crab is left aiming at where he used to be.
            let delta = CGPoint(x: king.position.x - previousKing.x,
                                y: king.position.y - previousKing.y)
            if delta.x != 0 || delta.y != 0 {
                for index in crabs.indices { crabs[index].shift(by: delta) }
                for index in carriers.indices { carriers[index].shift(by: delta) }
            }
        }
        if isFirst {
            // Small upper bounds, reserving capacity only; they do not create
            // or draw a single additional object.
            crabs.reserveCapacity(GameConfig.answerBubbleCount)
            grains.reserveCapacity(ArenaPerformanceBudget.grainsPerBurst * 4)
            ambientBubbles.reserveCapacity(ArenaConfig.maximumAmbientBubbles)
            celebration.reserveCapacity(ArenaPerformanceBudget.isConstrained ? 60 : 110)
        }
        seedMotes()
    }

    private func seedMotes() {
        motes = (0..<ArenaConfig.moteCount).map { _ in
            let x = CGFloat.random(in: 0...size.width)
            return ReefMote(position: CGPoint(x: x, y: CGFloat.random(in: 0...size.height)),
                            radius: CGFloat.random(in: ArenaConfig.moteRadius),
                            speed: CGFloat.random(in: ArenaConfig.moteSpeed),
                            sway: CGFloat.random(in: 4...14),
                            period: Double.random(in: 3...7),
                            phase: Double.random(in: 0..<(2 * .pi)),
                            baseX: x)
        }
    }

    // MARK: Session control

    /// Supplies the board length before its first question is loaded. The actual
    /// hidden trigger questions are chosen when that question arrives, which
    /// also makes a resumed board plan only over its remaining rounds.
    func configureBonusCrab(maximumRounds: Int) {
        self.maximumRounds = max(1, maximumRounds)
    }

    /// Installs a round. Called only when the sum actually changes, so smashing
    /// the guarded answer leaves the same sum standing.
    func load(round: GameRound?) {
        let previousRoundNumber = self.round?.number
        self.round = round
        guard let round else {
            crabs.removeAll()
            return
        }

        // Playing again reuses this SwiftUI playfield and therefore this engine.
        // A fresh round one starts a genuinely fresh hidden plan.
        if round.number == 1, previousRoundNumber != nil {
            shells.removeAll()
            carriers.removeAll()
            bonusTriggerRounds.removeAll()
            nextBonusTrigger = 0
            pendingBonusDelays.removeAll()
            isLifeCrabAvailable = false
            lifeCrabDelay = nil
        }
        if bonusTriggerRounds.isEmpty {
            makeBonusCrabPlan(startingAt: round.number)
        }
        while nextBonusTrigger < bonusTriggerRounds.count,
              round.number >= bonusTriggerRounds[nextBonusTrigger] {
            pendingBonusDelays.append(Double.random(in: ArenaConfig.bonusCrabQuestionDelay))
            nextBonusTrigger += 1
        }
        beginWave()
    }

    private func makeBonusCrabPlan(startingAt firstRound: Int) {
        let requestedCount = Int.random(in: GameConfig.bonusFishCount)

        // `maximumRounds` is only the one-shell-per-answer ceiling. A perfect
        // streak pays two shells, and every caught 2x crab can make one of those
        // answers worth four. Plan against that shortest possible run; a crab
        // may then be late, but never on a question the level cannot reach.
        let streakStart = min(GameConfig.streakThreshold, maximumRounds)
        let shellsAfterStreakStart = max(0,
            maximumRounds - streakStart - requestedCount * GameConfig.bonusFishMultiplier
        )
        let shortestPossibleRun = streakStart
            + Int(ceil(Double(shellsAfterStreakStart) / Double(GameConfig.streakMultiplier)))
        let lastRound = max(firstRound, min(maximumRounds, shortestPossibleRun))
        let availableRounds = Array(firstRound...lastRound)
        let count = min(requestedCount, availableRounds.count)
        bonusTriggerRounds = Array(availableRounds.shuffled().prefix(count)).sorted()
        nextBonusTrigger = 0
    }

    /// Play is live only while the session is accepting an answer.
    func setLive(_ live: Bool) {
        guard isLive != live else { return }
        isLive = live
        // The wave the player lost is replaced the moment the session is ready
        // for a new attempt, not while its feedback is still playing.
        if live { restartWaveIfReady() }
    }

    func setBonusAura(_ active: Bool) {
        guard hasBonusAura != active else { return }
        hasBonusAura = active
        // This can change while the simulation is paused, so it cannot wait for
        // the next clock update to be drawn.
        objectWillChange.send()
    }

    func setLifeCrabAvailable(_ available: Bool) {
        if available, !isLifeCrabAvailable, !carriers.contains(where: { $0.kind == .life }) {
            lifeCrabDelay = Double.random(in: ArenaConfig.lifeCrabDelay)
        } else if !available {
            lifeCrabDelay = nil
        }
        isLifeCrabAvailable = available
    }

    func setSpeedMultiplier(_ multiplier: Double) {
        speedMultiplier = max(1, multiplier)
    }

    func setScoreTarget(_ target: CGPoint?) {
        scoreTarget = target
    }

    /// Starts and stops the simulation itself. Everything freezes when the game
    /// is paused, covered or left.
    func setRunning(_ running: Bool) {
        if running {
#if canImport(UIKit)
            guard displayLink == nil else { return }
            lastFrameTargetTimestamp = nil
            let link = CADisplayLink(target: displayLinkTarget,
                                     selector: #selector(DisplayLinkTarget.advance(_:)))
            let maximumFPS = ArenaPerformanceBudget.isConstrained
                ? 60
                : max(60, UIScreen.main.maximumFramesPerSecond)
            link.preferredFrameRateRange = CAFrameRateRange(
                minimum: 60,
                maximum: Float(maximumFPS),
                preferred: Float(maximumFPS)
            )
            link.add(to: .main, forMode: .common)
            displayLink = link
#else
            guard timer == nil else { return }
            let timer = Timer(timeInterval: ArenaConfig.tick, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated { self?.tick(dt: ArenaConfig.tick) }
            }
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
#endif
        } else {
#if canImport(UIKit)
            displayLink?.invalidate()
            displayLink = nil
            lastFrameTargetTimestamp = nil
#else
            timer?.invalidate()
            timer = nil
#endif
        }
    }

    /// Tears the scene down for good: no timer, no crabs, nothing pending.
    func stop() {
        setRunning(false)
        crabs.removeAll()
        carriers.removeAll()
        shells.removeAll()
        grains.removeAll()
        celebration.removeAll()
        round = nil
        sweepGather = nil
        entranceCompletion = nil
        completionElapsed = nil
        completionCallback = nil
        tutorialPlan = CrabTutorialPlan()
        tutorialCrabDelay = nil
        onGuardedArrival = nil
        onBreach = nil
        onSmashedGuard = nil
        onSmash = nil
        onSweep = nil
        onShellArrived = nil
        onBonusCrabCaught = nil
        onLifeCrabArrived = nil
        onTutorialEvent = nil
    }

    /// The King climbs out of the sand before the first round. Gameplay is
    /// deliberately started by the completion, not alongside it.
    func beginKingEntrance(completion: @escaping () -> Void) {
        guard size.width > 0, arena.height > 0 else {
            completion()
            return
        }
        entranceCompletion = completion
        entranceDidOpenRound = false
        king.entranceAge = 0
        burst(at: CGPoint(x: king.position.x, y: king.position.y + kingSize * 0.34),
              strength: 1.4)
    }

    /// Takes over after the final answer: the King cheers on his own floor while
    /// shells stream up out of the sand.
    func beginLevelCompletion(reduceMotion: Bool, completion: @escaping () -> Void) {
        guard completionElapsed == nil else { return }
        isLive = false
        crabs.removeAll()
        carriers.removeAll()
        celebration.removeAll()
        completionElapsed = 0
        completionCallback = completion
        completionSpeckCountdown = 0
        reducesCompletionMotion = reduceMotion
        king.isCheering = !reduceMotion
        king.sweepAge = reduceMotion ? nil : 0
    }

    func endLevelCompletion() {
        completionElapsed = nil
        completionCallback = nil
        celebration.removeAll()
        king.isCheering = false
    }

    // MARK: The walkthrough

    /// Takes the walkthrough's marching orders for the step now being taught. A
    /// step that changes what the arena holds clears it first, so the player
    /// always reads the new message against the crabs that message describes.
    func applyTutorial(_ plan: CrabTutorialPlan) {
        let previous = tutorialPlan
        tutorialPlan = plan
        guard plan != previous else { return }

        guard plan.isActive else {
            tutorialCrabDelay = nil
            return
        }

        if plan.suppressesAnswers {
            burrowLiveCrabs()
        } else if plan.answers != previous.answers || previous.suppressesAnswers {
            burrowLiveCrabs()
            pendingWaveRestart = true
            if isLive { restartWaveIfReady() }
        }

        // A helper crab that has already given up its reward is on its way out
        // and may finish crossing; one still carrying a reward belongs to the
        // step that asked for it and leaves with it.
        if !plan.wantsLifeCrab {
            carriers.removeAll { $0.kind == .life && $0.isCarryingReward }
        }
        if !plan.wantsBonusCrab {
            carriers.removeAll { $0.kind == .bonus && $0.isCarryingReward }
        }
        if plan.wantsLifeCrab != previous.wantsLifeCrab
            || plan.wantsBonusCrab != previous.wantsBonusCrab {
            tutorialCrabDelay = (plan.wantsLifeCrab || plan.wantsBonusCrab)
                ? ArenaConfig.tutorialCrabArrival
                : nil
        }
    }

    // MARK: Taps

    /// The player touched the glass. Exactly one crab can be taken by one touch,
    /// and only ever the nearest one inside its own reach.
    func tap(at point: CGPoint) {
        guard completionElapsed == nil, king.entranceAge == nil else { return }

        // The 2x crab stays catchable during answer feedback, exactly as the
        // passing power-up always has been.
        if let index = carriers.firstIndex(where: { carrier in
            carrier.kind == .bonus && carrier.isCarryingReward
                && within(point, of: carrier.position, radius: ArenaConfig.tapRadius(isPad: isPad))
        }), !hasBonusAura {
            carriers[index].isCarryingReward = false
            hasBonusAura = true
            burst(at: carriers[index].position, strength: 0.6)
            onBonusCrabCaught?()
            onTutorialEvent?(.caughtBonusCrab)
            return
        }

        guard isLive, !isResolvingWave else { return }

        let reach = ArenaConfig.tapRadius(isPad: isPad)
        let hit = crabs.indices
            .filter { crabs[$0].isTappable && within(point, of: hitCentre(of: crabs[$0]), radius: reach) }
            .min { distance(point, hitCentre(of: crabs[$0])) < distance(point, hitCentre(of: crabs[$1])) }
        guard let index = hit else { return }

        if crabs[index].isCorrect {
            // The session has the final say. If it does not take it — feedback
            // still playing, round already resolved — nothing happens at all.
            guard onSmashedGuard?() == true else { return }
            isResolvingWave = true
            pendingWaveRestart = true
            smash(index: index, from: point)
            // Every other crab gives up and digs itself back in, so the arena
            // is clear for the next attempt without a long wait.
            burrowLiveCrabs()
        } else {
            smash(index: index, from: point)
            onSmash?(false)
            onTutorialEvent?(.smashedWrongCrab)
            if !crabs.contains(where: { $0.isLive }) {
                onTutorialEvent?(.clearedWave)
            }
        }
    }

    /// The shell is carried well above the body, so the middle of what a child
    /// actually aims at sits between the two — a radius measured from the feet
    /// would miss the answer they were pointing at.
    private func hitCentre(of crab: AnswerCrab) -> CGPoint {
        CGPoint(x: crab.position.x, y: crab.position.y - crabSize * 0.55)
    }

    private func within(_ point: CGPoint, of centre: CGPoint, radius: CGFloat) -> Bool {
        let dx = point.x - centre.x
        let dy = point.y - centre.y
        return dx * dx + dy * dy <= radius * radius
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }

    private func smash(index: Int, from point: CGPoint) {
        var crab = crabs[index]
        crab.phase = .smashed
        crab.phaseAge = 0
        // Thrown away from the finger and up out of the sand, so the hit reads
        // as a blow rather than as a disappearance.
        let dx = crab.position.x - point.x
        let dy = crab.position.y - point.y
        let length = max(1, hypot(dx, dy))
        crab.flingVelocity = CGPoint(x: dx / length * CGFloat.random(in: 220...320),
                                     y: dy / length * 90 - CGFloat.random(in: 240...330))
        crab.spin = Double.random(in: -9...9)
        crabs[index] = crab
        burst(at: crab.position, strength: 1.0)
        if crab.isCorrect { onSmash?(true) }
    }

    /// Every crab still walking digs itself back into the sand. Short and
    /// unmistakable: the attempt is over, and the next one is seconds away.
    private func burrowLiveCrabs() {
        for index in crabs.indices where crabs[index].isLive {
            crabs[index].phase = .burrowing
            crabs[index].phaseAge = 0
            burst(at: crabs[index].position, strength: 0.55)
        }
    }

    // MARK: Waves

    /// Walks one crab in from each side of the screen: the right answer and
    /// three wrong ones, in a fresh arrangement every time, so nothing about
    /// where the answer comes from can be learned.
    private func beginWave() {
        // Anything already thrown or digging itself in keeps its animation: the
        // new wave arrives over the top of the old one leaving.
        crabs.removeAll { $0.isLive }
        sweepGather = nil
        isResolvingWave = false
        pendingWaveRestart = false
        guard let round, arena.height > 0, !tutorialPlan.suppressesAnswers else { return }

        let options = waveOptions(from: round)
        guard !options.isEmpty else { return }
        let entries = Array(entryPoints.shuffled().prefix(options.count))
        let ring = kingSize * ArenaConfig.arrivalRingFactor

        for (index, option) in options.enumerated() {
            let entry = entries[index]
            let angle = atan2(Double(entry.y - king.position.y),
                              Double(entry.x - king.position.x))
            let target = CGPoint(x: king.position.x + ring * CGFloat(cos(angle)),
                                 y: king.position.y + ring * CGFloat(sin(angle)))
            let start = offscreenStart(for: entry)
            // Where along the walk the answer can be read: the number sits in
            // the middle of the shell, so that happens well before the crab is
            // all the way in. Up to there it hurries; from there it walks, so
            // the time the player has to read an answer is the time they have
            // always had — they just get it sooner.
            let span = target.x - start.x
            let entryProgress = abs(span) < 1
                ? 0
                : min(0.6, max(0, Double((readablePoint(for: entry) - start.x) / span)))
            crabs.append(AnswerCrab(
                optionID: option.id,
                text: option.text,
                isCorrect: option.isCorrect,
                start: start,
                target: target,
                position: start,
                entryProgress: entryProgress,
                duration: GameConfig.crabWalkDuration
                    * Double.random(in: GameConfig.crabWalkVariation),
                startDelay: Double.random(in: GameConfig.crabStartStagger),
                waddleAmplitude: crabSize * CGFloat.random(in: 0.05...0.10),
                // One sway per pair of steps: the body leans onto the legs that
                // are carrying it.
                waddleRate: Double.random(in: 3.4...4.6),
                strideFactor: CGFloat.random(in: 0.90...1.12),
                gaitOffset: Double.random(in: 0..<(2 * .pi)),
                cardLean: Double.random(in: -5...5),
                scuttleRate: Double.random(in: 1.6...2.6),
                scuttlePhase: Double.random(in: 0..<(2 * .pi)),
                facing: target.x >= start.x ? 1 : -1
            ))
        }
    }

    /// The four points a crab is fully on screen at, one per corner of the
    /// walking area. A crab starts outside the screen level with one of these
    /// and walks in through it, which is what keeps the pace of the walk from
    /// here on exactly what it has always been.
    private var entryPoints: [CGPoint] {
        let side = crabSize * 0.85 + ArenaConfig.sideInset(isPad: isPad)
        // The shell is carried above the head, so the two upper lanes run low
        // enough that a fresh answer never overlaps the sum.
        let top = crabSize * 0.75 + ArenaConfig.cardHeight(isPad: isPad) * 1.1
        let bottom = crabSize * 0.75
        return [
            CGPoint(x: arena.minX + side, y: arena.minY + top),
            CGPoint(x: arena.maxX - side, y: arena.minY + top),
            CGPoint(x: arena.minX + side, y: arena.maxY - bottom),
            CGPoint(x: arena.maxX - side, y: arena.maxY - bottom)
        ]
    }

    /// Where a crab starts: level with the point it walks in at, and only just
    /// far enough past the side of the screen to be out of sight. Any further
    /// out is ground it has to cover before the answer can be read.
    private func offscreenStart(for entry: CGPoint) -> CGPoint {
        let clearance = ArenaConfig.cardWidth(isPad: isPad) * 0.54 + 6
        return CGPoint(x: entry.x < arena.midX ? arena.minX - clearance
                                              : arena.maxX + clearance,
                       y: entry.y)
    }

    /// How far in a crab has to be for the number it carries to be readable:
    /// the shell's middle, and with it the answer, is over the screen by then.
    private func readablePoint(for entry: CGPoint) -> CGFloat {
        let inset = ArenaConfig.cardWidth(isPad: isPad) * 0.20
        return entry.x < arena.midX ? arena.minX + inset : arena.maxX - inset
    }

    /// The right answer and three wrong ones, shuffled. A walkthrough step may
    /// ask for fewer — never for more, since a wave has four corners.
    private func waveOptions(from round: GameRound) -> [AnswerOption] {
        let correct = round.correctOption
        let wrong = round.options.filter { !$0.isCorrect }.shuffled()

        if tutorialPlan.isActive, let wave = tutorialPlan.answers {
            var picks: [AnswerOption] = []
            if wave.correct > 0, let correct { picks.append(correct) }
            picks += wrong.prefix(wave.wrong)
            return picks.shuffled()
        }

        var picks = Array(wrong.prefix(max(0, GameConfig.answerBubbleCount - 1)))
        if let correct { picks.append(correct) }
        return picks.shuffled()
    }

    private func restartWaveIfReady() {
        guard pendingWaveRestart, isLive else { return }
        guard !crabs.contains(where: { $0.isLive }) else { return }
        pendingWaveRestart = false
        beginWave()
    }

    /// The sea floor keeps offering the same answers for as long as the sum
    /// stands. A wave that ends without settling the question — every crab
    /// smashed or swept, and the right answer still unanswered — is followed by
    /// a fresh one after a short breather rather than by an empty arena.
    private func refillWaveIfEmpty(_ dt: Double) {
        guard isLive,
              round != nil,
              !pendingWaveRestart,
              sweepGather == nil,
              !tutorialPlan.suppressesAnswers,
              !crabs.contains(where: { $0.isLive || $0.phase == .arrived })
        else {
            refillDelay = nil
            return
        }
        let remaining = (refillDelay ?? ArenaConfig.waveRefillGap) - dt
        guard remaining <= 0 else {
            refillDelay = remaining
            return
        }
        refillDelay = nil
        beginWave()
    }

    // MARK: Simulation

#if canImport(UIKit)
    /// Uses the display's real presentation interval. This keeps motion at the
    /// same speed when a frame is late and lets ProMotion devices render the
    /// simulation at their native cadence instead of repeating every frame.
    private func advance(_ displayLink: CADisplayLink) {
        let target = displayLink.targetTimestamp
        let measured = lastFrameTargetTimestamp.map { target - $0 }
            ?? (target - displayLink.timestamp)
        lastFrameTargetTimestamp = target
        // Do not let a debugger stop or a transient system stall teleport a crab
        // into the King. Normal 60/120 Hz intervals pass unchanged.
        tick(dt: min(max(measured, 1.0 / 120.0), 1.0 / 30.0))
    }
#endif

    private func tick(dt: Double) {
        moveMotes(dt)
        moveGrains(dt)
        moveShells(dt)
        moveKing(dt)

        if completionElapsed != nil {
            moveLevelCompletion(dt)
            advanceClocks(dt)
            return
        }

        moveAmbientBubbles(dt)
        spawnAmbientBubbleIfDue(dt)
        moveCrabs(dt)
        moveCarriers(dt)
        spawnBonusCrabIfDue(dt)
        spawnLifeCrabIfDue(dt)
        spawnTutorialCrabIfDue(dt)
        resolveSweepIfDue(dt)
        restartWaveIfReady()
        refillWaveIfEmpty(dt)
        // Publish only after every part of this frame has been simulated, so
        // SwiftUI observes one coherent scene rather than intermediate state.
        advanceClocks(dt)
    }

    private func advanceClocks(_ dt: Double) {
        let nextClock = clock + dt
        swayClock = (nextClock / ArenaConfig.swayInterval).rounded(.down)
            * ArenaConfig.swayInterval
        driftClock = (nextClock / ArenaConfig.driftInterval).rounded(.down)
            * ArenaConfig.driftInterval
        // This is the one published write for the completed frame.
        clock = nextClock
    }

    // MARK: Crabs

    private func moveCrabs(_ dt: Double) {
        for index in crabs.indices {
            var crab = crabs[index]
            crab.age += dt
            crab.phaseAge += dt

            switch crab.phase {
            case .waiting:
                // It stands off the side of the screen until its turn in the
                // stagger comes, and then simply starts walking on.
                crab.startDelay -= dt
                if crab.startDelay <= 0 {
                    crab.phase = .walking
                    crab.phaseAge = 0
                }

            case .walking:
                // The walk is a straight line from off screen to the King; the
                // waddle and the scuttle only make it look like walking, never
                // like drifting. The scuttle averages out over its own cycle,
                // so the six seconds still hold.
                let scuttle = 1 + 0.32 * sin(crab.age * crab.scuttleRate + crab.scuttlePhase)
                // The on-screen stretch is the one the duration is about; the
                // rush over the last of the off-screen stretch eases out of
                // itself, so the crab arrives in view already walking.
                let onScreen = max(0.05, 1 - crab.entryProgress)
                var rate = onScreen / crab.duration
                if crab.progress < crab.entryProgress {
                    let left = 1 - crab.progress / crab.entryProgress
                    rate *= 1 + (ArenaConfig.approachRush - 1) * left * left
                }
                crab.progress = min(1, crab.progress + dt * speedMultiplier * scuttle * rate)
                let eased = crab.progress
                let base = CGPoint(
                    x: crab.start.x + (crab.target.x - crab.start.x) * CGFloat(eased),
                    y: crab.start.y + (crab.target.y - crab.start.y) * CGFloat(eased)
                )
                let along = CGVector(dx: crab.target.x - crab.start.x,
                                     dy: crab.target.y - crab.start.y)
                let length = max(1, hypot(along.dx, along.dy))
                // Sideways sway across the line of travel, one lean per pair of
                // steps, which is how a crab actually crosses open ground.
                let sway = CGFloat(sin(crab.age * crab.waddleRate)) * crab.waddleAmplitude
                let stepped = CGPoint(x: base.x - along.dy / length * sway,
                                      y: base.y + along.dx / length * sway)
                crab.walked += hypot(stepped.x - crab.position.x,
                                     stepped.y - crab.position.y)
                crab.position = stepped
                if crab.progress >= 1 {
                    crab.phase = .arrived
                    crab.phaseAge = 0
                    crab.position = crab.target
                    if sweepGather == nil { sweepGather = ArenaConfig.sweepGather }
                }

            case .arrived:
                // Held at the ring, shuffling in place until the King answers.
                let jitter = CGFloat(sin(crab.age * 11)) * crabSize * 0.02
                crab.position = CGPoint(x: crab.target.x + jitter, y: crab.target.y)

            case .smashed, .swept:
                crab.position.x += crab.flingVelocity.x * CGFloat(dt)
                crab.position.y += crab.flingVelocity.y * CGFloat(dt)
                crab.flingVelocity.y += 1_050 * CGFloat(dt)

            case .burrowing:
                // Straight down into the sand, no travel.
                break
            }
            crabs[index] = crab
        }

        crabs.removeAll { crab in
            switch crab.phase {
            case .smashed:   return crab.phaseAge >= ArenaConfig.smashDuration
            case .burrowing: return crab.phaseAge >= ArenaConfig.burrowDuration
            case .swept:     return crab.phaseAge >= ArenaConfig.sweptDuration
            default:         return false
            }
        }
    }

    // MARK: The King

    private func moveKing(_ dt: Double) {
        if var age = king.entranceAge {
            age += dt
            if !entranceDidOpenRound,
               age >= ArenaConfig.entranceDuration - ArenaConfig.entranceAnswerLead {
                entranceDidOpenRound = true
                let completion = entranceCompletion
                entranceCompletion = nil
                completion?()
            }
            king.entranceAge = age >= ArenaConfig.entranceDuration ? nil : age
            if king.entranceAge == nil, !entranceDidOpenRound {
                // Normally delivered during the rise, but keep a fallback so a
                // future timing change can never stall play.
                entranceDidOpenRound = true
                let completion = entranceCompletion
                entranceCompletion = nil
                completion?()
            }
        }
        if var age = king.sweepAge {
            age += dt
            king.sweepAge = (age >= ArenaConfig.sweepDuration && !king.isCheering) ? nil : age
        }
        if var age = king.healAge {
            age += dt
            king.healAge = age >= ArenaConfig.healDuration ? nil : age
        }
    }

    /// One blow answers everything standing at the ring. Two crabs arriving all
    /// but together therefore produce a single sweep, and their score and life
    /// consequences are applied afterwards, one by one.
    private func resolveSweepIfDue(_ dt: Double) {
        guard var remaining = sweepGather else { return }
        remaining -= dt
        guard remaining <= 0 else {
            sweepGather = remaining
            return
        }
        sweepGather = nil

        let arrived = crabs.indices.filter { crabs[$0].phase == .arrived }
        guard !arrived.isEmpty else { return }

        king.sweepAge = 0
        king.sweepDirection = Bool.random() ? 1 : -1
        onSweep?()

        // Wrong answers land first: they are what the King is being hit with,
        // and the right answer is what he is left holding.
        var scored = false
        for index in arrived where !crabs[index].isCorrect {
            onBreach?()
        }
        if let index = arrived.first(where: { crabs[$0].isCorrect }) {
            scored = onGuardedArrival?(crabs[index].optionID) == true
        }

        for index in arrived {
            fling(index: index)
        }
        if scored {
            // The sum is about to change, so nothing else is left walking.
            for index in crabs.indices where crabs[index].isLive {
                fling(index: index)
            }
            emitShell()
        }
    }

    private func fling(index: Int) {
        var crab = crabs[index]
        let dx = crab.position.x - king.position.x
        let dy = crab.position.y - king.position.y
        let length = max(1, hypot(dx, dy))
        crab.phase = .swept
        crab.phaseAge = 0
        crab.flingVelocity = CGPoint(x: dx / length * CGFloat.random(in: 420...560),
                                     y: dy / length * 260 - CGFloat.random(in: 180...260))
        crab.spin = Double.random(in: -13...13)
        crabs[index] = crab
    }

    /// The shell a scored answer sends to the HUD, along a curve that leaves the
    /// King and settles exactly over its stationary twin in the score counter.
    private func emitShell() {
        let diameter: CGFloat = isPad ? 34 : 26
        let start = CGPoint(x: king.position.x, y: king.position.y - kingSize * 0.46)
        let target = scoreTarget ?? CGPoint(x: size.width / 2,
                                            y: max(diameter / 2, arena.minY - 30))
        let firstControl = CGPoint(x: start.x + (start.x - target.x) * 0.18,
                                   y: start.y - kingSize * 0.42)
        let secondControl = CGPoint(x: target.x + (start.x - target.x) * 0.24,
                                    y: start.y + (target.y - start.y) * 0.72)
        shells.append(ShellReward(diameter: diameter,
                                  start: start,
                                  firstControl: firstControl,
                                  secondControl: secondControl,
                                  target: target,
                                  position: start))
    }

    private func moveShells(_ dt: Double) {
        for index in shells.indices {
            shells[index].age += dt
            let raw = min(1, shells[index].age / ArenaConfig.shellFlightDuration)
            let t = CGFloat(raw * raw * (3 - 2 * raw))
            let shell = shells[index]
            shells[index].position = cubicPoint(from: shell.start,
                                                control1: shell.firstControl,
                                                control2: shell.secondControl,
                                                to: shell.target,
                                                t: t)
        }
        let arrived = shells.reduce(into: 0) { count, shell in
            if shell.age >= ArenaConfig.shellFlightDuration { count += 1 }
        }
        shells.removeAll { $0.age >= ArenaConfig.shellFlightDuration }
        for _ in 0..<arrived { onShellArrived?() }
    }

    private func cubicPoint(from start: CGPoint, control1: CGPoint,
                            control2: CGPoint, to end: CGPoint,
                            t: CGFloat) -> CGPoint {
        let remaining = 1 - t
        let a = remaining * remaining * remaining
        let b = 3 * remaining * remaining * t
        let c = 3 * remaining * t * t
        let d = t * t * t
        return CGPoint(x: a * start.x + b * control1.x + c * control2.x + d * end.x,
                       y: a * start.y + b * control1.y + c * control2.y + d * end.y)
    }

    // MARK: Carrier crabs

    private func spawnBonusCrabIfDue(_ dt: Double) {
        // While the walkthrough is running, the only helper crab in the arena is
        // the one the current step put there.
        guard !tutorialPlan.isActive,
              carriers.isEmpty,
              !hasBonusAura,
              !pendingBonusDelays.isEmpty,
              arena.height > 0 else { return }
        pendingBonusDelays[0] -= dt
        guard pendingBonusDelays[0] <= 0 else { return }
        pendingBonusDelays.removeFirst()
        spawnBonusCrab()
    }

    private func spawnBonusCrab() {
        let size = ArenaConfig.bonusCrabSize(isPad: isPad)
        let direction: CGFloat = Bool.random() ? 1 : -1
        let start = CGPoint(x: direction > 0 ? -size : arena.maxX + size,
                            y: bonusCrabLane(size: size))
        let target = CGPoint(x: direction > 0 ? arena.maxX + size : -size, y: start.y)
        let travel = Double(abs(target.x - start.x))
        carriers.append(CarrierCrab(
            kind: .bonus,
            size: size,
            start: start,
            target: target,
            position: start,
            duration: travel / Double(CGFloat.random(in: ArenaConfig.bonusCrabSpeed)),
            waddleRate: Double.random(in: 4.4...6.0),
            strideFactor: CGFloat.random(in: 0.92...1.08),
            facing: direction
        ))
    }

    /// A crossing height clear of the King, so the 2x crab never scuttles
    /// behind him. It takes whichever band above or below has the room.
    private func bonusCrabLane(size: CGFloat) -> CGFloat {
        let above = (arena.minY + size, king.position.y - kingSize * 0.72)
        let below = (king.position.y + kingSize * 0.72, arena.maxY - size)
        let lanes = [above, below].filter { $0.1 - $0.0 > size * 0.5 }
        guard let lane = lanes.randomElement() else { return arena.midY }
        return CGFloat.random(in: lane.0...lane.1)
    }

    private func spawnLifeCrabIfDue(_ dt: Double) {
        guard !tutorialPlan.isActive,
              carriers.isEmpty,
              isLifeCrabAvailable,
              var delay = lifeCrabDelay,
              arena.height > 0 else { return }
        delay -= dt
        lifeCrabDelay = delay
        guard delay <= 0 else { return }
        lifeCrabDelay = nil
        spawnLifeCrab()
    }

    /// The comeback crab walks in from a side rather than from a corner, so it
    /// is never mistaken for one of the four answers.
    private func spawnLifeCrab() {
        let size = ArenaConfig.lifeCrabSize(isPad: isPad)
        let fromLeft = Bool.random()
        let start = CGPoint(x: fromLeft ? -size : arena.maxX + size,
                            y: king.position.y + CGFloat.random(in: -20...20))
        let ring = kingSize * ArenaConfig.arrivalRingFactor
        let target = CGPoint(x: king.position.x + (fromLeft ? -ring : ring),
                             y: king.position.y)
        carriers.append(CarrierCrab(
            kind: .life,
            size: size,
            start: start,
            target: target,
            position: start,
            duration: GameConfig.lifeCrabWalkDuration,
            waddleRate: Double.random(in: 3.2...4.2),
            strideFactor: CGFloat.random(in: 0.92...1.08),
            facing: fromLeft ? 1 : -1
        ))
    }

    /// Puts the taught helper crab in the arena, and puts it back whenever it
    /// crosses without being taken: a step ends because the player managed it,
    /// never because they were unlucky.
    private func spawnTutorialCrabIfDue(_ dt: Double) {
        guard tutorialPlan.isActive,
              tutorialPlan.wantsLifeCrab || tutorialPlan.wantsBonusCrab,
              arena.height > 0,
              !carriers.contains(where: \.isCarryingReward) else { return }

        guard var delay = tutorialCrabDelay else {
            tutorialCrabDelay = ArenaConfig.tutorialCrabArrival
            return
        }
        delay -= dt
        tutorialCrabDelay = delay
        guard delay <= 0 else { return }
        tutorialCrabDelay = nil
        if tutorialPlan.wantsLifeCrab {
            spawnLifeCrab()
        } else {
            spawnBonusCrab()
        }
    }

    private func moveCarriers(_ dt: Double) {
        for index in carriers.indices {
            var carrier = carriers[index]
            carrier.progress = min(1, carrier.progress + dt / carrier.duration)
            let base = CGPoint(
                x: carrier.start.x + (carrier.target.x - carrier.start.x) * CGFloat(carrier.progress),
                y: carrier.start.y + (carrier.target.y - carrier.start.y) * CGFloat(carrier.progress)
            )
            let stepped = CGPoint(
                x: base.x,
                y: base.y + CGFloat(sin(clock * carrier.waddleRate)) * carrier.size * 0.045
            )
            carrier.walked += hypot(stepped.x - carrier.position.x,
                                    stepped.y - carrier.position.y)
            carrier.position = stepped
            carriers[index] = carrier
        }

        // A life crab that reaches the King hands its life over; a 2x crab that
        // reaches the far side simply leaves.
        for index in carriers.indices where carriers[index].progress >= 1 {
            let carrier = carriers[index]
            guard carrier.kind == .life, carrier.isCarryingReward else { continue }
            carriers[index].isCarryingReward = false
            if onLifeCrabArrived?() == true {
                king.healAge = 0
            }
            onTutorialEvent?(.lifeCrabArrived)
        }
        carriers.removeAll { carrier in
            guard carrier.progress >= 1 else { return false }
            // In the walkthrough a missed 2x crab simply comes back: its step is
            // not over until the player has actually taken one.
            if carrier.isCarryingReward, tutorialPlan.wantsBonusCrab {
                tutorialCrabDelay = ArenaConfig.tutorialCrabArrival
            }
            return true
        }
    }

    // MARK: Sand

    /// A puff of sand. Used by everything that meets the sea floor hard enough
    /// to disturb it: an emerging crab, a smashed one, a burrowing one.
    private func burst(at point: CGPoint, strength: CGFloat) {
        let count = max(3, Int(CGFloat(ArenaPerformanceBudget.grainsPerBurst) * strength))
        for _ in 0..<count {
            let angle = Double.random(in: -Double.pi ... 0)
            let speed = CGFloat.random(in: 60...190) * strength
            grains.append(SandGrain(
                position: CGPoint(x: point.x + CGFloat.random(in: -6...6),
                                  y: point.y + crabSize * 0.30 + CGFloat.random(in: -4...4)),
                velocity: CGPoint(x: CGFloat(cos(angle)) * speed,
                                  y: CGFloat(sin(angle)) * speed),
                radius: CGFloat.random(in: 1.6...4.4) * (0.7 + strength * 0.5),
                tone: Double.random(in: 0...1),
                lifetime: Double.random(in: 0.34...0.62)
            ))
        }
    }

    private func moveGrains(_ dt: Double) {
        for index in grains.indices {
            grains[index].age += dt
            grains[index].position.x += grains[index].velocity.x * CGFloat(dt)
            grains[index].position.y += grains[index].velocity.y * CGFloat(dt)
            // Sand thrown up underwater slows quickly and drifts back down.
            grains[index].velocity.y += 420 * CGFloat(dt)
            let damping = CGFloat(pow(0.22, dt))
            grains[index].velocity.x *= damping
        }
        grains.removeAll { $0.age >= $0.lifetime }
    }

    // MARK: Ambience

    private func moveMotes(_ dt: Double) {
        guard size.height > 0 else { return }
        for index in motes.indices {
            motes[index].age += dt
            var mote = motes[index]
            mote.position.y -= mote.speed * CGFloat(dt)
            let sway = sin(mote.age * 2 * .pi / mote.period + mote.phase)
            mote.position.x = mote.baseX + mote.sway * CGFloat(sway)
            if mote.position.y < -mote.radius {
                mote.position.y = size.height + mote.radius
            }
            motes[index] = mote
        }
    }

    private func spawnAmbientBubbleIfDue(_ dt: Double) {
        ambientBubbleCountdown -= dt
        guard ambientBubbleCountdown <= 0 else { return }
        ambientBubbleCountdown = Double.random(in: ArenaConfig.ambientBubbleGap)
        guard ambientBubbles.count < ArenaConfig.maximumAmbientBubbles,
              size.width > 0, arena.height > 0 else { return }

        let inset = ArenaConfig.sideInset(isPad: isPad)
            + ArenaConfig.ambientBubbleRadius.upperBound
        let x = CGFloat.random(in: inset...max(inset, size.width - inset))
        ambientBubbles.append(ReefAmbientBubble(
            baseX: x,
            position: CGPoint(x: x, y: arena.maxY - CGFloat.random(in: 0...40)),
            radius: CGFloat.random(in: ArenaConfig.ambientBubbleRadius),
            speed: CGFloat.random(in: ArenaConfig.ambientBubbleSpeed),
            phase: Double.random(in: 0..<(2 * .pi))
        ))
    }

    private func moveAmbientBubbles(_ dt: Double) {
        for index in ambientBubbles.indices {
            ambientBubbles[index].age += dt
            if ambientBubbles[index].popAge != nil {
                ambientBubbles[index].popAge! += dt
                continue
            }
            ambientBubbles[index].position.y -= ambientBubbles[index].speed * CGFloat(dt)
            ambientBubbles[index].position.x = ambientBubbles[index].baseX
                + CGFloat(sin(ambientBubbles[index].age * 2.4
                              + ambientBubbles[index].phase)) * 8
        }
        ambientBubbles.removeAll { bubble in
            if let popAge = bubble.popAge {
                return popAge >= ArenaConfig.ambientBubblePopDuration
            }
            return bubble.position.y < -bubble.radius * 2
        }
    }

    // MARK: Level completion

    private func moveLevelCompletion(_ dt: Double) {
        guard let elapsed = completionElapsed else { return }
        let next = elapsed + dt

        if !reducesCompletionMotion {
            completionSpeckCountdown -= dt
            if completionSpeckCountdown <= 0 {
                completionSpeckCountdown = ArenaPerformanceBudget.celebrationInterval
                spawnCelebrationSpeck()
            }
        }
        moveCelebration(dt)

        completionElapsed = next
        let duration = reducesCompletionMotion ? 0.9 : ArenaConfig.completionDuration
        if next >= duration {
            completionElapsed = nil
            king.isCheering = false
            king.sweepAge = nil
            let callback = completionCallback
            completionCallback = nil
            callback?()
        }
    }

    private func spawnCelebrationSpeck() {
        guard size.width > 0 else { return }
        let x = CGFloat.random(in: 0...size.width)
        celebration.append(CelebrationSpeck(
            position: CGPoint(x: x, y: arena.maxY + 10),
            radius: CGFloat.random(in: isPad ? 6...16 : 5...12),
            speed: CGFloat.random(in: 110...230),
            phase: Double.random(in: 0..<(2 * .pi)),
            // Roughly one in three is a shell, so the finale reads as the
            // currency being showered rather than as plain bubbles.
            kind: Int.random(in: 0..<3) == 0 ? .shell : .bubble
        ))
    }

    private func moveCelebration(_ dt: Double) {
        for index in celebration.indices {
            celebration[index].age += dt
            celebration[index].position.y -= celebration[index].speed * CGFloat(dt)
            celebration[index].position.x += CGFloat(sin(
                celebration[index].age * 3 + celebration[index].phase
            )) * CGFloat(dt) * 11
        }
        celebration.removeAll { $0.position.y < -$0.radius * 2 }
    }
}
