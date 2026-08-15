//
//  KingCrabPlayfield.swift
//  King Krab
//
//  Everything the arena looks like: the water, the sea floor, the sum at the
//  top, the King in the middle and the crabs walking in on him. The simulation
//  itself lives in `KingCrabArena`; this file only draws what that simulation
//  reports and hands touches back to it.
//
//  Deliberately never mirrored. Below the HUD this is a physical space — a crab
//  entering bottom-left really is entering bottom-left — so a right-to-left
//  language flips the text and the HUD around it, never the arena itself.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Playfield

/// The two things a wave is laid out from, observed as one value so they can
/// never reach the arena a round apart. See the `onChange` that uses it.
private struct WaveInput: Equatable {
    let round: GameRound?
    let isGolden: Bool
}

struct KingCrabPlayfield: View {
    let round: GameRound?
    let maximumRounds: Int
    let character: AnimalCharacter
    let isPad: Bool
    /// Whether an answer may be taken right now.
    let isLive: Bool
    /// Whether the simulation runs at all.
    let isRunning: Bool
    /// True between dismissing the level card and opening the first round.
    let playsKingEntrance: Bool
    let hasBonusPower: Bool
    let isLifeCrabAvailable: Bool
    let isStreakBoostActive: Bool
    let playsLevelCompletion: Bool
    let reduceMotion: Bool
    /// What the walkthrough wants in the arena, if one is running.
    var tutorialPlan = CrabTutorialPlan()
    /// Screen edges the arena works around: the HUD at the top, the home
    /// indicator at the bottom.
    let topReserve: CGFloat
    let bottomReserve: CGFloat
    /// Exact global centre of the currency icon in the overlaid HUD.
    let scoreTarget: CGPoint?

    /// Hands the answer a crab delivered to the session; the return value says
    /// whether it counted.
    let onGuardedArrival: (UUID) -> Bool
    /// The player smashed the crab carrying the right answer.
    let onSmashedGuard: () -> Bool
    /// A wrong answer reached the King.
    let onBreach: () -> Void
    /// A crab was smashed; the flag says whether it was the guarded one.
    let onSmash: (Bool) -> Void
    let onSweep: () -> Void
    let onShellArrived: () -> Void
    let onBonusCrabCaught: () -> Void
    let onLifeCrabArrived: () -> Bool
    let onKingEntranceComplete: () -> Void
    let onLevelCompletionFinished: () -> Void
    /// Everything the walkthrough waits on that only the arena can see.
    var onTutorialEvent: (CrabTutorialEvent) -> Void = { _ in }

    @StateObject private var arena = KingCrabArena()

    private var palette: ReefPalette { ReefPalette.palette(for: character) }

    /// Where the sum's banner sits, and therefore where the walking area starts.
    private var bannerTop: CGFloat { topReserve + (isPad ? 12 : 8) }

    /// The walkthrough's message card hangs under the sum, so while one is
    /// running the crabs walk below it rather than behind it.
    private var arenaTop: CGFloat {
        bannerTop + ArenaConfig.bannerHeight(isPad: isPad) + (isPad ? 26 : 18)
            + (tutorialPlan.isActive ? ArenaConfig.tutorialMessageReserve(isPad: isPad) : 0)
    }

    /// `top` overrides `arenaTop` for callers that already hold a newer value
    /// than the view does — an `onChange` closure on iOS 16 sees the previous
    /// `arenaTop`, so the one it is handed has to be passed in explicitly.
    private func arenaRect(in size: CGSize, top: CGFloat? = nil) -> CGRect {
        let bottom = size.height - bottomReserve - ArenaConfig.floorInset(isPad: isPad)
        let top = min(top ?? arenaTop, max(0, bottom - 120))
        return CGRect(x: 0, y: top, width: size.width, height: max(1, bottom - top))
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let rect = arenaRect(in: size)

            // A third water, two thirds floor. The cap holds that even when
            // something claims the top of the arena — the walkthrough's
            // message card takes over a hundred points of it — so the sea
            // floor never ends up starting halfway down the screen.
            let crest = min(rect.minY + ArenaConfig.floorCrest(isPad: isPad),
                            size.height * 0.38)
            // Where the sun lands, as a share of the sand bed. The King is the
            // thing the eye is meant to be carried down to, so the warm patch
            // on the floor is put under him rather than in the middle of the
            // sand — which is a good deal higher, and reads as a spotlight
            // aimed at nothing.
            let sunShare = (rect.minY + rect.height * ArenaConfig.kingAnchorShare - crest)
                / max(1, size.height - crest)

            // Seven layers, back to front: open water and its surface; the weed
            // silhouetted against it; the sea floor with its own reef; the
            // depth down both edges; the light coming through all of it; the
            // animals; and the water itself in front of them.
            ZStack(alignment: .topLeading) {
                WaterColumn(palette: palette, clock: arena.driftClock)
                    .equatable()

                DistantWeeds(palette: palette, crest: crest, clock: arena.swayClock)
                    .equatable()
                    .frame(width: size.width, height: size.height)

                ArenaFloor(palette: palette,
                           isPad: isPad,
                           crest: crest,
                           sunShare: sunShare,
                           clock: arena.swayClock)
                    .equatable()
                    .frame(width: size.width, height: size.height)

                // Over the scenery, under the animals: the edges of the arena
                // fall away into the water without ever dimming a crab.
                DepthVignette(palette: palette)
                    .equatable()
                    .frame(width: size.width, height: size.height)

                LightShafts(clock: arena.driftClock, isPad: isPad)
                    .equatable()
                    .frame(width: size.width, height: size.height)

                ArenaEffectsCanvas(motes: arena.motes,
                                   ambientBubbles: arena.ambientBubbles,
                                   grains: arena.grains,
                                   palette: palette)
                    .allowsHitTesting(false)

                // The King is drawn before the crabs, so a crab reaching him
                // passes in front of his claws rather than behind his shell.
                KingCrabView(king: arena.king,
                             character: character,
                             palette: palette,
                             isPad: isPad,
                             clock: arena.clock,
                             hasBonusPower: arena.hasBonusAura)
                    .position(arena.king.position)
                    .allowsHitTesting(false)

                ForEach(arena.crabs) { crab in
                    AnswerCrabView(crab: crab,
                                   palette: palette,
                                   isPad: isPad,
                                   isGolden: crab.isGolden,
                                   clock: arena.clock,
                                   king: arena.king.anchor)
                        .position(crab.position)
                        .allowsHitTesting(false)
                }

                // The two near corners, in front of the animals: they are the
                // closest thing in the scene, so a crab walking the lower lane
                // comes out from behind the coral rather than over the top of
                // it. The lane itself runs above the reef's own crest — see
                // `ArenaConfig.nearReefRise` — so the answer being carried is
                // in clear water the whole way in.
                NearReef(palette: palette,
                         isPad: isPad,
                         crest: crest,
                         clock: arena.swayClock)
                    .equatable()
                    .frame(width: size.width, height: size.height)
                    .allowsHitTesting(false)

                // Nearer still: the helper crabs walk the very front edge of
                // the floor, in front of the reef and everything behind it.
                ForEach(arena.carriers) { carrier in
                    CarrierCrabView(carrier: carrier,
                                    palette: palette,
                                    isPad: isPad,
                                    clock: arena.clock)
                        .position(carrier.position)
                        .allowsHitTesting(false)
                }

                ForEach(arena.shells) { shell in
                    ShellRewardView(shell: shell, palette: palette, isPad: isPad)
                        .position(shell.position)
                        .allowsHitTesting(false)
                }

                // Over the animals, under the sum — exactly where a `ForEach` of
                // speck views used to sit. The streak throws up to a hundred of
                // these at once, and as views each one carried its own layout,
                // its own `.position` and its own gradient; one immediate-mode
                // pass draws the lot for the cost of the paths themselves.
                CelebrationCanvas(specks: arena.celebration, palette: palette)
                    .allowsHitTesting(false)

                // Water in front of the arena rather than behind it. A few
                // specks too close to the eye to be in focus is the whole of
                // it, and it is the difference between looking at the reef and
                // being in the water with it.
                NearDrift(clock: arena.swayClock)
                    .equatable()
                    .frame(width: size.width, height: size.height)
                    .allowsHitTesting(false)

                // The sum sits above everything: no crab and no sand may ever
                // cover the question the player is answering.
                QuestionBanner(prompt: round?.question.prompt ?? "",
                               roundID: round?.id,
                               palette: palette,
                               isPad: isPad)
                    .frame(width: size.width - (isPad ? 120 : 34),
                           height: ArenaConfig.bannerHeight(isPad: isPad))
                    .position(x: size.width / 2,
                              y: bannerTop + ArenaConfig.bannerHeight(isPad: isPad) / 2)
                    .opacity(playsLevelCompletion ? 0 : 1)
                    .allowsHitTesting(false)
            }
            .frame(width: size.width, height: size.height)
            .contentShape(Rectangle())
#if canImport(UIKit)
            // A plain SwiftUI gesture only ever tracks one active touch, so a
            // child throwing sand with both thumbs at once — one crab on each
            // side — would have the second finger simply ignored until the
            // first lifts. This UIKit view underneath sees every finger down
            // as its own event, so simultaneous taps on either side of the
            // screen both land.
            .overlay(
                MultiTouchTapView { point in arena.tap(at: point) }
            )
#else
            .gesture(
                // Reacting on touch-down rather than on lift keeps smashing a
                // crab as immediate as hitting one: a child taps fast, and a
                // gesture that waits for the finger to leave feels broken.
                DragGesture(minimumDistance: 0)
                    .onChanged { value in arena.tap(at: value.startLocation) }
            )
#endif
            .allowsHitTesting(!playsLevelCompletion)
            // See the note on the type: the arena is a simulated space, so it
            // keeps its own orientation whatever the language reads like.
            .environment(\.layoutDirection, .leftToRight)
            .onAppear {
                arena.onGuardedArrival = onGuardedArrival
                arena.onSmashedGuard = onSmashedGuard
                arena.onBreach = onBreach
                arena.onSmash = onSmash
                arena.onSweep = onSweep
                arena.onShellArrived = onShellArrived
                arena.onBonusCrabCaught = onBonusCrabCaught
                arena.onLifeCrabArrived = onLifeCrabArrived
                arena.onTutorialEvent = onTutorialEvent
                arena.layout(size: size, arena: rect, isPad: isPad)
                arena.configureBonusCrab(maximumRounds: maximumRounds)
                arena.applyTutorial(tutorialPlan)
                // Before the round: a session resumed mid-streak has to lay its
                // first wave out gold rather than red.
                arena.setGolden(isStreakBoostActive)
                arena.load(round: round)
                arena.setLive(isLive)
                arena.setBonusAura(hasBonusPower)
                arena.setLifeCrabAvailable(isLifeCrabAvailable)
                arena.setSpeedMultiplier(isStreakBoostActive
                                         ? GameConfig.streakSpeedMultiplier : 1)
                arena.setScoreTarget(scoreTarget)
                arena.setClawTip(character.rig?.clawReach ?? ArenaConfig.clawTip)
                arena.setRunning(isRunning)
                if playsKingEntrance {
                    arena.beginKingEntrance(completion: onKingEntranceComplete)
                }
                if playsLevelCompletion {
                    arena.beginLevelCompletion(reduceMotion: reduceMotion,
                                               completion: onLevelCompletionFinished)
                }
            }
            .onChange(of: size) { newSize in
                arena.layout(size: newSize, arena: arenaRect(in: newSize), isPad: isPad)
            }
            .onChange(of: arenaTop) { newTop in
                arena.layout(size: size, arena: arenaRect(in: size, top: newTop), isPad: isPad)
            }
        }
        // A new sum sends in a fresh wave. Smashing the guarded answer keeps the
        // same round, so this deliberately does not fire for it.
        // Deliberately observes the round itself rather than its id: on iOS 16
        // `onChange(of:perform:)` runs its closure against the view value from
        // *before* the update, so reading `round` in here would still see the
        // previous one — nil on the very first round, which left the arena
        // without a wave and the sum blank. Only the value handed to the
        // closure is current, so the new round has to be the value observed.
        //
        // The gold flag rides along with the round rather than sitting in its
        // own `onChange`: a streak starts on the answer that also installs the
        // next sum, so two separate observers would race, and the wave would
        // come up in the colour the streak had one round ago. Observed
        // together, both values reach the arena in the same call. Only the
        // round drives the wave; `load` ignores a repeat of the sum it is
        // already showing, which is what a colour-only change looks like.
        .onChange(of: WaveInput(round: round, isGolden: isStreakBoostActive)) { input in
            arena.setGolden(input.isGolden)
            arena.load(round: input.round)
        }
        .onChange(of: isLive) { live in
            arena.setLive(live)
        }
        .onChange(of: isRunning) { running in
            arena.setRunning(running)
        }
        .onChange(of: hasBonusPower) { active in
            arena.setBonusAura(active)
        }
        .onChange(of: isLifeCrabAvailable) { available in
            arena.setLifeCrabAvailable(available)
        }
        .onChange(of: isStreakBoostActive) { active in
            arena.setSpeedMultiplier(active ? GameConfig.streakSpeedMultiplier : 1)
            // Only the streak landing is worth celebrating; it breaking is not.
            if active, !reduceMotion { arena.beginStreakCelebration() }
        }
        .onChange(of: scoreTarget) { target in
            arena.setScoreTarget(target)
        }
        .onChange(of: tutorialPlan) { plan in
            withAnimation(.easeInOut(duration: 0.25)) {
                arena.applyTutorial(plan)
            }
        }
        .onChange(of: playsKingEntrance) { shouldPlay in
            if shouldPlay {
                arena.beginKingEntrance(completion: onKingEntranceComplete)
            }
        }
        .onChange(of: playsLevelCompletion) { shouldPlay in
            if shouldPlay {
                arena.beginLevelCompletion(reduceMotion: reduceMotion,
                                           completion: onLevelCompletionFinished)
            } else {
                arena.endLevelCompletion()
            }
        }
        .onDisappear {
            arena.stop()
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - The sum

/// The equation, large and unmissable at the top of the screen. It changes with
/// a short dissolve so a new sum reads as a new sum rather than as a jump.
private struct QuestionBanner: View {
    let prompt: String
    let roundID: UUID?
    let palette: ReefPalette
    let isPad: Bool

    @State private var shownPrompt = ""
    @State private var isVisible = true

    var body: some View {
        Text(verbatim: shownPrompt)
            .font(.system(size: isPad ? 54 : 40, weight: .black, design: .rounded))
            .minimumScaleFactor(0.34)
            .lineLimit(1)
            .foregroundStyle(palette.coralDeep)
            .padding(.horizontal, isPad ? 30 : 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: isPad ? 34 : 26, style: .continuous)
                        .fill(.white.opacity(0.95))
                        .shadow(color: palette.coralDeep.opacity(0.26), radius: 12, y: 6)
                    // The same dashed edge the level cards use, so the sum reads
                    // as part of the app rather than as a new kind of panel.
                    RoundedRectangle(cornerRadius: isPad ? 27 : 20, style: .continuous)
                        .stroke(palette.coralDeep.opacity(0.30),
                                style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
                        .padding(isPad ? 8 : 6)
                }
            }
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.96)
            .onAppear { shownPrompt = prompt }
            // The round's id and its sum are observed together: the id is what
            // says a new question has come up (two rounds running may ask the
            // same sum), while the prompt has to travel with it because on
            // iOS 16 `onChange(of:perform:)` sees the view as it was *before*
            // the update — reading `prompt` in the closure would still give the
            // previous sum, and the empty one on the very first round.
            .onChange(of: Question(id: roundID, prompt: prompt)) { question in
                revealNewQuestion(question.prompt)
            }
            .accessibilityIdentifier("question-card")
            .accessibilityLabel(Text(L("game.question \(prompt)")))
    }

    /// The sum being asked, as one value so a single `onChange` carries both.
    private struct Question: Equatable {
        let id: UUID?
        let prompt: String
    }

    private func revealNewQuestion(_ newPrompt: String) {
        guard !shownPrompt.isEmpty else {
            shownPrompt = newPrompt
            return
        }
        withAnimation(.easeOut(duration: 0.10)) { isVisible = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
            shownPrompt = newPrompt
            withAnimation(.easeOut(duration: 0.20)) { isVisible = true }
        }
    }
}

// MARK: - The King

/// The player's own character, crowned, holding the middle of the sea floor.
/// Keeping the character here is what keeps every unlock meaningful: the animal
/// the player earned is the one they are defending.
private struct KingCrabView: View {
    let king: KingState
    let character: AnimalCharacter
    let palette: ReefPalette
    let isPad: Bool
    let clock: Double
    let hasBonusPower: Bool

    private var size: CGFloat { ArenaConfig.kingSize(isPad: isPad) }

    /// 0 → the sweep has just begun, 1 → it is over.
    private var sweep: Double? {
        king.sweepAge.map { min(1, $0 / ArenaConfig.sweepDuration) }
    }

    /// A slow breath at rest, a lurching stride while he is crossing the floor,
    /// a hard round-house while sweeping, and an outright jig once the level is
    /// won. Used for the characters that are drawn from one flat picture: the
    /// rigged King gets all of this out of his own limbs instead.
    private var lean: Double {
        if king.isCheering { return sin(clock * 7.5) * 13 }
        if let sweep, sweep < 1 {
            // One full swing out and back, so the blow lands and recovers.
            return sin(sweep * .pi * 2) * 18 * king.sweepDirection
        }
        return sin(clock * 1.4) * 1.6 + sin(king.stride) * 7 * king.effort
    }

    private var pulse: CGFloat {
        if king.isCheering { return 1 + CGFloat(abs(sin(clock * 5))) * 0.09 }
        guard let sweep, sweep < 1 else { return 1 + CGFloat(sin(clock * 1.9)) * 0.012 }
        return 1 + CGFloat(sin(sweep * .pi)) * 0.15
    }

    // MARK: The rigged pose

    /// Everything the King's own limbs are doing this frame, built up from the
    /// simulation: the gait underneath, then whichever of the sweep, the hop or
    /// the two claw throws is playing over the top of it.
    private var pose: KingRigPose {
        var pose = KingRigPose.idle(clock: clock, stride: king.stride, effort: king.effort)

        // The blow: he drops his weight and drives both claws down and out.
        if let sweep, sweep < 1 {
            let swing = sin(sweep * .pi * 2) * king.sweepDirection
            let drive = sin(sweep * .pi)
            pose.lean += swing * 10
            pose.stretch -= CGFloat(drive) * 0.10
            pose.leftClaw += -drive * 40 - swing * 10
            pose.rightClaw += drive * 40 - swing * 10
            pose.leftLegs -= drive * 8
            pose.rightLegs += drive * 8
        }

        // Winning the board: claws thrown up, and a hop he tucks his legs under.
        if let age = king.farewellAge {
            let hop = min(1, age / ArenaConfig.kingHopDuration)
            let tuck = sin(hop * .pi)
            if hop < 1 {
                // Crouch, spring, tuck, land. The squash is what sells it.
                pose.stretch += CGFloat(sin(hop * .pi) * 0.18 - (hop < 0.16 ? 0.12 : 0))
                pose.leftLegs -= tuck * 24
                pose.rightLegs += tuck * 24
            }
            if king.isCheering {
                pose.leftClaw -= 32 + sin(clock * 9) * 8
                pose.rightClaw += 32 + sin(clock * 9 + 1.2) * 8
            }
            if king.effort > 0 {
                // Running off: leaning into it, claws swept back.
                pose.lean += 7
                pose.leftClaw += 12
                pose.rightClaw += 12
            }
        }

        // The streak: both claws swing up over the crown until the pincers
        // meet. Positive lifts the left claw and drops the right, so the two
        // sides take the same number with opposite signs.
        if let age = king.streakAge {
            let t = min(1, age / ArenaConfig.streakCelebrationDuration)
            let raise = streakClaw(t) * ArenaConfig.streakCelebrationClawTouch
            pose.leftClaw += raise
            pose.rightClaw -= raise
            // He draws himself up as the claws go, and sinks a little into the
            // dip that starts it.
            pose.stretch += CGFloat(streakClaw(t)) * 0.07
        }

        pose.leftClaw += throwAngle(king.leftClaw, isRight: false)
        pose.rightClaw += throwAngle(king.rightClaw, isRight: true)
        return pose
    }

    /// The claws through the celebration, as a share of the full turn that
    /// brings the two pincers together: down first, then all the way up, held
    /// there while it reads, and back down to rest. Negative is the dip.
    private func streakClaw(_ t: Double) -> Double {
        let dip = 0.16       // down
        let up = 0.46        // and all the way over the crown
        let hold = 0.78      // held together
        let low = -ArenaConfig.streakCelebrationClawDip
        func ease(_ u: Double) -> Double { u * u * (3 - 2 * u) }

        if t < dip { return low * ease(t / dip) }
        if t < up { return low + (1 - low) * ease((t - dip) / (up - dip)) }
        if t < hold { return 1 }
        return 1 - ease((t - hold) / (1 - hold))
    }

