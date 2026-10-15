# Streaming search integrations

Nova's search results use `MusicSearchResult`, which carries the provider ID
and provider URL through the UI. Provider clients implement `MusicCatalogService`
and expose a status so setup, disconnection, and unsupported providers remain
visible instead of appearing as empty successful searches.

## Current slice

- Apple Music catalog search calls Apple's official catalog endpoint and keeps
  the Apple song ID, artwork, album, and Apple Music URL. It uses the selected
  storefront. A developer token is supplied at build time as
  `APPLE_MUSIC_DEVELOPER_TOKEN`; do not commit a token or the signing key.
- This does not sign a user into Apple Music. Searching the user's library and
  using MusicKit playback require separate Apple Music user authorization.
- Spotify currently reports `needsSetup`. A user-facing connection requires a
  registered Spotify app, Authorization Code with PKCE, a per-platform redirect
  URI, and protected refresh-token storage before search can be enabled.
- YouTube Music is reported as unsupported. The official YouTube Data API
  searches videos and is not a YouTube Music account or catalog API.
- Provider results are opened at their official service URL. Nova does not
  proxy audio or claim that catalog metadata grants playback rights.

## Before production

The compile-time Apple developer token is a development bridge only: a token
embedded in a shipped client can be extracted. Production should obtain short-
lived developer tokens from a small server-side token broker that keeps the
Apple Music private signing key off client devices. User OAuth tokens must be
stored in platform-protected storage and never in `SharedPreferences`.

Spotify development-mode apps require the app owner to meet Spotify's Premium
requirement and each test user to be allowlisted. Spotify's platform rules also
restrict commercial streaming integrations and playback/content handling; Nova
must use Spotify's approved playback handoff or SDK model rather than retrieving
or altering audio.

## Required setup to complete account connections

1. Choose the initial supported targets (Android, iOS, Windows, macOS, Linux,
   and/or web). OAuth callback registration and secure storage differ by target.
2. Create a Spotify developer app, provide its client ID, and register a
   redirect URI for each selected target. No client secret belongs in Flutter.
3. For Apple catalog development, supply a short-lived developer token through
   the local build environment. For production, configure the token broker and
   Apple developer credentials on the server; never put the signing key in the
   repository or app bundle.
4. Apple Music library search/playback additionally needs an Apple Music user
   authorization flow on supported Apple platforms. The catalog token alone is
   not that user authorization.

No credentials are currently configured in the project.
