# Ginger Node.js Example

A minimal Node.js HTTP server packaged and deployed using the [Ginger OS](https://gingercybersecurity.com).

Must use Node.js v25 for sea-config capabilities. Last tested on gingervm 0.6.0

## What this is

This repo shows how to run a Node.js application inside a Ginger VM — a minimal, audited, immutable execution environment. The VM image contains only the Node.js binary and its required shared libraries. The application code and configuration are delivered via a separate deployment disk. Everything runs under a non-root UID with read-only file permissions and CIS-compliant audit logging.

## Project structure

```
ginger-nodejs/
├── www/
│   └── server.js          # Node.js application code
└── ginger/
    ├── image.yaml         # Runtime image: Node.js binary + shared libs
    ├── deployment.yaml    # Deployment disk: app code + config files
    ├── init.yaml          # Boot commands: auditd, measurerd, node
    ├── data.yaml          # Empty data disk definition
    ├── auditd.conf        # Audit daemon configuration
    ├── auditd.rules       # CIS-compliant audit rules
    ├── build.sh           # Builds image version and deployment via gingervm CLI
    ├── setup.sh           # Configures host network bridge and TAP devices
    └── launch.sh          # Launches the VM with QEMU
```

## Preparing the Node.js binary

Rather than running `node server.js` directly, the application is compiled into a [Node.js Single Executable Application (SEA)](https://nodejs.org/api/single-executable-applications.html). This produces a self-contained binary that cannot modify itself at runtime, which is a requirement for the integrity measurements Ginger takes of the image. A mutable binary would produce non-deterministic measurements and break attestation.

The SEA config also sets `--jitless` and `--predictable`. These carry some performance cost — JIT compilation is disabled and V8 uses a fixed-layout heap — but they eliminate the unpredictable memory write patterns that JIT produces. Without those, Ginger can take accurate runtime attestation of the binary's memory state.

**`www/sea-config.json`:**

```json
{
  "main": "server.js",
  "output": "../dist/node-server",
  "disableExperimentalSEAWarning": true,
  "execArgv": [
    "--jitless",
    "--predictable"
  ]
}
```

To build the SEA binary:

```sh
cd www
mkdir -p ../dist
node --build-sea sea-config.json
```

This produces `dist/node-server`. To verify it works:

```sh
./dist/node-server
# Server running at http://0.0.0.0:3000/
```

The `dist/node-server` binary is what `deployment.yaml` copies into the VM at `/usr/www/`.

## Building and deploying

### Prerequisites

- `gingervm` CLI installed at `~/.ginger/bin/gingervm`
- A Ginger org, image, and server already created (get IDs from the Ginger dashboard)
- Node.js v22 installed via nvm (or update the `source` path in `image.yaml`)

Follow the [instructions online](https://www.gingercybersecurity.com/steps-every-deployment.html) for information about creating a VM

Output disk images are written to `target/`.

## Security notes

- The Node.js binary runs with only the `cap_mmap_exec` Linux capability (needed for V8 JIT). All other capabilities are dropped.
- Application code is deployed read-only (`0o400`) and owned by UID 10.
- Audit logging follows CIS Benchmark recommendations: time changes, permission modifications, file deletions, mount events, and kernel module loads are all recorded.
- There is no shell, package manager, or compiler in the image — only the Node.js binary and its shared libraries.