    /// One throw: the claw cocks up, snaps out to full reach — which is where
    /// the sand leaves it — and eases home.
    ///
    /// Turning a claw *inward* carries it up toward the crown, so the wind-up
    /// stays the smaller of the two moves: enough to read as a wind-up while
    /// the pincer stays clear of the head. The strike is the big one, and it
    /// throws the claw right down and out past the shell.
    private func throwAngle(_ swing: ClawThrow?, isRight: Bool) -> Double {
        guard let swing else { return 0 }
        let t = swing.progress
        let wind = ArenaConfig.clawWindUpShare
        let strike = ArenaConfig.clawStrikeShare
        // Positive degrees lift the left claw and drop the right one, so the
        // sign of the whole swing flips with the side of the body.
        let side: Double = isRight ? -1 : 1
        let raised = 16.0
        // He throws flatter at a crab above him and further down at one below,
        // so the claw ends up pointing at what it is throwing at.
        let rise = Double((king.anchor.y - swing.target.y) / max(1, size))
        let thrown = -56.0 + max(-1, min(1, rise)) * 12

        let value: Double
        if t < wind {
            let u = t / wind
            value = raised * (1 - pow(1 - u, 2))
        } else if t < wind + strike {
            let u = (t - wind) / strike
            value = raised + (thrown - raised) * (u * u * (3 - 2 * u))
        } else {
            let u = (t - wind - strike) / (1 - wind - strike)
            value = thrown * (1 - u) * (1 - u)
        }
        return value * side
    }

    var body: some View {
        ZStack {
            // A soft shadow welds him to the sand rather than leaving him
            // hovering over it. It stays on the floor while he hops, and
            // shrinks with the height, which is the whole of what makes a jump
            // read as leaving the ground.
            Ellipse()
                .fill(palette.sandDeep.opacity(0.34 * shadowFade))
                .frame(width: size * 0.82 * shadowFade, height: size * 0.19 * shadowFade)
                .offset(y: size * groundDrop + king.lift)
                .blur(radius: 5)

            if let sweep, sweep < 1 {
                shockwave(progress: sweep)
            }

            if let age = king.healAge {
                healGlow(progress: min(1, age / ArenaConfig.healDuration))
            }

            figure

            if hasBonusPower {
                bonusBadge
            }
        }
        .frame(width: size * 1.5, height: size * 1.5)
        .accessibilityHidden(true)
    }

    /// A rigged character is animated limb by limb; everyone else is still one
    /// picture with a crown drawn on top of it.
    @ViewBuilder
    private var figure: some View {
        if let rig = character.rig {
            RiggedCharacterView(rig: rig, pose: pose, size: size)
                .shadow(color: palette.coralDeep.opacity(0.24), radius: 7, y: 5)
        } else {
            character.artwork
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .overlay(alignment: .top) { crown }
                .rotationEffect(.degrees(lean))
                .scaleEffect(pulse)
                .shadow(color: palette.coralDeep.opacity(0.24), radius: 7, y: 5)
        }
    }

    private var crown: some View {
        CrownShape()
            .fill(
                LinearGradient(colors: [Color(red: 1.0, green: 0.90, blue: 0.45),
                                        Color(red: 0.92, green: 0.66, blue: 0.10)],
                               startPoint: .top, endPoint: .bottom)
            )
            .overlay {
                CrownShape().stroke(Color(red: 0.62, green: 0.40, blue: 0.03),
                                    lineWidth: isPad ? 2.4 : 1.8)
            }
            .frame(width: size * 0.42, height: size * 0.26)
            .offset(y: -size * 0.14)
            .shadow(color: .orange.opacity(0.45), radius: 4, y: 2)
    }

    /// How far below his middle the sand is. A rigged character stands on his
    /// own feet, which hang past the bottom of the artwork square; a flat one
    /// is drawn inside it and keeps the old line.
    private var groundDrop: CGFloat {
        guard let rig = character.rig else { return 0.44 }
        return rig.groundLine - 0.5
    }

    /// Tightens and pales as he leaves the ground.
    private var shadowFade: CGFloat {
        guard king.lift > 0 else { return 1 }
        return max(0.45, 1 - king.lift / (size * 0.5))
    }

    /// The blow itself: a wall of displaced water thrown out all around him,
    /// which is what makes one sweep read as answering every crab at once.
    private func shockwave(progress: Double) -> some View {
        let fade = pow(1 - progress, 1.4)
        return ZStack {
            Circle()
                .fill(.white.opacity(0.26 * fade))
                .frame(width: size * (0.6 + progress * 1.5),
                       height: size * (0.6 + progress * 1.5))
            Circle()
                .stroke(.white.opacity(0.95 * fade),
                        lineWidth: max(2.5, size * 0.075 * fade))
                .frame(width: size * (0.7 + progress * 1.45),
                       height: size * (0.7 + progress * 1.45))
            Circle()
                .stroke(palette.coral.opacity(0.7 * fade),
                        lineWidth: max(1.5, size * 0.035 * fade))
                .frame(width: size * (0.5 + progress * 1.15),
                       height: size * (0.5 + progress * 1.15))
        }
        .blur(radius: size * 0.012)
    }

    private func healGlow(progress: Double) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(colors: [Color.green.opacity(0.42 * (1 - progress)), .clear],
                                   center: .center, startRadius: 1, endRadius: size * 0.8)
                )
                .frame(width: size * 1.5, height: size * 1.5)

            Image(systemName: "heart.fill")
                .font(.system(size: size * 0.30, weight: .bold))
                .foregroundStyle(palette.coralDeep)
                .shadow(color: .white.opacity(0.9), radius: 3)
                .offset(y: -size * (0.52 + 0.34 * CGFloat(progress)))
                .opacity(1 - progress)
        }
    }

    private var bonusBadge: some View {
        Text(verbatim: "2×")
            .font(.system(size: isPad ? 24 : 18, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(palette.coralDeep, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.9), lineWidth: 2))
            .offset(y: -size * 0.62)
            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
    }
}

/// Three points, a band and a jewel. Small enough to read at 40 points.
private struct CrownShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: h * 0.20))
        path.addLine(to: CGPoint(x: w * 0.22, y: h * 0.52))
        path.addLine(to: CGPoint(x: w * 0.50, y: 0))
        path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.52))
        path.addLine(to: CGPoint(x: w, y: h * 0.20))
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()
        return path
    }
}

// MARK: - Answer crabs

/// One walking crab and the card it carries. Everything here is drawn rather
/// than sprited, so the same crab can be red, gold or green without ten assets.
private struct AnswerCrabView: View {
    let crab: AnswerCrab
    let palette: ReefPalette
    let isPad: Bool
    /// During the streak every crab is gold and every answer pays double.
    let isGolden: Bool
    let clock: Double
    /// Where the King is standing. A crab keeps its eyes on him.
    let king: CGPoint

    private var bodyWidth: CGFloat { ArenaConfig.crabSize(isPad: isPad) }

    /// How far through its exit animation this crab is, if it is leaving.
    private var exit: Double {
        switch crab.phase {
        case .smashed:   return min(1, crab.phaseAge / ArenaConfig.smashDuration)
        case .burrowing: return min(1, crab.phaseAge / ArenaConfig.burrowDuration)
        case .swept:     return min(1, crab.phaseAge / ArenaConfig.sweptDuration)
        default:         return 0
        }
    }

    /// A crab arrives at full size: it walks on from off the screen, so there
    /// is nothing to fade or pop in.
    private var scale: CGFloat {
        switch crab.phase {
        case .smashed:   return CGFloat(1 - exit * 0.75)
        case .swept:     return CGFloat(1 - exit * 0.8)
        default:         return 1
        }
    }

    private var opacity: Double {
        switch crab.phase {
        case .smashed, .swept: return 1 - exit * exit
        default:               return 1
        }
    }

    // MARK: Digging in

    /// Where the sand's surface is, in shares of the body width below the
    /// crab's middle: the line its own feet stand on. Everything about the dig
    /// is measured from it, because it is the line the crab goes *through*.
    /// It is the artwork's own footline, so the shadow, the pit and the cut at
    /// the sand's surface all follow the drawing rather than a guess about it.
    private var groundLine: CGFloat { (rig.groundLine - 0.5) / rig.bodyWidth }

    /// How far a crab has already settled onto its legs by the time it has
    /// finished handing its shell over. The dig picks the pose up at exactly
    /// this point, which is what makes the give and the burrow one movement
    /// instead of two animations played back to back.
    private static let handOverSettle: CGFloat = 0.62

    /// The share of the dig spent crouching. A crab that has just handed its
    /// answer over is more than half way into the crouch already, so it only
    /// has to finish the movement it is in.
    private var squatShare: Double {
        crab.hasDelivered
            ? ArenaConfig.burrowSquatShare * 0.42
            : ArenaConfig.burrowSquatShare
    }

    /// The crouch: before anything sinks, the crab hunkers down over the spot
    /// and starts working. A crab that simply slid downwards would read as a
    /// lift going down rather than as an animal digging.
    private var squat: CGFloat {
        let base: CGFloat = crab.hasDelivered ? Self.handOverSettle : 0
        let t = min(1, exit / squatShare)
        return base + (1 - base) * CGFloat(t * t * (3 - 2 * t))
    }

    /// How far into the sand it has pulled itself, 0 → 1. Nothing here happens
    /// until the crouch is done, and then it goes: the sand it has been digging
    /// out from under itself gives way, and it drops through the floor.
    private var dig: CGFloat {
        let t = (exit - squatShare) / max(0.01, 1 - squatShare)
        return CGFloat(pow(min(1, max(0, t)), 2.1))
    }

    /// Far enough that the shell it is holding is under the sand too.
    private var sinkDepth: CGFloat { bodyWidth * 2.6 * dig }

    /// The shimmy. A burrowing crab does not slide under: it screws itself down,
    /// rocking hard from one side to the other, and that rocking is most of what
    /// makes the sinking read as the animal's own doing. It works fastest while
    /// it is still digging and eases off as the sand closes over it.
    /// Four crabs digging in together must not rock as one, so each starts its
    /// own rhythm somewhere else — except one that has just handed its shell
    /// over, which starts from rest because it is already mid-movement.
    private var rockPhase: Double { crab.hasDelivered ? 0 : crab.gaitOffset }

    private var shimmy: CGFloat {
        let rock = sin(crab.phaseAge * 30 + rockPhase)
        return CGFloat(rock) * (1 - 0.5 * dig)
    }

    /// The heave: each half of the shimmy is a push, and a crab pushing itself
    /// down bobs against the sand rather than sliding through it. Twice the
    /// shimmy's rate, because both sides of the rock take a bite.
    private var heave: CGFloat {
        CGFloat(abs(sin(crab.phaseAge * 30 + rockPhase)))
            * bodyWidth * 0.07 * squat * (1 - dig)
    }

    /// What the crab has its eyes on: the King. Following the way it walked in
    /// instead left the two above him staring at each other across his crown,
    /// when what they are doing is closing in on him.
    private var gaze: CGSize {
        let dx = king.x - crab.position.x
        let dy = king.y - crab.position.y
        let length = hypot(dx, dy)
        guard length > 1 else { return CGSize(width: crab.facing, height: 0) }
        return CGSize(width: dx / length, height: dy / length)
    }

    /// The shell's own lean and sway this frame. The hands are placed off the
    /// same two numbers, which is what keeps them on its rim while it swings.
    private var cardSway: Double { sin(crab.age * crab.waddleRate - 0.6) }
    /// A shell wedged in two claws turns with them. Only once it is being
    /// handed over, or pulled down into the sand, does it get a lean of its own.
    private var cardAngle: Double {
        isHoldingFast ? shellRoll
                      : crab.cardLean + cardSway * 3.4 * (1 + 0.8 * run)
    }
    /// The artwork this crab is drawn from, and the square that artwork covers
    /// at the size the arena is asking for.
    private var rig: AnswerCrabRig { isGolden ? .gold : .red }
    private var square: CGFloat { rig.square(bodyWidth: bodyWidth) }

    /// True for a crab on the King's right, whose whole drawing is flipped.
    private var isMirrored: Bool { crab.facing < 0 }

    /// Where the pincers are when the claws are at rest — the two points the
    /// shell has to be held between.
    ///
    /// The drawing is not symmetrical about the middle of its own square, so a
    /// flipped crab's claws are not where an unflipped one's are. The shell is
    /// placed out here, outside the flip, and it has to be told: reading the
    /// drawing's own left and right for a crab that is standing the other way
    /// round put every shell on the King's right a few points off its claws.
    private var mouths: (left: CGPoint, right: CGPoint) {
        let left = rig.point(rig.leftPincer, square: square)
        let right = rig.point(rig.rightPincer, square: square)
        guard isMirrored else { return (left, right) }
        return (left: CGPoint(x: -right.x, y: right.y),
                right: CGPoint(x: -left.x, y: left.y))
    }

    /// Where the pincers close on the shell, as shares of its own frame.
    private var grip: CGPoint {
        AnswerShellShape.grip(span: rig.pincerSpan(square: square),
                              width: ArenaConfig.cardWidth(isPad: isPad))
    }

    /// Where the shell rides while it is simply being carried: with its lower
    /// edge exactly in the two open claws. A carried shell is *held*, not
    /// balanced — it rides the animal's own roll and bob rather than swinging
    /// against them, which is what stops the claws having to chase it.
    private var carriedShell: CGPoint {
        let mouth = mouths
        let height = ArenaConfig.cardHeight(isPad: isPad)
        return CGPoint(x: (mouth.left.x + mouth.right.x) / 2,
                       y: mouth.left.y - (grip.y - 0.5) * height)
    }

    /// True while the shell is locked in the claws: everything but the reach
    /// that hands it over and the dig that takes it under.
    private var isHoldingFast: Bool {
        crab.phase != .delivering && crab.phase != .burrowing
    }

    private var bodyRoll: Double {
        CrabSprite.roll(stepPhase: gait, isWalking: isStepping, facing: crab.facing)
    }
    private var bodyBob: CGFloat {
        CrabSprite.bob(bodyWidth: bodyWidth, stepPhase: gait, isWalking: isStepping)
    }

    /// The body's roll as the *screen* sees it.
    ///
    /// A crab on the King's right is drawn flipped, and a turn one way inside a
    /// flipped drawing comes out the other way round on screen. The shell is
    /// laid outside that flip — it carries a number, so it must not be mirrored
    /// — which means it has to be given the roll already turned back. Left to
    /// the drawing's own roll it leaned against its claws instead of with them,
    /// and since the roll is half walk cycle, the two rocked apart and back on
    /// every step: rock solid on the King's left, never still on his right.
    private var shellRoll: Double { isMirrored ? -bodyRoll : bodyRoll }

    /// A point carried through the body's own roll and bob, on screen.
    private func onBody(_ point: CGPoint) -> CGPoint {
        let radians = shellRoll * .pi / 180
        return CGPoint(x: point.x * cos(radians) - point.y * sin(radians),
                       y: point.x * sin(radians) + point.y * cos(radians) + bodyBob)
    }

    /// Where the hands are `t` of the way through handing the shell over: out
    /// towards the King's claws, and down off the crab's own head as it lets
    /// go — which is what keeps the whole movement inside an arm's own span.
    /// The reach is capped at what an arm can actually cover; the rest of the
    /// journey is the King's, and he makes it as the shell he sends to the
    /// score.
    private func offeredShell(_ t: CGFloat) -> CGPoint {
        let base = carriedShell
        let offered = CGPoint(x: base.x, y: base.y * (1 - 0.32 * t))
        let dx = crab.handOver.x - offered.x
        let dy = crab.handOver.y - offered.y
        let span = max(1, hypot(dx, dy))
        let reach = min(bodyWidth * 0.45, span) * t / span
        return CGPoint(x: offered.x + dx * reach, y: offered.y + dy * reach)
    }

    private var cardCentre: CGPoint {
        switch crab.phase {
        case .delivering:
            return offeredShell(handOver)
        case .burrowing:
            // The claws come in as the crouch finishes — from wherever the
            // hand-over left them, so a crab that has just given its shell away
            // carries straight on into the dig without resetting its pose. One
            // still holding its shell pulls it down over itself first: nothing
            // goes under the sand while it is held out at arm's length.
            let start: CGFloat = crab.hasDelivered ? Self.handOverSettle : 0
            let closed = (squat - start) / max(0.01, 1 - start)
            let from = crab.hasDelivered ? offeredShell(1) : carriedShell
            let to = CGPoint(x: 0, y: carriedShell.y * (crab.hasDelivered ? 0.10 : 0.45))
            return CGPoint(x: from.x + (to.x - from.x) * closed,
                           y: from.y + (to.y - from.y) * closed)
        default:
            return onBody(carriedShell)
        }
    }

    // MARK: Handing the answer over

    /// How far through the hand-over this crab is, eased so the shell leaves
    /// slowly and lands in the King's claws.
    private var handOver: CGFloat {
        guard crab.phase == .delivering else { return 0 }
        let t = min(1, crab.phaseAge / ArenaConfig.deliverDuration)
        return CGFloat(t * t * (3 - 2 * t))
    }

    /// The reach itself, as one arc: the crab comes up onto its toes to put the
    /// shell in the King's claws and comes straight back down out of it. It
    /// ends where it started, so nothing snaps when the dig takes over.
    private var handOverArc: Double { sin(Double(handOver) * .pi) }

    /// …and having let go, it is already settling onto its legs. This is the
    /// front half of the crouch the burrow then finishes.
    private var handOverCrouch: CGFloat {
        let t = min(1, max(0, Double(handOver) - 0.45) / 0.55)
        return Self.handOverSettle * CGFloat(t * t * (3 - 2 * t))
    }

    /// The two lower corners of the shell's rim, carried through its lean into
    /// the sprite's own coordinates. The pincers close on exactly these points,
    /// so the crab holds the edge of the shell however the shell is swinging.
    private var hold: CrabHold {
        let width = ArenaConfig.cardWidth(isPad: isPad)
        let height = ArenaConfig.cardHeight(isPad: isPad)
        let centre = cardCentre
        let angle = cardAngle * .pi / 180
        let cosine = CGFloat(cos(angle))
        let sine = CGFloat(sin(angle))
        func onRim(_ share: CGPoint) -> CGPoint {
            let local = CGPoint(x: (share.x - 0.5) * width, y: (share.y - 0.5) * height)
            return CGPoint(x: centre.x + local.x * cosine - local.y * sine,
                           y: centre.y + local.x * sine + local.y * cosine)
        }
        let left = grip
        return CrabHold(left: onRim(left),
                        right: onRim(CGPoint(x: 1 - left.x, y: left.y)),
                        centre: centre)
    }

    /// The legs work both when the crab is covering ground and when it is
    /// digging: a crab burrows with the same six legs it walks on.
    private var isStepping: Bool {
        crab.phase == .walking || crab.phase == .burrowing
    }

    /// The shell fades out of the crab's claws as the King takes it: the same
    /// shell leaves his own claws for the score a moment later.
    private var shellOpacity: Double {
        if crab.hasDelivered { return 0 }
        guard crab.phase == .delivering else { return 1 }
        return 1 - Double(max(0, handOver - 0.45) / 0.55)
    }

    /// The walk cycle, measured off the ground the crab has actually covered —
    /// except while digging, where no ground is covered at all and the legs are
    /// scrabbling against the sand rather than carrying the animal over it.
    private var gait: Double {
        guard crab.phase != .burrowing else {
            return crab.phaseAge * 34 + crab.gaitOffset
        }
        return Double(crab.walked
            / max(1, bodyWidth * CrabSprite.strideLength * crab.strideFactor))
            * 2 * .pi + crab.gaitOffset
    }

    /// How far into its run the crab is, 0 → 1, once it is the last one left.
    private var run: Double {
        guard crab.isRushing, crab.phase == .walking else { return 0 }
        let ramp = min(1, crab.rushAge / ArenaConfig.rushRamp)
        return ramp * ramp
    }

    /// The patch of shade the crab is standing in.
    ///
    /// It is what welds a walking crab to the sea floor: without one the animal
    /// reads as sliding over a picture of sand rather than across it. The
    /// artwork's own footline puts it under the feet, and it tightens on every
    /// step as the body rises off them — a shadow that never moves is what
    /// gives a walk cycle away. A crab that has been thrown clear of the sand
    /// has none: there is nothing under it to cast one on.
    @ViewBuilder
    private var shadow: some View {
        switch crab.phase {
        case .hit, .smashed, .swept:
            EmptyView()
        default:
            ContactShadow(bodyWidth: bodyWidth,
                          footLine: groundLine * bodyWidth,
                          lift: -bodyBob,
                          roll: bodyRoll,
                          fade: 1 - dug,
                          palette: palette)
        }
    }

    /// How far the sand has closed over the crab, 0 → 1. Its shadow goes with
    /// it: there is nothing left above the floor to cast one.
    private var dug: CGFloat { crab.phase == .burrowing ? dig : 0 }

    var body: some View {
        let crabAndShell = AnswerCrabSprite(
            rig: rig,
            bodyWidth: bodyWidth,
            roll: bodyRoll,
            bob: bodyBob,
            // The drawing is made for a crab on the King's left; one that came
            // in from his right is the whole thing flipped.
            mirrored: isMirrored,
            gaze: gaze,
            // A held shell needs no reaching for: the claws stay in the pose
            // they are drawn in and the shell is locked between them. They only
            // solve for a grip once it starts moving away from them.
            grip: (isHoldingFast || shellOpacity <= 0)
                ? nil : (left: hold.left, right: hold.right)
        ) {
            AnswerShell(text: crab.text,
                        palette: palette,
                        isPad: isPad,
                        isGolden: isGolden)
                // The shell swings a beat behind the body, the way anything
                // held over your head does.
                .rotationEffect(.degrees(cardAngle))
                .scaleEffect(1 - 0.18 * handOver)
                .offset(x: cardCentre.x, y: cardCentre.y)
                .opacity(shellOpacity)
        }

        return Group {
            if crab.phase == .burrowing {
                digging(crabAndShell)
            } else {
                ZStack {
                    // The shadow is laid on the sand, outside everything the
                    // crab itself is doing: it stays flat on the floor while
                    // the animal over it leans, rises and tumbles away.
                    shadow
                    crabAndShell
                        // Running, it throws itself forward over its own legs.
                        .rotationEffect(.degrees(Double(crab.facing) * 7 * run),
                                        anchor: .bottom)
                        // Handing the shell over: up onto its toes and leaning
                        // in on the reach, back down onto its legs as it lets go.
                        .rotationEffect(.degrees(handOverArc * -5 * Double(crab.facing)),
                                        anchor: .bottom)
                        .offset(y: -bodyWidth * 0.09 * CGFloat(handOverArc))
                        // …and straight on into the crouch the dig starts from.
                        .scaleEffect(x: 1 + 0.14 * handOverCrouch,
                                     y: 1 - 0.22 * handOverCrouch,
                                     anchor: .bottom)
                        // A smashed or swept crab tumbles away with the blow.
                        .rotationEffect(.radians(crab.spin * exit))
                        .scaleEffect(scale)
                        .opacity(opacity)
                }
            }
        }
        .accessibilityHidden(true)
    }

