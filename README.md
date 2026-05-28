# Local Cafe Hunter

Flutter app for discovering local cafes, with the backend foundation now set up for Supabase.

## Current Scope

- Email/password authentication is wired through Supabase Auth.
- The cafe catalog now syncs from a Supabase-backed `cafe_catalog` table, with bundled local seed fallback when Supabase is unavailable.
- Future feature branches will keep expanding map, reviews, collections, and profile flows.
- This branch focuses on backend catalog sync and runtime setup, not the full product surface.

## Setup

### 1. Create a Supabase project

- Open https://supabase.com
- Create a project
- In `Project Settings > API`, copy:
  - `Project URL`
  - `Publishable key`

### 2. Configure env

Copy `.env.example` to `.env` and fill in:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxx
```

### 3. Apply backend schema

Run `supabase/schema.sql` in the Supabase SQL editor.

This creates the public cafe catalog table and seeds the current demo cafes, so the app can pull a real catalog from Supabase instead of only using the bundled local seed.

If review/storage RLS needs to be repaired later, use `supabase/repair_reviews_storage.sql`.

### 4. Run the app

```bash
flutter pub get
flutter run
```

## Notes

- If sign-up succeeds but no session is created, disable `Confirm email` in Supabase Auth for this demo flow.
- Firebase emulator files and rules will be handled separately as legacy support.
