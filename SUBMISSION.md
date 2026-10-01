# SidelineReel Product Manager Assessment

**Video:** [ADD PUBLIC VIDEO LINK BEFORE SUBMISSION]
**Candidate:** Allan Odhiambo
**Prototype:** [ATTACH THE RUNNABLE SOURCE ZIP OR ADD A PUBLIC WORKING LINK]

## Task 1. The Roadmap Call

Build a pre-release roster-match review flow first. The outcome is that families receive highlights of their own children, with uncertain clips held for coach confirmation or excluded. This is a targeted trust and correctness intervention, not a commitment to rebuild the recognition model.

### What the evidence supports

- **Material 1:** Carla says highlights contributed to renewal for half her parents. This is a customer assertion, not a measured causal result, but it supports protecting the existing value. She also requests livestreaming before signups in six weeks.
- **Material 2:** 58% of 210 surveyed parents across 40 clubs want more editing controls. However, only 6% of parents opened the editor over 90 days, and fewer than 1% of that subgroup finished an edit: fewer than 0.06% of all parents, assuming consistent parent denominators. This does not prove editing is unwanted; discoverability or a broken workflow could explain it. It does not yet justify expanding the editor.
- **Material 3:** Three tickets across soccer, lacrosse, and baseball describe similar-number identity errors. One is from Ridgeline itself. These are repeated examples across accounts, not a measured error rate. The icon and watermark tickets concern lower-severity issues on the available evidence.
- **Material 4:** Ridgeline represents $180k per season and the highest-risk renewal this quarter. The risk is material. We do not know total revenue concentration, the probability of churn, or whether a limited livestream option would satisfy the board.
- **Material 5:** The 92% share rate covers only opened reels. Approximately 30% are never opened, so the implied rate across all generated reels is approximately 0.70 x 0.92 = **64.4%**, assuming the same cohort/window and compatible definitions. This is an estimate, not a newly measured KPI. The note attributes unopened reels mostly to late notifications or wrong-child thumbnails; it does not quantify each cause or prove causation.

The 90% auto-recap Share-button usage in Material 2 measures a different object and event from personal-reel sharing in Material 5. I would not combine the two. Neither proves recipient viewing or satisfaction.

### Ranked roadmap

| Rank | Candidate | Decision and tradeoff |
| --- | --- | --- |
| 1 | Prevent uncertain roster matches from reaching families | Build the coach-review and release gate. Multiple accounts report a core promise failing; the analytics note links the same issue to unopened reels. The cost is added coach work and potential delay, which the rollout must measure. |
| 2 | Improve notification timing | Next, validate recipient-local delivery timing and test daytime delivery. The dashboard directly identifies late notifications as another opening barrier. It will not correct a wrong child's reel, so it follows the correctness intervention. |
| 3 | Repair watermark consistency on camera-roll exports | Triage the export path and estimate a bounded fix. A real quality issue, but one ticket explicitly describes it as not urgent. No evidence supplied makes it more consequential than identity errors. |
| 4 | Expand parent editing controls | Defer expansion. Observe attempted edits and validate the existing completion funnel first. Survey demand deserves investigation; very low completion may indicate usability failure rather than lack of demand. |
| 5 | Livestreaming | Do not build next or promise delivery in six weeks. It introduces a substantial new workflow and operational obligations before we have sizing, broader demand, or evidence that a smaller version would save renewal. Commercial discovery starts immediately despite its low build rank. |
| 6 | Replace the soccer-ball app icon | Defer. The all-sports mismatch is real but there is little evidence of material harm. Consider a small branding change when its effort is known; this ranking is not an instruction to block a trivial fix indefinitely. |

Instrumentation for the chosen feature is part of item 1, not a separate competing initiative. Rankings reflect supplied evidence; engineering estimates may change the sequencing of small fixes.

### Ridgeline and Sales

I would tell Carla and Jamal: "Ridgeline's $180k renewal matters. We cannot responsibly promise livestreaming within six weeks without proving what we can deliver. We are prioritizing a failure your own families have reported: the wrong child appearing in a reel. Within two business days I will meet with you and delivery to define the minimum live-viewing need and assess an existing-provider or link-out option, including access and consent constraints. Within one week I will return with feasibility, cost, limitations, and a go/no-go recommendation. That is a decision commitment, not a delivery promise."

These are proposed commitments I would make as PM, not conversations already held. A workaround is not assumed to be acceptable. I would ask for the board's actual renewal criteria and avoid implying that correcting tagging alone saves the account.