    /// The dig. A crab giving up on the wave does not fade away: it hunkers
    /// down where it stands, works the sand out from under itself, and screws
    /// itself through the sea floor — and the sea floor cuts it off cleanly at
    /// the surface, which is the whole reason the sinking reads as going *into*
    /// something rather than as shrinking.
    private func digging<Content: View>(_ crabAndShell: Content) -> some View {
        ZStack {
            burrowPit
            shadow
            crabAndShell
                // The rock, taken about the feet: the crab screws itself down.
                .rotationEffect(.degrees(Double(shimmy) * 11), anchor: .bottom)
                .offset(x: shimmy * bodyWidth * 0.075, y: sinkDepth - heave)
                // It squats onto its legs and squeezes into its own hole.
                .scaleEffect(x: 1 + 0.14 * squat, y: 1 - 0.22 * squat, anchor: .bottom)
                .mask { seaFloor }
            // The sand it has thrown out piles up around the hole, and the last
            // of it slides back in over the top of the crab.
            burrowMound
        }
    }

    /// Sand is opaque: whatever has gone below its surface is simply not there
    /// any more. One rectangle ending at the crab's own footline does that.
    private var seaFloor: some View {
        let reach = bodyWidth * 8
        return Rectangle()
            .frame(width: reach, height: reach)
            .offset(y: groundLine * bodyWidth - reach / 2)
    }

    /// How wide the disturbed sand is this frame. It opens while the crab works
    /// its way down, and settles back once there is nothing left to dig around.
    private var pitWidth: CGFloat {
        let open = CGFloat(min(1, exit / 0.45))
        let closed = CGFloat(max(0, (exit - 0.7) / 0.3))
        return bodyWidth * (0.5 + 0.8 * open) * (1 - 0.55 * closed * closed)
    }

    private var pitFade: Double { 1 - max(0, (exit - 0.78) / 0.22) }

    /// The hole itself, drawn behind the crab: the dark of an open burrow.
    private var burrowPit: some View {
        Ellipse()
            .fill(
                RadialGradient(colors: [palette.sandDeep.opacity(0.85 * pitFade),
                                        palette.sandDeep.opacity(0.15 * pitFade)],
                               center: .center,
                               startRadius: 0,
                               endRadius: max(1, pitWidth * 0.55))
            )
            .frame(width: pitWidth, height: pitWidth * 0.36)
            .offset(y: groundLine * bodyWidth)
    }

    /// The spoil heap, drawn in *front* of the crab: sand does not stay in the
    /// hole it came out of, and a rim rising over the crab's back is what turns
    /// a sinking sprite into an animal being covered up.
    private var burrowMound: some View {
        let rise = CGFloat(min(1, exit / 0.62))
        let width = pitWidth * 1.12
        return ZStack {
            // The near lip: a crescent of sand banked up on the player's side.
            Ellipse()
                .fill(
                    LinearGradient(colors: [palette.sand,
                                            palette.sand.opacity(0.85)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .frame(width: width, height: width * 0.30 * rise)
                .overlay {
                    Ellipse()
                        .stroke(palette.sandDeep.opacity(0.25), lineWidth: 1)
                        .frame(width: width, height: width * 0.30 * rise)
                }
                .offset(y: groundLine * bodyWidth + width * 0.10 * rise)
                .blur(radius: 0.8)
        }
        .opacity(pitFade)
    }
}

/// The shade a crab standing on the sand casts, for whichever crab is standing
/// on it. One soft ellipse on the artwork's own footline, which tightens and
/// darkens as the body comes down onto its legs and spreads and pales as it
/// rises off them — so the shadow is part of the walk rather than a disc being
/// dragged along under it. It also leans a hair with the body's roll, which is
/// what keeps it under the animal's weight rather than under its middle.
private struct ContactShadow: View {
    let bodyWidth: CGFloat
    /// How far below the crab's middle the sand is, in points.
    let footLine: CGFloat
    /// How far the body is off its feet this frame, in points.
    let lift: CGFloat
    /// The body's roll, in degrees.
    let roll: Double
    /// Taken to zero by anything that puts the crab under the sand.
    var fade: CGFloat = 1
    let palette: ReefPalette

    var body: some View {
        // A body one full bob off the sand throws a shadow about a third
        // weaker. Anything more separates the two.
        let tight = max(0.62, 1 - lift / max(1, bodyWidth * 0.14))
        let strength = fade * tight
        return Ellipse()
            .fill(palette.sandDeep.opacity(0.38 * Double(strength)))
            // Wider than the shell: what is standing on the sand is the spread
            // of legs, not the body they are carrying.
            .frame(width: bodyWidth * 1.26 * strength,
                   height: bodyWidth * 0.30 * strength)
            .blur(radius: 3.5)
            .offset(x: CGFloat(sin(roll * .pi / 180)) * bodyWidth * 0.16,
                    y: footLine)
    }
}

/// The answer a crab carries: a scallop shell with the number on it. The
/// currency of the game is shells, so the thing being fought over looks like
/// one — and a fan shape reads as "carried" in a way a rectangle never does.
private struct AnswerShell: View {
    let text: String
    let palette: ReefPalette
    let isPad: Bool
    let isGolden: Bool

    private var width: CGFloat { ArenaConfig.cardWidth(isPad: isPad) }
    private var height: CGFloat { ArenaConfig.cardHeight(isPad: isPad) }
    private var rim: Color {
        isGolden ? Color(red: 0.82, green: 0.55, blue: 0.04) : palette.coralDeep
    }

    var body: some View {
        ZStack {
            AnswerShellShape()
                .fill(
                    LinearGradient(colors: isGolden
                                   ? [Color(red: 1.0, green: 0.96, blue: 0.80),
                                      Color(red: 0.99, green: 0.86, blue: 0.52)]
                                   : [.white, Color(red: 0.96, green: 0.96, blue: 0.99)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .overlay {
                    // The shell's own ribs, kept faint enough that the number
                    // stays the first thing read.
                    AnswerShellRibs()
                        .stroke(rim.opacity(0.16),
                                style: StrokeStyle(lineWidth: max(1, width * 0.022),
                                                   lineCap: .round))
                }
                .overlay {
                    AnswerShellShape()
                        .stroke(rim, lineWidth: isPad ? 3.5 : 2.6)
                }
                .shadow(color: .black.opacity(0.20), radius: 4, y: 3)

            Text(verbatim: text)
                .font(.system(size: height * 0.46, weight: .black, design: .rounded))
                .minimumScaleFactor(0.34)
                .lineLimit(1)
                .foregroundStyle(palette.coralDeep)
                .padding(.horizontal, width * 0.16)
                .offset(y: height * 0.04)
        }
        .frame(width: width, height: height)
    }
}

/// A scallop: hinged at the bottom, fluted along the top, wider than it is tall
/// so a two-digit answer sits comfortably across its face.
private struct AnswerShellShape: Shape {
    private static let scallops = 6

    /// The outline's own landmarks, in shares of the frame: the hinge at the
    /// bottom and the control point that swings the left shoulder out to the
    /// rim. The claws are placed off this same curve, so a hand always closes
    /// on the shell's edge rather than near it.
    static let hinge = CGPoint(x: 0.5, y: 0.99)
    static let shoulderControl = CGPoint(x: 0.04, y: 0.92)

    static func rim(_ t: Double) -> CGPoint {
        CGPoint(x: 0.02 + 0.96 * t, y: 0.56 - 0.52 * sin(.pi * t))
    }

    /// Where the left claw closes, for a crab whose two pincers are `span`
    /// apart. The pincers are drawn where they are drawn, so the shell has to
    /// be gripped that far in from its middle rather than out at its corners —
    /// which is what puts the mouth of a claw on the rim instead of past it.
    static func grip(span: CGFloat, width: CGFloat) -> CGPoint {
        shoulderPoint(atX: 0.5 - min(0.46, span / max(1, width) / 2))
    }

    /// The point on the shoulder curve at a given share across the shell. The
    /// curve is monotonic in x over the stretch that matters, so a handful of
    /// halvings lands on it closely enough for a claw a few points wide.
    private static func shoulderPoint(atX x: CGFloat) -> CGPoint {
        var low: CGFloat = 0
        var high: CGFloat = 1
        for _ in 0..<24 {
            let mid = (low + high) / 2
            if shoulderPoint(mid).x > x { low = mid } else { high = mid }
        }
        return shoulderPoint((low + high) / 2)
    }

    /// A point along the shoulder curve, from the hinge (0) to the rim (1).
    private static func shoulderPoint(_ t: CGFloat) -> CGPoint {
        let rest = 1 - t
        let end = rim(0)
        return CGPoint(
            x: rest * rest * hinge.x + 2 * rest * t * shoulderControl.x + t * t * end.x,
            y: rest * rest * hinge.y + 2 * rest * t * shoulderControl.y + t * t * end.y
        )
    }

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + w * x, y: rect.minY + h * y)
        }

        let hinge = point(Self.hinge.x, Self.hinge.y)
        let rim: [CGPoint] = (0...Self.scallops).map { index in
            let share = Self.rim(Double(index) / Double(Self.scallops))
            return point(share.x, share.y)
        }

        var path = Path()
        path.move(to: hinge)
        // The two shoulders that run down to the hinge.
        path.addQuadCurve(to: rim[0],
                          control: point(Self.shoulderControl.x, Self.shoulderControl.y))
        for index in 1...Self.scallops {
            let previous = rim[index - 1]
            let next = rim[index]
            let mid = CGPoint(x: (previous.x + next.x) / 2, y: (previous.y + next.y) / 2)
            let dx = mid.x - hinge.x
            let dy = mid.y - hinge.y
            let length = max(0.001, (dx * dx + dy * dy).squareRoot())
            path.addQuadCurve(to: next,
                              control: CGPoint(x: mid.x + dx / length * w * 0.05,
                                               y: mid.y + dy / length * h * 0.07))
        }
        path.addQuadCurve(to: hinge,
                          control: point(1 - Self.shoulderControl.x, Self.shoulderControl.y))
        path.closeSubpath()
        return path
    }
}

/// The flutes, drawn as lines from the hinge rather than cut out of the shell:
/// on something carrying a number, holes would only make it harder to read.
private struct AnswerShellRibs: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let hinge = CGPoint(x: rect.minX + w * AnswerShellShape.hinge.x,
                            y: rect.minY + h * AnswerShellShape.hinge.y)
        var path = Path()
        for index in 1..<6 {
            let share = AnswerShellShape.rim(Double(index) / 6)
            let tip = CGPoint(x: rect.minX + w * share.x, y: rect.minY + h * share.y)
            path.move(to: CGPoint(x: hinge.x + (tip.x - hinge.x) * 0.16,
                                  y: hinge.y + (tip.y - hinge.y) * 0.16))
            path.addLine(to: CGPoint(x: hinge.x + (tip.x - hinge.x) * 0.86,
                                     y: hinge.y + (tip.y - hinge.y) * 0.86))
        }
        return path
    }
}

// MARK: - Carrier crabs

/// The 2x crab and the comeback crab, drawn from their own limbs exactly as the
/// King is — see `CharacterRig.bonusHelper`. Both are painted crabs rather than
/// the flat-shaded answer crabs, and both hold what they have brought up over
/// their heads in two raised claws, which is the whole of what says *this one
/// is bringing you something*.
///
/// What it carries is drawn outside the sprite's own mirror. The crab turns
/// round to walk the other way; a 2× that turned with it would read as ×2.
private struct CarrierCrabView: View {
    let carrier: CarrierCrab
    let palette: ReefPalette
    let isPad: Bool
    let clock: Double

    private var rig: CharacterRig {
        carrier.kind == .bonus ? .bonusHelper : .lifeHelper
    }

    /// The walk cycle, measured off ground covered — so a planted foot stays
    /// planted — except while digging, where nothing is covered at all and the
    /// legs are scrabbling against the sand instead of carrying the animal.
    private var gait: Double {
        guard carrier.phase != .burrowing else {
            return carrier.phaseAge * 34 + carrier.gaitOffset
        }
        return Double(carrier.walked
                      / max(1, carrier.bodyWidth * ArenaConfig.strideLength
                            * carrier.strideFactor)) * 2 * .pi + carrier.gaitOffset
    }

    /// How far through the dig it is, 0 → 1.
    private var exit: Double {
        guard carrier.phase == .burrowing else { return 0 }
        return min(1, carrier.phaseAge / ArenaConfig.burrowDuration)
    }

    /// The same two-part dig the answer crabs make: hunker down and work, then
    /// drop through the floor the sand has been taken out from under.
    private var squat: CGFloat {
        let t = min(1, exit / ArenaConfig.burrowSquatShare)
        return CGFloat(t * t * (3 - 2 * t))
    }

    private var dig: CGFloat {
        let t = (exit - ArenaConfig.burrowSquatShare)
            / max(0.01, 1 - ArenaConfig.burrowSquatShare)
        return CGFloat(pow(min(1, max(0, t)), 2.1))
    }

    /// The rock that screws it down, easing off as the sand closes over it.
    private var shimmy: CGFloat {
        CGFloat(sin(carrier.phaseAge * 30 + carrier.gaitOffset)) * (1 - 0.5 * dig)
    }

    /// Where the sand's surface is, below the crab's middle: the artwork's own
    /// footline, which is the line it goes through.
    private var footLine: CGFloat { (rig.groundLine - 0.5) * carrier.size }

    var body: some View {
        let figure = RiggedCharacterView(
            rig: rig,
            pose: .carrying(clock: clock, stride: gait),
            size: carrier.size
        ) {
            token
                // Undoes the mirror the whole crab is about to be given, so
                // the coin faces the player whichever way the crab is walking.
                .scaleEffect(x: carrier.facing < 0 ? -1 : 1, y: 1)
                .opacity(carrier.isCarryingReward ? 1 : 0)
        }
        .scaleEffect(x: carrier.facing < 0 ? -1 : 1, y: 1)
        .shadow(color: palette.coralDeep.opacity(0.22), radius: 5, y: 4)

        return ZStack {
            ContactShadow(bodyWidth: carrier.bodyWidth,
                          footLine: footLine,
                          lift: 0,
                          roll: 0,
                          fade: 1 - dig,
                          palette: palette)
            if carrier.phase == .burrowing {
                figure
                    .rotationEffect(.degrees(Double(shimmy) * 11), anchor: .bottom)
                    .offset(x: shimmy * carrier.bodyWidth * 0.075,
                            y: carrier.bodyWidth * 2.6 * dig)
                    .scaleEffect(x: 1 + 0.14 * squat, y: 1 - 0.22 * squat, anchor: .bottom)
                    // Sand is opaque: whatever has gone under it is not there.
                    .mask {
                        Rectangle()
                            .frame(width: carrier.size * 4, height: carrier.size * 4)
                            .offset(y: footLine - carrier.size * 2)
                    }
            } else {
                figure
            }
        }
        .accessibilityHidden(true)
    }

    /// The coin or the heart, sized to the hold the artwork's two pincers make.
    @ViewBuilder
    private var token: some View {
        let side = carrier.size * ArenaConfig.helperTokenShare
        switch carrier.kind {
        case .bonus:
            Text(verbatim: "2×")
                .font(.system(size: side * 0.52, weight: .black, design: .rounded))
                .foregroundStyle(palette.waterDeep)
                .frame(width: side, height: side)
                .background {
                    Circle()
                        .fill(LinearGradient(colors: [.white, .yellow.opacity(0.92)],
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing))
                        .overlay { Circle().stroke(.orange, lineWidth: isPad ? 3 : 2) }
                }
                .shadow(color: .orange.opacity(0.55), radius: 4, y: 2)
        case .life:
            Image(systemName: "heart.fill")
                .font(.system(size: side * 0.62, weight: .bold))
                .foregroundStyle(palette.coralDeep)
                .frame(width: side, height: side)
                .background {
                    Circle()
                        .fill(.white)
                        .overlay { Circle().stroke(palette.coralDeep, lineWidth: isPad ? 3 : 2) }
                }
                .shadow(color: .white.opacity(0.9), radius: 5)
        }
    }
}

// MARK: - The crab itself

private enum CrabTint {
    case enemy, gold, bonus, life

    var shell: (Color, Color) {
        switch self {
        case .enemy:
            return (Color(red: 0.95, green: 0.40, blue: 0.22),
                    Color(red: 0.78, green: 0.19, blue: 0.06))
        case .gold:
            return (Color(red: 1.00, green: 0.84, blue: 0.34),
                    Color(red: 0.85, green: 0.55, blue: 0.05))
        case .bonus:
            return (Color(red: 1.00, green: 0.78, blue: 0.24),
                    Color(red: 0.88, green: 0.48, blue: 0.04))
        case .life:
            return (Color(red: 0.46, green: 0.84, blue: 0.54),
                    Color(red: 0.16, green: 0.56, blue: 0.32))
        }
    }

    /// The one colour every edge of the animal is drawn in. A single ink line
    /// around the whole silhouette — body, legs, arms, claws — is what makes
    /// the parts read as one character instead of as assembled pieces.
    var line: Color {
        switch self {
        case .enemy: return Color(red: 0.51, green: 0.10, blue: 0.03)
        case .gold:  return Color(red: 0.58, green: 0.34, blue: 0.02)
        case .bonus: return Color(red: 0.60, green: 0.29, blue: 0.02)
        case .life:  return Color(red: 0.08, green: 0.34, blue: 0.19)
        }
    }

}

/// A small cartoon crab: a domed shell, two slim arms, six walking legs and a
/// face. Everything that moves is driven by one walk cycle, which is what keeps
/// four of them on screen affordable.
private struct CrabSprite: View {
    let bodyWidth: CGFloat
    let tint: CrabTint
    /// Radians of the walk cycle.
    let stepPhase: Double
    let isWalking: Bool
    /// Which way it is travelling: the legs stride that way and the body leans
    /// into it.
    var facing: CGFloat = 1
    /// Where it is looking, as a unit vector in screen space.
    var gaze: CGSize = .zero
    /// This crab's own stride, against the standard one. It scales the phase
    /// and the footfall together — they have to agree exactly, or the planted
    /// foot creeps.
    var strideFactor: CGFloat = 1
    let palette: ReefPalette

    /// The shell is this much of its own width tall. The arm rig measures from
    /// the same number, so shoulders stay under the shell's edge at any size.
    static let heightRatio: CGFloat = 0.72

    private var bodyHeight: CGFloat { bodyWidth * Self.heightRatio }

    /// Two bobs per cycle: the body rises onto each set of legs in turn.
    static func bob(bodyWidth: CGFloat, stepPhase: Double, isWalking: Bool) -> CGFloat {
        isWalking ? -CGFloat(abs(sin(stepPhase))) * bodyWidth * 0.038 : 0
    }
    /// It rolls onto the legs that are carrying it, and leans a little into the
    /// direction it is going.
    static func roll(stepPhase: Double, isWalking: Bool, facing: CGFloat) -> Double {
        guard isWalking else { return 0 }
        return sin(stepPhase) * 4.5 + Double(facing) * 2.5
    }

    private var bob: CGFloat {
        Self.bob(bodyWidth: bodyWidth, stepPhase: stepPhase, isWalking: isWalking)
    }
    private var roll: Double {
        Self.roll(stepPhase: stepPhase, isWalking: isWalking, facing: facing)
    }

    /// How thick the ink line around the animal is, on each side of an edge.
    var outline: CGFloat { max(0.75, bodyWidth * 0.026) }

    /// A point on the body, carried through the body's own roll and bob. It is
    /// what lets a limb be hinged to the shell while being drawn outside it.
    private func onBody(_ point: CGPoint) -> CGPoint {
        let radians = roll * .pi / 180
        let cosine = CGFloat(cos(radians))
        let sine = CGFloat(sin(radians))
        return CGPoint(x: point.x * cosine - point.y * sine,
                       y: point.x * sine + point.y * cosine + bob)
    }

    var body: some View {
        let colors = tint.shell

        return ZStack {
            Ellipse()
                .fill(palette.sandDeep.opacity(0.32))
                .frame(width: bodyWidth * 0.84, height: bodyWidth * 0.16)
                .offset(y: bodyHeight * 0.68)
                .blur(radius: 3)

            // The legs are drawn outside the body's roll: their hips are
            // carried through it, but a planted foot has to stay where it was
            // put. Rolling the feet with the shell skates them across the sand.
            legs(colors: colors)

            ZStack {
                shell(colors: colors)
                face(colors: colors)
            }
            .rotationEffect(.degrees(roll))
            .offset(y: bob)
        }
        .frame(width: bodyWidth * 1.7, height: bodyWidth * 1.5)
    }

    // MARK: The shell

    private func shell(colors: (Color, Color)) -> some View {
        ZStack {
            // The body's edge is inked underneath and painted over, exactly the
            // way every limb is. Stroking it instead would draw the line half
            // inside the shape, leaving the body outlined twice as heavily as
            // the legs growing out of it — which is what makes a joint look
            // like a join.
            CarapaceShape().inked(tint.line, width: outline)
            carapace(colors: colors)
        }
        .frame(width: bodyWidth, height: bodyHeight)
    }

