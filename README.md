# SidelineReel Review Prototype

Requires .NET 10 SDK.

From this folder:

```sh
dotnet run --project src/Web/SR.Web/SR.Web.csproj --launch-profile http
```

Open http://localhost:5082. Stop with Ctrl+C.

The root solution initially contained no project. Use the explicit project command above.

## Walkthrough

1. First clip: select Ava #4 and acknowledge checking footage; confirm.
2. Second clip: select Mia #14 and acknowledge; confirm.
3. Third clip: exclude because identity is unknown.
4. Preview the corrected reels. Enable the demo release failure.
5. Release: observe failure with preserved decisions. Retry: observe success.
6. Reset, exclude all three, and verify there is nothing to release.

All names and footage frames are fictional. No real video or notifications. State is per interactive session and resets on reload. Production requirements are in SUBMISSION.md; the demo implements only the core interaction.
