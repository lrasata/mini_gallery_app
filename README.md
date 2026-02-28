# Mini Gallery App (Flutter)

A small Flutter app that lets you pick images from your device and upload them using a **presigned upload URL** flow. After uploading, the app refreshes and displays uploaded images in a responsive grid.

> 🚧 **Local testing only (for now):** This project is currently intended to run only in a local/dev environment. It is not production-ready yet.

---

## Features

- Pick an image from a local device
- Fetch and display uploaded images
- Responsive grid layout (adapts to screen size)
- Basic loading state during upload and refresh

---

## Requirements

- Flutter SDK (use the version compatible with `pubspec.yaml`)
- A backend service (local/dev) that provides:
  - **Fetch endpoint** returning a JSON object with an `images` list
  - **Presign endpoint** returning an `upload_url` for direct upload
- A local `.env` file with required configuration values

---

## Getting Started (Local / Dev)

### 1) Install dependencies
```bash
flutter pub get
```
### 2) Create a local `.env`

Create a `.env` file in the project root.

Example (use placeholders; replace with your local/dev values):
```env
FETCH_FILES_ENDPOINT=<LOCAL_FETCH_ENDPOINT_URL>
UPLOAD_ENDPOINT=<LOCAL_UPLOAD_ENDPOINT_URL>

# Following env variables are only for Local testing purposes
USER_ID=<LOCAL_TEST_USER_ID>
RESOURCE=<LOCAL_TEST_RESOURCE>
```
Notes:
- Keep `.env` values local.
- Do not commit real environment values.

### 3) Run the app
```bash
flutter run
```
---

## How the Upload Works (High Level)

1. App requests a presigned upload URL from the backend (using filename/resource/mime type).
2. Backend returns `upload_url`
3. App uploads the image bytes directly to that URL in the s3 bucket.
4. App refreshes the image list also by getting a presigned get URL and updates the grid.

---

## Project Structure

The project is organized to stay clean even with a small codebase:
```
text
lib/
    app/                    App bootstrap
    core/                   Cross-cutting concerns (config, helpers, errors)
    features/   
        gallery/              Gallery feature (models + presentation)
    services/               Networking services (API integration)
    main.dart               Entry point (.env load, runApp)
```
---

## Limitations (Why It’s Local-Only Right Now)

This is intentionally minimal. For production readiness you would typically add:

- Authentication/authorization
- Secure handling of configuration/secrets (no `.env` shipping strategies)
- Better error mapping and user-friendly UI messaging
- Image caching and improved placeholders
- Pagination/infinite scrolling for large galleries
- CI checks and more automated tests
- Environment flavors (dev/staging/prod) and build pipelines

---

## License

Add a license if you plan to distribute publicly. For now, this project is intended for local testing/development use.