    private func carapace(colors: (Color, Color)) -> some View {
        CarapaceShape()
            .fill(
                LinearGradient(stops: [
                    .init(color: colors.0.opacity(0.96), location: 0),
                    .init(color: colors.0, location: 0.35),
                    .init(color: colors.1, location: 1)
                ], startPoint: .top, endPoint: .bottom)
            )
            // The underside of a domed shell is always in its own shadow.
            .overlay {
                LinearGradient(stops: [
                    .init(color: .clear, location: 0.45),
                    .init(color: colors.1.opacity(0.50), location: 1)
                ], startPoint: .top, endPoint: .bottom)
                    .mask { CarapaceShape() }
            }
            .overlay { shellTexture(colors: colors) }
            // A hard rim of light along the top, and a soft one on the flank.
            .overlay {
                CarapaceShape()
                    .stroke(.white.opacity(0.45), lineWidth: max(1, bodyWidth * 0.030))
                    .mask {
                        LinearGradient(colors: [.white, .white.opacity(0.15), .clear],
                                       startPoint: .top, endPoint: .bottom)
                    }
            }
            .frame(width: bodyWidth, height: bodyHeight)
    }

    /// The specular highlight and the shell's own pitting. Both are what stop a
    /// flat oval from reading as a sticker.
    private func shellTexture(colors: (Color, Color)) -> some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(colors: [.white.opacity(0.55), .white.opacity(0.05)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: bodyWidth * 0.34, height: bodyHeight * 0.26)
                .rotationEffect(.degrees(-18))
                .offset(x: -bodyWidth * 0.18, y: -bodyHeight * 0.22)

            ForEach(Array(Self.pits.enumerated()), id: \.offset) { _, pit in
                Ellipse()
                    .fill(colors.1.opacity(0.30))
                    .frame(width: bodyWidth * pit.2, height: bodyWidth * pit.2 * 0.78)
                    .offset(x: bodyWidth * pit.0, y: bodyHeight * pit.1)
            }
        }
        .mask { CarapaceShape() }
    }

    /// x, y (shares of the shell), size — the shell's own mottling.
    private static let pits: [(CGFloat, CGFloat, CGFloat)] = [
        (-0.30, 0.16, 0.075), (-0.10, 0.28, 0.055), (0.14, 0.22, 0.085),
        (0.31, 0.05, 0.060), (0.02, -0.02, 0.050), (-0.24, -0.12, 0.045)
    ]

    // MARK: The face

    /// Two eyes that follow where the crab is going, and a small smile. A crab
    /// with a face is something a child aims at; a red blob is something they
    /// hesitate over.
    ///
    /// The eyes are big and they stand *over* the top of the shell rather than
    /// sitting inside it — a crab's eyes are on stalks, and the two domes
    /// breaking the carapace's outline are what make it read as an animal
    /// looking up at the player.
    private func face(colors: (Color, Color)) -> some View {
        ZStack {
            // A warm cheek either side of the mouth, kept inside the shell so
            // it reads as colour in the skin rather than as a sticker on it.
            ZStack {
                cheek.offset(x: -bodyWidth * 0.29, y: bodyHeight * 0.06)
                cheek.offset(x: bodyWidth * 0.29, y: bodyHeight * 0.06)
            }
            .mask { CarapaceShape().frame(width: bodyWidth, height: bodyHeight) }

            mouth
                .offset(y: bodyHeight * 0.06)

            HStack(spacing: bodyWidth * 0.055) {
                eye()
                eye()
            }
            .offset(y: -bodyHeight * 0.44)
        }
    }

    private var cheek: some View {
        Ellipse()
            .fill(
                RadialGradient(colors: [.white.opacity(0.34), .white.opacity(0)],
                               center: .center, startRadius: 0,
                               endRadius: bodyWidth * 0.10)
            )
            .frame(width: bodyWidth * 0.20, height: bodyWidth * 0.13)
    }

    /// A wide grin with an inside to it. At the size this animal actually is,
    /// one clean shape in the ink colour reads as a smile where a lip, a throat
    /// and a tongue turn into a smudge.
    private var mouth: some View {
        MouthShape()
            .fill(tint.line)
            .frame(width: bodyWidth * 0.34, height: bodyWidth * 0.15)
    }

    private func eye() -> some View {
        let diameter = bodyWidth * 0.30
        let look = CGSize(width: gaze.width * diameter * 0.14,
                          height: gaze.height * diameter * 0.14)
        return Circle()
            .fill(.white)
            .overlay {
                Circle()
                    .fill(Color(red: 0.11, green: 0.13, blue: 0.22))
                    .frame(width: diameter * 0.46, height: diameter * 0.46)
                    .offset(x: look.width, y: look.height + diameter * 0.05)
            }
            .overlay(alignment: .topLeading) {
                // The catchlight, which is most of what makes an eye alive.
                Circle()
                    .fill(.white)
                    .frame(width: diameter * 0.19, height: diameter * 0.19)
                    .offset(x: diameter * 0.24, y: diameter * 0.20)
            }
            // An eye standing clear of the shell carries the same ink line as
            // the rest of the animal, or it dissolves into what is behind it.
            .overlay {
                Circle().stroke(tint.line, lineWidth: outline * 1.6)
            }
            .frame(width: diameter, height: diameter)
    }

    /// Six legs in the alternating gait a crab actually uses: three of them
    /// swing while the other three carry, and every swinging leg lifts clear of
    /// the sand instead of dragging through it.
    // MARK: Legs

    /// One leg's plan, in shares of the body: where it is hinged, where its
    /// foot rests, and how long the limb is. Front to back, the legs reach
    /// further out and plant lower — which is what gives a face-on crab depth.
    ///
    /// hip x, hip y, foot x, foot y, limb length.
    ///
    /// Every hip sits on the shell's *lower* flank and well inside its outline.
    /// A leg hinged at the widest line comes out of the animal's shoulder and
    /// kinks straight away; hinged below it, the three legs leave the body in
    /// an even fan and the first bend happens clear of the shell.
    private static let legPlan: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (0.32, 0.08, 0.46, 0.78, 0.74),
        (0.30, 0.24, 0.62, 0.98, 0.82),
        (0.22, 0.38, 0.52, 1.14, 0.78)
    ]

    /// The share of the cycle a foot spends on the ground. Above a half means
    /// three feet are always planted, which is what a walk is.
    private static let stanceShare = 0.62

    /// How far the body travels per full cycle, as a share of its own width.
    /// The legs take their phase from ground covered, so this number is the one
    /// thing keeping the feet from sliding — and the simulation counts the
    /// footfalls it sheds sand on off the very same stride.
    static let strideLength: CGFloat = ArenaConfig.strideLength

    private var legLift: CGFloat { bodyWidth * 0.14 }

    /// One leg's pose this frame, so the same solved geometry can be drawn
    /// twice: once as the ink line under everything, once as the limb itself.
    private struct LegPose {
        var limb: LimbShape
        var rest: CGFloat
        var toe: CGFloat
        var contact: Double
    }

    private func legs(colors: (Color, Color)) -> some View {
        let poses = legPoses
        let shade = LinearGradient(
            stops: [.init(color: colors.0, location: 0),
                    .init(color: colors.1, location: 0.62)],
            startPoint: .top, endPoint: .bottom
        )
        // Every leg's outline is laid down before any leg's colour, so where
        // two of them cross there is no ink line between them: six legs read as
        // six legs of one animal, not as six cut-outs.
        return ZStack {
            ForEach(poses.indices, id: \.self) { index in
                Ellipse()
                    .fill(palette.sandDeep.opacity(0.30 * poses[index].contact))
                    .frame(width: bodyWidth * 0.13, height: bodyWidth * 0.05)
                    .offset(x: poses[index].toe, y: poses[index].rest)
            }
            ForEach(poses.indices, id: \.self) { index in
                poses[index].limb.inked(tint.line, width: outline)
            }
            ForEach(poses.indices, id: \.self) { index in
                poses[index].limb.fill(shade)
            }
        }
    }

    /// Six walking legs, solved rather than drawn: each foot is placed first —
    /// planted and sliding backwards under the body through the stance, then
    /// lifted and swung forward — and the knee is whatever angle reaches it.
    private var legPoses: [LegPose] {
        Self.legPlan.enumerated().flatMap { index, plan -> [LegPose] in
            // Alternating tripod: left 1 and 3 swing with right 2, and the
            // other way about — with a small lag down the row, the way the
            // wave actually runs along a crab.
            let lag = Double(index) * 0.22
            return [
                pose(plan: plan, side: -1,
                     phase: stepPhase + (index == 1 ? .pi : 0) + lag),
                pose(plan: plan, side: 1,
                     phase: stepPhase + (index == 1 ? 0 : .pi) + lag)
            ]
        }
    }

    private func pose(plan: (CGFloat, CGFloat, CGFloat, CGFloat, CGFloat),
                      side: CGFloat, phase: Double) -> LegPose {
        let cycle = (phase / (2 * .pi)).truncatingRemainder(dividingBy: 1)
        let t = cycle < 0 ? cycle + 1 : cycle

        // Where the foot is in its stroke, from +0.5 (reached forward) to
        // -0.5 (trailing behind), and how far it is off the ground.
        let travel: CGFloat
        let lift: CGFloat
        if t < Self.stanceShare {
            travel = 0.5 - CGFloat(t / Self.stanceShare)
            lift = 0
        } else {
            let swing = (t - Self.stanceShare) / (1 - Self.stanceShare)
            travel = -0.5 + CGFloat(swing)
            lift = CGFloat(sin(swing * .pi)) * legLift
        }

        let stride = isWalking
            ? bodyWidth * Self.strideLength * strideFactor * CGFloat(Self.stanceShare)
            : 0
        // The hip rides the body; the foot belongs to the ground.
        let hip = onBody(CGPoint(x: side * bodyWidth * plan.0, y: bodyHeight * plan.1))
        let foot = CGPoint(x: side * bodyWidth * plan.2 + facing * stride * travel,
                           y: bodyHeight * plan.3 - lift)
        let limb = bodyWidth * plan.4
        // A crab bends its knees up and outward, so the joint is taken on the
        // side the leg is on.
        let knee = crabJoint(from: hip, to: foot,
                             first: limb * 0.56, second: limb * 0.50, bend: side)

        return LegPose(
            // Thick where it leaves the body, closing to the point a crab
            // actually walks on. The root is wide enough that the leg is still
            // at full thickness where it clears the shell's edge — a limb that
            // has already tapered by then looks pinned on rather than grown.
            limb: LimbShape(points: [hip, knee, foot],
                            widths: [bodyWidth * 0.088, bodyWidth * 0.056,
                                     bodyWidth * 0.018]),
            rest: bodyHeight * plan.3 + bodyWidth * 0.02,
            toe: foot.x,
            // The dimple the planted foot presses into the sand fades as the
            // leg picks up, which is what sells the contact.
            contact: 1 - Double(lift / legLift)
        )
    }

}

/// Two-bone inverse kinematics, shared by the legs and the arms. Given where a
/// limb is hinged and where its end has to be, there is exactly one joint
/// position on each side of the line between them; `bend` picks which.
private func crabJoint(from root: CGPoint, to end: CGPoint,
                       first: CGFloat, second: CGFloat, bend: CGFloat) -> CGPoint {
    let dx = end.x - root.x
    let dy = end.y - root.y
    let reach = max(0.001, (dx * dx + dy * dy).squareRoot())
    // A limb can neither stretch past its own length nor fold through itself;
    // clamping here is what keeps the joint from snapping.
    let span = min(max(reach, abs(first - second) + 0.1), first + second - 0.1)
    let along = (first * first - second * second + span * span) / (2 * span)
    let out = (max(0, first * first - along * along)).squareRoot()
    let ux = dx / reach
    let uy = dy / reach
    return CGPoint(x: root.x + ux * along + uy * out * bend,
                   y: root.y + uy * along - ux * out * bend)
}

/// One limb, drawn as a single closed outline through a chain of points with a
/// width at each: hip to knee to toe, or shoulder to elbow to palm, or the
/// finger of a claw. There are no separate segments and no knuckle discs to
/// give a joint away — the outline runs round the whole limb once, and the
/// bends in it are curves rather than corners.
///
/// The points are in the sprite's own centred coordinates, so a limb can be
/// laid over the same frame as everything else it belongs to.
private struct LimbShape: Shape {
    var points: [CGPoint]
    /// Half-widths, one per point.
    var widths: [CGFloat]

    func path(in rect: CGRect) -> Path {
        guard points.count >= 2, widths.count == points.count else { return Path() }
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        let spine = points.map { CGPoint(x: centre.x + $0.x, y: centre.y + $0.y) }

        // The direction of each segment, and the direction at each point: at a
        // bend it is the average of the two, which is what keeps the outline
        // from pinching on the inside of the joint.
        var headings: [CGPoint] = []
        for index in spine.indices {
            let back = index > 0 ? direction(spine[index - 1], spine[index]) : nil
            let ahead = index < spine.count - 1 ? direction(spine[index], spine[index + 1]) : nil
            switch (back, ahead) {
            case let (previous?, next?):
                headings.append(normalised(CGPoint(x: previous.x + next.x,
                                                   y: previous.y + next.y)))
            case let (previous?, nil): headings.append(previous)
            case let (nil, next?):     headings.append(next)
            default:                   headings.append(CGPoint(x: 1, y: 0))
            }
        }

        let left = spine.indices.map { index in
            CGPoint(x: spine[index].x - headings[index].y * widths[index],
                    y: spine[index].y + headings[index].x * widths[index])
        }
        let right = spine.indices.map { index in
            CGPoint(x: spine[index].x + headings[index].y * widths[index],
                    y: spine[index].y - headings[index].x * widths[index])
        }

        var path = Path()
        path.move(to: left[0])
        trace(&path, along: left)
        cap(&path, at: spine[spine.count - 1], from: left[left.count - 1],
            to: right[right.count - 1], heading: headings[headings.count - 1],
            width: widths[widths.count - 1])
        trace(&path, along: right.reversed())
        cap(&path, at: spine[0], from: right[0], to: left[0],
            heading: CGPoint(x: -headings[0].x, y: -headings[0].y), width: widths[0])
        path.closeSubpath()
        return path
    }

    /// A smooth run down one side of the limb: every bend is taken as a curve
    /// through the offset points rather than as a corner between two segments.
    private func trace(_ path: inout Path, along side: [CGPoint]) {
        guard side.count > 2 else {
            if let last = side.last { path.addLine(to: last) }
            return
        }
        for index in 1..<(side.count - 1) {
            let next = index == side.count - 2
                ? side[index + 1]
                : CGPoint(x: (side[index].x + side[index + 1].x) / 2,
                          y: (side[index].y + side[index + 1].y) / 2)
            path.addQuadCurve(to: next, control: side[index])
        }
    }

    /// The round end of the limb, drawn as two quarter turns through the point
    /// straight ahead of it.
    private func cap(_ path: inout Path, at point: CGPoint,
                     from start: CGPoint, to end: CGPoint,
                     heading: CGPoint, width: CGFloat) {
        let ahead = CGPoint(x: point.x + heading.x * width, y: point.y + heading.y * width)
        path.addQuadCurve(to: ahead,
                          control: CGPoint(x: start.x + heading.x * width,
                                           y: start.y + heading.y * width))
        path.addQuadCurve(to: end,
                          control: CGPoint(x: end.x + heading.x * width,
                                           y: end.y + heading.y * width))
    }

    private func direction(_ from: CGPoint, _ to: CGPoint) -> CGPoint {
        normalised(CGPoint(x: to.x - from.x, y: to.y - from.y))
    }

    private func normalised(_ point: CGPoint) -> CGPoint {
        let length = max(0.0001, (point.x * point.x + point.y * point.y).squareRoot())
        return CGPoint(x: point.x / length, y: point.y / length)
    }
}

extension Shape {
    /// The ink line for one piece of an animal: the piece itself, grown by the
    /// line's width all the way round. Every piece of a limb is inked first and
    /// filled afterwards, so the line only ever shows on the outside of the
    /// silhouette and never between two pieces of the same creature.
    func inked(_ colour: Color, width: CGFloat) -> some View {
        self.fill(colour)
            .overlay {
                self.stroke(colour, style: StrokeStyle(lineWidth: width * 2,
                                                       lineCap: .round,
                                                       lineJoin: .round))
            }
    }
}

/// The crab's back: a broad dome with a flatter face, tucked in at the bottom
/// and spiked along its widest line.
private struct CarapaceShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.06, y: h * 0.52))
        // The dome.
        path.addCurve(to: CGPoint(x: w * 0.50, y: 0),
                      control1: CGPoint(x: w * 0.07, y: h * 0.17),
                      control2: CGPoint(x: w * 0.26, y: 0))
        path.addCurve(to: CGPoint(x: w * 0.94, y: h * 0.52),
                      control1: CGPoint(x: w * 0.74, y: 0),
                      control2: CGPoint(x: w * 0.93, y: h * 0.17))
        // A small spike either side, on the widest line.
        path.addLine(to: CGPoint(x: w * 1.00, y: h * 0.60))
        path.addLine(to: CGPoint(x: w * 0.93, y: h * 0.64))
        // The tucked-in underside.
        path.addCurve(to: CGPoint(x: w * 0.50, y: h),
                      control1: CGPoint(x: w * 0.90, y: h * 0.92),
                      control2: CGPoint(x: w * 0.72, y: h))
        path.addCurve(to: CGPoint(x: w * 0.07, y: h * 0.64),
                      control1: CGPoint(x: w * 0.28, y: h),
                      control2: CGPoint(x: w * 0.10, y: h * 0.92))
        path.addLine(to: CGPoint(x: 0, y: h * 0.60))
        path.closeSubpath()
        return path
    }
}

/// A grin: corners up, a shallow curve across the top and a deep one under it,
/// so the mouth is widest where it is open and closes to a point at each end.
private struct MouthShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                          control: CGPoint(x: rect.midX, y: rect.minY + h * 0.34))
        path.addCurve(to: CGPoint(x: rect.minX, y: rect.minY),
                      control1: CGPoint(x: rect.minX + w * 0.86, y: rect.minY + h * 1.5),
                      control2: CGPoint(x: rect.minX + w * 0.14, y: rect.minY + h * 1.5))
        path.closeSubpath()
        return path
    }
}

// MARK: - Arms

/// What a crab is holding, in the sprite's own centred coordinates: the two
/// points on the load's edge its pincers close on, and the load's centre, which
/// is the direction the jaws are turned to bite in.
private struct CrabHold {
    var left: CGPoint
    var right: CGPoint
    var centre: CGPoint

    /// A crab holding nothing still keeps its claws up, the way a crab does.
    static func raised(bodyWidth: CGFloat) -> CrabHold {
        CrabHold(left: CGPoint(x: -bodyWidth * 0.56, y: -bodyWidth * 0.50),
                 right: CGPoint(x: bodyWidth * 0.56, y: -bodyWidth * 0.50),
                 centre: CGPoint(x: 0, y: -bodyWidth * 0.62))
    }
}

/// One crab's two arms, solved rather than posed. The shoulders are carried
/// through the body's own bob and roll, the hands are wherever the load's edge
/// has swung to, and the elbow is whatever angle joins the two — so the crab
/// keeps hold of a shell that is moving independently of it.
///
/// The proportions are the point of the thing: a slim arm and a small pincer
/// against a shell wider than the crab reads as *carrying something big*, where
/// a heavy claw reads as a crab with a card stuck to it.
private struct CrabArmRig {
    /// One arm as the four shapes it is drawn from: the arm itself, the palm,
    /// and the two fingers of the claw. They overlap on purpose — inked
    /// together they are one silhouette with one line round it.
    struct Arm {
        var limb: LimbShape
        /// The heel of the hand: a fat oval lying along the arm, not a dot. A
        /// crab's claw is mostly palm, and it is the one part that stops two
        /// fingers from reading as a fork on the end of a stick.
        var palm: LimbShape
        var fingers: [LimbShape]
    }

    var outline: CGFloat
    /// The body this arm belongs to, where it is this frame. The arms are drawn
    /// over everything the crab is carrying, so the body has to be cut back out
    /// of them again — that is what puts a shoulder behind the shell it grows
    /// from without breaking the arm into pieces to do it.
    var bodySize: CGSize
    var bodyRoll: Double
    var bodyBob: CGFloat
    var left: Arm
    var right: Arm

