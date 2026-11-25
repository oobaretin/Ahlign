import Foundation

enum AffirmationLibrary {
    static func affirmations(for step: ChakraStep) -> [Affirmation] {
        switch step {
        case .root:
            return [
                Affirmation(id: "r1", english: "I am loved."),
                Affirmation(id: "r2", english: "I am safe."),
                Affirmation(id: "r3", english: "I am grounded."),
                Affirmation(id: "r4", english: "I am enough."),
                Affirmation(id: "r5", english: "I belong here."),
                Affirmation(id: "r6", english: "I am supported by the earth."),
                Affirmation(id: "r7", english: "I trust my body."),
                Affirmation(id: "r8", english: "I am rooted in peace."),
                Affirmation(id: "r9", english: "I am worthy of stability."),
                Affirmation(id: "r10", english: "I am home in myself."),
                Affirmation(id: "r11", english: "I release fear; I am secure."),
                Affirmation(id: "r12", english: "I am present in my body.")
            ]
        case .sacral:
            return [
                Affirmation(id: "s1", english: "I feel loved."),
                Affirmation(id: "s2", english: "I honor my emotions."),
                Affirmation(id: "s3", english: "I feel creative flow."),
                Affirmation(id: "s4", english: "I feel pleasure without guilt."),
                Affirmation(id: "s5", english: "I feel connected to others."),
                Affirmation(id: "s6", english: "I feel alive in my sensitivity."),
                Affirmation(id: "s7", english: "I feel worthy of joy."),
                Affirmation(id: "s8", english: "I feel my feelings and let them move."),
                Affirmation(id: "s9", english: "I feel inspired."),
                Affirmation(id: "s10", english: "I feel balanced in giving and receiving."),
                Affirmation(id: "s11", english: "I feel sensual and whole."),
                Affirmation(id: "s12", english: "I feel at ease in change.")
            ]
        case .solarPlexus:
            return [
                Affirmation(id: "sp1", english: "I do not chase; I attract."),
                Affirmation(id: "sp2", english: "I act with confidence."),
                Affirmation(id: "sp3", english: "I do what aligns with my purpose."),
                Affirmation(id: "sp4", english: "I do set healthy boundaries."),
                Affirmation(id: "sp5", english: "I do trust my decisions."),
                Affirmation(id: "sp6", english: "I do honor my power."),
                Affirmation(id: "sp7", english: "I do show up for myself."),
                Affirmation(id: "sp8", english: "I do release what drains me."),
                Affirmation(id: "sp9", english: "I do create my reality with intention."),
                Affirmation(id: "sp10", english: "I do speak my truth with clarity."),
                Affirmation(id: "sp11", english: "I do forgive myself and move forward."),
                Affirmation(id: "sp12", english: "I do shine without dimming others.")
            ]
        case .heart:
            return [
                Affirmation(id: "h1", english: "I love myself."),
                Affirmation(id: "h2", english: "I love without conditions."),
                Affirmation(id: "h3", english: "I love and I am loved."),
                Affirmation(id: "h4", english: "I forgive myself and others."),
                Affirmation(id: "h5", english: "I open my heart safely."),
                Affirmation(id: "h6", english: "I love my journey."),
                Affirmation(id: "h7", english: "I radiate compassion."),
                Affirmation(id: "h8", english: "I love who I am becoming."),
                Affirmation(id: "h9", english: "I love with a peaceful mind."),
                Affirmation(id: "h10", english: "I release resentment; I choose love."),
                Affirmation(id: "h11", english: "I love my body as it is today."),
                Affirmation(id: "h12", english: "Love keeps me whole.")
            ]
        case .throat:
            return [
                Affirmation(id: "t1", english: "I speak my truth with kindness."),
                Affirmation(id: "t2", english: "I speak with clarity."),
                Affirmation(id: "t3", english: "My voice matters."),
                Affirmation(id: "t4", english: "I speak what I need."),
                Affirmation(id: "t5", english: "I speak honestly and calmly."),
                Affirmation(id: "t6", english: "I listen as deeply as I speak."),
                Affirmation(id: "t7", english: "I speak affirmations that heal."),
                Affirmation(id: "t8", english: "I speak without fear of judgment."),
                Affirmation(id: "t9", english: "I speak creativity into the world."),
                Affirmation(id: "t10", english: "I speak boundaries with love."),
                Affirmation(id: "t11", english: "I speak only what I want to amplify."),
                Affirmation(id: "t12", english: "I speak and I am heard.")
            ]
        case .thirdEye:
            return [
                Affirmation(id: "te1", english: "I see my manifestations unfold."),
                Affirmation(id: "te2", english: "I see with inner wisdom."),
                Affirmation(id: "te3", english: "I see the truth clearly."),
                Affirmation(id: "te4", english: "I see opportunities aligned with my path."),
                Affirmation(id: "te5", english: "I see beyond fear."),
                Affirmation(id: "te6", english: "I see signs that guide me."),
                Affirmation(id: "te7", english: "I see myself with compassion."),
                Affirmation(id: "te8", english: "I see what is ready to be released."),
                Affirmation(id: "te9", english: "I see abundance everywhere."),
                Affirmation(id: "te10", english: "I see my intuition as trustworthy."),
                Affirmation(id: "te11", english: "I see the lesson in every moment."),
                Affirmation(id: "te12", english: "I see my highest vision taking form.")
            ]
        case .crown:
            return [
                Affirmation(id: "c1", english: "I understand love is infinite."),
                Affirmation(id: "c2", english: "I understand I am connected to all life."),
                Affirmation(id: "c3", english: "I understand peace is my nature."),
                Affirmation(id: "c4", english: "I understand this moment is enough."),
                Affirmation(id: "c5", english: "I understand wisdom flows through me."),
                Affirmation(id: "c6", english: "I understand surrender is strength."),
                Affirmation(id: "c7", english: "I understand I am spirit in a body."),
                Affirmation(id: "c8", english: "I understand clarity comes in stillness."),
                Affirmation(id: "c9", english: "I understand my path is unique."),
                Affirmation(id: "c10", english: "I understand gratitude opens me."),
                Affirmation(id: "c11", english: "I understand unity beyond separation."),
                Affirmation(id: "c12", english: "I understand I am complete.")
            ]
        }
    }
}