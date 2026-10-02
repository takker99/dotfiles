#!/usr/bin/env bash
# Body of the `update` app defined in flake.nix (writeShellApplication).
# Expects FLAKE_SYSTEM (injected via runtimeEnv) and runtimeInputs on PATH.

update_opencode2() {
  local sources=nix/opencode2/sources.json
  local current latest url sys npm hash tmp count=0
  local platforms='{}'

  if [[ ! -f $sources ]]; then
    echo "opencode2: $sources not found" >&2
    return 1
  fi
  if ! current=$(jq -er .version "$sources"); then
    echo "opencode2: cannot read the version from $sources" >&2
    return 1
  fi
  if ! latest=$(curl -fsSL https://registry.npmjs.org/@opencode/cli/latest \
      | jq -er '.version | select(test("^[0-9]+[.][0-9]+[.][0-9]+"))'); then
    echo "opencode2: cannot determine the latest version from the npm registry" >&2
    return 1
  fi

  if [[ $latest == "$current" ]]; then
    echo "opencode2: $current is already the latest release"
    return 0
  fi
  if [[ $(printf '%s\n%s\n' "$current" "$latest" | sort -V | tail -n 1) != "$latest" ]]; then
    echo "opencode2: npm latest ($latest) is not newer than $current; skipping" >&2
    return 0
  fi
  if ! jq -e '.platforms | type == "object" and length > 0' "$sources" >/dev/null; then
    echo "opencode2: $sources does not list any platform" >&2
    return 1
  fi

  echo "opencode2: $current -> $latest"
  while read -r sys npm; do
    url="https://registry.npmjs.org/@opencode/cli-$npm/-/cli-$npm-$latest.tgz"
    if ! hash=$(nix store prefetch-file --unpack --json "$url" \
        | jq -er '.hash | select(startswith("sha256-"))'); then
      echo "opencode2: failed to prefetch $url" >&2
      return 1
    fi
    if ! platforms=$(jq -c --arg sys "$sys" --arg npm "$npm" --arg hash "$hash" \
        '. + {($sys): {npm: $npm, hash: $hash}}' <<<"$platforms"); then
      echo "opencode2: failed to record the hash for $sys" >&2
      return 1
    fi
    echo "  $sys -> $hash"
    count=$((count + 1))
  done < <(jq -r '.platforms | to_entries[] | "\(.key) \(.value.npm)"' "$sources")

  if (( count == 0 )); then
    echo "opencode2: no platform entries found in $sources" >&2
    return 1
  fi

  if ! tmp=$(mktemp nix/opencode2/.sources.json.XXXXXX); then
    echo "opencode2: cannot create a temporary file" >&2
    return 1
  fi
  if ! jq -n --arg version "$latest" --argjson platforms "$platforms" \
      '{version: $version, platforms: $platforms}' >"$tmp"; then
    rm -f "$tmp"
    echo "opencode2: failed to render the new $sources" >&2
    return 1
  fi
  if ! mv "$tmp" "$sources"; then
    rm -f "$tmp"
    echo "opencode2: failed to write $sources" >&2
    return 1
  fi
}

# Resolve the repository root first so relative references
# (flake.lock, sources.json) always hit this repository, no
# matter where the app is invoked from.
if ! root=$(git rev-parse --show-toplevel 2>/dev/null) \
    || [[ ! -f $root/flake.nix || ! -f $root/nix/opencode2/sources.json ]]; then
  echo "update: run from inside the dotfiles repository" >&2
  exit 1
fi
cd "$root" || exit 1

status=0

echo "Updating flake..."
nix flake update

if ! update_opencode2; then
  echo "update: opencode2 version bump failed; continuing with Home Manager" >&2
  status=1
fi

echo "Updating home-manager..."
if ! nix run .#home-manager -- switch --flake ".#takker-$FLAKE_SYSTEM"; then
  status=1
fi

if git status --porcelain -- flake.lock nix/opencode2/sources.json | grep -q .; then
  echo "Changed files to review and commit:"
  git status --short -- flake.lock nix/opencode2/sources.json
fi

if (( status != 0 )); then
  echo "Update finished with errors" >&2
  exit "$status"
fi
echo "Update complete!"