    init(bodyWidth: CGFloat, stepPhase: Double, isWalking: Bool,
         facing: CGFloat, hold: CrabHold) {
        let bodyHeight = bodyWidth * CrabSprite.heightRatio
        outline = max(0.75, bodyWidth * 0.026)
        bodySize = CGSize(width: bodyWidth, height: bodyHeight)

        // The shoulders ride with the body: the rig is drawn outside the roll,
        // so it has to apply that roll to its own two anchor points.
        let roll = CrabSprite.roll(stepPhase: stepPhase,
                                   isWalking: isWalking,
                                   facing: facing) * .pi / 180
        let bob = CrabSprite.bob(bodyWidth: bodyWidth,
                                 stepPhase: stepPhase,
                                 isWalking: isWalking)
        bodyRoll = CrabSprite.roll(stepPhase: stepPhase,
                                   isWalking: isWalking,
                                   facing: facing)
        bodyBob = bob
        let cosine = CGFloat(cos(roll))
        let sine = CGFloat(sin(roll))
        func onBody(_ point: CGPoint) -> CGPoint {
            CGPoint(x: point.x * cosine - point.y * sine,
                    y: point.x * sine + point.y * cosine + bob)
        }

        // Well inside the shell, so the arm runs out from under the body rather
        // than being pinned to its outline. The body is masked back out of the
        // arms, so this end is never seen.
        let shoulder = CGPoint(x: bodyWidth * 0.30, y: -bodyHeight * 0.06)
        // Short segments: a crab's arms are stubby, and holding the load low
        // means the elbow has somewhere to bend to.
        // A quarter shorter than the arms were first drawn at: long arms let the
        // load drift out to the side of the head and wobble there, and the card
        // has to sit square over the animal that is carrying it.
        let upper = bodyWidth * 0.42
        let fore = bodyWidth * 0.36
        // The pincer is the character's face after its face: a crab is *its
        // claws*, so the hand is drawn at the size a real one is — a good third
        // of the body — rather than as a fingertip on the end of the arm.
        let hand = bodyWidth * 0.44

        func arm(shoulder: CGPoint, grip: CGPoint, bend: CGFloat) -> Arm {
            let toLoad = CGPoint(x: hold.centre.x - grip.x, y: hold.centre.y - grip.y)
            let span = max(0.0001, (toLoad.x * toLoad.x + toLoad.y * toLoad.y).squareRoot())
            let bite = CGPoint(x: toLoad.x / span, y: toLoad.y / span)
            // The palm stays outside the edge it holds and only the two finger
            // tips cross it. A claw whose whole hand sits on the shell reads as
            // stuck to it; one that closes on the edge reads as pinching it.
            let palm = CGPoint(x: grip.x - bite.x * hand * 0.88,
                               y: grip.y - bite.y * hand * 0.88)
            // The heel is offset across the bite as well as back along it, so
            // the hand is a claw lying at an angle on the wrist rather than a
            // sausage pointing straight at what it holds.
            let wrist = CGPoint(x: palm.x - bite.x * hand * 0.46 - bite.y * hand * 0.10 * bend,
                                y: palm.y - bite.y * hand * 0.46 + bite.x * hand * 0.10 * bend)
            let elbow = crabJoint(from: shoulder, to: wrist,
                                  first: upper, second: fore, bend: bend)
            /// A point on the claw, in the claw's own frame: `along` runs from
            /// the knuckle out towards the edge being held, `across` is the
            /// side the pincer opens to. Both are shares of the hand's own
            /// size, so the whole claw scales with the animal.
            func onClaw(_ along: CGFloat, _ across: CGFloat) -> CGPoint {
                CGPoint(x: palm.x + (bite.x * along - bite.y * across * bend) * hand,
                        y: palm.y + (bite.y * along + bite.x * across * bend) * hand)
            }

            /// One jaw, drawn as a hook: it leaves the knuckle splayed wide,
            /// carries its bulk half way out and curls back onto the axis at
            /// the tip. The two of them close on the edge with a sliver left
            /// between them — and that dark sliver, more than the outline, is
            /// what makes a claw read as a pincer rather than as a mitten.
            func jaw(_ points: [(CGFloat, CGFloat)], _ widths: [CGFloat]) -> LimbShape {
                LimbShape(points: points.map { onClaw($0.0, $0.1) },
                          widths: widths.map { $0 * hand })
            }

            return Arm(
                // A crab's arm is thicker than its walking legs: it is the limb
                // the animal carries things with, and an arm holding a shell
                // twice the body's width cannot be the thinnest thing on it.
                limb: LimbShape(points: [shoulder, elbow, wrist],
                                widths: [bodyWidth * 0.098, bodyWidth * 0.082,
                                         bodyWidth * 0.070]),
                // The heel of the claw: a fat pear lying along the wrist, wider
                // at the knuckle than where it joins the arm, which is the one
                // part that keeps two jaws from reading as a fork on a stick.
                palm: LimbShape(points: [wrist, palm],
                                widths: [hand * 0.22, hand * 0.30]),
                fingers: [
                    // The fixed jaw: the long, heavy one on the outside of the
                    // claw, which is the one taking the shell's weight.
                    jaw([(0.02, 0.16), (0.40, 0.42), (0.74, 0.36), (0.96, 0.20)],
                        [0.20, 0.175, 0.145, 0.100]),
                    // The movable jaw, closing onto it from the other side.
                    jaw([(0.02, -0.16), (0.34, -0.38), (0.64, -0.30), (0.84, -0.14)],
                        [0.18, 0.155, 0.130, 0.090])
                ]
            )
        }

        // The elbows bow away from the body, which is what leaves the shell's
        // face clear and the arms reading as raised rather than folded.
        left = arm(shoulder: onBody(CGPoint(x: -shoulder.x, y: shoulder.y)),
                   grip: hold.left,
                   bend: 1)
        right = arm(shoulder: onBody(shoulder),
                    grip: hold.right,
                    bend: -1)
    }
}

/// Both arms, each drawn as one creature part rather than as a stack of
/// segments: every piece of both arms is inked first and coloured afterwards,
/// so no line ever falls between the arm and its own claw, or between a claw
/// and the shell it is closed on. What is left is a silhouette with a single
/// line round it — which is what an arm on a finished character looks like.
private struct CrabArmsView: View {
    let rig: CrabArmRig
    let colors: (Color, Color)
    let line: Color

