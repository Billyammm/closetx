# ClosetX

ClosetX is a Flutter + Supabase t-shirt e-commerce app built around role-based routing. The same app presents different experiences for customers, designers, and admins after login.

## What the app does

The product is focused on shopping and showcasing t-shirt designs with AR-ready assets.

- Customers can browse approved t-shirts and AR-ready products.
- Customers must sign in before using protected actions such as cart and liked items.
- Designers can upload new t-shirt designs, attach images, and optionally upload GLB or GLTF 3D assets.
- Admins can review submissions, approve or reject designs, manage users, and monitor the catalog.
- Role detection routes each user to the correct dashboard after authentication.

## Core flow

1. The app starts in `lib/main.dart`.
2. Supabase is initialized before the UI runs.
3. The splash screen shows the ClosetX brand and loads the first experience.
4. Users sign in or register with Supabase Auth.
5. The app reads the user role and routes to the customer, designer, or admin dashboard.

## Screens

- Splash screen: branded entry screen with a fade animation and automatic transition.
- Login screen: email/password sign-in with validation and a sign-up link.
- Sign-up screen: collects name, email, password, confirmation, and role choice.
- Home screen: role router that sends users to the correct dashboard.
- Customer dashboard: approved catalog access, AR-ready browsing, and placeholder wishlist/orders areas.
- Designer dashboard: upload and manage designs, plus pending approval views.
- Admin dashboard: moderation, user management, and catalog overview.

## Data and backend

ClosetX uses Supabase for authentication, database access, and storage.

### Tables

- `users`: stores profile data such as id, email, full name, role, and created_at.
- `tshirts`: stores product and design data such as designer_id, title, description, price, sizes, colors, image_url, stock_quantity, and status.
- `models_3d`: stores optional 3D model metadata for AR support.

### Storage buckets

- `tshirt-images`: uploaded shirt images.
- `tshirt-models`: uploaded 3D files.

## Project structure

- `lib/`: real Flutter app source code.
- `lib/screens/`: login, sign-up, splash, home, and dashboard screens.
- `test/`: automated tests.
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`: standard Flutter platform wrappers.
- `build/`: generated build output and safe to ignore.

## Current status

### Implemented

- Supabase sign-in and registration.
- Role-based routing.
- Designer upload flow for shirts and optional 3D assets.
- Admin approval and moderation flow.
- Customer product browsing.
- Shared app theming with Poppins and custom controls.

### Still placeholder or future work

- Wishlist.
- Orders.
- Analytics pages.
- Forgot-password flow.
- Full AR try-on interaction.
- Product detail pages.

## Local setup

1. Install Flutter.
2. Run `flutter pub get`.
3. Configure your Supabase project if the URL or anon key changes.
4. Start the app with `flutter run`.

## Testing

Run the widget test suite with:

```bash
flutter test
```

The default starter test has been replaced with a smoke test for the real ClosetX app shell.
