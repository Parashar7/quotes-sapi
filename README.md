# demo-quotes-sapi

A small MuleSoft **System API** that returns a hardcoded catalog of sales quotes. It has one endpoint, `GET /api/quotes`, defined by an OpenAPI 3.0 contract and served through APIkit. There is no backend or database behind it, so it is useful as a demo, a CI/CD test target, or a template for a real System API.

| | |
|---|---|
| Artifact | `com.acme:demo-quotes-sapi:1.0.0-SNAPSHOT` (`mule-application`) |
| Mule runtime | 4.11.x (`minMuleVersion` 4.11.0, app runtime 4.11.6) |
| Java | 17 |
| Connectors | HTTP connector 1.10.6, APIkit module 1.11.10 |
| API contract | `src/main/resources/api/demo-quotes-sapi.yaml` (OAS 3.0.3, `v1`) |

## What it does

1. An HTTP listener receives any request under `/api/*`.
2. The flow records the method, path and correlation id, and logs the start and end of every request (`api.start` and `api.end` log categories).
3. The APIkit router validates the request against the OpenAPI contract and routes it to the matching flow.
4. `GET /quotes` calls the `load-quotes` sub-flow, which returns the hardcoded list in `src/main/resources/dwl/quotes.dwl`.
5. Any error is turned into a JSON problem-detail body by the global error handler.

## How to call it

```
GET http://localhost:8081/api/quotes
```

The host, port and base path come from `config/global/config.yaml`: `0.0.0.0`, `8081` and `/api`.

**Required header:** `x-correlation-id`, an id you choose to trace the request. It is written to the logs and echoed back in error responses.

```bash
curl -i http://localhost:8081/api/quotes \
  -H 'x-correlation-id: 8f3b2c10-6a1e-4f2d-9c77-2a1b6e5d4c3a'
```

### Response `200 OK`

```json
[
  { "quoteId": "q-100", "customerName": "Acme Corp", "amount": 1200.00, "currency": "USD", "status": "open" },
  { "quoteId": "q-200", "customerName": "Northwind Traders", "amount": 480.50, "currency": "USD", "status": "accepted" }
]
```

| Field | Type | Notes |
|---|---|---|
| `quoteId` | string | for example `q-100` |
| `customerName` | string | |
| `amount` | number (double) | |
| `currency` | string | |
| `status` | string | `open`, `accepted` or `expired` per the contract |

### Errors

Errors return a JSON problem-detail body: `type`, `title`, `status`, `detail`, `instance`, `correlationId`.

| Status | When | `type` |
|---|---|---|
| 400 | The request fails contract validation, for example a missing `x-correlation-id` | `https://errors.example.com/quotes/bad-request` |
| 404 | The path is not in the contract | `https://errors.example.com/quotes/not-found` |
| 500 | Any other error | `https://errors.example.com/quotes/server-error` |

> Only the 400 and 404 APIkit errors are mapped explicitly. Other APIkit errors, such as a `POST` to `/api/quotes` (method not allowed), fall through to the catch-all handler and return `500`. This comes from reading the error-handling flow and has not been tested against a running instance.

## Run it locally

You need JDK 17 and Maven, plus Anypoint Studio or Mule Runtime 4.11.x.

- **Studio:** import the project (*File > Import > Mule Project from File System*) and run it as a Mule Application. The listener comes up on port 8081.
- **Maven:** `mvn clean package` produces a deployable archive under `target/`.

## Configuration

| File | Purpose |
|---|---|
| `config/${mule.env}/config.yaml` | Environment-specific values. `mule.env` defaults to `dev`. |
| `config/global/config.yaml` | Shared values: `http.host`, `http.port`, `http.basePath` |

To use another environment, add `config/<env>/config.yaml` and start the app with `-Dmule.env=<env>`. There are no credentials or secrets in this project.

## Project layout

```
pom.xml                          Maven build (mule-application)
mule-artifact.json               Mule runtime and Java requirements
demo-quotes-sapi-spec.zip        Packaged API spec
src/main/mule/
  demo-quotes-sapi.xml           Main flow, load-quotes sub-flow, GET /quotes flow
  common/global.xml              Properties, HTTP listener config, APIkit config
  common/error-handling.xml      Global error handler (400, 404, 500)
src/main/resources/
  api/                           OpenAPI contract and Exchange descriptor
  config/                        Per-environment and global properties
  dwl/quotes.dwl                 The hardcoded quote data
  log4j2.xml                     Logging configuration
```