    private var shade: LinearGradient {
        LinearGradient(stops: [.init(color: colors.0, location: 0.15),
                               .init(color: colors.1, location: 1)],
                       startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        ZStack {
            ink(rig.left)
            ink(rig.right)
            colour(rig.left)
            colour(rig.right)
        }
        .compositingGroup()
        // The body is taken back out, so each arm runs behind the shell it
        // grows from and comes out over the one it is carrying — one drawing,
        // with the crab's own back in front of its shoulder.
        .mask {
            ZStack {
                // Well past the sprite's own frame: the claws reach above it to
                // the shell they are holding, and a mask the size of the frame
                // would cut them off there.
                Rectangle().fill(.white).scaleEffect(4)
                CarapaceShape()
                    .frame(width: rig.bodySize.width, height: rig.bodySize.height)
                    .rotationEffect(.degrees(rig.bodyRoll))
                    .offset(y: rig.bodyBob)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
        }
    }

    @ViewBuilder
    private func ink(_ arm: CrabArmRig.Arm) -> some View {
        arm.limb.inked(line, width: rig.outline)
        arm.palm.inked(line, width: rig.outline)
        ForEach(arm.fingers.indices, id: \.self) { index in
            arm.fingers[index].inked(line, width: rig.outline)
        }
    }

    @ViewBuilder
    private func colour(_ arm: CrabArmRig.Arm) -> some View {
        arm.limb.fill(shade)
        arm.palm.fill(shade)
        ForEach(arm.fingers.indices, id: \.self) { index in
            arm.fingers[index].fill(shade)
        }
    }
}

// MARK: - Rewards and specks

private struct ShellRewardView: View {
    let shell: ShellReward
    let palette: ReefPalette
    let isPad: Bool

    private var progress: Double {
        min(1, shell.age / ArenaConfig.shellFlightDuration)
    }

    var body: some View {
        CurrencyIcon(size: shell.diameter)
            .foregroundStyle(palette.character.deepColor)
            .frame(width: shell.diameter, height: shell.diameter)
            .scaleEffect(0.52 + (1 - pow(1 - min(1, progress / 0.28), 3)) * 0.48)
            .shadow(color: .white.opacity(0.82), radius: isPad ? 8 : 6)
            .accessibilityHidden(true)
    }
}

/// The streak's shower of shells and bubbles, all of it in one drawing pass.
///
/// A speck has no state, no hit testing and nothing to lay out — it is a shape
/// at a point — so it never needed a view of its own, and the celebration puts
/// a hundred of them on screen at once while the King is dancing.
private struct CelebrationCanvas: View {
    let specks: [CelebrationSpeck]
    let palette: ReefPalette

    var body: some View {
        // Synchronous, for the same reason as the effects canvas: an
        // asynchronously rendered pass can trail the animals by a frame.
        Canvas(opaque: false, rendersAsynchronously: false) { context, _ in
            for speck in specks {
                // They pop in rather than appearing at full size.
                let scale = min(1, CGFloat(speck.age / 0.18))
                guard scale > 0 else { continue }
                switch speck.kind {
                case .shell:
                    draw(shell: speck, scale: scale, in: &context)
                case .bubble:
                    draw(bubble: speck, scale: scale, in: &context)
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func draw(shell speck: CelebrationSpeck, scale: CGFloat,
                      in context: inout GraphicsContext) {
        let side = speck.radius * 2.4 * scale
        let rect = CGRect(x: speck.position.x - side / 2,
                          y: speck.position.y - side / 2,
                          width: side, height: side)
        // The same even-odd fill `CurrencyIcon` uses, so the shell keeps its
        // ribs rather than filling in solid.
        context.fill(ShellShape().path(in: rect),
                     with: .color(palette.coralDeep),
                     style: FillStyle(eoFill: true))
    }

    private func draw(bubble speck: CelebrationSpeck, scale: CGFloat,
                      in context: inout GraphicsContext) {
        let radius = speck.radius * scale
        let rect = CGRect(x: speck.position.x - radius, y: speck.position.y - radius,
                          width: radius * 2, height: radius * 2)
        let path = Path(ellipseIn: rect)
        context.fill(
            path,
            with: .radialGradient(
                Gradient(colors: [.white.opacity(0.42),
                                  palette.waterTop.opacity(0.22),
                                  .white.opacity(0.16)]),
                // `.topLeading` of the bubble's own box, as the gradient was
                // anchored when each speck had a frame to be relative to.
                center: CGPoint(x: rect.minX, y: rect.minY),
                startRadius: 1,
                endRadius: radius * 1.4
            )
        )
        context.stroke(path, with: .color(.white.opacity(0.48)),
                       lineWidth: max(1, speck.radius * 0.09))
    }
}

// MARK: - Effects

/// Plankton, rising bubbles and kicked-up sand share one immediate-mode render
/// pass. None of them needs its own layout, accessibility or hit-testing node.
private struct ArenaEffectsCanvas: View {
    let motes: [ReefMote]
    let ambientBubbles: [ReefAmbientBubble]
    let grains: [SandGrain]
    let palette: ReefPalette

    var body: some View {
        // Draw synchronously with the current display frame. Asynchronous
        // Canvas rendering can trail the crabs by a frame on older hardware.
        Canvas(opaque: false, rendersAsynchronously: false) { context, _ in
            for mote in motes {
                let rect = CGRect(x: mote.position.x - mote.radius,
                                  y: mote.position.y - mote.radius,
                                  width: mote.radius * 2,
                                  height: mote.radius * 2)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.34)))
            }

            for grain in grains {
                let progress = min(1, grain.age / grain.lifetime)
                let radius = grain.radius * (1 - CGFloat(progress) * 0.35)
                let rect = CGRect(x: grain.position.x - radius,
                                  y: grain.position.y - radius,
                                  width: radius * 2,
                                  height: radius * 2)
                let colour = grain.tone < 0.5 ? palette.sand : palette.sandDeep
                context.fill(Path(ellipseIn: rect),
                             with: .color(colour.opacity(0.85 * (1 - progress))))
            }

            for bubble in ambientBubbles {
                draw(ambientBubble: bubble, in: &context)
            }
        }
        .accessibilityHidden(true)
    }

    private func draw(ambientBubble bubble: ReefAmbientBubble,
                      in context: inout GraphicsContext) {
        let progress = bubble.popAge.map {
            min(1, CGFloat($0 / ArenaConfig.ambientBubblePopDuration))
        } ?? 0
        let opacity = 1 - Double(progress)
        let scale = bubble.popAge == nil ? CGFloat(1) : 1 + progress * 1.15
        let radius = bubble.radius * scale
        let rect = CGRect(x: bubble.position.x - radius,
                          y: bubble.position.y - radius,
                          width: radius * 2,
                          height: radius * 2)
        let shell = Path(ellipseIn: rect)
        context.fill(shell, with: .color(.white.opacity(0.10 * opacity)))
        context.stroke(shell, with: .color(.white.opacity(0.48 * opacity)),
                       lineWidth: max(1, bubble.radius * 0.16))

        let highlightRadius = bubble.radius * 0.19 * scale
        let highlightCenter = CGPoint(x: bubble.position.x - radius * 0.43,
                                      y: bubble.position.y - radius * 0.43)
        let highlight = CGRect(x: highlightCenter.x - highlightRadius,
                               y: highlightCenter.y - highlightRadius,
                               width: highlightRadius * 2,
                               height: highlightRadius * 2)
        context.fill(Path(ellipseIn: highlight),
                     with: .color(.white.opacity(0.68 * opacity)))
    }
}

/// The nearest layer in the scene: a few soft, out-of-focus specks drifting up
/// between the eye and the arena.
///
/// Deliberately almost invisible. Anything readable here would compete with the
/// answers a child is trying to read; what it is for is parallax. These move
/// several times faster than anything on the sea floor, and that difference is
/// what puts the arena at a distance.
private struct NearDrift: View, Equatable {
    let clock: Double

    /// x, diameter, rise rate, wobble phase.
    private static let specks: [(CGFloat, CGFloat, CGFloat, Double)] = [
        (0.13, 46, 15, 0.0), (0.31, 26, 22, 2.4), (0.49, 60, 11, 4.1),
        (0.67, 30, 19, 1.2), (0.84, 52, 13, 3.6), (0.94, 22, 25, 5.4)
    ]

    var body: some View {
        Canvas(opaque: false, rendersAsynchronously: false) { context, size in
            guard !ArenaPerformanceBudget.isConstrained else { return }

            for speck in Self.specks {
                let travel = size.height + speck.1 * 2
                // Rising and wrapping, so the layer has no start and no end.
                let raw = size.height - CGFloat(clock) * speck.2
                    + speck.3 * 40
                let wrapped = raw.truncatingRemainder(dividingBy: travel)
                let y = (wrapped >= 0 ? wrapped : wrapped + travel) - speck.1
                let x = size.width * speck.0
                    + CGFloat(sin(clock * 0.29 + speck.3)) * 14
                let radius = speck.1 / 2

                context.fill(
                    Path(ellipseIn: CGRect(x: x - radius, y: y - radius,
                                           width: speck.1, height: speck.1)),
                    with: .radialGradient(
                        Gradient(stops: [
                            .init(color: .white.opacity(0.05), location: 0),
                            .init(color: .white.opacity(0.09), location: 0.72),
                            .init(color: .white.opacity(0), location: 1)
                        ]),
                        center: CGPoint(x: x, y: y), startRadius: 0, endRadius: radius
                    )
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Water

/// The water column: the whole screen, from the surface at the very top edge
/// down to the sea floor.
///
/// Four rungs rather than two. Shallow tropical water reads as *shallow*
/// because of what happens between the surface and the floor: it goes in
/// almost white-cyan, saturates to blue through the open middle, and turns
/// green again as it picks the sand back up. A straight top-to-bottom fade
/// between two blues gives depth but no water.
private struct WaterColumn: View, Equatable {
    let palette: ReefPalette
    let clock: Double

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.palette.character == rhs.palette.character && lhs.clock == rhs.clock
    }

    var body: some View {
        // The surface breathes on two periods that never come back round
        // together, so the top of the screen never settles into a pulse.
        let breath = 0.5 + 0.5 * sin(clock * 0.21)
        let glint = 0.5 + 0.5 * sin(clock * 0.13 + 1.7)

        ZStack(alignment: .top) {
            LinearGradient(stops: [
                .init(color: palette.waterSurface, location: 0),
                .init(color: palette.waterShallow, location: 0.11),
                .init(color: palette.waterMid, location: 0.34),
                .init(color: palette.waterMid, location: 0.52),
                .init(color: palette.waterFloor, location: 0.84),
                .init(color: palette.waterFloor, location: 1)
            ], startPoint: .top, endPoint: .bottom)

            // The sun going in. It sits over the middle of the top edge, which
            // is where the shafts below hang from, and slowly gains and loses
            // its edge the way a surface seen from underneath does.
            SurfaceGlow(strength: 0.72 + 0.28 * breath, glint: glint)
        }
        // The glow adds itself to the water under it and to nothing else. Left
        // ungrouped, `plusLighter` would reach past the column into whatever
        // the playfield is sitting on.
        .compositingGroup()
    }
}

/// The lit surface at the very top of the screen: a wide bloom over the middle
/// and a couple of soft bands under it, standing in for the ceiling of moving
/// water that the whole scene is lit through.
private struct SurfaceGlow: View {
    let strength: Double
    let glint: Double

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            // Only the top of the screen is surface; everything below it is
            // water, and painting over that would flatten the column.
            let band = height * 0.22

            ZStack(alignment: .top) {
                // The bloom itself, centred and wider than it is tall.
                Ellipse()
                    .fill(
                        // Bright, but not white: the surface is the most
                        // saturated turquoise in the picture, and washing it
                        // out is what turns "sunlit water" into "overexposed".
                        RadialGradient(
                            colors: [.white.opacity(0.40 * strength),
                                     .white.opacity(0.12 * strength),
                                     .white.opacity(0)],
                            center: .center, startRadius: 0, endRadius: width * 0.62
                        )
                    )
                    .frame(width: width * 1.6, height: band * 1.5)
                    .offset(y: -band * 0.75)

                // Two bands of glancing light just under it. They are what make
                // the ceiling read as water rather than as a lamp.
                LinearGradient(stops: [
                    .init(color: .white.opacity(0.30 * glint), location: 0),
                    .init(color: .white.opacity(0.10 * glint), location: 0.35),
                    .init(color: .white.opacity(0), location: 1)
                ], startPoint: .top, endPoint: .bottom)
                    .frame(height: band * 0.55)

                LinearGradient(stops: [
                    .init(color: .white.opacity(0), location: 0),
                    .init(color: .white.opacity(0.12 * (1 - glint)), location: 0.5),
                    .init(color: .white.opacity(0), location: 1)
                ], startPoint: .top, endPoint: .bottom)
                    .frame(height: band * 0.42)
                    .offset(y: band * 0.30)
            }
            .frame(width: width, height: height, alignment: .top)
            .blendMode(.plusLighter)
        }
        .allowsHitTesting(false)
    }
}

/// The depth that sits over everything scenic: darker, bluer water down both
/// outer edges and along the very top corners.
///
/// Drawn above the sea floor but below the animals. The edges of a real arena
/// fall away into the water, which is what hands the middle of the screen its
/// attention for free — but a crab walking in at the side still has to be as
/// readable as one in the centre, so the fall-off never reaches them.
private struct DepthVignette: View, Equatable {
    let palette: ReefPalette

    var body: some View {
        LinearGradient(stops: [
            .init(color: palette.waterDeep.opacity(0.42), location: 0),
            .init(color: palette.waterDeep.opacity(0.12), location: 0.16),
            .init(color: .clear, location: 0.34),
            .init(color: .clear, location: 0.66),
            .init(color: palette.waterDeep.opacity(0.12), location: 0.84),
            .init(color: palette.waterDeep.opacity(0.42), location: 1)
        ], startPoint: .leading, endPoint: .trailing)
        .blendMode(.multiply)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// The water standing between the eye and the far end of the sea floor.
///
/// The crest itself is taken care of where the sand is drawn, on the curve.
/// This is the rest of it: a wash of the water's own blue-green over the far
/// third of the bed, so the reef and the stones back there lose their contrast
/// the way the sand under them already has.
private struct DistanceHaze: View, Equatable {
    let palette: ReefPalette

    var body: some View {
        LinearGradient(stops: [
            .init(color: palette.waterFloor.opacity(0.34), location: 0),
            .init(color: palette.waterFloor.opacity(0.22), location: 0.09),
            .init(color: palette.waterFloor.opacity(0.07), location: 0.18),
            .init(color: palette.waterFloor.opacity(0), location: 0.28)
        ], startPoint: .top, endPoint: .bottom)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

/// Thin weed and a few plant silhouettes along the outer edges of the open
/// water, above the sea floor.
///
/// They are almost the water's own colour: at that distance a plant is a
/// shape, not a thing with leaves. They keep to the outermost tenth of each
/// side so the middle of the screen stays the open blue the arena is read
/// against, and they are the slowest-moving layer in the scene.
private struct DistantWeeds: View, Equatable {
    let palette: ReefPalette
    let crest: CGFloat
    let clock: Double

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.palette.character == rhs.palette.character
            && lhs.crest == rhs.crest
            && lhs.clock == rhs.clock
    }

    /// x (share of width), height (share of the water above the crest), lean,
    /// sway rate, phase, thickness.
    private static let blades: [(CGFloat, CGFloat, CGFloat, Double, Double, CGFloat)] = [
        (0.012, 0.62, 0.10, 0.28, 0.0, 1.00), (0.040, 0.44, -0.08, 0.34, 1.9, 0.72),
        (0.068, 0.52, 0.06, 0.25, 2.6, 0.84), (0.096, 0.30, 0.13, 0.31, 3.4, 0.58),
        (0.026, 0.24, -0.14, 0.39, 5.1, 0.46), (0.054, 0.35, 0.11, 0.33, 0.6, 0.62),
        (0.124, 0.21, -0.10, 0.37, 4.7, 0.44),
        (0.988, 0.58, -0.11, 0.26, 0.8, 0.94), (0.960, 0.40, 0.09, 0.36, 2.7, 0.68),
        (0.932, 0.50, -0.07, 0.24, 3.9, 0.80), (0.904, 0.27, -0.12, 0.30, 4.3, 0.54),
        (0.974, 0.20, 0.15, 0.41, 5.8, 0.42), (0.946, 0.33, -0.13, 0.35, 1.4, 0.60),
        (0.876, 0.19, 0.12, 0.38, 5.3, 0.40)
    ]

    private var blades: [(CGFloat, CGFloat, CGFloat, Double, Double, CGFloat)] {
        ArenaPerformanceBudget.isConstrained
            ? Self.blades.enumerated().filter { $0.offset.isMultiple(of: 2) }.map(\.element)
            : Self.blades
    }

    var body: some View {
        Canvas(opaque: false, rendersAsynchronously: false) { context, size in
            let bed = max(1, size.height - crest)
            // How much water there is to grow up through, and therefore how
            // tall anything back there can afford to be.
            let reach = max(80, crest)

            for blade in blades {
                let sway = sin(clock * blade.3 + blade.4)
                let lean = blade.2 + CGFloat(sway) * 0.09
                // Rooted on the sand as it actually lies at this x, not on the
                // crown of the mound. These grow at the very edges of the
                // screen, which is where the sea floor has fallen furthest
                // away from its middle — root them all at the crest and they
                // hang in open water.
                let fromMiddle = pow(abs(blade.0 - 0.5) * 2, 1.4)
                let root = crest + bed * sandCrestDrop * fromMiddle + bed * 0.008
                let top = root - reach * blade.1
                let x = size.width * blade.0
                let width = max(2, size.width * 0.010 * blade.5)

                var path = Path()
                path.move(to: CGPoint(x: x, y: root))
                path.addCurve(
                    to: CGPoint(x: x + reach * blade.1 * lean, y: top),
                    control1: CGPoint(x: x, y: root - reach * blade.1 * 0.45),
                    control2: CGPoint(x: x + reach * blade.1 * lean * 1.5,
                                      y: root - reach * blade.1 * 0.78)
                )
                context.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [palette.waterFloor.opacity(0.16),
                                          palette.plant.opacity(0.44)]),
                        startPoint: CGPoint(x: x, y: top),
                        endPoint: CGPoint(x: x, y: root)
                    ),
                    style: StrokeStyle(lineWidth: width, lineCap: .round)
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Sunlight coming down through the surface. The shafts are drawn over the
/// water *and* over the sea floor, because that is what puts the player under
/// the water rather than in front of a picture of it: light falls across the
/// sand, not behind it.
///
/// Each shaft is two gradients rather than a blurred shape — soft at both edges
/// and fading with depth — which costs a fraction of a full-screen blur pass.
private struct LightShafts: View, Equatable {
    let clock: Double
    let isPad: Bool

    /// centre x, width, lean, drift rate, brightness, breathing rate.
    ///
    /// The leans open *outward* from the middle of the top edge: left-hand
    /// shafts fall to the left, right-hand ones to the right. That is the one
    /// thing that says the light has a source rather than being a rain of
    /// parallel stripes — and the source is exactly where the surface bloom
    /// hangs, over the middle of the screen.
    ///
    /// The widths are deliberately uneven. Two broad, two narrow and a thin
    /// bright one between them is what water does; five of the same width is
    /// what a pattern does.
    private static let shafts: [(CGFloat, CGFloat, Double, Double, Double, Double)] = [
        (0.09, 0.32, -19, 0.17, 0.86, 0.11),
        (0.26, 0.11, -12, 0.23, 0.66, 0.19),
        (0.36, 0.30, -6, 0.13, 0.58, 0.09),
        (0.50, 0.26, 1, 0.27, 0.50, 0.23),
        (0.67, 0.30, 8, 0.10, 0.62, 0.14),
        (0.82, 0.14, 14, 0.20, 0.66, 0.17),
        (0.94, 0.28, 20, 0.15, 0.78, 0.12)
    ]

    /// Four beams where the frame budget is tightest. They are full-height
    /// gradients across the whole scene, so this is the cheapest place in the
    /// backdrop to give something back.
    private var shafts: [(CGFloat, CGFloat, Double, Double, Double, Double)] {
        ArenaPerformanceBudget.isConstrained
            ? Self.shafts.enumerated().filter { !$0.offset.isMultiple(of: 2) }.map(\.element)
            : Self.shafts
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.clock == rhs.clock && lhs.isPad == rhs.isPad
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack(alignment: .top) {
                ForEach(Array(shafts.enumerated()), id: \.offset) { index, shaft in
                    // Each beam gains and loses strength on its own period, so
                    // the light over the arena is never twice the same and
                    // never visibly a loop.
                    let pulse = 0.72 + 0.28 * sin(clock * shaft.5 + Double(index) * 1.7)

                    Rectangle()
                        .fill(
                            LinearGradient(stops: [
                                .init(color: .white.opacity(0), location: 0),
                                .init(color: .white.opacity(0.50 * shaft.4 * pulse),
                                      location: 0.40),
                                .init(color: .white.opacity(0.72 * shaft.4 * pulse),
                                      location: 0.54),
                                .init(color: .white.opacity(0.34 * shaft.4 * pulse),
                                      location: 0.70),
                                .init(color: .white.opacity(0), location: 1)
                            ], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: width * shaft.1, height: height * 1.6)
                        // The beam is brightest just under the surface and gone
                        // long before the deepest sand.
                        .mask {
                            LinearGradient(stops: [
                                .init(color: .white.opacity(0.30), location: 0),
                                .init(color: .white, location: 0.14),
                                .init(color: .white.opacity(0.40), location: 0.32),
                                .init(color: .white.opacity(0.10), location: 0.52),
                                .init(color: .clear, location: 0.74)
                            ], startPoint: .top, endPoint: .bottom)
                        }
                        .rotationEffect(.degrees(shaft.2), anchor: .top)
                        .offset(x: width * (shaft.0 - 0.5)
                                    + CGFloat(sin(clock * shaft.3 + Double(index))) * width * 0.035)
                }
            }
            .frame(width: width, height: height, alignment: .top)
        }
        .blendMode(.plusLighter)
        // Seven beams rather than five, so each one carries less. Over water
        // they can be as strong as they like — and they are what the empty
        // blue between the sum and the sand is made of. It is on the sand that
        // a beam stops being light and becomes a stripe, and the mask above
        // has them all but gone by the time they get there.
        .opacity(0.19)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Sea floor

/// The arena floor: a sand bed with its crest just under the sum, light dappling
/// across it, and a reef of coral and rock framing both edges. Everything here
/// is scenery — nothing on this layer is ever touched or walked into.
private struct ArenaFloor: View, Equatable {
    let palette: ReefPalette
    let isPad: Bool
    /// Screen y of the sand's crest.
    let crest: CGFloat
    /// Where the sun lands on the bed, as a share of its height.
    let sunShare: CGFloat
    let clock: Double

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.palette.character == rhs.palette.character
            && lhs.isPad == rhs.isPad
            && lhs.crest == rhs.crest
            && lhs.sunShare == rhs.sunShare
            && lhs.clock == rhs.clock
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let sandHeight = max(140, size.height - crest)
            // The whole floor leans with the water, by a hand's width at most,
            // and each layer by less than the one in front of it. There is no
            // camera to move, so this is where the scene's depth comes from:
            // far weed barely stirs, the near corners visibly do.
            let drift = CGFloat(sin(clock * 0.11))

            ZStack(alignment: .bottom) {
                // The sand itself does not move. The floor around it is rebuilt
                // on every sway step, so the pieces that hold still say so and
                // are skipped rather than re-solved into the same picture.
                SandBed(palette: palette)
                    .equatable()
                    .frame(height: sandHeight)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                // The far bed's own light, hanging in the water above it.
                CrestGlow(palette: palette)
                    .equatable()
                    .frame(height: sandHeight)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                // Ripples, dimples, stones and shells. All of it lies still, so
                // none of it takes the clock.
                SandRelief(palette: palette, isPad: isPad)
                    .equatable()
                    .frame(height: sandHeight)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                // Stones with their own planting growing out from between them.
                SeaGardens(palette: palette, isPad: isPad, clock: clock)
                    .frame(height: sandHeight)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .offset(x: drift * 1.5)

                // The reef itself, hugging both edges where nothing walks.
                ReefBorder(palette: palette, isPad: isPad, clock: clock)
                    .frame(height: sandHeight)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .offset(x: drift * 2.5)

                // Everything above this line is far away, and the water it is
                // seen through takes its edge off — the far reef included.
                DistanceHaze(palette: palette)
                    .equatable()
                    .frame(height: sandHeight)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                // The light comes last of the far layers, so it falls across
                // the stones and the coral as well as the sand. Light that
                // stopped at the sand would put the reef in front of a picture
                // of the sea floor rather than in it.
                SandLight(palette: palette, isPad: isPad,
                          sunShare: sunShare, clock: clock)
                    .frame(height: sandHeight)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                // The near corners are *not* here: they are the closest thing
                // in the scene, so they are drawn over the animals instead —
                // see `NearReef`, which the playfield lays in above the crabs.
            }
            .frame(width: size.width, height: size.height)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// The sand itself: one soft mound rather than a straight edge, running off the
/// bottom of the screen so the floor never ends in a visible line.
private struct SandBed: View, Equatable {
    let palette: ReefPalette

    var body: some View {
        SandShape()
            .fill(
                // Warmest through the middle, where the sun lands, and darker
                // again right at the bottom edge — sand close enough to the eye
                // to be under the reef rather than lit by the surface.
                LinearGradient(stops: [
                    .init(color: palette.sand, location: 0),
                    .init(color: palette.sand, location: 0.26),
                    .init(color: palette.sandSunlit, location: 0.54),
                    .init(color: palette.sand, location: 0.78),
                    .init(color: palette.sandDeep, location: 1)
                ], startPoint: .top, endPoint: .bottom)
            )
            .overlay {
                // The far end of the bed, taking the water's own colour. It
                // is stroked along the crest rather than laid across the top
                // of the frame, because the crest is a curve: a horizontal
                // band of haze would sit right on the middle of the mound and
                // miss both corners, which are the furthest sand in the
                // picture and the part that most needs to go.
                SandCrestShape()
                    .stroke(palette.waterFloor, lineWidth: 64)
                    .blur(radius: 26)
                    .mask { SandShape() }
                    .opacity(0.85)
            }
            .overlay {
                // A pale lip along the crest, where the light hits the ridge
                // the whole arena sits on. Kept faint: the haze laid over it
                // is what the distance is made of, and a crisp lip under that
                // would put the horizon straight back.
                SandShape()
                    .stroke(.white.opacity(0.14), lineWidth: 2.5)
                    .blur(radius: 1.5)
                    .mask {
                        LinearGradient(colors: [.white, .clear],
                                       startPoint: .top, endPoint: .bottom)
                    }
            }
            // The crest itself is dissolved rather than drawn: the sand is
            // masked by a blurred copy of its own outline, so it comes up out
            // of the water over some forty points instead of starting at a
            // line. Tinting either side of a hard edge cannot do this — the
            // edge has to stop existing.
            //
            // The mask is grown past the frame on the sides and the bottom
            // first, so the same blur that softens the crest does not eat the
            // sand where it runs off the screen.
            .mask {
                SandShape()
                    .fill(.white)
                    .padding(EdgeInsets(top: 0, leading: -34, bottom: -34, trailing: -34))
                    .blur(radius: 17)
            }
            .accessibilityHidden(true)
    }
}

/// The far side of the bed glowing through the water above it.
///
/// The same curve as the crest, stroked pale and blurred wide enough to bleed
/// on both sides of it. Distance in water is not something that happens to the
/// floor and stops: the light comes off it and hangs in the water in front of
/// it, and that overspill is the reason there is nothing here that could be
/// pointed at and called the horizon.
private struct CrestGlow: View, Equatable {
    let palette: ReefPalette

    var body: some View {
        SandCrestShape()
            .stroke(palette.sand.opacity(0.55), lineWidth: 24)
            .blur(radius: 24)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

/// How far below the top of the sand bed the crest actually lies, at its
/// lowest — the two outer corners, where `SandShape`'s mound has dropped away
/// from its middle.
///
/// Anything drawn *on* the floor starts below this line. A ripple or a patch
/// of light that began at the top of the bed would be over the crest and out
/// in open water at both edges, which is the one mistake that gives away that
/// the sea floor is a rectangle with a curve drawn on it.
private let sandBedTop: CGFloat = sandCrestDrop + 0.012

/// How far the crest falls away from the middle of the screen to the two
/// corners, as a share of the sand bed's height.
///
/// Small on purpose. A shallow bed seen from just above it rises a little in
/// the middle and no more; anything deeper stops being a rise in the floor and
/// becomes a hill standing in the water, with two visible slopes and a summit.
/// Everything that has to sit on the floor reads this back, so the whole scene
/// agrees about where the sand is.
private let sandCrestDrop: CGFloat = 0.055

/// Traces the crest from the left corner to the right one.
private func addSandCrest(to path: inout Path, in rect: CGRect) {
    let w = rect.width
    let h = rect.height
    let drop = h * sandCrestDrop
    path.move(to: CGPoint(x: rect.minX, y: drop))
    // A long, flat-topped bulge rather than a peak: the control points hold
    // the curve down almost until the middle, so there is no summit anywhere.
    path.addCurve(to: CGPoint(x: w * 0.50, y: 0),
                  control1: CGPoint(x: w * 0.20, y: drop * 0.94),
                  control2: CGPoint(x: w * 0.34, y: drop * 0.06))
    path.addCurve(to: CGPoint(x: rect.maxX, y: drop * 0.88),
                  control1: CGPoint(x: w * 0.68, y: drop * 0.04),
                  control2: CGPoint(x: w * 0.83, y: drop * 0.82))
}

/// The crest of `SandShape` on its own, as an open curve.
///
/// Anything that belongs *to the edge* of the sea floor rather than to its
/// surface is drawn along this: the haze, the glow above it. Stroking the
/// closed sand shape instead would run the same line down both sides of the
/// screen and along the bottom, and put fog in the near corners.
private struct SandCrestShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        addSandCrest(to: &path, in: rect)
        return path
    }
}

private struct SandShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        addSandCrest(to: &path, in: rect)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Everything lying still on the sand: the ripples the swell leaves behind, the
/// dimples between them, and the pebbles, shells and starfish scattered along
/// the walking lanes.
///
/// One immediate-mode pass for all of it, and no clock anywhere in it. Their
/// positions are fixed — a floor that reshuffled itself between rounds would be
/// noticed immediately — so the whole layer says it is unchanged and the sway
/// step steps straight over it.
///
/// Everything here is drawn with depth in mind: the same ripple is finer,
/// flatter and fainter at the top of the bed than at the bottom, because the
/// top of the bed is metres further away.
private struct SandRelief: View, Equatable {
    let palette: ReefPalette
    let isPad: Bool

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.palette.character == rhs.palette.character && lhs.isPad == rhs.isPad
    }

    /// Ribbed sand, from the far bed down to the near edge.
    private static let rippleRows = 16

    /// Hollows scooped out between the ribs: x, y, width, depth of shading.
    private static let dimples: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (0.21, 0.20, 0.10, 0.55), (0.62, 0.28, 0.08, 0.45),
        (0.38, 0.47, 0.13, 0.70), (0.83, 0.52, 0.11, 0.60),
        (0.14, 0.63, 0.12, 0.65), (0.55, 0.71, 0.16, 0.85),
        (0.30, 0.86, 0.15, 0.90), (0.76, 0.92, 0.18, 1.00)
    ]

    /// Where the loose stones lie. Pebbles gather: a scattering of single ones
    /// reads as noise, while three or four together read as a sea floor.
    /// x, y (shares of the sand bed), scale.
    private static let pebbleClusters: [(CGFloat, CGFloat, CGFloat)] = [
        (0.075, 0.22, 1.00), (0.185, 0.52, 0.78), (0.115, 0.79, 0.90),
        (0.300, 0.30, 0.66), (0.395, 0.66, 0.74), (0.500, 0.16, 0.60),
        (0.560, 0.90, 0.82), (0.680, 0.44, 0.70), (0.790, 0.24, 0.86),
        (0.870, 0.62, 0.96), (0.930, 0.36, 0.72), (0.735, 0.80, 0.88),
        (0.245, 0.94, 0.68), (0.960, 0.88, 0.80)
    ]

    /// The stones inside one cluster: offset from its centre, and size.
    private static let clusterStones: [(CGFloat, CGFloat, CGFloat)] = [
        (0, 0, 1.00), (0.85, 0.34, 0.62), (-0.62, 0.42, 0.48), (0.30, -0.55, 0.40)
    ]

    /// Shells lying half in the sand: x, y, scale.
    private static let shells: [(CGFloat, CGFloat, CGFloat)] = [
        (0.145, 0.62, 0.80), (0.330, 0.86, 0.66), (0.545, 0.36, 0.72),
        (0.700, 0.68, 0.62), (0.845, 0.16, 0.78), (0.905, 0.72, 0.68),
        (0.430, 0.12, 0.60)
    ]

    /// Loose starfish, away from the ones lying against the garden stones.
    private static let starfish: [(CGFloat, CGFloat, CGFloat)] = [
        (0.225, 0.14, 0.92), (0.620, 0.26, 0.74), (0.480, 0.74, 0.86),
        (0.815, 0.46, 0.68)
    ]

    var body: some View {
        Canvas(opaque: false, rendersAsynchronously: false) { context, size in
            drawRipples(in: &context, size: size)
            drawDimples(in: &context, size: size)
            drawSpecks(in: &context, size: size)
            drawGrain(in: &context, size: size)
        }
        .opacity(0.85)
        .accessibilityHidden(true)
    }

    /// The ribs the swell leaves in shallow sand: long, soft, roughly parallel
    /// ridges, each one a shadow with a lit lip above it.
    ///
    /// The rows are spaced by the square of their depth, which is what a flat
    /// plane does when you look along it: far ribs crowd together near the
    /// crest and open out toward the bottom of the screen. Their height, their
    /// wavelength and their contrast all follow the same curve, so the bed
    /// recedes without a single row of it being drawn differently.
    private func drawRipples(in context: inout GraphicsContext, size: CGSize) {
        let rows = ArenaPerformanceBudget.isConstrained
            ? Self.rippleRows / 2 : Self.rippleRows

        for row in 0..<rows {
            let t = (Double(row) + 0.5) / Double(rows)
            let depth = pow(t, 1.5)
            let y = size.height * (sandBedTop + (1 - sandBedTop) * CGFloat(depth))
            // Height off the bed, how far apart the crests run, and how much
            // of the ripple the water still lets through at that distance.
            let amplitude = size.height * CGFloat(0.003 + 0.013 * depth)
            let crests = 2.6 - 0.9 * depth
            let strength = 0.06 + 0.26 * depth
            let weight = 1 + 1.8 * CGFloat(depth)
            // A turn of the golden angle per row: no two rows line up, and the
            // bed never falls into a plaid.
            let phase = Double(row) * 2.399963

            // Sampled far finer than the wave is long. A ripple undersampled
            // is not a soft ripple: it is a zigzag, and it reads as a pattern
            // printed on the sand rather than as sand.
            var ridge = Path()
            let steps = 44
            for step in 0...steps {
                let along = Double(step) / Double(steps)
                let x = size.width * (CGFloat(along) * 1.1 - 0.05)
                let wave = sin(along * crests * 2 * .pi + phase)
                    + 0.28 * sin(along * crests * 3.3 * .pi + phase * 1.6)
                let point = CGPoint(x: x, y: y + amplitude * CGFloat(wave))
                if step == 0 { ridge.move(to: point) } else { ridge.addLine(to: point) }
            }

            // The trough first, then the crest sitting on top of it. Two lines
            // a hair apart is all a ripple is.
            context.stroke(ridge,
                           with: .color(palette.sandDeep.opacity(strength)),
                           style: StrokeStyle(lineWidth: weight, lineCap: .round))
            context.stroke(ridge.offsetBy(dx: 0, dy: -weight * 0.85),
                           with: .color(.white.opacity(strength * 0.55)),
                           style: StrokeStyle(lineWidth: weight * 0.7, lineCap: .round))
        }
    }

    /// Shallow scoops in the bed. A dimple is only ever a dark rim on the far
    /// side and a lit one on the near side; anything more turns into a hole.
    private func drawDimples(in context: inout GraphicsContext, size: CGSize) {
        guard !ArenaPerformanceBudget.isConstrained else { return }

        for dimple in Self.dimples {
            let width = size.width * dimple.2
            let height = width * 0.44
            let rect = CGRect(x: size.width * dimple.0 - width / 2,
                              y: size.height * dimple.1 - height / 2,
                              width: width, height: height)
            context.fill(
                Path(ellipseIn: rect),
                with: .linearGradient(
                    Gradient(stops: [
                        .init(color: palette.sandDeep.opacity(0.30 * dimple.3), location: 0),
                        .init(color: palette.sandDeep.opacity(0.05 * dimple.3), location: 0.62),
                        .init(color: .white.opacity(0.16 * dimple.3), location: 1)
                    ]),
                    startPoint: CGPoint(x: rect.midX, y: rect.minY),
                    endPoint: CGPoint(x: rect.midX, y: rect.maxY)
                )
            )
        }
    }

    /// Individual grains, and only where the eye could possibly resolve them:
    /// the near third of the bed. Further back the same speckle would read as
    /// dirt on the screen rather than as sand.
    private func drawGrain(in context: inout GraphicsContext, size: CGSize) {
        guard !ArenaPerformanceBudget.isConstrained else { return }

        var seed: UInt64 = 0x5EA_F100
        func next() -> Double {
            seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return Double(seed >> 11) / Double(UInt64(1) << 53)
        }

        for _ in 0..<90 {
            let depth = 0.62 + next() * 0.38
            let x = size.width * CGFloat(next())
            let y = size.height * CGFloat(depth)
            let side = CGFloat(0.7 + next() * 1.4) * (isPad ? 1.5 : 1)
            let lit = next() > 0.45
            let fade = (depth - 0.62) / 0.38
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: side, height: side)),
                with: .color(lit ? .white.opacity(0.26 * fade)
                                 : palette.sandDeep.opacity(0.30 * fade))
            )
        }
    }

    private func drawSpecks(in context: inout GraphicsContext, size: CGSize) {
        let base = isPad ? 30.0 : 21.0

        for cluster in Self.pebbleClusters {
            let unit = base * cluster.2
            for stone in Self.clusterStones {
                let side = unit * stone.2
                let centre = CGPoint(x: size.width * cluster.0 + unit * stone.0,
                                     y: size.height * cluster.1 + unit * stone.1 * 0.6)
                let rect = CGRect(x: centre.x - side / 2, y: centre.y - side * 0.40,
                                  width: side, height: side * 0.80)
                // Each stone sits in its own dimple, which is what stops the
                // group from looking painted on.
                context.fill(
                    Path(ellipseIn: rect.offsetBy(dx: 0, dy: side * 0.16)
                        .insetBy(dx: -side * 0.06, dy: side * 0.20)),
                    with: .color(palette.sandDeep.opacity(0.26))
                )
                context.fill(Path(ellipseIn: rect),
                             with: .color(palette.rockDeep.opacity(0.34)))
                context.fill(
                    Path(ellipseIn: rect.insetBy(dx: side * 0.16, dy: side * 0.18)
                        .offsetBy(dx: -side * 0.04, dy: -side * 0.08)),
                    with: .color(.white.opacity(0.22))
                )
            }
        }

        for shell in Self.shells {
            let side = base * shell.2
            let rect = CGRect(x: size.width * shell.0 - side / 2,
                              y: size.height * shell.1 - side / 2,
                              width: side, height: side)
            context.fill(ShellShape().path(in: rect),
                         with: .color(palette.sandDeep.opacity(0.62)))
            context.stroke(ShellShape().path(in: rect),
                           with: .color(.white.opacity(0.35)), lineWidth: 1)
        }

        for star in Self.starfish {
            let side = base * star.2 * 1.25
            let rect = CGRect(x: size.width * star.0 - side / 2,
                              y: size.height * star.1 - side / 2,
                              width: side, height: side)
            var path = StarfishShape().path(in: rect)
            path = path.applying(
                CGAffineTransform(translationX: rect.midX, y: rect.midY)
                    .rotated(by: Double(star.0) * 6)
                    .translatedBy(x: -rect.midX, y: -rect.midY)
            )
            context.fill(path, with: .color(palette.reefAccent(1).opacity(0.70)))
            context.stroke(path, with: .color(.white.opacity(0.30)), lineWidth: 1.2)
            context.fill(
                Path(ellipseIn: CGRect(x: rect.midX - side * 0.07,
                                       y: rect.midY - side * 0.07,
                                       width: side * 0.14, height: side * 0.14)),
                with: .color(.white.opacity(0.32))
            )
        }
    }

}

/// The net of surface light on the floor, and the warm patch the sun lays in
/// the middle of it.
///
/// This is the one layer of the sea floor that actually moves, so it is the
/// only one that takes the clock. Caustics are drawn at two scales: broad soft
/// cells that breathe in place, and small bright cores inside them that drift.
/// One scale alone reads either as clouds or as confetti; the two together are
/// what sunlight through moving water looks like.
private struct SandLight: View {
    let palette: ReefPalette
    let isPad: Bool
    /// Where on the bed the sun lands, as a share of its height.
    let sunShare: CGFloat
    let clock: Double

    /// x, y, radius factor, drift phase. Many small patches read as sunlight
    /// through moving water; a few large ones only read as clouds on the floor.
    private static let dapples: [(CGFloat, CGFloat, CGFloat, Double)] = [
        (0.09, 0.12, 0.90, 0.4), (0.24, 0.07, 0.62, 2.1), (0.41, 0.15, 0.78, 3.7),
        (0.57, 0.06, 0.58, 5.2), (0.72, 0.13, 0.84, 1.3), (0.88, 0.08, 0.66, 4.4),
        (0.14, 0.31, 0.72, 0.9), (0.33, 0.38, 0.90, 2.8), (0.52, 0.30, 0.60, 5.9),
        (0.69, 0.36, 0.80, 3.1), (0.86, 0.29, 0.68, 1.7), (0.06, 0.52, 0.62, 4.9),
        (0.27, 0.58, 0.84, 2.3), (0.47, 0.53, 0.66, 0.2), (0.65, 0.60, 0.90, 3.9),
        (0.83, 0.55, 0.58, 5.5), (0.17, 0.76, 0.76, 1.1), (0.40, 0.82, 0.62, 4.2),
        (0.60, 0.75, 0.86, 2.6), (0.80, 0.84, 0.70, 0.7)
    ]

    /// Half the patches where the frame budget is tightest: the floor still
    /// reads as dappled, at half the gradient fills.
    private var dapples: [(CGFloat, CGFloat, CGFloat, Double)] {
        ArenaPerformanceBudget.isConstrained
            ? Self.dapples.enumerated().filter { $0.offset.isMultiple(of: 2) }.map(\.element)
            : Self.dapples
    }

    var body: some View {
        Canvas(opaque: false, rendersAsynchronously: false) { context, size in
            drawSunPool(in: &context, size: size)
            drawCaustics(in: &context, size: size)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// Where the shafts land: a broad, warm patch of sand under the King.
    ///
    /// Wide and shallow rather than bright and tight. This is the end of the
    /// path the eye takes down from the surface, and it has to read as *the
    /// sun reaching the floor here* — a small hot spot reads instead as a lamp
    /// pointed at the sand, which is the one thing an open reef never has.
    private func drawSunPool(in context: inout GraphicsContext, size: CGSize) {
        let breath = 1 + 0.05 * sin(clock * 0.14)
        let centre = CGPoint(x: size.width * 0.5 + CGFloat(sin(clock * 0.08)) * size.width * 0.02,
                             y: size.height * min(max(sunShare, 0.2), 0.9))
        let radius = size.width * 0.86 * CGFloat(breath)
        context.fill(
            Path(ellipseIn: CGRect(x: centre.x - radius, y: centre.y - radius * 0.72,
                                   width: radius * 2, height: radius * 1.44)),
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: palette.sandSunlit.opacity(0.30), location: 0),
                    .init(color: palette.sandSunlit.opacity(0.20), location: 0.44),
                    .init(color: palette.sandSunlit.opacity(0.07), location: 0.74),
                    .init(color: palette.sandSunlit.opacity(0), location: 1)
                ]),
                center: centre, startRadius: 0, endRadius: radius
            )
        )
    }

    /// Slow, overlapping patches of surface light. They breathe rather than
    /// travel, which is what sunlight through moving water actually does — but
    /// the bright core inside each one does travel, a little, and that is the
    /// part the eye reads as the water itself moving.
    private func drawCaustics(in context: inout GraphicsContext, size: CGSize) {
        let base = size.width * (isPad ? 0.075 : 0.095)
        let showsCores = !ArenaPerformanceBudget.isConstrained

        for dapple in dapples {
            let breath = 1 + 0.20 * sin(clock * 0.46 + dapple.3)
            let radius = base * dapple.2 * CGFloat(breath)
            let centre = CGPoint(x: size.width * dapple.0
                                    + CGFloat(sin(clock * 0.23 + dapple.3)) * 7,
                                 y: size.height * (sandBedTop + (1 - sandBedTop) * dapple.1)
                                    + CGFloat(cos(clock * 0.19 + dapple.3)) * 4)
            let rect = CGRect(x: centre.x - radius, y: centre.y - radius * 0.58,
                              width: radius * 2, height: radius * 1.16)
            context.fill(
                Path(ellipseIn: rect),
                with: .radialGradient(
                    Gradient(stops: [
                        .init(color: .white.opacity(0.15), location: 0),
                        .init(color: .white.opacity(0.09), location: 0.55),
                        .init(color: .white.opacity(0), location: 1)
                    ]),
                    center: centre, startRadius: 0, endRadius: radius
                )
            )

            guard showsCores else { continue }

            // The bright knot inside the cell, wandering around its own middle
            // on a period that has nothing to do with the cell's.
            let coreRadius = radius * 0.34
            let core = CGPoint(x: centre.x + CGFloat(cos(clock * 0.37 + dapple.3 * 1.7)) * radius * 0.30,
                               y: centre.y + CGFloat(sin(clock * 0.31 + dapple.3 * 2.3)) * radius * 0.18)
            context.fill(
                Path(ellipseIn: CGRect(x: core.x - coreRadius, y: core.y - coreRadius * 0.5,
                                       width: coreRadius * 2, height: coreRadius)),
                with: .radialGradient(
                    Gradient(stops: [
                        .init(color: .white.opacity(0.22), location: 0),
                        .init(color: .white.opacity(0), location: 1)
                    ]),
                    center: core, startRadius: 0, endRadius: coreRadius
                )
            )
        }
    }
}

// MARK: - Rock gardens

/// Stones with their own planting. Nothing on the sea floor grows on bare sand:
/// grass roots itself between rocks and coral takes hold on them, so every tuft
/// on this floor belongs to a stone rather than floating beside one.
private struct SeaGardens: View {
    let palette: ReefPalette
    let isPad: Bool
    let clock: Double

    /// x, y (shares of the band), scale, variant, mirrored. All of them keep to
    /// the outer fifth or to the very bottom, where nothing walks.
    private static let gardens: [(CGFloat, CGFloat, CGFloat, Int, Bool)] = [
        (0.055, 0.30, 0.68, 0, false), (0.035, 0.58, 0.88, 1, false),
        (0.085, 0.99, 0.82, 2, false), (0.945, 0.24, 0.64, 2, true),
        (0.975, 0.54, 0.84, 0, true),  (0.905, 0.99, 0.90, 1, true),
        (0.245, 1.05, 0.72, 2, false), (0.400, 1.10, 0.58, 0, true),
        (0.615, 1.06, 0.66, 1, false), (0.765, 1.09, 0.62, 2, true)
    ]

    /// Half the gardens where the frame budget is tightest. Each one is a small
    /// pile of swaying blades, and the sea floor is rebuilt on every sway step.
    private var gardens: [(CGFloat, CGFloat, CGFloat, Int, Bool)] {
        ArenaPerformanceBudget.isConstrained
            ? Self.gardens.enumerated().filter { $0.offset.isMultiple(of: 2) }.map(\.element)
            : Self.gardens
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let unit = min(width * 0.26, isPad ? 200 : 128)

            ForEach(Array(gardens.enumerated()), id: \.offset) { index, garden in
                RockGarden(palette: palette,
                           clock: clock,
                           variant: garden.3,
                           phase: Double(index) * 1.37)
                    .frame(width: unit * garden.2, height: unit * garden.2 * 0.72)
                    .scaleEffect(x: garden.4 ? -1 : 1, y: 1)
                    // Rooted where it is placed, not centred on it.
                    .position(x: width * garden.0,
                              y: height * garden.1 - unit * garden.2 * 0.28)
            }
        }
        .accessibilityHidden(true)
    }
}

/// One garden: a boulder with two smaller stones, grass coming up from behind
/// them, and — depending on the variant — a coral tuft or a starfish resting
/// against the rock.
private struct RockGarden: View {
    let palette: ReefPalette
    let clock: Double
    let variant: Int
    let phase: Double

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                // The planting first: it grows up from behind the stones, which
                // is what welds the two together.
                grass(width: w, height: h)

                if variant == 1 {
                    coralTuft(width: w, height: h)
                }

                // Stones and starfish are the still half of a garden. Only the
                // grass and the coral tuft above take the clock, so these say
                // they are unchanged and the sway step steps straight over them.
                Boulder(palette: palette, width: w * 0.52, height: h * 0.52)
                    .equatable()
                    .position(x: w * 0.42, y: h * 0.70)
                Boulder(palette: palette, width: w * 0.34, height: h * 0.34)
                    .equatable()
                    .position(x: w * 0.72, y: h * 0.80)
                Boulder(palette: palette, width: w * 0.22, height: h * 0.22)
                    .equatable()
                    .position(x: w * 0.20, y: h * 0.87)

                if variant == 2 {
                    StarfishView(colour: palette.reefAccent(1),
                                 shade: palette.reefAccentDeep(1))
                        .equatable()
                        .frame(width: w * 0.30, height: w * 0.30)
                        .rotationEffect(.degrees(-18))
                        .position(x: w * 0.74, y: h * 0.62)
                }
            }
        }
    }

    /// Blades rooted behind the boulder, leaning away from it.
    private func grass(width w: CGFloat, height h: CGFloat) -> some View {
        let blades: [(CGFloat, CGFloat, Double)] = [
            (0.24, 0.78, 0.0), (0.36, 1.00, 1.1), (0.48, 0.88, 2.3),
            (0.58, 1.12, 3.4), (0.70, 0.74, 4.6), (0.80, 0.92, 5.2)
        ]
        return ZStack(alignment: .bottom) {
            ForEach(Array(blades.enumerated()), id: \.offset) { _, blade in
                let sway = sin(clock * (0.62 + Double(blade.0) * 0.3) + phase + blade.2)
                PlantBladeShape(bend: CGFloat(sway) * 0.30 + (blade.0 - 0.5) * 0.5)
                    .stroke(
                        LinearGradient(colors: [palette.plantLight, palette.plant],
                                       startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: max(2.5, w * 0.045), lineCap: .round)
                    )
                    .frame(width: w * 0.30, height: h * blade.1)
                    .position(x: w * blade.0, y: h * 0.82 - h * blade.1 / 2)
            }
        }
    }

    /// A small growth of coral wedged between the stones.
    private func coralTuft(width w: CGFloat, height h: CGFloat) -> some View {
        let sway = sin(clock * 0.5 + phase)
        return FingerCoralShape(bend: CGFloat(sway) * 0.10)
            .stroke(
                LinearGradient(colors: [palette.reefAccent(3), palette.reefAccentDeep(3)],
                               startPoint: .top, endPoint: .bottom),
                style: StrokeStyle(lineWidth: max(3, w * 0.075), lineCap: .round)
            )
            .frame(width: w * 0.34, height: h * 0.52)
            .position(x: w * 0.68, y: h * 0.52)
    }

}

/// A stone: rounded, lit from above, and sitting in its own dimple of sand.
private struct Boulder: View, Equatable {
    let palette: ReefPalette
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            Ellipse()
                .fill(palette.sandDeep.opacity(0.34))
                .frame(width: width * 1.12, height: height * 0.34)
                .offset(y: height * 0.44)

            RockShape()
                .fill(LinearGradient(colors: [palette.rock, palette.rockDeep],
                                     startPoint: .top, endPoint: .bottom))
                .overlay {
                    RockShape()
                        .stroke(palette.rockDeep.opacity(0.55), lineWidth: 1)
                }
                .overlay(alignment: .top) {
                    Ellipse()
                        .fill(.white.opacity(0.22))
                        .frame(width: width * 0.46, height: height * 0.24)
                        .offset(x: -width * 0.06, y: height * 0.13)
                }
                .frame(width: width, height: height)
        }
        .frame(width: width, height: height)
    }
}

