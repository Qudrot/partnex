# Building Partnest: How We Engineered Trust in SME Investments

*By the Product Team @ Partnest*

Every great product is born from a stark realization. For us at Partnest, that realization was simple but profound: in the world of Small and Medium Enterprise (SME) investing, **the biggest barrier isn't a lack of capital, it's a lack of trust.**

Investors have the funds, and SMEs have the drive. But the bridge connecting them—due diligence—is broken, opaque, and incredibly manual. This is the story of how we built Partnest to fix it.

---

## Identifying the Core Problem

During our early user interviews with Angel Investors and Micro-VCs, a common theme emerged: *“I see great SMEs, but I don’t have the time to verify their financial claims or operational history.”* 

Conversely, SME founders told us: *“I spend more time finding and formatting my financial metrics for investors than I do running my business.”*

**The Hypothesis:** If we could automate data extraction and synthesize it into a standardized, easily digestible format, we could increase interaction rates between investors and SMEs by 10x.

---

## The "Aha!" Moment: The Credibility Score

We needed a unifying metric—a "North Star" number that an investor could look at and immediately gauge the health and reliability of a business. We conceptualized the **Credibility Score**.

This wasn't just a random number; it was a weighted algorithm based on:
- **Financial Metrics:** Revenue trends, expense ratios, and historical cash flow.
- **Evidence Completeness:** How much verifiable documentation the SME had uploaded.
- **Historical Timestamps:** Ensuring data freshness and avoiding manipulated historical records.

---

## Building the MVP: Feature Prioritization

As a PM, my job was to ruthlessly prioritize. What did we *need* to prove our hypothesis? We narrowed it down to four core pillars:

### 1. The SME Discovery Feed
We required an interface that allowed investors to passively browse vetted deals. We worked heavily on mock data refinement early on, ensuring profiles like "Reelnosh" felt realistic, with investor-focused copy that highlighted traction rather than fluff.

### 2. The Credibility Dashboard
This was our flagship feature. It had to not only show the score but explain it. Transparency builds trust. If an SME has a score of 85, the investor needs to click in and see the exact breakdown of Financial Metrics vs. Deep Dive Evidence that led to that score.

### 3. Investor Comparison Watchlist
Investors rarely look at one deal in a vacuum. We built a feature to let them aggregate and compare SMEs side-by-side.

### 4. Seamless Onboarding & Profile Generation
For SMEs, we couldn't ask for a 40-page questionnaire. We needed API integrations to pull data and a smart onboarding flow to fill in the qualitative gaps.

---

## Overcoming Product & Engineering Challenges

No build is without its hurdles. During our beta phase, we hit a critical issue: **Financial Metrics Persistence**. 

Users reported that after a session refresh, key financial metrics (like revenue trends and expense ratios) were resetting to default values. A zero credibility score was showing on the dashboard despite backend generation working perfectly. 

Working closely with our mobile engineering team, we traced the data flow from our API gateway (`ApiAuthRepository`) through our state management layer (`AuthBloc` to `ScoreCubit`) to the `CredibilityDashboardPage`. The fix involved tightening our state persistence and resolving an intricate payload delivery mapping issue. 

It was a tough week, but it taught us a valuable lesson: **In fintech, data persistence isn't just a technical requirement; it is the foundation of user trust.** If a score disappears on a refresh, the investor loses faith in the platform.

---

## Go-to-Market & The Road Ahead

Partnest is now rolling out to our early-access cohort. Our immediate roadmap focuses on expanding the automatic API integrations for SME onboarding and implementing more granular comparative analytics for the Investor Watchlist.

### Key Takeaways for Product Managers
1. **Solve for Trust First:** If your platform connects two parties in a high-stakes environment (like investing), your UX/UI and data architecture must radiate reliability.
2. **Standardize the Subjective:** Turning messy financial/evidence data into a clean "Credibility Score" was our hardest but most valuable product decision.
3. **Sweat the Edge Cases:** When real money is involved, a UI bug isn't just an annoyance; it's a dealbreaker. (Our rigorous use of Golden Tests for the UI saved us from many regression issues).

*Building Partnest has been a journey of turning fragmented chaos into structured opportunity. We can't wait to see the partnerships that form on the platform.*
