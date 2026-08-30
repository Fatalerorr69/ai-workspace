param(
  [Parameter(Mandatory=\True)][string]\,
  [Parameter(Mandatory=\True)][string]\,
  [Parameter(Mandatory=\True)][string]\
)
# Template: mirror a push do cílového monorepo. Upravit dle potřeby.
\ = "https://github.com/\/\.git"
\ = Join-Path \C:\Users\Starko\AppData\Local\Temp ("\.git")
if (Test-Path \) { Remove-Item -Recurse -Force \ }
git clone --mirror \ \
cd \
git remote add target \
git push target --mirror
Write-Host "Pushed mirror of \ to \"