/// A stone: an ellipse with two flats knocked off it, so a pile of them never
/// reads as a pile of eggs.
private struct RockShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.04, y: h * 0.66))
        path.addQuadCurve(to: CGPoint(x: w * 0.34, y: h * 0.06),
                          control: CGPoint(x: w * 0.06, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.62, y: 0))
        path.addQuadCurve(to: CGPoint(x: w * 0.97, y: h * 0.52),
                          control: CGPoint(x: w * 0.99, y: h * 0.16))
        path.addQuadCurve(to: CGPoint(x: w * 0.58, y: h),
                          control: CGPoint(x: w * 0.95, y: h * 0.94))
        path.addQuadCurve(to: CGPoint(x: w * 0.04, y: h * 0.66),
                          control: CGPoint(x: w * 0.16, y: h * 0.98))
        path.closeSubpath()
        return path
    }
}

/// A starfish with proper rounded arms, a paler middle and its own speckles.
private struct StarfishView: View, Equatable {
    let colour: Color
    let shade: Color

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            ZStack {
                StarfishShape()
                    .fill(LinearGradient(colors: [colour, shade],
                                         startPoint: .top, endPoint: .bottom))
                    .overlay {
                        StarfishShape().stroke(shade.opacity(0.7), lineWidth: 1)
                    }
                ForEach(0..<5, id: \.self) { index in
                    let angle = Double(index) * 2 * .pi / 5 - .pi / 2
                    Circle()
                        .fill(.white.opacity(0.55))
                        .frame(width: side * 0.07, height: side * 0.07)
                        .offset(x: CGFloat(cos(angle)) * side * 0.22,
                                y: CGFloat(sin(angle)) * side * 0.22)
                }
                Circle()
                    .fill(.white.opacity(0.30))
                    .frame(width: side * 0.14, height: side * 0.14)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

/// Five arms that swell from a round middle, rather than five straight points.
private struct StarfishShape: Shape {
    func path(in rect: CGRect) -> Path {
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.42
        var path = Path()
        for index in 0..<5 {
            let tipAngle = Double(index) * 2 * .pi / 5 - .pi / 2
            let leftAngle = tipAngle - .pi / 5
            let rightAngle = tipAngle + .pi / 5
            func point(_ angle: Double, _ radius: CGFloat) -> CGPoint {
                CGPoint(x: centre.x + CGFloat(cos(angle)) * radius,
                        y: centre.y + CGFloat(sin(angle)) * radius)
            }
            let tip = point(tipAngle, outer)
            let left = point(leftAngle, inner)
            let right = point(rightAngle, inner)
            if index == 0 { path.move(to: left) } else { path.addLine(to: left) }
            // Each arm swells out to its tip and tapers back in.
            path.addQuadCurve(to: tip, control: point(tipAngle - .pi / 9, outer * 0.78))
            path.addQuadCurve(to: right, control: point(tipAngle + .pi / 9, outer * 0.78))
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - The reef

/// The garden down both edges of the arena: rocks with coral growing out of
/// them, in the reef's own colours rather than in one flat theme tint. It is
/// deliberately kept to the outer sixth of the screen, so it frames the crabs
/// without ever crowding the answer they are carrying.
private struct ReefBorder: View {
    let palette: ReefPalette
    let isPad: Bool
    let clock: Double

    /// y (share of the band), scale, style, colour index, phase. Mirrored onto
    /// the right-hand edge with its own offsets, so the two sides never look
    /// like a stamped pair.
    ///
    /// They grow as they come forward. A coral high up the band is far away and
    /// stays small and sparse; the ones near the bottom are close, larger and
    /// packed together, which is what turns two edges into a frame.
    /// The first two of each side sit right on the crest and grow up out of it
    /// into the blue. That is what closes the picture at the top: without them
    /// the sand's far edge runs off both sides of the screen into nothing, and
    /// the eye reads the whole floor as a band laid across the water rather
    /// than as ground with a reef standing on it.
    private static let leftClusters: [(CGFloat, CGFloat, Int, Int, Double)] = [
        (0.02, 0.46, 2, 2, 1.1), (0.07, 0.38, 3, 4, 4.4),
        (0.16, 0.44, 0, 0, 0.5), (0.31, 0.56, 2, 2, 3.6),
        (0.48, 0.66, 1, 3, 2.4), (0.64, 0.76, 3, 4, 5.3),
        (0.80, 0.98, 1, 1, 4.1), (0.95, 0.88, 3, 3, 1.2)
    ]
    private static let rightClusters: [(CGFloat, CGFloat, Int, Int, Double)] = [
        (0.03, 0.42, 0, 3, 2.6), (0.09, 0.36, 1, 1, 5.5),
        (0.19, 0.48, 2, 4, 3.3), (0.34, 0.52, 3, 0, 1.5),
        (0.51, 0.68, 1, 0, 0.8), (0.67, 0.74, 0, 2, 4.7),
        (0.83, 0.86, 3, 2, 5.0), (0.97, 0.98, 0, 1, 2.0)
    ]

    /// Five per side where the frame budget is tightest. The two on the crest
    /// are kept whatever happens — they are doing composition work, not
    /// decoration — and the thinning is taken out of the middle of the band.
    private var leftClusters: [(CGFloat, CGFloat, Int, Int, Double)] {
        Self.thinned(Self.leftClusters)
    }
    private var rightClusters: [(CGFloat, CGFloat, Int, Int, Double)] {
        Self.thinned(Self.rightClusters)
    }

    private static func thinned(
        _ clusters: [(CGFloat, CGFloat, Int, Int, Double)]
    ) -> [(CGFloat, CGFloat, Int, Int, Double)] {
        guard ArenaPerformanceBudget.isConstrained else { return clusters }
        return clusters.enumerated()
            .filter { $0.offset < 2 || $0.offset.isMultiple(of: 2) }
            .map(\.element)
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let unit = min(width * 0.17, isPad ? 132 : 84)

            ZStack {
                // Stone does not sway; only the coral growing between it does.
                RockPile(palette: palette)
                    .equatable()
                    .frame(width: unit * 1.5, height: unit * 0.78)
                    .position(x: width * 0.03, y: height * 0.93)
                RockPile(palette: palette)
                    .equatable()
                    .frame(width: unit * 1.35, height: unit * 0.66)
                    .scaleEffect(x: -1, y: 1)
                    .position(x: width * 0.97, y: height * 0.86)

                ForEach(Array(leftClusters.enumerated()), id: \.offset) { index, cluster in
                    coral(cluster, unit: unit)
                        .position(x: width * (index.isMultiple(of: 2) ? 0.085 : 0.15),
                                  y: height * cluster.0)
                }
                ForEach(Array(rightClusters.enumerated()), id: \.offset) { index, cluster in
                    coral(cluster, unit: unit)
                        .scaleEffect(x: -1, y: 1)
                        .position(x: width * (index.isMultiple(of: 2) ? 0.915 : 0.85),
                                  y: height * cluster.0)
                }
            }
            .frame(width: width, height: height)
        }
        .accessibilityHidden(true)
    }

    private func coral(_ cluster: (CGFloat, CGFloat, Int, Int, Double),
                       unit: CGFloat) -> some View {
        let sway = sin(clock * 0.52 + cluster.4)
        let side = unit * cluster.1
        return CoralCluster(style: cluster.2,
                            colour: palette.reefAccent(cluster.3),
                            shade: palette.reefAccentDeep(cluster.3),
                            bend: CGFloat(sway) * 0.14)
            .frame(width: side, height: side * 1.2)
            .rotationEffect(.degrees(3.4 * sway), anchor: .bottom)
            // Rooted at the point it is placed on, rather than centred on it.
            .offset(y: -side * 0.6)
    }
}

/// The closest thing in the scene: the reef piling up in the two bottom
/// corners of the screen.
///
/// This is the layer that makes the arena an *arena*. Everything above it has
/// been drawn to recede — hazed, cooled, flattened — and the picture needs
/// something at the front to recede *from*. So these corals are the largest,
/// the most saturated and the only ones with no water drawn over them at all,
/// and they sway more than anything behind them.
///
/// They keep to the outer eighth of each side and lean outward, away from the
/// middle. The centre of the floor stays the open sand the crabs walk in on.
/// The near reef, laid over the animals rather than under them.
///
/// Everything else on the sea floor is behind the crabs, because everything
/// else is further away than they are. These two corners are not: they are the
/// front of the scene, and a crab walking the lower lane has to pass behind
/// them or the floor reads as flat. It is bottom-aligned to the screen and
/// leans with the water exactly as it did inside `ArenaFloor`, so nothing about
/// the corner itself has moved — only what it is drawn in front of.
private struct NearReef: View, Equatable {
    let palette: ReefPalette
    let isPad: Bool
    /// Screen y of the sand's crest, which is where the floor's own frame ends.
    let crest: CGFloat
    let clock: Double

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.palette.character == rhs.palette.character
            && lhs.isPad == rhs.isPad
            && lhs.crest == rhs.crest
            && lhs.clock == rhs.clock
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ForegroundReef(palette: palette, isPad: isPad, clock: clock)
                .frame(height: max(140, size.height - crest))
                .frame(width: size.width, height: size.height, alignment: .bottom)
                .offset(x: CGFloat(sin(clock * 0.11)) * 4.5)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct ForegroundReef: View {
    let palette: ReefPalette
    let isPad: Bool
    let clock: Double

    /// x (share of width), root depth below the bottom edge, scale, style,
    /// colour index, phase, mirrored.
    private static let corals: [(CGFloat, CGFloat, CGFloat, Int, Int, Double, Bool)] = [
        (0.030, 0.02, 1.00, 2, 1, 0.4, false),
        (0.098, 0.06, 0.74, 1, 0, 2.2, false),
        (0.162, 0.10, 0.50, 3, 4, 4.0, false),
        (0.970, 0.02, 0.94, 0, 2, 1.3, true),
        (0.900, 0.07, 0.76, 3, 3, 3.1, true),
        (0.838, 0.11, 0.48, 1, 1, 5.2, true)
    ]

    /// The four largest where the frame budget is tightest. Losing the small
    /// ones costs the corner some density; losing a big one would leave a hole.
    private var corals: [(CGFloat, CGFloat, CGFloat, Int, Int, Double, Bool)] {
        ArenaPerformanceBudget.isConstrained
            ? Self.corals.filter { $0.2 > 0.6 } : Self.corals
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let unit = min(width * 0.30, isPad ? 250 : 148)

            ZStack {
                // The stone the corner is built on, low and wide so the coral
                // above it has something to have grown out of.
                RockPile(palette: palette)
                    .equatable()
                    .frame(width: unit * 1.15, height: unit * 0.56)
                    .position(x: width * 0.05, y: height * 1.02)
                RockPile(palette: palette)
                    .equatable()
                    .frame(width: unit * 1.05, height: unit * 0.50)
                    .scaleEffect(x: -1, y: 1)
                    .position(x: width * 0.95, y: height * 1.04)

                BarrelSponge(colour: palette.reefAccent(4), shade: palette.reefAccentDeep(4))
                    .frame(width: unit * 0.40, height: unit * 0.62)
                    .position(x: width * 0.135, y: height - unit * 0.24)
                BarrelSponge(colour: palette.reefAccent(2), shade: palette.reefAccentDeep(2))
                    .frame(width: unit * 0.33, height: unit * 0.52)
                    .position(x: width * 0.872, y: height - unit * 0.20)

                ForEach(Array(corals.enumerated()), id: \.offset) { index, coral in
                    let sway = sin(clock * (0.44 + Double(index) * 0.04) + coral.5)
                    let side = unit * coral.2

                    CoralCluster(style: coral.3,
                                 colour: palette.reefAccent(coral.4),
                                 shade: palette.reefAccentDeep(coral.4),
                                 bend: CGFloat(sway) * 0.20)
                        .frame(width: side, height: side * 1.25)
                        .rotationEffect(.degrees(4.6 * sway), anchor: .bottom)
                        .scaleEffect(x: coral.6 ? -1 : 1, y: 1)
                        // Rooted just under the bottom edge, so the corner is
                        // full rather than a row of plants standing on a line.
                        .position(x: width * coral.0,
                                  y: height * (1 + coral.1) - side * 0.625)
                }

                // Long weed in front of the lot, drawn last and swaying hardest.
                // Movement is depth: this is the closest thing to the eye, so it
                // is also the thing the water most obviously pushes around.
                ForegroundWeed(palette: palette, clock: clock, unit: unit)
            }
            .frame(width: width, height: height)
        }
        .accessibilityHidden(true)
    }
}

/// Tall ribbon weed in the two near corners.
private struct ForegroundWeed: View {
    let palette: ReefPalette
    let clock: Double
    let unit: CGFloat

    /// x, height factor, sway rate, phase, thickness.
    private static let blades: [(CGFloat, CGFloat, Double, Double, CGFloat)] = [
        (0.012, 1.05, 0.51, 0.0, 1.00), (0.062, 0.78, 0.62, 1.8, 0.78),
        (0.118, 0.94, 0.47, 3.5, 0.86), (0.188, 0.58, 0.68, 5.0, 0.62),
        (0.988, 1.00, 0.49, 0.9, 0.96), (0.936, 0.72, 0.64, 2.6, 0.74),
        (0.882, 0.90, 0.44, 4.2, 0.82), (0.812, 0.54, 0.71, 5.7, 0.58)
    ]

    private var blades: [(CGFloat, CGFloat, Double, Double, CGFloat)] {
        ArenaPerformanceBudget.isConstrained
            ? Self.blades.enumerated().filter { $0.offset.isMultiple(of: 2) }.map(\.element)
            : Self.blades
    }

    var body: some View {
        Canvas(opaque: false, rendersAsynchronously: false) { context, size in
            for blade in blades {
                let sway = sin(clock * blade.2 + blade.3)
                let length = unit * blade.1
                let x = size.width * blade.0
                let root = size.height + 4
                let tip = root - length
                // The whole blade leans, but the tip leans further than the
                // middle: weed bends, it does not pivot.
                let lean = CGFloat(sway) * length * 0.22

                var path = Path()
                path.move(to: CGPoint(x: x, y: root))
                path.addCurve(
                    to: CGPoint(x: x + lean, y: tip),
                    control1: CGPoint(x: x + lean * 0.10, y: root - length * 0.42),
                    control2: CGPoint(x: x + lean * 0.78, y: root - length * 0.76)
                )
                context.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [palette.plantLight, palette.plant]),
                        startPoint: CGPoint(x: x, y: tip),
                        endPoint: CGPoint(x: x, y: root)
                    ),
                    style: StrokeStyle(lineWidth: max(3, unit * 0.055 * blade.4),
                                       lineCap: .round)
                )
            }
        }
        .allowsHitTesting(false)
    }
}

/// A barrel sponge: a thick tapered tube with an open rim, ribbed down its
/// side. Nothing else on this floor has a hole in it, which is most of why one
/// of these is worth drawing.
private struct BarrelSponge: View {
    let colour: Color
    let shade: Color

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                BarrelSpongeShape()
                    .fill(LinearGradient(colors: [colour, shade],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing))
                    .overlay {
                        BarrelSpongeRibs()
                            .stroke(shade.opacity(0.55),
                                    style: StrokeStyle(lineWidth: max(1, w * 0.045),
                                                       lineCap: .round))
                    }

