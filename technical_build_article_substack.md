# Scaling Trust: Architecting the Partnest Flutter App

*Published in Mobile Dev Digest | Substack*

When you're building a platform that facilitates financial investments between Angels and SMEs, "move fast and break things" doesn't apply. You have to move fast and build vaults. 

As the Lead Mobile Developer for **Partnest**, a dual-sided marketplace app, my mandate was to build a visually stunning, highly performant, and absolutely reliable mobile application. We chose **Flutter** for its ability to deliver premium, 60fps UIs across both iOS and Android from a single codebase.

Here is a deep dive into how we architected Partnest, managed complex state, and ensured pixel-perfect reliability.

---

## 🏗 Architecture: Clean & Modular

From day one, we adopted **Clean Architecture**. In a fintech app dealing with dense payloads and complex scoring algorithms, separating concerns is non-negotiable. 

Our directory structure strictly separated:
- `data/` (Repositories, API integrations, data sources)
- `domain/` (Entities, Use cases)
- `presentation/` (UI, pages, widgets, state management)

This modularity saved us countless hours when we had to pivot our mock data strategies and refine our `ApiAuthRepository` without touching the UI layer.

---

## 🧠 State Management: The Power of Bloc & Cubit

To manage the app's state, we relied heavily on the **BLoC (Business Logic Component)** library. We used a hybrid approach: `Bloc` for complex event-driven state (like Authentication and Onboarding flows) and `Cubit` for simpler state pipelines.

### The Lifecycle of the Credibility Score
The core value proposition of Partnest is the **Credibility Score**. Fetching and distributing this score across the app required a bulletproof flow.

We implemented a `ScoreCubit` to listen to state changes from our `AuthBloc`. When an SME logs in, the `ApiAuthRepository` fetches their profile, and a `"RUNNING_SCORE_GENERATION"` payload is sent to our backend. 
Once the backend crunch finishes, the `ScoreCubit` parses the intricate data model—which includes `FinancialMetrics` (Revenue Trends, Expense Ratios)—and emits the `ScoreState`.

**The Bug That Almost Broke Us:**
During late-stage testing, we encountered a severe issue: Financial Metrics Persistence. On a hot restart, the credibility score would flatline to zero, and metrics would reset to defaults. 
By isolating the issue within our `ScoreCubit`, we realized that the cached state was failing to re-hydrate from local storage before the UI rendered. We fixed this by introducing a robust hydration sequence at the root `AuthBloc` level, ensuring the `CredibilityDashboardPage` only painted *after* the local SQLite cache was fully loaded.

---

## 🎨 Pixel-Perfect UI & Golden Tests

Partnest required a premium look. We built bespoke widgets like the `SmeBioContactCard` and complex, animated radial charts for the Dashboard. 

However, ensuring these complex UIs didn't break across different device screen sizes or during refactoring was a challenge. Our solution? **Golden Testing**.

Before our final release candidate, we implemented an extensive suite of Golden Tests targeted specifically at the iPhone 16 viewport frame size. 

We generated goldens for:
- `splash_page_golden_test.dart`
- `score_drivers_detail_page_golden_test.dart`
- `revenue_expenses_page_golden_test.dart`
- And our complex `sme_discovery_feed_page`.

This meant if someone accidentally added a `Container` padding that shifted the dashboard by even 2 pixels, the CI/CD pipeline would flag it instantly.

---

## 📡 Handling Mock Data Gracefully

While the backend was still finalizing the scoring endpoints, we needed a robust way to test the UI. Instead of hardcoding data into the UI, we created a comprehensive `mock_sme_data.dart` file injected via the Dependency Injection layer into the `ApiAuthRepository`.

This allowed us to simulate complex edge cases. For instance, we created complete profiles for mock SMEs like "Reelnosh", generating randomized historical timestamps to test our data sorting and ensuring our UI gracefully handled edge cases like missing "Deep Dive Evidence".

---

## 🚀 Takeaways from the Trenches

Building Partnest reinforced three crucial principles for large-scale Flutter apps:
1. **Never Compromise on Golden Tests:** They are a pain to set up initially, but they are the ultimate safety net for complex, premium UIs.
2. **State Hydration is Tricky:** Always account for app lifecycle events (backgrounding, hot restarts) when dealing with critical financial data.
3. **Decouple Everything:** Having the `ScoreCubit` cleanly separated from the UI allowed us to fix major business logic bugs without ever needing to touch our widget tree.

We successfully finalized the codebase, suppressed all static analysis warnings, and shipped a release build that feels native, premium, and reliable. Partnest is now ready to change how investors and SMEs connect. 

*Follow for more deep dives into Flutter architecture and mobile app engineering!*
