:: Chocolatey - The missing Package Manager for Windows
:: https://chocolatey.org/install
::
:: --Install Script--
:: From and administrative cmd prompt run this:
::
:: @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"


:: Install Packages
choco install cmake --installargs 'ADD_CMAKE_TO_PATH=""System""' -y
for %%P in (ninja nodejs 7zip) do choco install %%P -y

:: Upgrade Packages
for %%P in (cmake ninja nodejs 7zip) do choco upgrade %%P -y
