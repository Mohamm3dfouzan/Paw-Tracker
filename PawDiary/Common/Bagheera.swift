import Foundation
import Observation

/// Bagheera — PawDiary's resident Black Himalayan cat.
/// He greets you, drops fun facts, and voices your reminder notifications.
@MainActor
@Observable
final class Bagheera {
    static let name = "Bagheera"

    private let defaults = UserDefaults.standard
    private let lastGreetingKey = "bagheera.lastGreeting"
    private let lastFactKey = "bagheera.lastFact"
    private let lastFactIndexKey = "bagheera.lastFactIndex"

    /// Whether we should show a launch greeting this app session.
    /// True if it's been > 4 hours since the last greeting (or never shown).
    var shouldGreetOnLaunch: Bool {
        guard let last = lastGreetingAt else { return true }
        return Date.now.timeIntervalSince(last) > 4 * 3600
    }

    var lastGreetingAt: Date? {
        get { defaults.object(forKey: lastGreetingKey) as? Date }
        set { defaults.set(newValue, forKey: lastGreetingKey) }
    }

    /// A fun fact for the daily card — same fact for the whole day so it doesn't
    /// flicker as the user navigates.
    var dailyFact: String {
        let today = Calendar.current.startOfDay(for: .now)
        if let saved = defaults.object(forKey: lastFactKey) as? Date,
           Calendar.current.isDate(saved, inSameDayAs: today) {
            let idx = defaults.integer(forKey: lastFactIndexKey) % Self.funFacts.count
            return Self.funFacts[idx]
        }
        let idx = Int.random(in: 0..<Self.funFacts.count)
        defaults.set(today, forKey: lastFactKey)
        defaults.set(idx, forKey: lastFactIndexKey)
        return Self.funFacts[idx]
    }

    func markGreetingShown() {
        lastGreetingAt = .now
    }

    func rerollFact() {
        let idx = Int.random(in: 0..<Self.funFacts.count)
        defaults.set(idx, forKey: lastFactIndexKey)
        defaults.set(Calendar.current.startOfDay(for: .now), forKey: lastFactKey)
    }

    // MARK: - Greetings

    func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: .now)
        let pool: [String]
        switch hour {
        case 5..<12: pool = Self.morningGreetings
        case 12..<17: pool = Self.afternoonGreetings
        case 17..<22: pool = Self.eveningGreetings
        default: pool = Self.nightGreetings
        }
        return pool.randomElement() ?? "Mrrrow."
    }

    // MARK: - Notification voicing

    /// Rewrites a reminder title/body in Bagheera's voice.
    func voice(title: String, body: String, kind: ReminderKind? = nil) -> (title: String, body: String) {
        let prefix: String
        switch kind {
        case .vaccination: prefix = "🐈‍⬛ Bagheera says"
        case .vetVisit: prefix = "🐈‍⬛ A nudge from Bagheera"
        case .medication: prefix = "🐈‍⬛ Bagheera reminds you"
        case .grooming: prefix = "🐈‍⬛ A purr from Bagheera"
        default: prefix = "🐈‍⬛ Bagheera says"
        }
        let opener = Self.notifOpeners.randomElement() ?? "Mrrrow…"
        return (
            title: "\(prefix): \(title)",
            body: "\(opener) \(body)"
        )
    }

    // MARK: - Pools

    private static let morningGreetings = [
        "Good morning. *stretches* — every paw accounted for?",
        "*yawn* Morning. The sunbeam is mine, but you may sit nearby.",
        "Up already? I admire your discipline. I'll be napping.",
        "Mrrrow. A new day. Try not to forget breakfast.",
    ]
    private static let afternoonGreetings = [
        "Afternoon. The window has moved. Tragic.",
        "Hello again. Have you brushed anyone today?",
        "*flicks tail* You're back. Excellent. Treats?",
        "I trust the day is well-supervised.",
    ]
    private static let eveningGreetings = [
        "Evening. Time for cuddles and chaos.",
        "*purrs* Welcome home. The kingdom is intact.",
        "Hello. I have been watching the bird outside. Tirelessly.",
        "Dinner soon? Asking for a friend. (Me.)",
    ]
    private static let nightGreetings = [
        "*nocturnal stare* You're up late.",
        "The witching hour. My favorite. Yours too?",
        "Quiet now. The hunters are about.",
        "Mrrrow. A night check-in. All paws cozy?",
    ]
    private static let notifOpeners = [
        "Mrrrow —",
        "*purr*",
        "Psst.",
        "A small nudge:",
        "Don't forget —",
        "*flicks tail*",
    ]

    static let funFacts: [String] = [
        "Cats have 32 muscles in each ear — they can rotate independently up to 180°.",
        "A dog's nose print is as unique as a human fingerprint.",
        "Himalayan cats descend from a 1930s cross between Persians and Siamese.",
        "Most cats are lactose intolerant. Water is a finer luxury anyway.",
        "Dogs can learn over 1,000 words and gestures — border collies sometimes more.",
        "A cat's purr vibrates between 25 and 150 Hz — frequencies linked to bone healing.",
        "A pet's resting heart rate is a useful baseline — track it once a month.",
        "Vaccinations don't last forever; most boosters are due every 1–3 years.",
        "Weighing your pet monthly catches health changes earlier than a yearly checkup.",
        "Cats sleep 12–16 hours a day. Don't take it personally.",
        "Rabbits' teeth never stop growing — they need fibrous food to wear them down.",
        "Black cats can have brown undertones in sunlight — a sign of melanin variation.",
        "Microchipping triples the chance of a lost pet making it home.",
        "Dental disease affects 70% of cats and 80% of dogs by age 3.",
        "A cat's whiskers are roughly as wide as its body — built-in measuring tape.",
    ]
}
