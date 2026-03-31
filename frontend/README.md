# Frontend

Sample Vue 3 application for the `converter_fstack_v1` workspace.

## Run locally

```bash
npm install
npm run dev
```

Then open the Vite URL shown in the terminal, typically `http://localhost:5173`.

## Build for production

```bash
npm run build
npm run preview
```

## Run with Docker

From the repository root:

```bash
docker compose up --build frontend
```

The production container serves the built app on port `80`.

