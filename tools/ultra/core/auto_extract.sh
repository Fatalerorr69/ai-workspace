auto_extract_all() {
  extract_github_repos

  for repo in "$ULTRA_ROOT/cache/github/"*; do
    [ -d "$repo" ] || continue
    generate_module_from_repo "$repo"
  done

  repair_structure
  log "[DONE] Auto‑extract z GitHubu dokončen"
}
