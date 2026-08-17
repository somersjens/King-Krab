// 
// GeneratedStringSymbols_Localizable.swift
// Auto-Generated symbols for localized strings defined in “Localizable.xcstrings”.
// 

import Foundation

#if SWIFT_PACKAGE
private nonisolated let resourceBundle = Foundation.Bundle.module
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
private nonisolated let resourceBundleDescription = LocalizedStringResource.BundleDescription.atURL(resourceBundle.bundleURL)
#else

private class ResourceBundleClass {}
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
private nonisolated let resourceBundleDescription = LocalizedStringResource.BundleDescription.forClass(ResourceBundleClass.self)
#endif

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
nonisolated extension LocalizedStringResource {
    /**
     Animal name, shown in the character picker, the premium gallery and unlock messages. One short noun a young child would use.
     
     Localized string for key “character.bear” in table “Localizable.xcstrings”.
     */
    static var characterBear: LocalizedStringResource {
        LocalizedStringResource("character.bear", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Animal name, shown in the character picker, the premium gallery and unlock messages. One short noun a young child would use.
     
     Localized string for key “character.bunny” in table “Localizable.xcstrings”.
     */
    static var characterBunny: LocalizedStringResource {
        LocalizedStringResource("character.bunny", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Animal name, shown in the character picker, the premium gallery and unlock messages. One short noun a young child would use.
     
     Localized string for key “character.crab” in table “Localizable.xcstrings”.
     */
    static var characterCrab: LocalizedStringResource {
        LocalizedStringResource("character.crab", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Animal name, shown in the character picker, the premium gallery and unlock messages. One short noun a young child would use.
     
     Localized string for key “character.dog” in table “Localizable.xcstrings”.
     */
    static var characterDog: LocalizedStringResource {
        LocalizedStringResource("character.dog", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Animal name, shown in the character picker, the premium gallery and unlock messages. One short noun a young child would use.
     
     Localized string for key “character.elephant” in table “Localizable.xcstrings”.
     */
    static var characterElephant: LocalizedStringResource {
        LocalizedStringResource("character.elephant", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Animal name, shown in the character picker, the premium gallery and unlock messages. One short noun a young child would use.
     
     Localized string for key “character.fox” in table “Localizable.xcstrings”.
     */
    static var characterFox: LocalizedStringResource {
        LocalizedStringResource("character.fox", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Animal name, shown in the character picker, the premium gallery and unlock messages. One short noun a young child would use.
     
     Localized string for key “character.frog” in table “Localizable.xcstrings”.
     */
    static var characterFrog: LocalizedStringResource {
        LocalizedStringResource("character.frog", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Animal name, shown in the character picker, the premium gallery and unlock messages. One short noun a young child would use.
     
     Localized string for key “character.lion” in table “Localizable.xcstrings”.
     */
    static var characterLion: LocalizedStringResource {
        LocalizedStringResource("character.lion", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Animal name, shown in the character picker, the premium gallery and unlock messages. One short noun a young child would use.
     
     Localized string for key “character.octopus” in table “Localizable.xcstrings”.
     */
    static var characterOctopus: LocalizedStringResource {
        LocalizedStringResource("character.octopus", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Animal name, shown in the character picker, the premium gallery and unlock messages. One short noun a young child would use.
     
     Localized string for key “character.penguin” in table “Localizable.xcstrings”.
     */
    static var characterPenguin: LocalizedStringResource {
        LocalizedStringResource("character.penguin", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Button that returns to the previous onboarding step. Also the VoiceOver label for the back chevron, so keep it a plain verb.
     
     Localized string for key “common.back” in table “Localizable.xcstrings”.
     */
    static var commonBack: LocalizedStringResource {
        LocalizedStringResource("common.back", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Button that dismisses a sheet without saving.
     
     Localized string for key “common.cancel” in table “Localizable.xcstrings”.
     */
    static var commonCancel: LocalizedStringResource {
        LocalizedStringResource("common.cancel", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Button that resumes a level the player left part-way through.
     
     Localized string for key “common.continue” in table “Localizable.xcstrings”.
     */
    static var commonContinue: LocalizedStringResource {
        LocalizedStringResource("common.continue", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Button that closes a settings sheet.
     
     Localized string for key “common.done” in table “Localizable.xcstrings”.
     */
    static var commonDone: LocalizedStringResource {
        LocalizedStringResource("common.done", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver value for a character the player has not earned yet. Pairs with common.unlocked.
     
     Localized string for key “common.locked” in table “Localizable.xcstrings”.
     */
    static var commonLocked: LocalizedStringResource {
        LocalizedStringResource("common.locked", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Very compact progress readout on the home screen streak chip: minutes played out of the goal. First number is progress, second is the goal. Space is tight — abbreviate the unit the way your language does on a watch face.
     
     Localized string for key “common.minutesShort %lld %lld” in table “Localizable.xcstrings”.
     */
    static func commonMinutesShort(_ arg1: Int, _ arg2: Int) -> LocalizedStringResource {
        LocalizedStringResource("common.minutesShort %lld %lld", defaultValue: "\(arg1, specifier: "%lld")\(arg2, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver value for a switch that is off. Pairs with common.on.
     
     Localized string for key “common.off” in table “Localizable.xcstrings”.
     */
    static var commonOff: LocalizedStringResource {
        LocalizedStringResource("common.off", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Button that acknowledges an informational message.
     
     Localized string for key “common.ok” in table “Localizable.xcstrings”.
     */
    static var commonOk: LocalizedStringResource {
        LocalizedStringResource("common.ok", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver value for a switch that is on. Pairs with common.off.
     
     Localized string for key “common.on” in table “Localizable.xcstrings”.
     */
    static var commonOn: LocalizedStringResource {
        LocalizedStringResource("common.on", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Button that confirms an edited value.
     
     Localized string for key “common.save” in table “Localizable.xcstrings”.
     */
    static var commonSave: LocalizedStringResource {
        LocalizedStringResource("common.save", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver value for a character the player has earned. Pairs with common.locked.
     
     Localized string for key “common.unlocked” in table “Localizable.xcstrings”.
     */
    static var commonUnlocked: LocalizedStringResource {
        LocalizedStringResource("common.unlocked", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver label for the score capsule on the result screen. First number is the score reached, second the maximum for that level.
     
     Localized string for key “game.accessibility.scoreOutOf %lld %lld” in table “Localizable.xcstrings”.
     */
    static func gameAccessibilityScoreOutOf(_ arg1: Int, _ arg2: Int) -> LocalizedStringResource {
        LocalizedStringResource("game.accessibility.scoreOutOf %lld %lld", defaultValue: "\(arg1, specifier: "%lld")\(arg2, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver value spoken for an answer crab that carries the correct answer. Pairs with game.answer.wrong. One word.
     
     Localized string for key “game.answer.correct” in table “Localizable.xcstrings”.
     */
    static var gameAnswerCorrect: LocalizedStringResource {
        LocalizedStringResource("game.answer.correct", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver value spoken for an answer crab that carries a wrong answer. Pairs with game.answer.correct. One word.
     
     Localized string for key “game.answer.wrong” in table “Localizable.xcstrings”.
     */
    static var gameAnswerWrong: LocalizedStringResource {
        LocalizedStringResource("game.answer.wrong", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver label for the running shell total, on the home screen header and the in-game counter. Shells are the game's collectible; the total only ever grows.
     
     Localized string for key “game.bubblesCollected %lld” in table “Localizable.xcstrings”.
     */
    static func gameBubblesCollected(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("game.bubblesCollected %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Encouragement on the result screen, picked by how well the player did. This is the lowest band (a weak score) — kind, never disappointed. Fits on one short line.
     
     Localized string for key “game.encouragement.0” in table “Localizable.xcstrings”.
     */
    static var gameEncouragement0: LocalizedStringResource {
        LocalizedStringResource("game.encouragement.0", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Encouragement on the result screen, band 2 of 10 (weak score). Kind and forward-looking. One short line.
     
     Localized string for key “game.encouragement.1” in table “Localizable.xcstrings”.
     */
    static var gameEncouragement1: LocalizedStringResource {
        LocalizedStringResource("game.encouragement.1", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Encouragement on the result screen, band 3 of 10 (below average). One short line.
     
     Localized string for key “game.encouragement.2” in table “Localizable.xcstrings”.
     */
    static var gameEncouragement2: LocalizedStringResource {
        LocalizedStringResource("game.encouragement.2", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Encouragement on the result screen, band 4 of 10 (below average). One short line.
     
     Localized string for key “game.encouragement.3” in table “Localizable.xcstrings”.
     */
    static var gameEncouragement3: LocalizedStringResource {
        LocalizedStringResource("game.encouragement.3", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Encouragement on the result screen, band 5 of 10 (average). One short line.
     
     Localized string for key “game.encouragement.4” in table “Localizable.xcstrings”.
     */
    static var gameEncouragement4: LocalizedStringResource {
        LocalizedStringResource("game.encouragement.4", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Encouragement on the result screen, band 6 of 10 (above average). One short line.
     
     Localized string for key “game.encouragement.5” in table “Localizable.xcstrings”.
     */
    static var gameEncouragement5: LocalizedStringResource {
        LocalizedStringResource("game.encouragement.5", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Encouragement on the result screen, band 7 of 10 (good). One short line.
     
     Localized string for key “game.encouragement.6” in table “Localizable.xcstrings”.
     */
    static var gameEncouragement6: LocalizedStringResource {
        LocalizedStringResource("game.encouragement.6", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Encouragement on the result screen, band 8 of 10 (very good). One short line.
     
     Localized string for key “game.encouragement.7” in table “Localizable.xcstrings”.
     */
    static var gameEncouragement7: LocalizedStringResource {
        LocalizedStringResource("game.encouragement.7", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Encouragement on the result screen, band 9 of 10 (nearly perfect). One short line.
     
     Localized string for key “game.encouragement.8” in table “Localizable.xcstrings”.
     */
    static var gameEncouragement8: LocalizedStringResource {
        LocalizedStringResource("game.encouragement.8", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Encouragement on the result screen, band 10 of 10 (just short of perfect). One short line.
     
     Localized string for key “game.encouragement.9” in table “Localizable.xcstrings”.
     */
    static var gameEncouragement9: LocalizedStringResource {
        LocalizedStringResource("game.encouragement.9", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Encouragement on the result screen for a perfect score. The strongest of the eleven bands — keep it clearly above game.encouragement.9.
     
     Localized string for key “game.encouragement.complete” in table “Localizable.xcstrings”.
     */
    static var gameEncouragementComplete: LocalizedStringResource {
        LocalizedStringResource("game.encouragement.complete", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Line under the title on the result screen when the level was completed by collecting every shell.
     
     Localized string for key “game.end.completionSubtitle” in table “Localizable.xcstrings”.
     */
    static var gameEndCompletionSubtitle: LocalizedStringResource {
        LocalizedStringResource("game.end.completionSubtitle", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title on the result screen when a level is finished. The argument is not text but the level's drawn badge ("+7", "×8", a stacked fraction). Put %@ wherever the badge belongs in your sentence — it may lead or follow.
     
     Localized string for key “game.end.completionTitle %@” in table “Localizable.xcstrings”.
     */
    static func gameEndCompletionTitle(_ arg1: String) -> LocalizedStringResource {
        LocalizedStringResource("game.end.completionTitle %@", defaultValue: "\(arg1)", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title on the result screen when the player ran out of lives. Matter-of-fact, not harsh — the audience is young.
     
     Localized string for key “game.end.gameOverTitle” in table “Localizable.xcstrings”.
     */
    static var gameEndGameOverTitle: LocalizedStringResource {
        LocalizedStringResource("game.end.gameOverTitle", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Button on the result screen that leaves the level and returns to the level menu.
     
     Localized string for key “game.end.mainMenu” in table “Localizable.xcstrings”.
     */
    static var gameEndMainMenu: LocalizedStringResource {
        LocalizedStringResource("game.end.mainMenu", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Button on the result screen that restarts the same level.
     
     Localized string for key “game.end.playAgain” in table “Localizable.xcstrings”.
     */
    static var gameEndPlayAgain: LocalizedStringResource {
        LocalizedStringResource("game.end.playAgain", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Badge on the result screen when the player beats their own best score for this level. Very little room — one short word.
     
     Localized string for key “game.highScore” in table “Localizable.xcstrings”.
     */
    static var gameHighScore: LocalizedStringResource {
        LocalizedStringResource("game.highScore", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Button on the level intro card that abandons the card and returns to the level menu.
     
     Localized string for key “game.intro.backToMainMenu” in table “Localizable.xcstrings”.
     */
    static var gameIntroBackToMainMenu: LocalizedStringResource {
        LocalizedStringResource("game.intro.backToMainMenu", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Primary button on the level intro card when a paused session for this level can be resumed instead of restarted.
     
     Localized string for key “game.intro.continue” in table “Localizable.xcstrings”.
     */
    static var gameIntroContinue: LocalizedStringResource {
        LocalizedStringResource("game.intro.continue", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Note on the level intro card telling the player that a half-finished run of this level is being kept for them.
     
     Localized string for key “game.intro.progressPaused” in table “Localizable.xcstrings”.
     */
    static var gameIntroProgressPaused: LocalizedStringResource {
        LocalizedStringResource("game.intro.progressPaused", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Primary button on the level intro card: begins the level.
     
     Localized string for key “game.intro.start” in table “Localizable.xcstrings”.
     */
    static var gameIntroStart: LocalizedStringResource {
        LocalizedStringResource("game.intro.start", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Primary button on the level intro card when the walkthrough has been armed, so pressing it starts the guided run.
     
     Localized string for key “game.intro.startTutorial” in table “Localizable.xcstrings”.
     */
    static var gameIntroStartTutorial: LocalizedStringResource {
        LocalizedStringResource("game.intro.startTutorial", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver label for the lives indicator during play. The value arrives already formatted and can be a half ("2.5"), so it is text rather than a number and cannot be pluralised.
     
     Localized string for key “game.livesRemaining %@” in table “Localizable.xcstrings”.
     */
    static func gameLivesRemaining(_ arg1: String) -> LocalizedStringResource {
        LocalizedStringResource("game.livesRemaining %@", defaultValue: "\(arg1)", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver label for the pause button during play.
     
     Localized string for key “game.pause” in table “Localizable.xcstrings”.
     */
    static var gamePause: LocalizedStringResource {
        LocalizedStringResource("game.pause", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver label announcing the sum currently on screen. The argument is the sum itself, written in digits and operators.
     
     Localized string for key “game.question %@” in table “Localizable.xcstrings”.
     */
    static func gameQuestion(_ arg1: String) -> LocalizedStringResource {
        LocalizedStringResource("game.question %@", defaultValue: "\(arg1)", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Second line of the streak boost banner, naming the two rewards. "2×" and "1.5×" are multipliers — keep the digits and use your language's decimal separator for 1.5.
     
     Localized string for key “game.streakBoost.subtitle” in table “Localizable.xcstrings”.
     */
    static var gameStreakBoostSubtitle: LocalizedStringResource {
        LocalizedStringResource("game.streakBoost.subtitle", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Banner shown when the player answers five in a row correctly. Celebratory, one short line.
     
     Localized string for key “game.streakBoost.title” in table “Localizable.xcstrings”.
     */
    static var gameStreakBoostTitle: LocalizedStringResource {
        LocalizedStringResource("game.streakBoost.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Label above the daily/weekly switch in the play-goal sheet.
     
     Localized string for key “goal.period” in table “Localizable.xcstrings”.
     */
    static var goalPeriod: LocalizedStringResource {
        LocalizedStringResource("goal.period", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Question in the play-goal sheet when the daily period is selected. Addressed to the player.
     
     Localized string for key “goal.promptDaily” in table “Localizable.xcstrings”.
     */
    static var goalPromptDaily: LocalizedStringResource {
        LocalizedStringResource("goal.promptDaily", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Question in the play-goal sheet when the weekly period is selected. Addressed to the player.
     
     Localized string for key “goal.promptWeekly” in table “Localizable.xcstrings”.
     */
    static var goalPromptWeekly: LocalizedStringResource {
        LocalizedStringResource("goal.promptWeekly", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Heading of the play-goal sheet reached from the home screen streak chip.
     
     Localized string for key “goal.title” in table “Localizable.xcstrings”.
     */
    static var goalTitle: LocalizedStringResource {
        LocalizedStringResource("goal.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Segment title for the daily play goal. Pairs with goalPeriod.weekly; both sit in one narrow segmented control.
     
     Localized string for key “goalPeriod.daily” in table “Localizable.xcstrings”.
     */
    static var goalPeriodDaily: LocalizedStringResource {
        LocalizedStringResource("goalPeriod.daily", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Segment title for the weekly play goal. Pairs with goalPeriod.daily; both sit in one narrow segmented control.
     
     Localized string for key “goalPeriod.weekly” in table “Localizable.xcstrings”.
     */
    static var goalPeriodWeekly: LocalizedStringResource {
        LocalizedStringResource("goalPeriod.weekly", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Countdown beside the next character on the home screen: how many more shells are needed. Extremely tight — the number plus at most one short word.
     
     Localized string for key “home.cardsRemaining %lld” in table “Localizable.xcstrings”.
     */
    static func homeCardsRemaining(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("home.cardsRemaining %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver label for a level tile in the menu. The argument is the level number.
     
     Localized string for key “home.levelAccessibility %lld” in table “Localizable.xcstrings”.
     */
    static func homeLevelAccessibility(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("home.levelAccessibility %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver label for the next-character prompt on the home screen. First argument is the shells still needed, second is the animal's name.
     
     Localized string for key “home.nextCharacter %lld %@” in table “Localizable.xcstrings”.
     */
    static func homeNextCharacter(_ arg1: Int, _ arg2: String) -> LocalizedStringResource {
        LocalizedStringResource("home.nextCharacter %lld %@", defaultValue: "\(arg1, specifier: "%lld")\(arg2)", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver value for a level tile that holds a paused run, saying how many shells are being kept.
     
     Localized string for key “home.pausedCards %lld” in table “Localizable.xcstrings”.
     */
    static func homePausedCards(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("home.pausedCards %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Heading of the mode pop-out for Fractions, where the three buttons choose the kind of fraction rather than an order.
     
     Localized string for key “info.mode.fractions.header” in table “Localizable.xcstrings”.
     */
    static var infoModeFractionsHeader: LocalizedStringResource {
        LocalizedStringResource("info.mode.fractions.header", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the Fractions "Multiple" button: the sums may ask for several parts of a whole, such as 3/4.
     
     Localized string for key “info.mode.fractions.multiple” in table “Localizable.xcstrings”.
     */
    static var infoModeFractionsMultiple: LocalizedStringResource {
        LocalizedStringResource("info.mode.fractions.multiple", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the Fractions "Single" button: the sums always ask for one part of a whole, such as 1/4.
     
     Localized string for key “info.mode.fractions.single” in table “Localizable.xcstrings”.
     */
    static var infoModeFractionsSingle: LocalizedStringResource {
        LocalizedStringResource("info.mode.fractions.single", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Heading of the pop-out that explains the three order buttons, for every topic except Fractions and Percentages.
     
     Localized string for key “info.mode.header” in table “Localizable.xcstrings”.
     */
    static var infoModeHeader: LocalizedStringResource {
        LocalizedStringResource("info.mode.header", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the Mixed button: sums are drawn from this level and every level below it. One short line in the pop-out.
     
     Localized string for key “info.mode.mixed” in table “Localizable.xcstrings”.
     */
    static var infoModeMixed: LocalizedStringResource {
        LocalizedStringResource("info.mode.mixed", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the Order button: the sums come in a fixed sequence. One short line in the pop-out.
     
     Localized string for key “info.mode.order” in table “Localizable.xcstrings”.
     */
    static var infoModeOrder: LocalizedStringResource {
        LocalizedStringResource("info.mode.order", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the Percentages "Decimal" button: answers may have a decimal fraction.
     
     Localized string for key “info.mode.percentages.decimal” in table “Localizable.xcstrings”.
     */
    static var infoModePercentagesDecimal: LocalizedStringResource {
        LocalizedStringResource("info.mode.percentages.decimal", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Heading of the mode pop-out for Percentages, where the three buttons choose the kind of answer rather than an order.
     
     Localized string for key “info.mode.percentages.header” in table “Localizable.xcstrings”.
     */
    static var infoModePercentagesHeader: LocalizedStringResource {
        LocalizedStringResource("info.mode.percentages.header", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the Percentages "Whole" button: every answer is a whole number.
     
     Localized string for key “info.mode.percentages.whole” in table “Localizable.xcstrings”.
     */
    static var infoModePercentagesWhole: LocalizedStringResource {
        LocalizedStringResource("info.mode.percentages.whole", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the Random button: the sums of this level come shuffled. One short line in the pop-out.
     
     Localized string for key “info.mode.random” in table “Localizable.xcstrings”.
     */
    static var infoModeRandom: LocalizedStringResource {
        LocalizedStringResource("info.mode.random", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the fourth Supermix square: which operations it draws from. A list of operation names.
     
     Localized string for key “info.super.all” in table “Localizable.xcstrings”.
     */
    static var infoSuperAll: LocalizedStringResource {
        LocalizedStringResource("info.super.all", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the first Supermix square: which operations it draws from. A list of operation names.
     
     Localized string for key “info.super.basic” in table “Localizable.xcstrings”.
     */
    static var infoSuperBasic: LocalizedStringResource {
        LocalizedStringResource("info.super.basic", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the third Supermix square: which operations it draws from. A list of operation names.
     
     Localized string for key “info.super.fraction” in table “Localizable.xcstrings”.
     */
    static var infoSuperFraction: LocalizedStringResource {
        LocalizedStringResource("info.super.fraction", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the second Supermix square: which operations it draws from. A list of operation names.
     
     Localized string for key “info.super.times” in table “Localizable.xcstrings”.
     */
    static var infoSuperTimes: LocalizedStringResource {
        LocalizedStringResource("info.super.times", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Heading of the pop-out that explains what the six topics practise.
     
     Localized string for key “info.topic.header” in table “Localizable.xcstrings”.
     */
    static var infoTopicHeader: LocalizedStringResource {
        LocalizedStringResource("info.topic.header", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver label for the flag button that opens the language menu.
     
     Localized string for key “language.select” in table “Localizable.xcstrings”.
     */
    static var languageSelect: LocalizedStringResource {
        LocalizedStringResource("language.select", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     First line of the level intro card for Addition, saying what the sums do. Emphasise the operation with Markdown **bold**, wherever it falls in your sentence.
     
     Localized string for key “levelIntro.addition.intro” in table “Localizable.xcstrings”.
     */
    static var levelIntroAdditionIntro: LocalizedStringResource {
        LocalizedStringResource("levelIntro.addition.intro", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title on the level intro card for an Addition level. The argument is the number being added.
     
     Localized string for key “levelIntro.addition.title %lld” in table “Localizable.xcstrings”.
     */
    static func levelIntroAdditionTitle(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("levelIntro.addition.title %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Third line of the level intro card: the most shells this level can yield. Emphasise the count and its noun with Markdown **bold**.
     
     Localized string for key “levelIntro.cardsBullet %lld” in table “Localizable.xcstrings”.
     */
    static func levelIntroCardsBullet(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("levelIntro.cardsBullet %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     First line of the level intro card for Fractions. Emphasise the operation with Markdown **bold**, wherever it falls in your sentence.
     
     Localized string for key “levelIntro.fractions.intro” in table “Localizable.xcstrings”.
     */
    static var levelIntroFractionsIntro: LocalizedStringResource {
        LocalizedStringResource("levelIntro.fractions.intro", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title on the level intro card for a Fractions level. The argument is the denominator, so the level is about dividing by it.
     
     Localized string for key “levelIntro.fractions.title %lld” in table “Localizable.xcstrings”.
     */
    static func levelIntroFractionsTitle(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("levelIntro.fractions.title %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Second line of the level intro card for Supermix and Mixed: the questions are drawn from level 1 up to this level. Emphasise the level reference with Markdown **bold**.
     
     Localized string for key “levelIntro.levelRange %lld” in table “Localizable.xcstrings”.
     */
    static func levelIntroLevelRange(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("levelIntro.levelRange %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Second line of the level intro card when the level is 1, so there is no range to name. Emphasise the level reference with Markdown **bold**.
     
     Localized string for key “levelIntro.levelRange.first” in table “Localizable.xcstrings”.
     */
    static var levelIntroLevelRangeFirst: LocalizedStringResource {
        LocalizedStringResource("levelIntro.levelRange.first", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     First line of the level intro card for Supermix, listing the operations it mixes. Emphasise the opening phrase with Markdown **bold**.
     
     Localized string for key “levelIntro.mixed.intro” in table “Localizable.xcstrings”.
     */
    static var levelIntroMixedIntro: LocalizedStringResource {
        LocalizedStringResource("levelIntro.mixed.intro", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title on the level intro card for a Supermix level. The argument is the level number. "Supermix" is the topic's name — see topic.mixed and keep the two identical.
     
     Localized string for key “levelIntro.mixed.title %lld” in table “Localizable.xcstrings”.
     */
    static func levelIntroMixedTitle(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("levelIntro.mixed.title %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Second line of the level intro card for Fractions with "Single" selected. Emphasise the key phrase with Markdown **bold**.
     
     Localized string for key “levelIntro.mode.fractions.order” in table “Localizable.xcstrings”.
     */
    static var levelIntroModeFractionsOrder: LocalizedStringResource {
        LocalizedStringResource("levelIntro.mode.fractions.order", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Second line of the level intro card for Fractions with "Multiple" selected. Emphasise the key phrase with Markdown **bold**.
     
     Localized string for key “levelIntro.mode.fractions.random” in table “Localizable.xcstrings”.
     */
    static var levelIntroModeFractionsRandom: LocalizedStringResource {
        LocalizedStringResource("levelIntro.mode.fractions.random", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Second line of the level intro card when the Order button is selected. Emphasise the key phrase with Markdown **bold**.
     
     Localized string for key “levelIntro.mode.order” in table “Localizable.xcstrings”.
     */
    static var levelIntroModeOrder: LocalizedStringResource {
        LocalizedStringResource("levelIntro.mode.order", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Second line of the level intro card for Percentages with "Whole" selected. Emphasise the key phrase with Markdown **bold**.
     
     Localized string for key “levelIntro.mode.percentages.order” in table “Localizable.xcstrings”.
     */
    static var levelIntroModePercentagesOrder: LocalizedStringResource {
        LocalizedStringResource("levelIntro.mode.percentages.order", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Second line of the level intro card for Percentages with "Decimal" selected. Emphasise the key phrase with Markdown **bold**.
     
     Localized string for key “levelIntro.mode.percentages.random” in table “Localizable.xcstrings”.
     */
    static var levelIntroModePercentagesRandom: LocalizedStringResource {
        LocalizedStringResource("levelIntro.mode.percentages.random", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Second line of the level intro card when the Random button is selected. Emphasise the key phrase with Markdown **bold**.
     
     Localized string for key “levelIntro.mode.random” in table “Localizable.xcstrings”.
     */
    static var levelIntroModeRandom: LocalizedStringResource {
        LocalizedStringResource("levelIntro.mode.random", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     First line of the level intro card for Percentages. Emphasise the operation with Markdown **bold**, wherever it falls in your sentence.
     
     Localized string for key “levelIntro.percentages.intro” in table “Localizable.xcstrings”.
     */
    static var levelIntroPercentagesIntro: LocalizedStringResource {
        LocalizedStringResource("levelIntro.percentages.intro", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title on the level intro card for a Percentages level. The argument already carries the percent sign ("25%"), so no percent sign belongs in this string.
     
     Localized string for key “levelIntro.percentages.title %@” in table “Localizable.xcstrings”.
     */
    static func levelIntroPercentagesTitle(_ arg1: String) -> LocalizedStringResource {
        LocalizedStringResource("levelIntro.percentages.title %@", defaultValue: "\(arg1)", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     First line of the level intro card for Subtraction. Emphasise the operation with Markdown **bold**, wherever it falls in your sentence.
     
     Localized string for key “levelIntro.subtraction.intro” in table “Localizable.xcstrings”.
     */
    static var levelIntroSubtractionIntro: LocalizedStringResource {
        LocalizedStringResource("levelIntro.subtraction.intro", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title on the level intro card for a Subtraction level. The argument is the number being taken away.
     
     Localized string for key “levelIntro.subtraction.title %lld” in table “Localizable.xcstrings”.
     */
    static func levelIntroSubtractionTitle(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("levelIntro.subtraction.title %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     First line of the level intro card for Tables. Emphasise the operation with Markdown **bold**, wherever it falls in your sentence.
     
     Localized string for key “levelIntro.tables.intro” in table “Localizable.xcstrings”.
     */
    static var levelIntroTablesIntro: LocalizedStringResource {
        LocalizedStringResource("levelIntro.tables.intro", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title on the level intro card for a Tables level. The argument is the multiplication table.
     
     Localized string for key “levelIntro.tables.title %lld” in table “Localizable.xcstrings”.
     */
    static func levelIntroTablesTitle(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("levelIntro.tables.title %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Badge on a level tile whose maximum score has been reached. All caps by design and very narrow — an abbreviation is fine.
     
     Localized string for key “menu.maximumCount” in table “Localizable.xcstrings”.
     */
    static var menuMaximumCount: LocalizedStringResource {
        LocalizedStringResource("menu.maximumCount", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver label spelling out the MAX badge: how often the level's maximum was reached.
     
     Localized string for key “menu.maximumCount.accessibility %lld” in table “Localizable.xcstrings”.
     */
    static func menuMaximumCountAccessibility(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("menu.maximumCount.accessibility %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Heading above the levels that come after the free ones.
     
     Localized string for key “menu.moreLevels” in table “Localizable.xcstrings”.
     */
    static var menuMoreLevels: LocalizedStringResource {
        LocalizedStringResource("menu.moreLevels", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Heading above the level range that only Premium opens.
     
     Localized string for key “menu.premiumLevels” in table “Localizable.xcstrings”.
     */
    static var menuPremiumLevels: LocalizedStringResource {
        LocalizedStringResource("menu.premiumLevels", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Pointer above the first playable level tile for a player who has not started yet. Two or three words.
     
     Localized string for key “menu.startHere” in table “Localizable.xcstrings”.
     */
    static var menuStartHere: LocalizedStringResource {
        LocalizedStringResource("menu.startHere", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Button under the locked levels that opens the Premium screen.
     
     Localized string for key “menu.unlockWithPremium” in table “Localizable.xcstrings”.
     */
    static var menuUnlockWithPremium: LocalizedStringResource {
        LocalizedStringResource("menu.unlockWithPremium", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Replaces mode.random on Fractions levels: sums about several parts of a whole. Sits in a narrow pill.
     
     Localized string for key “mode.fractions.multiple” in table “Localizable.xcstrings”.
     */
    static var modeFractionsMultiple: LocalizedStringResource {
        LocalizedStringResource("mode.fractions.multiple", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Replaces mode.order on Fractions levels: sums about one part of a whole. Sits in a narrow pill.
     
     Localized string for key “mode.fractions.single” in table “Localizable.xcstrings”.
     */
    static var modeFractionsSingle: LocalizedStringResource {
        LocalizedStringResource("mode.fractions.single", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Label on the third of three order buttons under a level: drawn from lower levels too. Sits in a narrow pill.
     
     Localized string for key “mode.mixed” in table “Localizable.xcstrings”.
     */
    static var modeMixed: LocalizedStringResource {
        LocalizedStringResource("mode.mixed", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Label on the first of three order buttons under a level: fixed sequence. Sits in a narrow pill.
     
     Localized string for key “mode.order” in table “Localizable.xcstrings”.
     */
    static var modeOrder: LocalizedStringResource {
        LocalizedStringResource("mode.order", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Replaces mode.random on Percentages levels: answers may have decimals. Sits in a narrow pill.
     
     Localized string for key “mode.percentages.decimal” in table “Localizable.xcstrings”.
     */
    static var modePercentagesDecimal: LocalizedStringResource {
        LocalizedStringResource("mode.percentages.decimal", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Replaces mode.order on Percentages levels: answers without decimals. Sits in a narrow pill.
     
     Localized string for key “mode.percentages.whole” in table “Localizable.xcstrings”.
     */
    static var modePercentagesWhole: LocalizedStringResource {
        LocalizedStringResource("mode.percentages.whole", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Label on the second of three order buttons under a level: shuffled. Sits in a narrow pill.
     
     Localized string for key “mode.random” in table “Localizable.xcstrings”.
     */
    static var modeRandom: LocalizedStringResource {
        LocalizedStringResource("mode.random", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Placeholder inside the name text field.
     
     Localized string for key “name.placeholder” in table “Localizable.xcstrings”.
     */
    static var namePlaceholder: LocalizedStringResource {
        LocalizedStringResource("name.placeholder", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Prompt above the name field on the home screen when no name has been given yet. Addressed to the child.
     
     Localized string for key “name.whatsYourName” in table “Localizable.xcstrings”.
     */
    static var nameWhatsYourName: LocalizedStringResource {
        LocalizedStringResource("name.whatsYourName", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification body when a new animal is nearly earned. The argument is the animal's name.
     
     Localized string for key “notif.animal.body %@” in table “Localizable.xcstrings”.
     */
    static func notifAnimalBody(_ arg1: String) -> LocalizedStringResource {
        LocalizedStringResource("notif.animal.body %@", defaultValue: "\(arg1)", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification title when a new animal is nearly earned. The argument is the shells still needed.
     
     Localized string for key “notif.animal.title %lld” in table “Localizable.xcstrings”.
     */
    static func notifAnimalTitle(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("notif.animal.title %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification body inviting a session. The argument is the player's own daily goal in minutes.
     
     Localized string for key “notif.cards.body %lld” in table “Localizable.xcstrings”.
     */
    static func notifCardsBody(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("notif.cards.body %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification title celebrating a shell milestone. The argument is the player's total.
     
     Localized string for key “notif.cards.title %lld” in table “Localizable.xcstrings”.
     */
    static func notifCardsTitle(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("notif.cards.title %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification body after a long absence. Warm, never guilt-inducing.
     
     Localized string for key “notif.comeback.body” in table “Localizable.xcstrings”.
     */
    static var notifComebackBody: LocalizedStringResource {
        LocalizedStringResource("notif.comeback.body", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification title after a long absence. Warm, never guilt-inducing.
     
     Localized string for key “notif.comeback.title” in table “Localizable.xcstrings”.
     */
    static var notifComebackTitle: LocalizedStringResource {
        LocalizedStringResource("notif.comeback.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification body on the eve of a third streak day. The argument is the player's own daily goal in minutes, used attributively ("a 5-minute session").
     
     Localized string for key “notif.day3.body %lld” in table “Localizable.xcstrings”.
     */
    static func notifDay3Body(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("notif.day3.body %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification title on the eve of a third streak day.
     
     Localized string for key “notif.day3.title” in table “Localizable.xcstrings”.
     */
    static var notifDay3Title: LocalizedStringResource {
        LocalizedStringResource("notif.day3.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification body introducing Premium. The argument is how many levels every topic then has.
     
     Localized string for key “notif.premium.body %lld” in table “Localizable.xcstrings”.
     */
    static func notifPremiumBody(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("notif.premium.body %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification title introducing Premium.
     
     Localized string for key “notif.premium.title” in table “Localizable.xcstrings”.
     */
    static var notifPremiumTitle: LocalizedStringResource {
        LocalizedStringResource("notif.premium.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification body after a very long absence. The argument is the number of days since the last session.
     
     Localized string for key “notif.reactivate.body %lld” in table “Localizable.xcstrings”.
     */
    static func notifReactivateBody(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("notif.reactivate.body %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification title after a very long absence.
     
     Localized string for key “notif.reactivate.title” in table “Localizable.xcstrings”.
     */
    static var notifReactivateTitle: LocalizedStringResource {
        LocalizedStringResource("notif.reactivate.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification body asking the player to keep the streak alive. The argument is their own daily goal in minutes.
     
     Localized string for key “notif.streak.body %lld” in table “Localizable.xcstrings”.
     */
    static func notifStreakBody(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("notif.streak.body %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification title praising a running streak. The argument is the streak length in days, used attributively ("your 4-day streak").
     
     Localized string for key “notif.streak.title %lld” in table “Localizable.xcstrings”.
     */
    static func notifStreakTitle(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("notif.streak.title %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification body for the weekly recap. The argument is the player's all-time shell total.
     
     Localized string for key “notif.weekly.body %lld” in table “Localizable.xcstrings”.
     */
    static func notifWeeklyBody(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("notif.weekly.body %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Push notification title for the weekly recap. The argument is the shells collected this week.
     
     Localized string for key “notif.weekly.title %lld” in table “Localizable.xcstrings”.
     */
    static func notifWeeklyTitle(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("notif.weekly.title %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the third difficulty card in terms of what the sums will be like.
     
     Localized string for key “onboarding.level.advanced.subtitle” in table “Localizable.xcstrings”.
     */
    static var onboardingLevelAdvancedSubtitle: LocalizedStringResource {
        LocalizedStringResource("onboarding.level.advanced.subtitle", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Third of three difficulty cards: the child is already confident. Pairs with onboarding.level.advanced.subtitle.
     
     Localized string for key “onboarding.level.advanced.title” in table “Localizable.xcstrings”.
     */
    static var onboardingLevelAdvancedTitle: LocalizedStringResource {
        LocalizedStringResource("onboarding.level.advanced.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the first difficulty card in terms of what the sums will be like.
     
     Localized string for key “onboarding.level.beginner.subtitle” in table “Localizable.xcstrings”.
     */
    static var onboardingLevelBeginnerSubtitle: LocalizedStringResource {
        LocalizedStringResource("onboarding.level.beginner.subtitle", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     First of three difficulty cards: the child is new to this topic. Pairs with onboarding.level.beginner.subtitle.
     
     Localized string for key “onboarding.level.beginner.title” in table “Localizable.xcstrings”.
     */
    static var onboardingLevelBeginnerTitle: LocalizedStringResource {
        LocalizedStringResource("onboarding.level.beginner.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the second difficulty card in terms of what the sums will be like.
     
     Localized string for key “onboarding.level.intermediate.subtitle” in table “Localizable.xcstrings”.
     */
    static var onboardingLevelIntermediateSubtitle: LocalizedStringResource {
        LocalizedStringResource("onboarding.level.intermediate.subtitle", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Second of three difficulty cards: the child has some practice. Pairs with onboarding.level.intermediate.subtitle.
     
     Localized string for key “onboarding.level.intermediate.title” in table “Localizable.xcstrings”.
     */
    static var onboardingLevelIntermediateTitle: LocalizedStringResource {
        LocalizedStringResource("onboarding.level.intermediate.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Line under the starting-difficulty headline. The argument is the topic the child just chose, already localized — so it arrives in whatever case topic.* uses.
     
     Localized string for key “onboarding.level.subtitle %@” in table “Localizable.xcstrings”.
     */
    static func onboardingLevelSubtitle(_ arg1: String) -> LocalizedStringResource {
        LocalizedStringResource("onboarding.level.subtitle %@", defaultValue: "\(arg1)", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Headline on the starting-difficulty onboarding screen. Addressed to the child, and deliberately unintimidating.
     
     Localized string for key “onboarding.level.title” in table “Localizable.xcstrings”.
     */
    static var onboardingLevelTitle: LocalizedStringResource {
        LocalizedStringResource("onboarding.level.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Line under the first onboarding headline, leading into the name field.
     
     Localized string for key “onboarding.name.subtitle” in table “Localizable.xcstrings”.
     */
    static var onboardingNameSubtitle: LocalizedStringResource {
        LocalizedStringResource("onboarding.name.subtitle", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Headline on the first onboarding screen. Set in a very large font; the line break in the source is a deliberate balance point — put yours where your sentence breaks best, or drop it.
     
     Localized string for key “onboarding.name.title” in table “Localizable.xcstrings”.
     */
    static var onboardingNameTitle: LocalizedStringResource {
        LocalizedStringResource("onboarding.name.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Line under the topic-choice headline.
     
     Localized string for key “onboarding.subject.subtitle” in table “Localizable.xcstrings”.
     */
    static var onboardingSubjectSubtitle: LocalizedStringResource {
        LocalizedStringResource("onboarding.subject.subtitle", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Headline on the topic-choice onboarding screen. Addressed to the child.
     
     Localized string for key “onboarding.subject.title” in table “Localizable.xcstrings”.
     */
    static var onboardingSubjectTitle: LocalizedStringResource {
        LocalizedStringResource("onboarding.subject.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Confirmation shown when the adult check passes.
     
     Localized string for key “parentGate.approved” in table “Localizable.xcstrings”.
     */
    static var parentGateApproved: LocalizedStringResource {
        LocalizedStringResource("parentGate.approved", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Counter showing failed attempts at the adult check. First number is attempts used, second the total allowed.
     
     Localized string for key “parentGate.attempts %lld %lld” in table “Localizable.xcstrings”.
     */
    static func parentGateAttempts(_ arg1: Int, _ arg2: Int) -> LocalizedStringResource {
        LocalizedStringResource("parentGate.attempts %lld %lld", defaultValue: "\(arg1, specifier: "%lld")\(arg2, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Instruction in the adult check: press and hold a named shape. First argument is the shape's name from parentGate.shape.*, second the number of seconds.
     
     Localized string for key “parentGate.holdInstruction %@ %lld” in table “Localizable.xcstrings”.
     */
    static func parentGateHoldInstruction(_ arg1: String, seconds: Int) -> LocalizedStringResource {
        LocalizedStringResource("parentGate.holdInstruction %@ %lld", defaultValue: "\(arg1)\(seconds, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Counter under the hold instruction, counting the seconds held.
     
     Localized string for key “parentGate.holdProgress %lld” in table “Localizable.xcstrings”.
     */
    static func parentGateHoldProgress(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("parentGate.holdProgress %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Shape name used inside the adult-check instruction and as the shape's VoiceOver label. Lower case, because it appears mid-sentence.
     
     Localized string for key “parentGate.shape.circle” in table “Localizable.xcstrings”.
     */
    static var parentGateShapeCircle: LocalizedStringResource {
        LocalizedStringResource("parentGate.shape.circle", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Shape name used inside the adult-check instruction and as the shape's VoiceOver label. Lower case, because it appears mid-sentence.
     
     Localized string for key “parentGate.shape.diamond” in table “Localizable.xcstrings”.
     */
    static var parentGateShapeDiamond: LocalizedStringResource {
        LocalizedStringResource("parentGate.shape.diamond", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Shape name used inside the adult-check instruction and as the shape's VoiceOver label. Lower case, because it appears mid-sentence.
     
     Localized string for key “parentGate.shape.heart” in table “Localizable.xcstrings”.
     */
    static var parentGateShapeHeart: LocalizedStringResource {
        LocalizedStringResource("parentGate.shape.heart", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Shape name used inside the adult-check instruction and as the shape's VoiceOver label. Lower case, because it appears mid-sentence.
     
     Localized string for key “parentGate.shape.hexagon” in table “Localizable.xcstrings”.
     */
    static var parentGateShapeHexagon: LocalizedStringResource {
        LocalizedStringResource("parentGate.shape.hexagon", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Shape name used inside the adult-check instruction and as the shape's VoiceOver label. Lower case, because it appears mid-sentence.
     
     Localized string for key “parentGate.shape.plus” in table “Localizable.xcstrings”.
     */
    static var parentGateShapePlus: LocalizedStringResource {
        LocalizedStringResource("parentGate.shape.plus", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Shape name used inside the adult-check instruction and as the shape's VoiceOver label. Lower case, because it appears mid-sentence.
     
     Localized string for key “parentGate.shape.square” in table “Localizable.xcstrings”.
     */
    static var parentGateShapeSquare: LocalizedStringResource {
        LocalizedStringResource("parentGate.shape.square", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Shape name used inside the adult-check instruction and as the shape's VoiceOver label. Lower case, because it appears mid-sentence.
     
     Localized string for key “parentGate.shape.star” in table “Localizable.xcstrings”.
     */
    static var parentGateShapeStar: LocalizedStringResource {
        LocalizedStringResource("parentGate.shape.star", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Shape name used inside the adult-check instruction and as the shape's VoiceOver label. Lower case, because it appears mid-sentence.
     
     Localized string for key “parentGate.shape.triangle” in table “Localizable.xcstrings”.
     */
    static var parentGateShapeTriangle: LocalizedStringResource {
        LocalizedStringResource("parentGate.shape.triangle", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains to the adult why the check exists, immediately under parentGate.title.
     
     Localized string for key “parentGate.subtitle” in table “Localizable.xcstrings”.
     */
    static var parentGateSubtitle: LocalizedStringResource {
        LocalizedStringResource("parentGate.subtitle", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Instruction in the adult check: tap a named shape a number of times. First argument is the number of taps, second the shape's name from parentGate.shape.*.
     
     Localized string for key “parentGate.tapInstruction %lld %@” in table “Localizable.xcstrings”.
     */
    static func parentGateTapInstruction(times: Int, _ arg2: String) -> LocalizedStringResource {
        LocalizedStringResource("parentGate.tapInstruction %lld %@", defaultValue: "\(times, specifier: "%lld")\(arg2)", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Counter under the tap instruction. First number is taps still to go, second the total asked for.
     
     Localized string for key “parentGate.tapProgress %lld %lld” in table “Localizable.xcstrings”.
     */
    static func parentGateTapProgress(_ arg1: Int, _ arg2: Int) -> LocalizedStringResource {
        LocalizedStringResource("parentGate.tapProgress %lld %lld", defaultValue: "\(arg1, specifier: "%lld")\(arg2, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title of the check that keeps children out of the purchase flow. Addressed to an adult, so the register is adult throughout this screen.
     
     Localized string for key “parentGate.title” in table “Localizable.xcstrings”.
     */
    static var parentGateTitle: LocalizedStringResource {
        LocalizedStringResource("parentGate.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Status under a character still to be earned. The argument is the shell total that opens it.
     
     Localized string for key “premium.availableAt %lld” in table “Localizable.xcstrings”.
     */
    static func premiumAvailableAt(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("premium.availableAt %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Status under a character that needs nothing to play.
     
     Localized string for key “premium.availableFromStart” in table “Localizable.xcstrings”.
     */
    static var premiumAvailableFromStart: LocalizedStringResource {
        LocalizedStringResource("premium.availableFromStart", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver label for the whole unlock celebration. The argument is the animal's name.
     
     Localized string for key “premium.characterUnlocked %@” in table “Localizable.xcstrings”.
     */
    static func premiumCharacterUnlocked(_ arg1: String) -> LocalizedStringResource {
        LocalizedStringResource("premium.characterUnlocked %@", defaultValue: "\(arg1)", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Status under a character showing how many shells the player has so far.
     
     Localized string for key “premium.earnedCards %lld” in table “Localizable.xcstrings”.
     */
    static func premiumEarnedCards(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("premium.earnedCards %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Status under a character that can only ever be opened by Premium, never by collecting.
     
     Localized string for key “premium.exclusiveWithPremium” in table “Localizable.xcstrings”.
     */
    static var premiumExclusiveWithPremium: LocalizedStringResource {
        LocalizedStringResource("premium.exclusiveWithPremium", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the second Premium selling point. The argument is the total number of animals in the game — always 10, so write the plural form; it is never one.
     
     Localized string for key “premium.feature.animals.subtitle %lld” in table “Localizable.xcstrings”.
     */
    static func premiumFeatureAnimalsSubtitle(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("premium.feature.animals.subtitle %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Second selling point on the Premium screen: every animal becomes playable.
     
     Localized string for key “premium.feature.animals.title” in table “Localizable.xcstrings”.
     */
    static var premiumFeatureAnimalsTitle: LocalizedStringResource {
        LocalizedStringResource("premium.feature.animals.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the first Premium selling point in one line.
     
     Localized string for key “premium.feature.levels.subtitle” in table “Localizable.xcstrings”.
     */
    static var premiumFeatureLevelsSubtitle: LocalizedStringResource {
        LocalizedStringResource("premium.feature.levels.subtitle", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     First selling point on the Premium screen. The argument is how many levels each topic then holds — always 99, so write the plural form; it is never one.
     
     Localized string for key “premium.feature.levels.title %lld” in table “Localizable.xcstrings”.
     */
    static func premiumFeatureLevelsTitle(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("premium.feature.levels.title %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Explains the third Premium selling point in one line.
     
     Localized string for key “premium.feature.noAds.subtitle” in table “Localizable.xcstrings”.
     */
    static var premiumFeatureNoAdsSubtitle: LocalizedStringResource {
        LocalizedStringResource("premium.feature.noAds.subtitle", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Third selling point on the Premium screen.
     
     Localized string for key “premium.feature.noAds.title” in table “Localizable.xcstrings”.
     */
    static var premiumFeatureNoAdsTitle: LocalizedStringResource {
        LocalizedStringResource("premium.feature.noAds.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Reassurance under the Premium button: a single purchase, no subscription.
     
     Localized string for key “premium.oneTime” in table “Localizable.xcstrings”.
     */
    static var premiumOneTime: LocalizedStringResource {
        LocalizedStringResource("premium.oneTime", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Button that restores an earlier purchase.
     
     Localized string for key “premium.restore” in table “Localizable.xcstrings”.
     */
    static var premiumRestore: LocalizedStringResource {
        LocalizedStringResource("premium.restore", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Button that closes the Premium screen and starts playing.
     
     Localized string for key “premium.start” in table “Localizable.xcstrings”.
     */
    static var premiumStart: LocalizedStringResource {
        LocalizedStringResource("premium.start", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Shown when the App Store cannot be reached. Addressed to an adult.
     
     Localized string for key “premium.storeUnavailable” in table “Localizable.xcstrings”.
     */
    static var premiumStoreUnavailable: LocalizedStringResource {
        LocalizedStringResource("premium.storeUnavailable", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Main call to action on the Premium screen when no price is available yet.
     
     Localized string for key “premium.unlock” in table “Localizable.xcstrings”.
     */
    static var premiumUnlock: LocalizedStringResource {
        LocalizedStringResource("premium.unlock", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Banner across the celebration screen when a new character is earned. All caps by design — use whatever casing carries that emphasis in your language, and note the line wraps to at most two lines.
     
     Localized string for key “premium.unlockBanner” in table “Localizable.xcstrings”.
     */
    static var premiumUnlockBanner: LocalizedStringResource {
        LocalizedStringResource("premium.unlockBanner", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Alternative call to action: open a character with collected shells instead of money.
     
     Localized string for key “premium.unlockWithCards” in table “Localizable.xcstrings”.
     */
    static var premiumUnlockWithCards: LocalizedStringResource {
        LocalizedStringResource("premium.unlockWithCards", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Main call to action on the Premium screen. The argument is the App Store price, already formatted in the store's own currency and locale — never reformat it.
     
     Localized string for key “premium.unlockWithPrice %@” in table “Localizable.xcstrings”.
     */
    static func premiumUnlockWithPrice(_ arg1: String) -> LocalizedStringResource {
        LocalizedStringResource("premium.unlockWithPrice %@", defaultValue: "\(arg1)", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Status under a character that Premium has already opened.
     
     Localized string for key “premium.unlockedWithPremium” in table “Localizable.xcstrings”.
     */
    static var premiumUnlockedWithPremium: LocalizedStringResource {
        LocalizedStringResource("premium.unlockedWithPremium", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title on the result screen when the level was finished.
     
     Localized string for key “result.complete” in table “Localizable.xcstrings”.
     */
    static var resultComplete: LocalizedStringResource {
        LocalizedStringResource("result.complete", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title on the result screen when the player paused out of the level.
     
     Localized string for key “result.stopped” in table “Localizable.xcstrings”.
     */
    static var resultStopped: LocalizedStringResource {
        LocalizedStringResource("result.stopped", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title on the result screen when the run earned a new character.
     
     Localized string for key “result.unlocked” in table “Localizable.xcstrings”.
     */
    static var resultUnlocked: LocalizedStringResource {
        LocalizedStringResource("result.unlocked", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Section heading for the character picker in settings.
     
     Localized string for key “settings.character” in table “Localizable.xcstrings”.
     */
    static var settingsCharacter: LocalizedStringResource {
        LocalizedStringResource("settings.character", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Footnote under the character picker, explaining that a character also changes the game's colours.
     
     Localized string for key “settings.characterInfo” in table “Localizable.xcstrings”.
     */
    static var settingsCharacterInfo: LocalizedStringResource {
        LocalizedStringResource("settings.characterInfo", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Stepper label for a freely chosen daily goal. The argument is the minutes; the unit is abbreviated because the row is narrow.
     
     Localized string for key “settings.customMinutes %lld” in table “Localizable.xcstrings”.
     */
    static func settingsCustomMinutes(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("settings.customMinutes %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Label above the row of preset daily goals.
     
     Localized string for key “settings.dailyGoal” in table “Localizable.xcstrings”.
     */
    static var settingsDailyGoal: LocalizedStringResource {
        LocalizedStringResource("settings.dailyGoal", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Footnote under the play goals. The argument is the daily goal a new player starts with, in minutes — always 5, so write the plural form; it is never one.
     
     Localized string for key “settings.goalInfo %lld” in table “Localizable.xcstrings”.
     */
    static func settingsGoalInfo(_ arg1: Int) -> LocalizedStringResource {
        LocalizedStringResource("settings.goalInfo %lld", defaultValue: "\(arg1, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Label for the background-music switch, and its VoiceOver label.
     
     Localized string for key “settings.music” in table “Localizable.xcstrings”.
     */
    static var settingsMusic: LocalizedStringResource {
        LocalizedStringResource("settings.music", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Section heading for the play-time goals in settings.
     
     Localized string for key “settings.playGoals” in table “Localizable.xcstrings”.
     */
    static var settingsPlayGoals: LocalizedStringResource {
        LocalizedStringResource("settings.playGoals", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Shown in settings once Premium has been bought, in place of the offer.
     
     Localized string for key “settings.premiumUnlocked” in table “Localizable.xcstrings”.
     */
    static var settingsPremiumUnlocked: LocalizedStringResource {
        LocalizedStringResource("settings.premiumUnlocked", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Section heading for the audio switches in settings.
     
     Localized string for key “settings.sound” in table “Localizable.xcstrings”.
     */
    static var settingsSound: LocalizedStringResource {
        LocalizedStringResource("settings.sound", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Label for the switch that covers both music and effects, and its VoiceOver label.
     
     Localized string for key “settings.soundEffects” in table “Localizable.xcstrings”.
     */
    static var settingsSoundEffects: LocalizedStringResource {
        LocalizedStringResource("settings.soundEffects", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Footnote under the audio switches, reassuring the player that muting changes nothing about the game.
     
     Localized string for key “settings.soundInfo” in table “Localizable.xcstrings”.
     */
    static var settingsSoundInfo: LocalizedStringResource {
        LocalizedStringResource("settings.soundInfo", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Label for the switch that has the sums read aloud. Only offered when the device has a voice for the chosen language.
     
     Localized string for key “settings.spokenSums” in table “Localizable.xcstrings”.
     */
    static var settingsSpokenSums: LocalizedStringResource {
        LocalizedStringResource("settings.spokenSums", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title of the settings sheet.
     
     Localized string for key “settings.title” in table “Localizable.xcstrings”.
     */
    static var settingsTitle: LocalizedStringResource {
        LocalizedStringResource("settings.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver hint for the streak chip, saying that tapping it opens the play-goal sheet.
     
     Localized string for key “streak.accessibility.choosePeriod” in table “Localizable.xcstrings”.
     */
    static var streakAccessibilityChoosePeriod: LocalizedStringResource {
        LocalizedStringResource("streak.accessibility.choosePeriod", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver label for the home screen streak chip. Arguments in order: the period name from goalPeriod.*, minutes played, the goal in minutes, and the streak length in days.
     
     Localized string for key “streak.accessibility.compact %@ %lld %lld %lld” in table “Localizable.xcstrings”.
     */
    static func streakAccessibilityCompact(_ arg1: String, _ arg2: Int, minutes: Int, days: Int) -> LocalizedStringResource {
        LocalizedStringResource("streak.accessibility.compact %@ %lld %lld %lld", defaultValue: "\(arg1)\(arg2, specifier: "%lld")\(minutes, specifier: "%lld")\(days, specifier: "%lld")", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Shown on the streak chip on the very first day, before a streak exists. Very narrow.
     
     Localized string for key “streak.dayOne” in table “Localizable.xcstrings”.
     */
    static var streakDayOne: LocalizedStringResource {
        LocalizedStringResource("streak.dayOne", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Topic name, shown on the topic selector and reused inside onboarding.level.subtitle. Keep it a noun.
     
     Localized string for key “topic.addition” in table “Localizable.xcstrings”.
     */
    static var topicAddition: LocalizedStringResource {
        LocalizedStringResource("topic.addition", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     One-line summary of the Addition topic in the topic pop-out.
     
     Localized string for key “topic.addition.detail” in table “Localizable.xcstrings”.
     */
    static var topicAdditionDetail: LocalizedStringResource {
        LocalizedStringResource("topic.addition.detail", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Topic name, shown on the topic selector and reused inside onboarding.level.subtitle. Keep it a noun.
     
     Localized string for key “topic.fractions” in table “Localizable.xcstrings”.
     */
    static var topicFractions: LocalizedStringResource {
        LocalizedStringResource("topic.fractions", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     One-line summary of the Fractions topic in the topic pop-out.
     
     Localized string for key “topic.fractions.detail” in table “Localizable.xcstrings”.
     */
    static var topicFractionsDetail: LocalizedStringResource {
        LocalizedStringResource("topic.fractions.detail", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Topic name for the topic that mixes all operations. A coined, playful name rather than a literal one — invent the equivalent in your language and keep it identical in levelIntro.mixed.title.
     
     Localized string for key “topic.mixed” in table “Localizable.xcstrings”.
     */
    static var topicMixed: LocalizedStringResource {
        LocalizedStringResource("topic.mixed", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     One-line summary of the Supermix topic in the topic pop-out.
     
     Localized string for key “topic.mixed.detail” in table “Localizable.xcstrings”.
     */
    static var topicMixedDetail: LocalizedStringResource {
        LocalizedStringResource("topic.mixed.detail", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Topic name, shown on the topic selector and reused inside onboarding.level.subtitle. Keep it a noun.
     
     Localized string for key “topic.percentages” in table “Localizable.xcstrings”.
     */
    static var topicPercentages: LocalizedStringResource {
        LocalizedStringResource("topic.percentages", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     One-line summary of the Percentages topic in the topic pop-out.
     
     Localized string for key “topic.percentages.detail” in table “Localizable.xcstrings”.
     */
    static var topicPercentagesDetail: LocalizedStringResource {
        LocalizedStringResource("topic.percentages.detail", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Topic name, shown on the topic selector and reused inside onboarding.level.subtitle. Keep it a noun.
     
     Localized string for key “topic.subtraction” in table “Localizable.xcstrings”.
     */
    static var topicSubtraction: LocalizedStringResource {
        LocalizedStringResource("topic.subtraction", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     One-line summary of the Subtraction topic in the topic pop-out.
     
     Localized string for key “topic.subtraction.detail” in table “Localizable.xcstrings”.
     */
    static var topicSubtractionDetail: LocalizedStringResource {
        LocalizedStringResource("topic.subtraction.detail", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Topic name for the multiplication tables, shown on the topic selector and reused inside onboarding.level.subtitle. Keep it a noun.
     
     Localized string for key “topic.tables” in table “Localizable.xcstrings”.
     */
    static var topicTables: LocalizedStringResource {
        LocalizedStringResource("topic.tables", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     One-line summary of the Tables topic in the topic pop-out.
     
     Localized string for key “topic.tables.detail” in table “Localizable.xcstrings”.
     */
    static var topicTablesDetail: LocalizedStringResource {
        LocalizedStringResource("topic.tables.detail", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     VoiceOver label for the cap on the level intro card that arms the walkthrough.
     
     Localized string for key “tutorial.button” in table “Localizable.xcstrings”.
     */
    static var tutorialButton: LocalizedStringResource {
        LocalizedStringResource("tutorial.button", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Body of the note shown when the walkthrough cannot be armed. Explains what to do instead.
     
     Localized string for key “tutorial.notice.message” in table “Localizable.xcstrings”.
     */
    static var tutorialNoticeMessage: LocalizedStringResource {
        LocalizedStringResource("tutorial.notice.message", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Title of the note shown when the walkthrough cannot be armed because a run is already in progress.
     
     Localized string for key “tutorial.notice.title” in table “Localizable.xcstrings”.
     */
    static var tutorialNoticeTitle: LocalizedStringResource {
        LocalizedStringResource("tutorial.notice.title", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Walkthrough step 1 of 10: only wrong answers walk in, and tapping one costs nothing yet. Spoken to a young child, one or two short sentences.
     
     Localized string for key “tutorial.step.1” in table “Localizable.xcstrings”.
     */
    static var tutorialStep1: LocalizedStringResource {
        LocalizedStringResource("tutorial.step.1", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Walkthrough step 10 of 10: where the score is shown.
     
     Localized string for key “tutorial.step.10” in table “Localizable.xcstrings”.
     */
    static var tutorialStep10: LocalizedStringResource {
        LocalizedStringResource("tutorial.step.10", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Walkthrough step 2 of 10: one crab carries the right answer and has to be let through. Spoken to a young child, one or two short sentences.
     
     Localized string for key “tutorial.step.2” in table “Localizable.xcstrings”.
     */
    static var tutorialStep2: LocalizedStringResource {
        LocalizedStringResource("tutorial.step.2", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Walkthrough step 3 of 10: what a mistake costs — crabs that get through cost half a life, smashing the right answer costs a whole one. Spoken to a young child, one or two short sentences.
     
     Localized string for key “tutorial.step.3” in table “Localizable.xcstrings”.
     */
    static var tutorialStep3: LocalizedStringResource {
        LocalizedStringResource("tutorial.step.3", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Walkthrough step 4 of 10: the pink helper crab, which carries an extra life to the King. Spoken to a young child, one or two short sentences.
     
     Localized string for key “tutorial.step.4” in table “Localizable.xcstrings”.
     */
    static var tutorialStep4: LocalizedStringResource {
        LocalizedStringResource("tutorial.step.4", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Walkthrough step 5 of 10: the rainbow 2x crab, which doubles the next correct answer. Spoken to a young child, one or two short sentences.
     
     Localized string for key “tutorial.step.5” in table “Localizable.xcstrings”.
     */
    static var tutorialStep5: LocalizedStringResource {
        LocalizedStringResource("tutorial.step.5", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Walkthrough step 6 of 10: five right answers in a row earn the super bonus. Spoken to a young child, one or two short sentences.
     
     Localized string for key “tutorial.step.6” in table “Localizable.xcstrings”.
     */
    static var tutorialStep6: LocalizedStringResource {
        LocalizedStringResource("tutorial.step.6", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Walkthrough step 7 of 10: the super bonus is running — gold crabs, faster marching, double value. Spoken to a young child, one or two short sentences.
     
     Localized string for key “tutorial.step.7” in table “Localizable.xcstrings”.
     */
    static var tutorialStep7: LocalizedStringResource {
        LocalizedStringResource("tutorial.step.7", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Walkthrough step 8 of 10: the super bonus lasts until a mistake; the walkthrough hands the level back. Spoken to a young child, one or two short sentences.
     
     Localized string for key “tutorial.step.8” in table “Localizable.xcstrings”.
     */
    static var tutorialStep8: LocalizedStringResource {
        LocalizedStringResource("tutorial.step.8", table: "Localizable", bundle: resourceBundleDescription)
    }

    /**
     Walkthrough step 9 of 10: the sign-off, pointing the player at the high score. Spoken to a young child, one or two short sentences.
     
     Localized string for key “tutorial.step.9” in table “Localizable.xcstrings”.
     */
    static var tutorialStep9: LocalizedStringResource {
        LocalizedStringResource("tutorial.step.9", table: "Localizable", bundle: resourceBundleDescription)
    }
}