                // The mouth, and the lit lip around it.
                Ellipse()
                    .fill(shade)
                    .frame(width: w * 0.40, height: h * 0.13)
                    .overlay {
                        Ellipse()
                            .stroke(.white.opacity(0.28), lineWidth: max(1, w * 0.035))
                    }
                    .position(x: w * 0.50, y: h * 0.11)
            }
            .frame(width: w, height: h)
        }
        .shadow(color: shade.opacity(0.30), radius: 4, y: 3)
    }
}

private struct BarrelSpongeShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.29, y: h * 0.11))
        path.addQuadCurve(to: CGPoint(x: w * 0.15, y: h),
                          control: CGPoint(x: w * 0.13, y: h * 0.62))
        path.addQuadCurve(to: CGPoint(x: w * 0.85, y: h),
                          control: CGPoint(x: w * 0.50, y: h * 1.12))
        path.addQuadCurve(to: CGPoint(x: w * 0.71, y: h * 0.11),
                          control: CGPoint(x: w * 0.87, y: h * 0.62))
        path.addQuadCurve(to: CGPoint(x: w * 0.29, y: h * 0.11),
                          control: CGPoint(x: w * 0.50, y: h * -0.05))
        path.closeSubpath()
        return path
    }
}

private struct BarrelSpongeRibs: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        for rib in [0.30, 0.50, 0.70] {
            path.move(to: CGPoint(x: w * rib, y: h * 0.20))
            path.addQuadCurve(
                to: CGPoint(x: w * (0.5 + (rib - 0.5) * 1.5), y: h * 0.94),
                control: CGPoint(x: w * (0.5 + (rib - 0.5) * 1.3), y: h * 0.58)
            )
        }
        return path
    }
}

/// One coral, in one of four growths: a fan, a branch, a stand of fingers or a
/// cluster of cups. Four shapes in five colours is what makes a reef out of
/// what would otherwise be the same plant repeated down the edge.
private struct CoralCluster: View {
    let style: Int
    let colour: Color
    let shade: Color
    let bend: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let unit = proxy.size.width
            let gradient = LinearGradient(colors: [colour, shade],
                                          startPoint: .top, endPoint: .bottom)
            Group {
                switch style {
                case 0:
                    FanCoralShape()
                        .fill(gradient)
                        .overlay {
                            FanCoralRibs()
                                .stroke(.white.opacity(0.38),
                                        style: StrokeStyle(lineWidth: max(1, unit * 0.035),
                                                           lineCap: .round))
                        }
                        .overlay {
                            FanCoralShape().stroke(shade.opacity(0.75),
                                                   lineWidth: max(1, unit * 0.03))
                        }
                case 1:
                    // Thick enough to be coral. A branching growth drawn thin
                    // is the one shape on this floor that can read as a bare
                    // twig, and one twig is all it takes to make the corner
                    // look like a winter hedge rather than a reef.
                    BranchingCoralShape(bend: bend)
                        .stroke(gradient,
                                style: StrokeStyle(lineWidth: max(4, unit * 0.21),
                                                   lineCap: .round, lineJoin: .round))
                case 2:
                    ZStack(alignment: .bottom) {
                        // A rooted stand rather than bars floating on the sand.
                        Ellipse()
                            .fill(shade)
                            .frame(width: unit * 0.86, height: unit * 0.26)
                        FingerCoralShape(bend: bend)
                            .stroke(gradient,
                                    style: StrokeStyle(lineWidth: max(3, unit * 0.15),
                                                       lineCap: .round))
                    }
                default:
                    CupCoral(colour: colour, shade: shade)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .shadow(color: shade.opacity(0.30), radius: 4, y: 3)
    }
}

/// A sea fan: a broad, scalloped blade on a short stem.
private struct FanCoralShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.50, y: h))
        path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.72))
        var previous = CGPoint(x: w * 0.06, y: h * 0.58)
        path.addLine(to: previous)
        // Five lobes around the top of the blade.
        let lobes: [(CGFloat, CGFloat)] = [
            (0.10, 0.22), (0.30, 0.04), (0.52, 0.00), (0.74, 0.06), (0.94, 0.26)
        ]
        for lobe in lobes {
            let next = CGPoint(x: w * lobe.0, y: h * lobe.1)
            path.addQuadCurve(to: next,
                              control: CGPoint(x: (previous.x + next.x) / 2 - w * 0.04,
                                               y: (previous.y + next.y) / 2 - h * 0.14))
            previous = next
        }
        path.addQuadCurve(to: CGPoint(x: w * 0.58, y: h * 0.72),
                          control: CGPoint(x: w * 0.92, y: h * 0.58))
        path.closeSubpath()
        return path
    }
}

/// The veins of the fan, which is most of what makes it read as coral.
private struct FanCoralRibs: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        let root = CGPoint(x: w * 0.50, y: h * 0.80)
        for tip in [(0.16, 0.32), (0.32, 0.16), (0.52, 0.12), (0.72, 0.18), (0.86, 0.34)] {
            path.move(to: root)
            path.addQuadCurve(to: CGPoint(x: w * tip.0, y: h * tip.1),
                              control: CGPoint(x: w * (0.50 + (tip.0 - 0.50) * 0.4),
                                               y: h * 0.48))
        }
        return path
    }
}

/// A stand of tube coral: four fingers of different heights leaning out of one
/// base, the way a real stand grows away from its own middle.
private struct FingerCoralShape: Shape {
    var bend: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        /// root x, tip height, how far it leans out.
        let fingers: [(CGFloat, CGFloat, CGFloat)] = [
            (0.24, 0.42, -0.10), (0.42, 0.16, -0.03),
            (0.60, 0.06, 0.05), (0.78, 0.34, 0.12)
        ]
        for finger in fingers {
            let lean = finger.2 + bend * 0.6
            path.move(to: CGPoint(x: w * finger.0, y: h * 0.92))
            path.addQuadCurve(
                to: CGPoint(x: w * (finger.0 + lean), y: h * finger.1),
                control: CGPoint(x: w * (finger.0 + lean * 0.25), y: h * 0.58)
            )
        }
        return path
    }
}

/// Cup coral: a knot of open bowls, drawn as rings on a low mound.
private struct CupCoral: View {
    let colour: Color
    let shade: Color

    private static let cups: [(CGFloat, CGFloat, CGFloat)] = [
        (0.28, 0.66, 0.46), (0.56, 0.50, 0.60), (0.78, 0.72, 0.40), (0.44, 0.84, 0.34)
    ]

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            ZStack {
                ForEach(Array(Self.cups.enumerated()), id: \.offset) { _, cup in
                    let side = w * cup.2
                    Circle()
                        .fill(LinearGradient(colors: [colour, shade],
                                             startPoint: .top, endPoint: .bottom))
                        .overlay {
                            Circle()
                                .fill(shade.opacity(0.85))
                                .padding(side * 0.26)
                        }
                        .frame(width: side, height: side)
                        .position(x: w * cup.0, y: h * cup.1)
                }
            }
        }
    }
}

/// The stones the reef grows on, at the very corners of the floor.
private struct RockPile: View, Equatable {
    let palette: ReefPalette

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            ZStack {
                rock(width: w * 0.62, height: h * 0.74)
                    .position(x: w * 0.30, y: h * 0.66)
                rock(width: w * 0.50, height: h * 0.52)
                    .position(x: w * 0.68, y: h * 0.78)
                rock(width: w * 0.38, height: h * 0.42)
                    .position(x: w * 0.52, y: h * 0.34)
            }
        }
    }

    private func rock(width: CGFloat, height: CGFloat) -> some View {
        Ellipse()
            .fill(LinearGradient(colors: [palette.rock, palette.rockDeep],
                                 startPoint: .top, endPoint: .bottom))
            .overlay(alignment: .top) {
                Ellipse()
                    .fill(.white.opacity(0.18))
                    .frame(width: width * 0.44, height: height * 0.22)
                    .offset(y: height * 0.14)
            }
            .frame(width: width, height: height)
    }
}

/// Branching coral gardens at both edges of the floor.
private struct CoralClump: View {
    let palette: ReefPalette
    let isPad: Bool
    let clock: Double
    /// How far above the bottom of the band the fronds are rooted, so they come
    /// out of the sand rather than off the edge of the screen.
    let rootDepth: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            // A garden, not a pair of poles: the fronds stay a fixed, modest
            // height however deep the sand behind them runs.
            let root = min(max(isPad ? 92 : 68, height - rootDepth), isPad ? 240 : 168)
            let clusterWidth = isPad ? 128.0 : 92.0
            let leftWave = sin(clock * 0.62 + 0.3)
            let rightWave = sin(clock * 0.57 + 2.7)

            ZStack {
                branchCluster(bend: CGFloat(leftWave) * 0.16)
                    .frame(width: clusterWidth, height: root)
                    .rotationEffect(.degrees(5.5 * leftWave), anchor: .bottom)
                    .position(x: width * 0.07, y: height - root / 2)

                branchCluster(bend: CGFloat(rightWave) * 0.16)
                    .frame(width: clusterWidth, height: root)
                    .scaleEffect(x: -1, y: 1)
                    .rotationEffect(.degrees(5.2 * rightWave), anchor: .bottom)
                    .position(x: width * 0.93, y: height - root / 2)
            }
            .frame(width: width, height: height)
        }
        .accessibilityHidden(true)
    }

    private func branchCluster(bend: CGFloat) -> some View {
        BranchingCoralShape(bend: bend)
            .stroke(
                LinearGradient(colors: [palette.coral.opacity(0.92), palette.coralDeep],
                               startPoint: .top, endPoint: .bottom),
                style: StrokeStyle(lineWidth: isPad ? 13 : 9,
                                   lineCap: .round,
                                   lineJoin: .round)
            )
            .shadow(color: palette.coralDeep.opacity(0.22), radius: 3, y: 3)
    }
}

private struct BranchingCoralShape: Shape {
    var bend: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        path.move(to: CGPoint(x: w * 0.52, y: h))
        path.addCurve(to: CGPoint(x: w * (0.43 + bend), y: h * 0.08),
                      control1: CGPoint(x: w * 0.54, y: h * 0.68),
                      control2: CGPoint(x: w * (0.39 + bend * 0.72), y: h * 0.36))

        path.move(to: CGPoint(x: w * 0.48, y: h * 0.66))
        path.addCurve(to: CGPoint(x: w * (0.16 + bend * 0.68), y: h * 0.29),
                      control1: CGPoint(x: w * 0.38, y: h * 0.52),
                      control2: CGPoint(x: w * (0.24 + bend * 0.45), y: h * 0.47))

        path.move(to: CGPoint(x: w * 0.46, y: h * 0.48))
        path.addCurve(to: CGPoint(x: w * (0.74 + bend * 1.12), y: h * 0.17),
                      control1: CGPoint(x: w * 0.57, y: h * 0.38),
                      control2: CGPoint(x: w * (0.68 + bend * 0.78), y: h * 0.31))

        path.move(to: CGPoint(x: w * 0.28, y: h * 0.43))
        path.addCurve(to: CGPoint(x: w * (0.10 + bend * 0.54), y: h * 0.10),
                      control1: CGPoint(x: w * 0.20, y: h * 0.34),
                      control2: CGPoint(x: w * (0.13 + bend * 0.40), y: h * 0.22))

        // Two short growths off the lower trunk. Without them the whole thing
        // is a trunk and three arms — which at the size the near corners draw
        // it at reads as a bare branch standing in the sand rather than as
        // something alive.
        path.move(to: CGPoint(x: w * 0.51, y: h * 0.84))
        path.addQuadCurve(to: CGPoint(x: w * (0.78 + bend * 0.5), y: h * 0.55),
                          control: CGPoint(x: w * 0.72, y: h * 0.78))

        path.move(to: CGPoint(x: w * 0.50, y: h * 0.30))
        path.addQuadCurve(to: CGPoint(x: w * (0.61 + bend * 0.9), y: h * 0.06),
                          control: CGPoint(x: w * (0.60 + bend * 0.6), y: h * 0.20))

        return path
    }
}

private struct PlantBladeShape: Shape {
    let bend: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.midX + rect.width * bend, y: rect.minY),
                      control1: CGPoint(x: rect.midX, y: rect.height * 0.68),
                      control2: CGPoint(x: rect.midX + rect.width * bend * 1.4,
                                        y: rect.height * 0.30))
        return path
    }
}

// MARK: - Multi-touch tapping

#if canImport(UIKit)
/// A transparent UIKit view that reports every finger as it touches down,
/// rather than the one active touch a SwiftUI `Gesture` is limited to. Two
/// hands throwing sand at once — one crab on each side of the screen — need
/// both touches recognised in the same frame, not the second one queued
/// behind the first.
private final class MultiTouchPassthroughView: UIView {
    var onTouchesBegan: ((CGPoint) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        isUserInteractionEnabled = true
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            onTouchesBegan?(touch.location(in: self))
        }
    }
}

private struct MultiTouchTapView: UIViewRepresentable {
    let onTap: (CGPoint) -> Void

    func makeUIView(context: Context) -> MultiTouchPassthroughView {
        let view = MultiTouchPassthroughView()
        view.onTouchesBegan = onTap
        return view
    }

    func updateUIView(_ uiView: MultiTouchPassthroughView, context: Context) {
        uiView.onTouchesBegan = onTap
    }
}
#endif
