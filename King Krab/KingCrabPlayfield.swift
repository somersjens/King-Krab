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

// MARK: - Playfield

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
    /// Where the touch being handled started. One touch may only take one crab,
    /// however long the finger stays down or however far it slides.
    @State private var handledTouchStart: CGPoint?

    private var palette: ReefPalette { ReefPalette(character: character) }

    /// Where the sum's banner sits, and therefore where the walking area starts.
    private var bannerTop: CGFloat { topReserve + (isPad ? 12 : 8) }

    /// The walkthrough's message card hangs under the sum, so while one is
    /// running the crabs walk below it rather than behind it.
    private var arenaTop: CGFloat {
        bannerTop + ArenaConfig.bannerHeight(isPad: isPad) + (isPad ? 26 : 18)
            + (tutorialPlan.isActive ? ArenaConfig.tutorialMessageReserve(isPad: isPad) : 0)
    }

    private func arenaRect(in size: CGSize) -> CGRect {
        let bottom = size.height - bottomReserve - ArenaConfig.floorInset(isPad: isPad)
        let top = min(arenaTop, max(0, bottom - 120))
        return CGRect(x: 0, y: top, width: size.width, height: max(1, bottom - top))
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let rect = arenaRect(in: size)

            ZStack(alignment: .topLeading) {
                WaterColumn(palette: palette, clock: arena.driftClock)
                    .equatable()

                ArenaFloor(palette: palette,
                           isPad: isPad,
                           crest: rect.minY - ArenaConfig.floorCrest(isPad: isPad),
                           clock: arena.swayClock)
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
                             hasBonusPower: arena.hasBonusAura,
                             isStreakBoostActive: isStreakBoostActive)
                    .position(arena.king.position)
                    .allowsHitTesting(false)

                ForEach(arena.crabs) { crab in
                    AnswerCrabView(crab: crab,
                                   palette: palette,
                                   isPad: isPad,
                                   isGolden: isStreakBoostActive,
                                   clock: arena.clock)
                        .position(crab.position)
                        .allowsHitTesting(false)
                }

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

                ForEach(arena.celebration) { speck in
                    CelebrationSpeckView(speck: speck, palette: palette)
                        .position(speck.position)
                        .allowsHitTesting(false)
                }

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
            .gesture(
                // Reacting on touch-down rather than on lift keeps smashing a
                // crab as immediate as hitting one: a child taps fast, and a
                // gesture that waits for the finger to leave feels broken.
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Keyed to where the finger landed rather than to a
                        // plain flag: a cancelled gesture that never reports
                        // its end can then never wedge the whole arena.
                        guard handledTouchStart != value.startLocation else { return }
                        handledTouchStart = value.startLocation
                        arena.tap(at: value.startLocation)
                    }
                    .onEnded { _ in handledTouchStart = nil }
            )
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
                arena.load(round: round)
                arena.setLive(isLive)
                arena.setBonusAura(hasBonusPower)
                arena.setLifeCrabAvailable(isLifeCrabAvailable)
                arena.setSpeedMultiplier(isStreakBoostActive
                                         ? GameConfig.streakSpeedMultiplier : 1)
                arena.setScoreTarget(scoreTarget)
                arena.setRunning(isRunning)
                if playsKingEntrance {
                    arena.beginKingEntrance(completion: onKingEntranceComplete)
                }
                if playsLevelCompletion {
                    arena.beginLevelCompletion(reduceMotion: reduceMotion,
                                               completion: onLevelCompletionFinished)
                }
            }
            .onChange(of: size) { _, newSize in
                arena.layout(size: newSize, arena: arenaRect(in: newSize), isPad: isPad)
            }
            .onChange(of: arenaTop) { _, _ in
                arena.layout(size: size, arena: arenaRect(in: size), isPad: isPad)
            }
        }
        // A new sum sends in a fresh wave. Smashing the guarded answer keeps the
        // same round, so this deliberately does not fire for it.
        .onChange(of: round?.id) { _, _ in
            arena.load(round: round)
        }
        .onChange(of: isLive) { _, live in
            arena.setLive(live)
        }
        .onChange(of: isRunning) { _, running in
            arena.setRunning(running)
        }
        .onChange(of: hasBonusPower) { _, active in
            arena.setBonusAura(active)
        }
        .onChange(of: isLifeCrabAvailable) { _, available in
            arena.setLifeCrabAvailable(available)
        }
        .onChange(of: isStreakBoostActive) { _, active in
            arena.setSpeedMultiplier(active ? GameConfig.streakSpeedMultiplier : 1)
        }
        .onChange(of: scoreTarget) { _, target in
            arena.setScoreTarget(target)
        }
        .onChange(of: tutorialPlan) { _, plan in
            withAnimation(.easeInOut(duration: 0.25)) {
                arena.applyTutorial(plan)
            }
        }
        .onChange(of: playsKingEntrance) { _, shouldPlay in
            if shouldPlay {
                arena.beginKingEntrance(completion: onKingEntranceComplete)
            }
        }
        .onChange(of: playsLevelCompletion) { _, shouldPlay in
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
            .onChange(of: roundID) { _, _ in revealNewQuestion() }
            .accessibilityIdentifier("question-card")
            .accessibilityLabel(Text(L("game.question \(prompt)")))
    }

    private func revealNewQuestion() {
        guard !shownPrompt.isEmpty else {
            shownPrompt = prompt
            return
        }
        withAnimation(.easeOut(duration: 0.10)) { isVisible = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
            shownPrompt = prompt
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
    let isStreakBoostActive: Bool

    private var size: CGFloat { ArenaConfig.kingSize(isPad: isPad) }

    /// 0 → the sweep has just begun, 1 → it is over.
    private var sweep: Double? {
        king.sweepAge.map { min(1, $0 / ArenaConfig.sweepDuration) }
    }

    /// The rise out of the sand before the first round.
    private var entrance: Double {
        guard let age = king.entranceAge else { return 1 }
        return min(1, age / ArenaConfig.entranceDuration)
    }

    /// A slow breath at rest, a hard round-house while sweeping, and an outright
    /// jig once the level is won.
    private var lean: Double {
        if king.isCheering { return sin(clock * 7.5) * 13 }
        guard let sweep, sweep < 1 else { return sin(clock * 1.4) * 1.6 }
        // One full swing out and back, so the blow lands and recovers.
        return sin(sweep * .pi * 2) * 18 * king.sweepDirection
    }

    private var pulse: CGFloat {
        if king.isCheering { return 1 + CGFloat(abs(sin(clock * 5))) * 0.09 }
        guard let sweep, sweep < 1 else { return 1 + CGFloat(sin(clock * 1.9)) * 0.012 }
        return 1 + CGFloat(sin(sweep * .pi)) * 0.15
    }

    var body: some View {
        ZStack {
            // A soft shadow welds him to the sand rather than leaving him
            // hovering over it.
            Ellipse()
                .fill(palette.sandDeep.opacity(0.34))
                .frame(width: size * 0.82, height: size * 0.19)
                .offset(y: size * 0.44)
                .blur(radius: 5)

            if isStreakBoostActive {
                streakRing
            }

            if let sweep, sweep < 1 {
                shockwave(progress: sweep)
            }

            if let age = king.healAge {
                healGlow(progress: min(1, age / ArenaConfig.healDuration))
            }

            character.artwork
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .overlay(alignment: .top) {
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
                .rotationEffect(.degrees(lean))
                .scaleEffect(pulse)
                .shadow(color: palette.coralDeep.opacity(0.24), radius: 7, y: 5)

            if hasBonusPower {
                bonusBadge
            }
        }
        .frame(width: size * 1.5, height: size * 1.5)
        // The rise: he comes up out of the sand, so the first thing the player
        // sees is the character they are about to defend.
        .scaleEffect(0.6 + 0.4 * entrance)
        .offset(y: size * 0.4 * (1 - CGFloat(entrance)))
        .opacity(entrance)
        .accessibilityHidden(true)
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

    private var streakRing: some View {
        let beat = (sin(clock * 4.2) + 1) / 2
        return Circle()
            .stroke(
                LinearGradient(colors: [Color(red: 1.0, green: 0.86, blue: 0.32),
                                        Color(red: 0.98, green: 0.60, blue: 0.10)],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                style: StrokeStyle(lineWidth: isPad ? 6 : 4.5, dash: [10, 7])
            )
            .frame(width: size * 1.12, height: size * 1.12)
            .rotationEffect(.radians(clock * 0.6))
            .opacity(0.55 + 0.35 * beat)
            .shadow(color: .yellow.opacity(0.6), radius: 8)
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

    private var emergence: Double {
        guard crab.phase == .emerging else { return 1 }
        guard crab.startDelay <= 0 else { return 0 }
        return min(1, crab.phaseAge / ArenaConfig.emergeDuration)
    }

    private var scale: CGFloat {
        switch crab.phase {
        case .emerging:  return CGFloat(emergence)
        case .smashed:   return CGFloat(1 - exit * 0.75)
        case .swept:     return CGFloat(1 - exit * 0.8)
        case .burrowing: return CGFloat(1 - exit * 0.55)
        default:         return 1
        }
    }

    private var opacity: Double {
        switch crab.phase {
        case .emerging:  return emergence
        case .smashed, .swept: return 1 - exit * exit
        case .burrowing: return 1 - exit
        default:         return 1
        }
    }

    /// Where the crab is headed, as a unit vector: it is what its eyes follow.
    private var gaze: CGSize {
        let dx = crab.target.x - crab.start.x
        let dy = crab.target.y - crab.start.y
        let length = max(1, hypot(dx, dy))
        return CGSize(width: dx / length, height: dy / length)
    }

    /// The shell's own lean and sway this frame. The hands are placed off the
    /// same two numbers, which is what keeps them on its rim while it swings.
    private var cardSway: Double { sin(crab.age * crab.waddleRate - 0.6) }
    private var cardAngle: Double { crab.cardLean + cardSway * 3.4 }
    private var cardCentre: CGPoint {
        let cardHeight = ArenaConfig.cardHeight(isPad: isPad)
        return CGPoint(x: CGFloat(cardSway) * bodyWidth * 0.025,
                       y: -bodyWidth * 0.75 - cardHeight * (ArenaConfig.cardLift - 0.5))
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
        let left = AnswerShellShape.grip
        return CrabHold(left: onRim(left),
                        right: onRim(CGPoint(x: 1 - left.x, y: left.y)),
                        centre: centre)
    }

    private var rig: CrabArmRig {
        CrabArmRig(bodyWidth: bodyWidth,
                   stepPhase: gait,
                   isWalking: crab.phase == .walking,
                   facing: crab.facing,
                   hold: hold)
    }

    /// The walk cycle, measured off the ground the crab has actually covered.
    private var gait: Double {
        Double(crab.walked / max(1, bodyWidth * CrabSprite.strideLength * crab.strideFactor))
            * 2 * .pi + crab.gaitOffset
    }

    var body: some View {
        let rig = self.rig
        let colors = (isGolden ? CrabTint.gold : CrabTint.enemy).shell

        return CrabSprite(bodyWidth: bodyWidth,
                          tint: isGolden ? .gold : .enemy,
                          stepPhase: gait,
                          isWalking: crab.phase == .walking,
                          facing: crab.facing,
                          gaze: gaze,
                          strideFactor: crab.strideFactor,
                          rig: rig,
                          // The hands go on above the shell instead, so the
                          // pincers close in front of its rim rather than
                          // disappearing behind it.
                          drawsHands: false,
                          palette: palette)
            .overlay {
                AnswerShell(text: crab.text,
                            palette: palette,
                            isPad: isPad,
                            isGolden: isGolden)
                    // The shell swings a beat behind the body, the way anything
                    // held over your head does.
                    .rotationEffect(.degrees(cardAngle))
                    .offset(x: cardCentre.x, y: cardCentre.y)
            }
            .overlay { CrabHandsView(rig: rig, colors: colors) }
            // A burrowing crab sinks straight down into the sand; a smashed or
            // swept one tumbles away with the blow that sent it.
            .offset(y: crab.phase == .burrowing ? bodyWidth * 0.5 * CGFloat(exit) : 0)
            .rotationEffect(.radians(crab.spin * exit))
            .scaleEffect(scale)
            .opacity(opacity)
            .accessibilityHidden(true)
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

    /// Where the left claw closes: high enough up the shoulder to be on the
    /// widest part of the shell, low enough to still read as carrying it.
    static var grip: CGPoint { shoulderPoint(0.82) }

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

/// The 2x crab and the comeback crab. They are deliberately not shaped like an
/// answer crab: no card, a different colour, and something held up instead.
private struct CarrierCrabView: View {
    let carrier: CarrierCrab
    let palette: ReefPalette
    let isPad: Bool
    let clock: Double

    /// Where the token rides, and the two points on its lower flanks the
    /// pincers close on — the same rig the answer crabs use, so a carrier
    /// holds its reward rather than balancing it.
    private static let tokenCentre: CGFloat = -0.86

    private var hold: CrabHold {
        let size = carrier.size
        guard carrier.isCarryingReward else { return .raised(bodyWidth: size) }
        return CrabHold(left: CGPoint(x: -size * 0.28, y: size * (Self.tokenCentre + 0.06)),
                        right: CGPoint(x: size * 0.28, y: size * (Self.tokenCentre + 0.06)),
                        centre: CGPoint(x: 0, y: size * Self.tokenCentre))
    }

    private var gait: Double {
        Double(carrier.walked
               / max(1, carrier.size * CrabSprite.strideLength * carrier.strideFactor)) * 2 * .pi
    }

    var body: some View {
        let rig = CrabArmRig(bodyWidth: carrier.size,
                             stepPhase: gait,
                             isWalking: true,
                             facing: carrier.facing,
                             hold: hold)
        let tint: CrabTint = carrier.kind == .bonus ? .bonus : .life

        return CrabSprite(bodyWidth: carrier.size,
                          tint: tint,
                          stepPhase: gait,
                          isWalking: true,
                          facing: carrier.facing,
                          gaze: CGSize(width: carrier.facing, height: 0),
                          strideFactor: carrier.strideFactor,
                          rig: rig,
                          drawsHands: !carrier.isCarryingReward,
                          palette: palette)
            .overlay {
                token
                    .offset(y: carrier.size * Self.tokenCentre)
                    .opacity(carrier.isCarryingReward ? 1 : 0)
            }
            // While it is carrying, the pincers close in front of the token.
            .overlay {
                if carrier.isCarryingReward {
                    CrabHandsView(rig: rig, colors: tint.shell)
                }
            }
            .scaleEffect(x: carrier.facing < 0 ? -1 : 1, y: 1)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var token: some View {
        let side = carrier.size * 0.52
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
            return (Color(red: 0.93, green: 0.36, blue: 0.20),
                    Color(red: 0.68, green: 0.14, blue: 0.05))
        case .gold:
            return (Color(red: 1.00, green: 0.84, blue: 0.34),
                    Color(red: 0.80, green: 0.52, blue: 0.04))
        case .bonus:
            return (Color(red: 1.00, green: 0.78, blue: 0.24),
                    Color(red: 0.85, green: 0.45, blue: 0.03))
        case .life:
            return (Color(red: 0.44, green: 0.82, blue: 0.52),
                    Color(red: 0.13, green: 0.51, blue: 0.29))
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
    /// The arms, already solved against whatever this crab is holding. Nil just
    /// raises them.
    var rig: CrabArmRig?
    /// A crab whose load is drawn over the sprite hands its pincers back, so
    /// they can be drawn again on top and close in front of the load's edge.
    var drawsHands: Bool = true
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

    private var armRig: CrabArmRig {
        rig ?? CrabArmRig(bodyWidth: bodyWidth,
                          stepPhase: stepPhase,
                          isWalking: isWalking,
                          facing: facing,
                          hold: .raised(bodyWidth: bodyWidth))
    }

    var body: some View {
        let colors = tint.shell
        let rig = armRig

        return ZStack {
            Ellipse()
                .fill(palette.sandDeep.opacity(0.32))
                .frame(width: bodyWidth * 0.84, height: bodyWidth * 0.16)
                .offset(y: bodyHeight * 0.68)
                .blur(radius: 3)

            // The arms are drawn first so both shoulders disappear under the
            // shell's edge. They are not inside the body's roll: the rig has
            // already carried the shoulders through it, and the hands have to
            // stay on what they are holding while the body swings under them.
            CrabArmsView(rig: rig, colors: colors)

            ZStack {
                // Legs sit behind the shell, but far enough out that the shell
                // never swallows them.
                legs(colors: colors)
                shell(colors: colors)
                face(colors: colors)
            }
            .rotationEffect(.degrees(roll))
            .offset(y: bob)

            if drawsHands {
                CrabHandsView(rig: rig, colors: colors)
            }
        }
        .frame(width: bodyWidth * 1.7, height: bodyWidth * 1.5)
    }

    // MARK: The shell

    private func shell(colors: (Color, Color)) -> some View {
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
            .overlay {
                CarapaceShape()
                    .stroke(colors.1, lineWidth: max(1, bodyWidth * 0.030))
                    .opacity(0.9)
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
    private func face(colors: (Color, Color)) -> some View {
        VStack(spacing: bodyHeight * 0.13) {
            HStack(spacing: bodyWidth * 0.12) {
                eye()
                eye()
            }
            SmileShape()
                .stroke(colors.1.opacity(0.95),
                        style: StrokeStyle(lineWidth: max(1.5, bodyWidth * 0.045),
                                           lineCap: .round))
                .frame(width: bodyWidth * 0.22, height: bodyWidth * 0.10)
        }
        .offset(y: -bodyHeight * 0.10)
    }

    private func eye() -> some View {
        let diameter = bodyWidth * 0.215
        let look = CGSize(width: gaze.width * diameter * 0.16,
                          height: gaze.height * diameter * 0.16)
        return Circle()
            .fill(.white)
            .overlay {
                Circle()
                    .fill(Color(red: 0.11, green: 0.13, blue: 0.22))
                    .frame(width: diameter * 0.44, height: diameter * 0.44)
                    .offset(x: look.width, y: look.height + diameter * 0.04)
            }
            .overlay(alignment: .topLeading) {
                // The catchlight, which is most of what makes an eye alive.
                Circle()
                    .fill(.white)
                    .frame(width: diameter * 0.20, height: diameter * 0.20)
                    .offset(x: diameter * 0.20, y: diameter * 0.16)
            }
            .overlay {
                Circle().stroke(.black.opacity(0.10), lineWidth: 1)
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
    private static let legPlan: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (0.33, -0.06, 0.44, 0.78, 0.72),
        (0.35, 0.14, 0.62, 0.98, 0.80),
        (0.27, 0.32, 0.52, 1.14, 0.76)
    ]

    /// The share of the cycle a foot spends on the ground. Above a half means
    /// three feet are always planted, which is what a walk is.
    private static let stanceShare = 0.62

    /// How far the body travels per full cycle, as a share of its own width.
    /// The legs take their phase from ground covered, so this number is the one
    /// thing keeping the feet from sliding.
    static let strideLength: CGFloat = 0.44

    private var legLift: CGFloat { bodyWidth * 0.14 }

    private func legs(colors: (Color, Color)) -> some View {
        let shade = AnyShapeStyle(LinearGradient(
            stops: [.init(color: colors.0, location: 0),
                    .init(color: colors.1, location: 0.55)],
            startPoint: .top, endPoint: .bottom
        ))
        return ZStack {
            ForEach(Array(Self.legPlan.enumerated()), id: \.offset) { index, plan in
                // Alternating tripod: left 1 and 3 swing with right 2, and the
                // other way about — with a small lag down the row, the way the
                // wave actually runs along a crab.
                let lag = Double(index) * 0.22
                let leftPhase = stepPhase + (index == 1 ? .pi : 0) + lag
                let rightPhase = stepPhase + (index == 1 ? 0 : .pi) + lag
                leg(plan: plan, side: -1, phase: leftPhase, color: shade)
                leg(plan: plan, side: 1, phase: rightPhase, color: shade)
            }
        }
    }

    /// One walking leg, solved rather than drawn: the foot is placed first —
    /// planted and sliding backwards under the body through the stance, then
    /// lifted and swung forward — and the knee is whatever angle reaches it.
    private func leg(plan: (CGFloat, CGFloat, CGFloat, CGFloat, CGFloat),
                     side: CGFloat, phase: Double, color: AnyShapeStyle) -> some View {
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
        let hip = CGPoint(x: side * bodyWidth * plan.0, y: bodyHeight * plan.1)
        let foot = CGPoint(x: side * bodyWidth * plan.2 + facing * stride * travel,
                           y: bodyHeight * plan.3 - lift)
        let limb = bodyWidth * plan.4
        // A crab bends its knees up and outward, so the joint is taken on the
        // side the leg is on.
        let knee = crabJoint(from: hip, to: foot,
                             first: limb * 0.56, second: limb * 0.50, bend: side)

        return ZStack {
            // The dimple the planted foot presses into the sand. It fades as
            // the leg picks up, which is what sells the contact.
            Ellipse()
                .fill(palette.sandDeep.opacity(0.30 * (1 - Double(lift / legLift))))
                .frame(width: bodyWidth * 0.13, height: bodyWidth * 0.05)
                .offset(x: foot.x, y: bodyHeight * plan.3 + bodyWidth * 0.02)

            CrabLegShape(hip: hip, knee: knee, foot: foot, width: bodyWidth * 0.125)
                .fill(color)

            // A knuckle at the knee: without it the two segments read as one
            // bent stick rather than as a jointed limb.
            Circle()
                .fill(color)
                .frame(width: bodyWidth * 0.112, height: bodyWidth * 0.112)
                .offset(x: knee.x, y: knee.y)
        }
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

/// A leg drawn as one tapered limb: thick at the hinge, narrower at the knee,
/// and closing to the point a crab actually walks on.
private struct CrabLegShape: Shape {
    let hip: CGPoint
    let knee: CGPoint
    let foot: CGPoint
    let width: CGFloat

    func path(in rect: CGRect) -> Path {
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        let a = CGPoint(x: centre.x + hip.x, y: centre.y + hip.y)
        let b = CGPoint(x: centre.x + knee.x, y: centre.y + knee.y)
        let c = CGPoint(x: centre.x + foot.x, y: centre.y + foot.y)

        func normal(_ from: CGPoint, _ to: CGPoint) -> CGPoint {
            let dx = to.x - from.x
            let dy = to.y - from.y
            let length = max(0.001, (dx * dx + dy * dy).squareRoot())
            return CGPoint(x: -dy / length, y: dx / length)
        }

        let upper = normal(a, b)
        let lower = normal(b, c)
        // The knee's own normal is the average of the two segments', which is
        // what keeps the outline smooth around the bend.
        let joint = CGPoint(x: (upper.x + lower.x) / 2, y: (upper.y + lower.y) / 2)
        let jointLength = max(0.001, (joint.x * joint.x + joint.y * joint.y).squareRoot())
        let jointNormal = CGPoint(x: joint.x / jointLength, y: joint.y / jointLength)

        // A gentle taper, not a spike: the foot ends in a soft tip the same
        // way the claws and the shell do.
        let hipWidth = width / 2
        let kneeWidth = width * 0.58
        let footWidth = width * 0.34

        var path = Path()
        path.move(to: CGPoint(x: a.x + upper.x * hipWidth, y: a.y + upper.y * hipWidth))
        path.addLine(to: CGPoint(x: b.x + jointNormal.x * kneeWidth,
                                 y: b.y + jointNormal.y * kneeWidth))
        path.addLine(to: CGPoint(x: c.x + lower.x * footWidth,
                                 y: c.y + lower.y * footWidth))
        path.addLine(to: CGPoint(x: c.x - lower.x * footWidth,
                                 y: c.y - lower.y * footWidth))
        path.addLine(to: CGPoint(x: b.x - jointNormal.x * kneeWidth,
                                 y: b.y - jointNormal.y * kneeWidth))
        path.addLine(to: CGPoint(x: a.x - upper.x * hipWidth, y: a.y - upper.y * hipWidth))
        path.closeSubpath()
        // A rounded shoulder where the leg leaves the shell, and a rounded toe
        // where it meets the sand. Both also fill the corners of the outline,
        // so no joint on this limb has a hard edge anywhere.
        path.addEllipse(in: CGRect(x: a.x - hipWidth, y: a.y - hipWidth,
                                   width: hipWidth * 2, height: hipWidth * 2))
        path.addEllipse(in: CGRect(x: c.x - footWidth, y: c.y - footWidth,
                                   width: footWidth * 2, height: footWidth * 2))
        return path
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

/// The mouth: a shallow upward arc.
private struct SmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                          control: CGPoint(x: rect.midX, y: rect.maxY * 1.9))
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
    struct Arm {
        var shoulder: CGPoint
        var elbow: CGPoint
        var hand: CGPoint
        /// Which way the open pincer points, in radians.
        var bite: Double
    }

    var upperWidth: CGFloat
    var foreWidth: CGFloat
    var handSize: CGFloat
    var left: Arm
    var right: Arm

    init(bodyWidth: CGFloat, stepPhase: Double, isWalking: Bool,
         facing: CGFloat, hold: CrabHold) {
        let bodyHeight = bodyWidth * CrabSprite.heightRatio
        upperWidth = bodyWidth * 0.13
        foreWidth = bodyWidth * 0.108
        handSize = bodyWidth * 0.25

        // The shoulders ride with the body: the rig is drawn outside the roll,
        // so it has to apply that roll to its own two anchor points.
        let roll = CrabSprite.roll(stepPhase: stepPhase,
                                   isWalking: isWalking,
                                   facing: facing) * .pi / 180
        let bob = CrabSprite.bob(bodyWidth: bodyWidth,
                                 stepPhase: stepPhase,
                                 isWalking: isWalking)
        let cosine = CGFloat(cos(roll))
        let sine = CGFloat(sin(roll))
        func onBody(_ point: CGPoint) -> CGPoint {
            CGPoint(x: point.x * cosine - point.y * sine,
                    y: point.x * sine + point.y * cosine + bob)
        }

        // High on the flank, so the arm leaves from under the shell's edge.
        let shoulder = CGPoint(x: bodyWidth * 0.38, y: -bodyHeight * 0.16)
        let upper = bodyWidth * 0.50
        let fore = bodyWidth * 0.46

        func arm(shoulder: CGPoint, hand: CGPoint, bend: CGFloat) -> Arm {
            Arm(shoulder: shoulder,
                elbow: crabJoint(from: shoulder, to: hand,
                                 first: upper, second: fore, bend: bend),
                hand: hand,
                bite: atan2(Double(hold.centre.y - hand.y),
                            Double(hold.centre.x - hand.x)))
        }

        // The elbows bow away from the body, which is what leaves the shell's
        // face clear and the arms reading as raised rather than folded.
        left = arm(shoulder: onBody(CGPoint(x: -shoulder.x, y: shoulder.y)),
                   hand: hold.left,
                   bend: 1)
        right = arm(shoulder: onBody(shoulder),
                    hand: hold.right,
                    bend: -1)
    }
}

/// The two arms: an upper arm, a forearm and a knuckle at the elbow. Without
/// the knuckle the segments read as one bent stick rather than a jointed limb.
private struct CrabArmsView: View {
    let rig: CrabArmRig
    let colors: (Color, Color)

    var body: some View {
        ZStack {
            arm(rig.left)
            arm(rig.right)
        }
    }

    private func arm(_ arm: CrabArmRig.Arm) -> some View {
        ZStack {
            segment(from: arm.shoulder, to: arm.elbow, width: rig.upperWidth)
            segment(from: arm.elbow, to: arm.hand, width: rig.foreWidth)
            Circle()
                .fill(colors.1)
                .frame(width: rig.foreWidth * 1.2, height: rig.foreWidth * 1.2)
                .offset(x: arm.elbow.x, y: arm.elbow.y)
        }
    }

    private func segment(from start: CGPoint, to end: CGPoint, width: CGFloat) -> some View {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = max(1, (dx * dx + dy * dy).squareRoot())
        return Capsule()
            .fill(LinearGradient(colors: [colors.0, colors.1],
                                 startPoint: .leading, endPoint: .trailing))
            .frame(width: width, height: length + width * 0.5)
            .rotationEffect(.radians(atan2(Double(dy), Double(dx)) + .pi / 2))
            .offset(x: start.x + dx / 2, y: start.y + dy / 2)
    }
}

/// The pincers, drawn apart from the arms so they can be layered in front of
/// whatever the crab is holding: a hand behind the shell's rim looks like a
/// crab standing under it, and a hand over the rim looks like a crab gripping.
private struct CrabHandsView: View {
    let rig: CrabArmRig
    let colors: (Color, Color)

    var body: some View {
        ZStack {
            hand(rig.left)
            hand(rig.right)
        }
    }

    private func hand(_ arm: CrabArmRig.Arm) -> some View {
        PincerView(size: rig.handSize, colors: colors)
            .rotationEffect(.radians(arm.bite))
            .offset(x: arm.hand.x, y: arm.hand.y)
    }
}

/// A small pincer: a knuckle and two jaws splayed around whatever it is closing
/// on. At the size a crab's hand actually is, two outlined capsules read as a
/// claw where a fully modelled one reads as a smudge — the outline is doing the
/// work, since the hand is usually sitting on the white face of a shell. It
/// points along +x before it is turned.
private struct PincerView: View {
    let size: CGFloat
    let colors: (Color, Color)

    private var knuckle: CGPoint { CGPoint(x: -size * 0.26, y: 0) }
    private var outline: CGFloat { max(1, size * 0.11) }

    var body: some View {
        ZStack {
            // The jaws reach well clear of the knuckle: a hand that is mostly
            // knuckle reads as a mitten, and the gap between the two fingers is
            // the whole reason it reads as a grip.
            jaw(degrees: -38, length: size * 1.15, width: size * 0.36)
            jaw(degrees: 34, length: size * 0.92, width: size * 0.31)

            Circle()
                .fill(colors.0)
                .overlay { Circle().stroke(colors.1, lineWidth: outline) }
                .frame(width: size * 0.70, height: size * 0.70)
                .offset(x: knuckle.x, y: knuckle.y)
        }
        .frame(width: size * 2.2, height: size * 2.2)
        .shadow(color: .black.opacity(0.18), radius: max(1, size * 0.09), y: size * 0.05)
    }

    private func jaw(degrees: Double, length: CGFloat, width: CGFloat) -> some View {
        let angle = degrees * .pi / 180
        return Capsule()
            .fill(colors.0)
            .overlay { Capsule().stroke(colors.1, lineWidth: outline) }
            .frame(width: width, height: length)
            .rotationEffect(.radians(angle + .pi / 2))
            .offset(x: knuckle.x + CGFloat(cos(angle)) * length * 0.52,
                    y: knuckle.y + CGFloat(sin(angle)) * length * 0.52)
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

private struct CelebrationSpeckView: View {
    let speck: CelebrationSpeck
    let palette: ReefPalette

    var body: some View {
        Group {
            switch speck.kind {
            case .shell:
                CurrencyIcon(size: speck.radius * 2.4)
                    .foregroundStyle(palette.coralDeep)
            case .bubble:
                Circle()
                    .fill(
                        RadialGradient(colors: [.white.opacity(0.42),
                                                palette.waterTop.opacity(0.22),
                                                .white.opacity(0.16)],
                                       center: .topLeading,
                                       startRadius: 1,
                                       endRadius: speck.radius * 1.4)
                    )
                    .overlay {
                        Circle().stroke(.white.opacity(0.48),
                                        lineWidth: max(1, speck.radius * 0.09))
                    }
                    .frame(width: speck.radius * 2, height: speck.radius * 2)
            }
        }
        .scaleEffect(min(1, CGFloat(speck.age / 0.18)))
        .allowsHitTesting(false)
        .accessibilityHidden(true)
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

// MARK: - Water

/// The water column: the whole screen, from the surface at the very top edge
/// down to the sea floor.
private struct WaterColumn: View, Equatable {
    let palette: ReefPalette
    let clock: Double

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.palette.character == rhs.palette.character && lhs.clock == rhs.clock
    }

    var body: some View {
        LinearGradient(colors: [palette.waterTop, palette.waterDeep],
                       startPoint: .top, endPoint: .bottom)
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

    /// centre x, width, lean, drift rate, brightness.
    private static let shafts: [(CGFloat, CGFloat, Double, Double, Double)] = [
        (0.14, 0.30, -14, 0.17, 0.85), (0.33, 0.17, -11, 0.13, 0.55),
        (0.52, 0.26, -9, 0.10, 0.75), (0.72, 0.15, -13, 0.15, 0.50),
        (0.88, 0.24, -8, 0.12, 0.70)
    ]

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.clock == rhs.clock && lhs.isPad == rhs.isPad
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack(alignment: .top) {
                ForEach(Array(Self.shafts.enumerated()), id: \.offset) { index, shaft in
                    Rectangle()
                        .fill(
                            LinearGradient(stops: [
                                .init(color: .white.opacity(0), location: 0),
                                .init(color: .white.opacity(0.55 * shaft.4), location: 0.42),
                                .init(color: .white.opacity(0.70 * shaft.4), location: 0.55),
                                .init(color: .white.opacity(0), location: 1)
                            ], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: width * shaft.1, height: height * 1.5)
                        // The beam is brightest just under the surface and gone
                        // long before the deepest sand.
                        .mask {
                            LinearGradient(stops: [
                                .init(color: .white.opacity(0.25), location: 0),
                                .init(color: .white, location: 0.20),
                                .init(color: .white.opacity(0.50), location: 0.55),
                                .init(color: .clear, location: 0.95)
                            ], startPoint: .top, endPoint: .bottom)
                        }
                        .rotationEffect(.degrees(shaft.2), anchor: .top)
                        .offset(x: width * (shaft.0 - 0.5)
                                    + CGFloat(sin(clock * shaft.3 + Double(index))) * width * 0.03)
                }
            }
            .frame(width: width, height: height, alignment: .top)
        }
        .blendMode(.plusLighter)
        .opacity(0.17)
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
            let sandHeight = max(140, size.height - crest)

            ZStack(alignment: .bottom) {
                SandBed(palette: palette)
                    .frame(height: sandHeight)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                // The light that reaches the bottom, and everything lying in it.
                SandDetail(palette: palette, isPad: isPad, clock: clock)
                    .frame(height: sandHeight)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                // The reef itself, hugging both edges where nothing walks.
                ReefBorder(palette: palette, isPad: isPad, clock: clock)
                    .frame(height: sandHeight)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                // Stones with their own planting growing out from between them.
                SeaGardens(palette: palette, isPad: isPad, clock: clock)
                    .frame(height: sandHeight)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .frame(width: size.width, height: size.height)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// The sand itself: one soft mound rather than a straight edge, running off the
/// bottom of the screen so the floor never ends in a visible line.
private struct SandBed: View {
    let palette: ReefPalette

    var body: some View {
        SandShape()
            .fill(
                LinearGradient(stops: [
                    .init(color: palette.sand, location: 0),
                    .init(color: palette.sand, location: 0.30),
                    .init(color: palette.sandDeep, location: 1)
                ], startPoint: .top, endPoint: .bottom)
            )
            .overlay {
                // A pale lip along the crest, where the light hits the ridge
                // the whole arena sits on.
                SandShape()
                    .stroke(.white.opacity(0.34), lineWidth: 2.5)
                    .blur(radius: 1.5)
                    .mask {
                        LinearGradient(colors: [.white, .clear],
                                       startPoint: .top, endPoint: .bottom)
                    }
            }
            .accessibilityHidden(true)
    }
}

private struct SandShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        // The crown of the hill sits above the sides, which is what makes the
        // floor read as a mound the King stands on rather than as a band.
        path.move(to: CGPoint(x: rect.minX, y: h * 0.16))
        path.addCurve(to: CGPoint(x: w * 0.50, y: 0),
                      control1: CGPoint(x: w * 0.16, y: h * 0.14),
                      control2: CGPoint(x: w * 0.30, y: -h * 0.02))
        path.addCurve(to: CGPoint(x: rect.maxX, y: h * 0.14),
                      control1: CGPoint(x: w * 0.72, y: h * 0.01),
                      control2: CGPoint(x: w * 0.86, y: h * 0.15))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Everything lying on the sand: the moving net of light from the surface, and
/// the pebbles, shells and starfish scattered between the walking lanes.
///
/// One immediate-mode pass for all of it. Their positions are fixed — a floor
/// that reshuffled itself between rounds would be noticed immediately — and only
/// the light actually moves.
private struct SandDetail: View {
    let palette: ReefPalette
    let isPad: Bool
    let clock: Double

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

    /// x, y, radius factor, drift phase — the caustic net of light. Many small
    /// patches read as sunlight through moving water; a few large ones only
    /// read as clouds on the floor.
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
            drawLight(in: &context, size: size)
            drawSpecks(in: &context, size: size)
        }
        .opacity(0.85)
        .accessibilityHidden(true)
    }

    /// Slow, overlapping patches of surface light. They breathe rather than
    /// travel, which is what sunlight through moving water actually does.
    private func drawLight(in context: inout GraphicsContext, size: CGSize) {
        let base = size.width * (isPad ? 0.075 : 0.095)
        for dapple in dapples {
            let breath = 1 + 0.20 * sin(clock * 0.46 + dapple.3)
            let radius = base * dapple.2 * CGFloat(breath)
            let centre = CGPoint(x: size.width * dapple.0
                                    + CGFloat(sin(clock * 0.23 + dapple.3)) * 5,
                                 y: size.height * dapple.1
                                    + CGFloat(cos(clock * 0.19 + dapple.3)) * 3)
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

                boulder(width: w * 0.52, height: h * 0.52)
                    .position(x: w * 0.42, y: h * 0.70)
                boulder(width: w * 0.34, height: h * 0.34)
                    .position(x: w * 0.72, y: h * 0.80)
                boulder(width: w * 0.22, height: h * 0.22)
                    .position(x: w * 0.20, y: h * 0.87)

                if variant == 2 {
                    StarfishView(colour: palette.reefAccent(1),
                                 shade: palette.reefAccentDeep(1))
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

    /// A stone: rounded, lit from above, and sitting in its own dimple of sand.
    private func boulder(width: CGFloat, height: CGFloat) -> some View {
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
private struct StarfishView: View {
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
    private static let leftClusters: [(CGFloat, CGFloat, Int, Int, Double)] = [
        (0.16, 0.66, 0, 0, 0.5), (0.42, 0.58, 2, 2, 2.4),
        (0.70, 0.92, 1, 1, 4.1), (0.93, 0.78, 3, 3, 1.2)
    ]
    private static let rightClusters: [(CGFloat, CGFloat, Int, Int, Double)] = [
        (0.22, 0.60, 2, 4, 3.3), (0.50, 0.80, 1, 0, 0.8),
        (0.76, 0.66, 3, 2, 5.0), (0.96, 0.88, 0, 1, 2.0)
    ]

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let unit = min(width * 0.17, isPad ? 132 : 84)

            ZStack {
                RockPile(palette: palette)
                    .frame(width: unit * 1.5, height: unit * 0.78)
                    .position(x: width * 0.03, y: height * 0.93)
                RockPile(palette: palette)
                    .frame(width: unit * 1.35, height: unit * 0.66)
                    .scaleEffect(x: -1, y: 1)
                    .position(x: width * 0.97, y: height * 0.86)

                ForEach(Array(Self.leftClusters.enumerated()), id: \.offset) { index, cluster in
                    coral(cluster, unit: unit)
                        .position(x: width * (index.isMultiple(of: 2) ? 0.085 : 0.15),
                                  y: height * cluster.0)
                }
                ForEach(Array(Self.rightClusters.enumerated()), id: \.offset) { index, cluster in
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
                    BranchingCoralShape(bend: bend)
                        .stroke(gradient,
                                style: StrokeStyle(lineWidth: max(3, unit * 0.15),
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

    private let cups: [(CGFloat, CGFloat, CGFloat)] = [
        (0.28, 0.66, 0.46), (0.56, 0.50, 0.60), (0.78, 0.72, 0.40), (0.44, 0.84, 0.34)
    ]

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            ZStack {
                ForEach(Array(cups.enumerated()), id: \.offset) { _, cup in
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
private struct RockPile: View {
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