Under pushback, the strongest counterargument is the size and imminence of the renewal. I would reconsider sequencing if a validated, low-effort option materially changes retention odds without displacing the correctness work, or if broader demand and commercial value justify a separate investment. I would not change the roadmap solely because the request is repeated more forcefully.

## Task 2. The Spec

### Outcome and scope

**Feature:** Coach review of uncertain roster matches before release.

**User:** A coach responsible for a game's roster and highlights.

**Outcome:** Reduce wrong-child clips and thumbnails reaching families while keeping coach effort and release delays acceptable. This reduces a known failure path; it does not guarantee that every incorrect match will be detected.

**In scope:** A game-specific review queue, footage context, suggested identity and uncertainty reason, confirmation/reassignment to an eligible roster player, exclusion when identity cannot be determined, regenerated personal reels/thumbnails and recap, and an auditable release gate. Review follows the roster attached to that game, not a cross-club player search.

**Out of scope:** Livestreaming, editor expansion, notification-time optimization, model retraining, real-time tagging, parent editing of identities, historical recall/remediation, and branding fixes. Existing authentication, recipient access rules, and media delivery are dependencies. Historical errors need a separate operational response; this feature governs new releases.

### Detection and human responsibility

Proposed queue triggers are an ambiguous candidate match, conflicting roster association, missing match, or a visually confusable number with unresolved identity. The supplied evidence does not establish a usable confidence threshold or prove these signals already exist. Engineering must validate signal availability on labeled clips before automatic routing is enabled. Do not invent an 85% threshold.

For the initial pilot, review all clips in the participating batch so we can collect labels and evaluate routing misses. The prototype shows three illustrative uncertain clips. Move to selective review only after measuring missed errors and coach workload; sample unflagged clips continuously. Jersey similarity is a clue, not a complete detector.

The system suggests and assembles. The coach checks the original clip with enough surrounding footage, confirms a roster player, or excludes the clip. Nothing is pre-approved. A coach who cannot identify the child must be able to exclude rather than guess. Human confirmation can still be wrong and is not ground truth without audit.

### Core flow and state rules

1. Coach opens the game review queue. Each item includes timestamp, playable source segment in production, suggested player, and reason for review. An unresolved item has no publishable assignment.
2. Coach selects an eligible player and explicitly confirms they checked the footage, or excludes the clip. Decisions can be revised before release. Reassignment removes the clip from the previous player's output; it never duplicates it across identities as a side effect.
3. Coach previews rebuilt personal reels, thumbnails, and recap, then releases. Any unresolved item blocks this pilot batch. Excluding an item resolves it without publishing it. A player with zero eligible clips receives no empty personal-reel notification; this does not remove the family from ordinary team recap eligibility.

States: NeedsReview -> Confirmed(player) or Excluded. Either decision can be changed before release. Changing a decision invalidates the old preview. Release requires a current rendered manifest whose review version matches the saved decisions and contains zero unresolved clips. An all-excluded batch has nothing to release.

For production, persist clip ID, game/roster version, suggested identity, confirmed identity or exclusion, reviewer, timestamp, and decision revision. Enforce coach/team authorization server-side. Reject stale or cross-roster updates. Persist a unique release request for the batch/revision, rebuild assets against that version, and make them available only after the manifest is ready. Do not send notifications against an old manifest. Retries reuse the release identity; notification delivery must deduplicate by release and recipient. If preparation fails, preserve decisions and publish nothing new.

### Testable acceptance criteria

| ID | Given / When | Expected result |
| --- | --- | --- |
| AC1 | A batch contains an unresolved clip; release is requested | Server rejects release; the UI identifies remaining review work. |
| AC2 | A coach selects a player but has not acknowledged footage review | Confirmation is unavailable. Invalid or non-roster player IDs are rejected server-side. |
| AC3 | A #4 clip was suggested for #14; coach confirms #4 | It belongs only to the confirmed player's personal reel; the previous player's reel and thumbnail no longer use it. |
| AC4 | Coach cannot establish identity and excludes a clip | It appears in neither personal reels nor team recap; the decision remains visible in the audit history. |
| AC5 | All items are resolved with at least one confirmed clip | Coach can preview the current output; only this reviewed version can be released. |
| AC6 | Every clip is excluded, or a player's reel has zero eligible clips | No empty batch release or empty personal-reel notification is created. |
| AC7 | A coach changes a decision after preview or another reviewer updates it | Old preview is invalidated; stale release/update is rejected and requires refresh. |
| AC8 | Asset preparation fails or the same release is retried | Decisions survive, no incomplete output is exposed, and a successful retry does not duplicate notifications. |
| AC9 | A user lacks permission for the team/game | Review and release requests are rejected, including direct API requests. |
| AC10 | A coach completes review using keyboard navigation | Controls have visible focus and labels; state/error feedback is available without relying on color alone. |

