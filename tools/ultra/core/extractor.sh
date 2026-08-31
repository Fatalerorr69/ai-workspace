extract_github_repos() {
  GH_USER="Fatalerorr69"
  GH_API="https://api.github.com/users/$GH_USER/repos?per_page=100"
  CACHE="$ULTRA_ROOT/cache/github"

  mkdir -p "$CACHE"
  log "[EXTRACT] Načítám repozitáře z GitHubu: $GH_USER"

  curl -s "$GH_API" | jq -r '.[] | .clone_url' > "$CACHE/repos.list"

  while read -r repo; do
    NAME=$(basename "$repo" .git)
    log "[EXTRACT] Klonuji $NAME"
    git clone --depth=1 "$repo" "$CACHE/$NAME" || true
  done < "$CACHE/repos.list"
}
