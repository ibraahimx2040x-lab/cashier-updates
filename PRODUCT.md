# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

One Flutter codebase ships the same design to Android (APK today), iPhone (pending an Apple Developer account) and the web (GitHub Pages). Android is the primary device; the design does not change per OS.

## Users

A worldwide audience that reads Arabic and English equally: adults who want to run their whole day (time, prayer, health, money, learning) from one place on their phone. Arabic (right-to-left) and English (left-to-right) are equal citizens in design and marketing; neither is a translation of the other.

## Product Purpose

Your whole life in one app. It replaces a stack of separate apps for tasks and calendar, prayer times, fitness and steps, food and water, sleep and women's/men's health, income and expenses, language learning, goals and habits. Success means the user opens one app in the morning, sees their real day, and keeps their commitments without juggling tools.

## Positioning

- Everything in one place, connected: the planner, reports and assistant see across sections.
- The day is planned around prayer: prayer times are part of the schedule, not a separate widget.
- An assistant that understands the user's own data, acting only within permissions the user grants, asking before big or sensitive changes, and never claiming an action it has not confirmed.
- Privacy first: the user owns their data; sensitive data (the menstrual cycle) can stay on this phone only, behind the phone's fingerprint or passcode.

## Operating Context

Daily, repeated use in short sessions: a morning look at "My day", quick adds through the day (an expense, a glass of water, a task), prayer reminders, an evening check. Used one-handed on a phone, often outdoors and in bright light, and late at night in dark mode.

## Capabilities and Constraints

- Sections: My day (home), Time (tasks, calendar, planner with real free time), Goals and habits, Prayer, Fitness (plans, programmes split by sex, exercise library), Activity and devices (Health Connect / HealthKit), Food and water, Sleep and measurements, Women's health (female accounts only), Money (fixed or variable income with salary history, monthly items, expenses, reports), English learning, Accountability, Notes, Assistant, Progress, Settings.
- Arabic and English, RTL and LTR, light and dark, phone and desktop web.
- Backend: Supabase (auth, owner-only row level security). Works locally without a connection.
- Health information is education, never diagnosis.
- Undecided: the final product name (the letter S is the chosen mark; the name should say what the app is for), the final logo, a guest mode limited to tasks, calendar and habits.

## Brand Commitments

- The mark is the letter **S** until a final logo is approved.
- The current name «حياتي / Hayati» is temporary and will be replaced; the identity must not depend on it.
- The owner asked for a fully new identity: the current navy and gold look is retired, not refined.
- The identity must be the app's own and must not imitate another app.

## Evidence on Hand

Real app screens and data structures in `hayati_app/`. No testimonials, user counts, press or reviews exist; none may be invented.

## Product Principles

1. One place, one day: every section feeds the same picture of today.
2. Real time, not task counts: busy means the hours are taken.
3. The user decides: the assistant proposes, the user approves; nothing silent, nothing claimed before it happened.
4. Private by default, especially for health.
5. Equal in both languages.

## Accessibility & Inclusion

Text must stay legible in bright sunlight and in dark mode; contrast meets WCAG AA. Supports system text scaling and screen readers. Arabic typography must be first-class, not a fallback.