AC7-9 describe production requirements; this in-memory prototype does not implement authentication, concurrent sessions, durable storage, rendering, or notification infrastructure.

### Measurement and rollout

Run a bounded opt-in pilot with a soccer club, a lacrosse club, and a baseball club if available; the supplied tickets justify testing across sports. Establish a pre-pilot baseline using comparable recent games. These are proposed pilot choices, not recruited participants.

Primary quality measure: independently audited wrong-child clips / all audited released clips, including both flagged and unflagged examples, with sample counts and sports reported. Track wrong-child thumbnails separately. Support reports are a supplementary signal, not the only detector.

Product outcome: unique personal reels shared / all generated personal reels within seven days of generation, with opened/generated and shared/opened reported separately. Use mature cohorts so newly generated reels are not treated as failures prematurely. This is a proposed measurement window. Keep auto-recap events separate.

Guardrails: review minutes per game, excluded clips / reviewed clips, children with no eligible personal reel, and release delay from scheduled delivery. Instrument queued, confirmed, reassigned, excluded, preview-ready, release-failed and release-completed events with batch/revision identifiers; do not place raw child names in analytics.

Before expansion, require no unresolved clips in released manifests and evidence of reduced audited identity errors against the baseline. As provisional operating budgets, aim for median review time <=5 minutes/game and >=95% of batches ready by scheduled delivery; validate these budgets with coaches and delivery rather than presenting them as established targets. If errors remain or workload is excessive, investigate routing/review design and narrow the pilot. Do not restore unsafe auto-release merely to improve timeliness. Do not claim retention or sharing lift from the small pilot alone.

### Top two post-launch failures

1. **Wrong identities still escape through unflagged clips or mistaken coach confirmation.** Catch this through stratified independent audits of released clips and thumbnails, including unflagged examples and similar-number pairs, plus linked parent reports. Audit manifests for unresolved clips automatically. On evidence of a systematic miss, stop expansion and broaden review for the affected pattern; investigate before changing thresholds.
2. **Coach review becomes a bottleneck, delaying or suppressing too many highlights.** Catch this through queue age, review minutes/game, excluded-clip rate, empty-reel rate, and scheduled-delivery misses. Alert the responsible coach and pilot owner before the delivery deadline. Allow explicit exclusions and release of the remaining resolved batch, but never silently approve overdue clips. Reduce pilot volume or improve the queue if the burden remains high.

## Task 3. Working Prototype

The supplied Blazor .NET 10 prototype implements three steps: review uncertain matches, preview personal reels and recap, and simulate release. It includes reassignment, exclusion, blocked progression while unresolved, an all-excluded empty state, a review history, and a one-shot release failure with retry.

**Run:** Unzip the source, install the .NET 10 SDK if needed, and from the extracted root run:

```sh
dotnet run --project src/Web/SR.Web/SR.Web.csproj --launch-profile http
```

Open http://localhost:5082 while the process is running. This localhost address is a local run instruction, not a public submission link.

**Demo:** Confirm the first clip as Ava #4, confirm the second as Mia #14, exclude the unidentifiable third clip, and preview. Enable the simulated release failure, attempt release, then retry successfully. Reset and exclude all clips to inspect the empty-batch behavior.

Fictional roster, illustrated frames, and in-memory state are intentional prototype boundaries. It does not play real footage, run recognition, regenerate media, authenticate a coach, persist review data, or send messages. Reload resets the demo. It proves the interaction and decision rules, not production recognition accuracy or operational reliability.

## Task 4. AI Workflow Note

I used AI to compare the five materials, check metric denominators, draft the specification, and implement the Blazor prototype. I explicitly approved the priority of correcting roster matches and deferring livestreaming; the final roadmap, commercial tradeoffs, and commitments remain my responsibility. I rejected earlier AI preparation that invented a fifth task and a two-minute video requirement: the actual assignment has four tasks and asks for a 5-10 minute recording. The implementation uses simulated media rather than claiming to have built video recognition.

I used AGENTS.md for persistent AI working rules and kept the feature specification directly in this submission. In a longer-lived repository I would separate FEATURE-SPEC.md, PLAN.md, and EXECUTION_STRATEGY.md when each has a distinct purpose. For this timed exercise, consolidating them avoids duplicate sources of truth and keeps implementation aligned with the assessed spec.

Prepared for [Ajaia](https://ajaia.ai).

