# Code Ocean Capsule — iot-mcp-servers

This is the reproducibility capsule for iot-mcp-servers (design principles for safe, vendor-neutral AI-to-OT integration).

## What this capsule runs

```bash
bash code_ocean/run
```

`run` attempts **all 5 servers** in this repo, honestly, not just the 2 that are
guaranteed to work in any environment:

| Server | Needs external service? | Expected here |
|---|---|---|
| `aws-iot-core` | No (tests `moto`, a Python-native AWS API emulator, in-process) | **26/26 pass**, guaranteed |
| `azure-iot-hub` | No (tests `respx` HTTP mocking + a local AMQP fake, in-process) | **37/37 pass**, guaranteed |
| `eclipse-ditto` | Yes -- real Ditto stack via `docker compose` | Pass IF this environment supports Docker-in-Docker; otherwise fails gracefully with a logged reason |
| `mqtt` | Yes -- real Eclipse Mosquitto broker via `docker compose` | Same as above |
| `sparkplug-b` | Yes -- real broker/stack via `docker compose` | Same as above |

It auto-detects the project root at runtime (checks `/code` first, since that's
where Code Ocean's git-clone import actually places this repo's contents, with a
fallback search) -- no manual file reorganizing is needed.

## Why the 3 docker-compose servers are attempted, not silently skipped

A Code Ocean Reproducible Run environment is itself a Docker container. Running a
NESTED `docker compose` stack inside it (what `eclipse-ditto`, `mqtt`, and
`sparkplug-b` each require for a real-instance test, per this project's own design
principle of testing against real backends rather than mocks) needs
Docker-in-Docker support, which most standard (non-privileged) Code Ocean compute
plans do not provide.

This capsule does **not** assume that limitation in advance and skip those 3 servers
unconditionally -- `code_ocean/run` genuinely attempts `docker compose up` for each
one, and only reports a graceful skip/failure if that actually fails in your specific
environment. If your Code Ocean plan or environment does support privileged/DinD
execution, all 5 servers run for real here, with real Docker containers.

If your environment does NOT support this (the common case), `run`'s output makes
this explicit: each of the 3 servers gets its own labeled section in
`/results/summary.txt` stating exactly why it didn't run, plus the precise command to
reproduce it yourself outside Code Ocean:

```bash
git clone https://github.com/nagarjunr/mcp-industrial-iot-codeocean.git
cd mcp-industrial-iot-codeocean/<server-name>   # eclipse-ditto, mqtt, or sparkplug-b
docker compose up -d
uv run pytest -v
```

These 3 servers' test suites were run for real, against genuine live backend
instances, during this project's own development -- see the project's evaluation
discussion and each server's own README for that verification.

## Results layout

- `/results/summary.txt` -- top-level pass/fail/skip status for all 5 servers
- `/results/<server>_pytest.log` -- full pytest output for each server individually

## A note on how this repo relates to its source repo

This repo (`mcp-industrial-iot-codeocean`) is a code-only public mirror created
specifically for Code Ocean's Git-import requirement (which needs a public
repository). The private source repository is not linked here.
