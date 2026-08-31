log() {
  echo "[$(date '+%F %T')] $1" | tee -a "$ULTRA_ROOT/modules/web/ultra.log"
}
