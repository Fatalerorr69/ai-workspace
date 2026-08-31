analyze_repo() {
  REPO="$1"
  TYPE="generic"

  if find "$REPO" -name "*android*" | grep -q .; then
    TYPE="android"
  elif find "$REPO" -name "*kali*" | grep -q .; then
    TYPE="pentest"
  elif find "$REPO" -name "*.sh" | grep -q .; then
    TYPE="system"
  fi

  echo "$TYPE"
}
