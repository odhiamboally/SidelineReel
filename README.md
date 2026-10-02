# SidelineReel Prototype Guide

This working prototype demonstrates a coach reviewing uncertain player matches before highlights become available to families. It was built for the [Ajaia](https://ajaia.ai) Product Manager assessment using .NET 10 and Blazor Interactive Server.

The sample inputs are hardcoded. Player assignments, exclusions, review counts, previews, and failure/retry behavior respond to your actions in memory. No AI model or video-processing service runs behind these screens.

## Run Locally

Requires the .NET 10 SDK. From the repository root:

```sh
dotnet run --project src/Web/SR.Web/SR.Web.csproj --launch-profile http
```

Open http://localhost:5082 while the process is running. Stop with Ctrl+C. This is a local address, not a hosted public demo.

You can also open `SidelineReel.slnx` in a compatible IDE and run the web project.

## What The Prototype Demonstrates

The proposed intervention is review before publishing: a coach confirms a roster player or excludes a clip when identity cannot be established. Unresolved clips block progression. This demonstrates a review requirement; it does not guarantee that the coach identifies the child correctly.

The roadmap rationale and production feature specification are in [SUBMISSION.md](SUBMISSION.md). This README explains the implemented prototype rather than duplicating the specification.

## The Three Steps

### 1. Review Matches

Select a clip from the queue. The screen shows an illustrated jersey, a timestamp, an initial player suggestion, and a reason to check the match.

To confirm:

1. Select a player from the fictional game roster.
2. Check the acknowledgement that you reviewed the footage and can identify the player.
3. Click **Confirm Player**.

Confirmation saves the selected player, marks the clip resolved, adds a history entry, and moves to the next unresolved clip. Changing the dropdown alone does not save a decision.

If identity cannot be established, click **Cannot Tell — Exclude Clip**. This clears the assignment and marks the clip resolved but excluded. Excluded clips appear in neither the personal-reel preview nor the included team-recap count.

You can revisit a queue item and change a saved decision before release. The acknowledgement resets when selecting an item or completing the batch; an unchecked box does not erase an earlier saved confirmation. The queue status shows the saved decision.

### 2. Check Reels

Once every clip is confirmed or excluded, **Preview Family Reels** becomes available.

The preview groups included clips by the player you confirmed. Counts and clip lists are calculated from the current in-memory records. A player with no included clips shows an empty-reel explanation. The weekly recap summarizes included, excluded, and unresolved clips for this sample batch.

The numbered cards are placeholders, not generated video thumbnails. No video files are assembled. **Back To Review** lets you revise decisions; returning to the preview reflects the saved changes.

If every clip is excluded, preview remains available, but release is disabled because there is nothing to publish.

### 3. Release Summary

**Release** means publishing the reviewed highlights for families to receive. It does not mean deploying the application, publishing code, or creating an AWS release.

In the prototype, **Release Reviewed Highlights** checks that the batch has no unresolved clips and at least one included clip, then changes the screen to a simulated success summary. It does not publish media or send notifications.

The included and excluded totals are calculated. The summary's zero unresolved value is a fixed display backed by the release handler's unresolved-clip check.

## What Make The Next Release Fail Does

**Demo: Make The Next Release Fail** is a testing control for demonstrating recovery:

1. Check it on the preview screen.
2. Click **Release Reviewed Highlights**.
3. The app deliberately displays a failure and stays on the preview.
4. Player assignments and exclusions remain intact in the current session.
5. The failure switch automatically turns off. Click release again to simulate success.

This demonstrates that an unsuccessful publishing attempt should not make the coach repeat the review. It is not a real network failure and does not prove recovery after a server restart. In production, this switch would belong in test tooling, not the ordinary coach interface.

## Where The Suggestions Come From

The following examples are seeded in code. They represent possible outputs from an upstream recognition system, which is not implemented here.

| Clip | Illustrated Evidence | Initial Suggestion | Intended Demo Decision |
| --- | --- | --- | --- |
| Goal At The Near Post, 12:08 | Jersey #4 | Mia Carter #14; similar numbers 14 / 4 | Confirm Ava Brooks #4 |
| Breakaway Finish, 28:42 | Jersey #14 | Ava Brooks #4; partly obscured jersey | Confirm Mia Carter #14 |
| Crowded Goal-Line Save, 46:11 | Unreadable number | Leo Morgan #11; number cannot be read | Exclude rather than guess |

The original suggestion stays visible after confirmation because it records the starting input. The queue's **Confirmed** label records your saved choice. The suggestions, explanations, timestamps, roster, and jersey illustrations are all fictional sample data.

## What Is Calculated And What Is Simulated

| Element | Implementation |
| --- | --- |
| Initial roster and three clip examples | Hardcoded sample records |
| Suggested identities and uncertainty reasons | Hardcoded; no recognition model |
| Selected player, resolved status, exclusion | Updated in memory when you confirm or exclude |
| Unresolved count | Calculated from clips where `Resolved` is false |
| Reviewed count | Calculated from resolved clips; the displayed total of three and heading are fixed for this sample |
| Preview button availability | Disabled while any clip remains unresolved |
| Personal-reel clip lists and counts | Calculated from saved player assignments, excluding omitted clips |
| Release eligibility | Checked by the handler as well as UI controls |
| Review history | Appended in memory for confirmations, exclusions, and release outcomes |
| Footage, thumbnails, and video assembly | Illustrated or represented by text; no real media processing |
| Release failure and success | Simulated state transitions; no external delivery |

For example, the unresolved count uses:

```csharp
clips.Count(c => !c.Resolved)
```

Confirming or excluding each clip changes the count from 3 to 2 to 1 to 0. The sentence beside it, "Release stays blocked until all are handled," is static explanatory copy. At zero, it describes the rule rather than an active block; preview is enabled.

## Suggested Demonstration

1. Click **Reset Demo**. Observe that confirmation and preview are initially disabled.
2. Assign the first clip to **Ava #4**, acknowledge reviewing it, and confirm.
3. Assign the second clip to **Mia #14**, acknowledge reviewing it, and confirm.
4. Exclude the third clip because the illustrated identity is unknown.
5. Open the preview: Ava has one clip, Mia has one, Leo has none; the recap includes two clips and excludes one.
6. Enable the simulated failure and attempt release. Observe the error and preserved decisions.
7. Retry release. Observe the summary with two included clips, one excluded clip, and zero unresolved clips.
8. Optionally reset and exclude all three clips. Preview shows no included clips and release is disabled.

## Human Review Is Not A Correctness Guarantee

The app accepts any eligible roster player when the coach explicitly confirms. It does not compare that selection with a verified identity. For example, assigning the illustrated #14 clip to Leo #11 will put it in Leo's preview even though that contradicts the intended sample evidence.

This is a limitation of the review boundary, not evidence that recognition succeeded. Production would need footage context, reviewer guidance, quality audits, and monitoring of errors that escape review. Those requirements are discussed in the submission.

## State And Production Boundaries

State belongs to the current Blazor interactive session. Reloading the page or choosing **Reset Demo** starts over and clears review history. The prototype has no durable database, authentication, cross-session coordination, real footage playback, model inference, media regeneration, or notification delivery.

A successful simulated retry does not establish production idempotency or durable recovery. The production spec describes those additional requirements separately.

## A Concise Explanation For The Video

> I mocked the recognition output so I could focus the prototype on the proposed intervention: coach review before publishing. Assignments, exclusions, counts, and publishing gates are functional in-memory interactions. Media processing and delivery are simulated. The workflow prevents unresolved clips from being published, but it does not guarantee that a coach's confirmation is correct.
