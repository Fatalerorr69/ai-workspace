STARCORE 36.20E - PC TERMUX AUTOCONNECT v2

Run CREATE_ICON.cmd once. Then use the desktop shortcut. The launcher discovers Tailscale 100.x endpoints when tailscale.exe is available, verifies each candidate through TCP/SSH, and requires USER=u0_a344 plus STARCORE_TERMUX_OK=YES before opening an interactive SSH session. It never connects to an unverified endpoint. The launcher uses PowerShell -NoExit and stays open after SSH exits. No Android, Magisk, package, service, setting, or reboot changes are performed. Logs are stored in .\logs.
