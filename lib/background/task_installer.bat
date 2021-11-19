taskkill /f /im "daemon.exe"
del "%HOMEDRIVE%%HOMEPATH%\Start Menu\Programs\Startup\daemon.exe"
copy /Y "%cd%\daemon.exe" "%HOMEDRIVE%%HOMEPATH%\Start Menu\Programs\Startup"
schtasks /delete /f /tn "Hawks Down Task"
schtasks /delete /f /tn "Hawks Up Task"
schtasks /delete /f /tn "Hawks Startup Down Runner"
schtasks /delete /f /tn "Hawks Startup Up Runner"
start "" "%HOMEDRIVE%%HOMEPATH%\Start Menu\Programs\Startup\daemon.exe" & exit