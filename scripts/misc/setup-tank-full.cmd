@echo off

title Full Setup Script For Tank

set adb="..\..\bin\adb.exe"
set adbKill=%adb% kill-server
set adbStart=%adb% start-server
set adbWait=%adb% wait-for-device
set sleep="..\..\bin\wait.exe"
set extractRAR="..\..\bin\rar.exe" -y x
set cocolor="..\..\bin\cocolor.exe"

set install=%adb% install
set uninstall=%adb% uninstall
set push=%adb% push
set pull=%adb% pull
set shell=%adb% shell
set twrp=%shell% twrp

if not exist "%temp%\firestick-loader" md "%temp%\firestick-loader"

:start
color 0e
set accessibility="..\settings\tank\system\scripts\accessibility.sh"
set applications="..\settings\tank\system\scripts\applications.sh"
set device="..\settings\tank\system\scripts\device.sh"
set displaysounds="..\settings\tank\system\scripts\display-sounds.sh"
set help="..\settings\tank\system\scripts\help.sh"
set myaccount="..\settings\tank\system\scripts\my-account.sh"
set network="..\settings\tank\system\scripts\network.sh"
set notifications="..\settings\tank\system\scripts\notifications.sh"
set preferences="..\settings\tank\system\scripts\preferences.sh"

:: Set Flags For ADB Service and Unknown Sources
set adb_success=0
set unk_sources_success=0

:: TWRP Requirement
set twrp_available=0
cls
echo Looking For TWRP Recovery...
echo.
%pull% /twres/twrp "%temp%\firestick-loader"
%sleep% 2
if exist "%temp%\firestick-loader\twrp" set twrp_available=1
if %twrp_available%==1 goto intro
if %twrp_available%==0 goto twrpfail

:twrpfail
%cocolor% 0c
echo.
echo.
echo TWRP Not Found!
echo.
echo Trying To Force Boot Into Recovery...
echo.
%sleep% 3
%adb% reboot recovery
%sleep% 25
goto start

:intro
:: Reset TWRP Flags
if %twrp_available%==1 del /f /q "%temp%\firestick-loader\twrp"
if %twrp_available%==1 set twrp_available=0

color 0c
set noway=0
cls
%cocolor% 0a
echo TWRP Found!
echo.
%cocolor% 0c
echo WARNING! THIS WILL ERASE THE SYSTEM AND DATA ON YOUR DEVICE DURING SETUP!
echo.
%cocolor% 0e
echo.
echo The device will have the following done to it:
echo.
echo - Downgrade To Stock Amazon FireOS 5.2.6.3
echo - Amazon Bloat Removed
echo - Custom OOBE App That Only Requires Remote, Wifi Setup, and Account
echo - Custom Home Menu and Data Installed To System
echo - TitaniumBackup Installed To System. Use To Restore All Apps and Data
echo - SH Script Runner Installed To System. Use For Shortcuts On Home Menu
echo - Restore Directory and All APKs and TitaniumBackup Files To /system/
echo - Scripts Directory and All Home Scripts To Launch Amazon Settings To /system/
echo - Magisk Installed For SuperUser and ADB Service
echo.
echo - The System, Data, Cache, and Dalvik Cache Will Be Formatted During Setup
echo.
echo.
echo Press 1 to EXIT, B to create BACKUP, or just press ENTER to continue...
echo.
set /p noway=

if %noway%==1 goto end
if %noway%==b %twrp% backup /system,data,cache,dalvik
if %noway%==b %adb% reboot recovery
if %noway%==b %sleep% 25
if %noway%==b goto start
if %noway%==B %twrp% backup /system,data,cache,dalvik
if %noway%==B %adb% reboot recovery
if %noway%==B %sleep% 25
if %noway%==B goto start

:stage1
color 0e
set rwcheck=0
cls
echo.
echo Mounting System as RW for System Install...
echo.
%twrp% remountrw /system

echo.
echo Check For RW Mount Status
echo.
echo.
echo Press 1 if there is an error, otherwise just press ENTER
echo.
set /p rwcheck=

if %rwcheck%==1 echo.
if %rwcheck%==1 echo Waiting on Reboot...
if %rwcheck%==1 echo.
if %rwcheck%==1 %adb% reboot recovery
if %rwcheck%==1 %sleep% 25
if %rwcheck%==1 goto stage1

cls
echo Preparing Stock FireOS 5.2.6.3 Downgrade Files
echo.
if not exist "%temp%\firestick-loader\downgrade\stick2" md "%temp%\firestick-loader\downgrade\stick2"
%extractRAR% "..\..\downgrade\stick2\firmware-tank-5.2.6.3.split" "%temp%\firestick-loader\downgrade\stick2"

cls
echo Pushing Downgrade Bin to /sdcard/...
echo.
%push% "%temp%\firestick-loader\downgrade\stick2\update-kindle-full_tank-288.6.0.6_user_606753420_5.2.6.3.bin" /sdcard/
%sleep% 2

cls
echo Wiping System...
echo.
%twrp% wipe /system
%sleep% 5

cls
echo Installing Stock FireOS 5.2.6.3...
echo.
%twrp% install /sdcard/update-kindle-full_tank-288.6.0.6_user_606753420_5.2.6.3.bin
%sleep% 5

cls
echo Cleaning Up Files...
echo.
rd /s /q "%temp%\firestick-loader\downgrade\stick2"
%shell% "rm /sdcard/update-kindle-full_tank-288.6.0.6_user_606753420_5.2.6.3.bin"
%sleep% 2

cls
echo Preparing Reboot...
echo.
%sleep% 5

cls
echo Rebooting Back Into Recovery...
echo.
%adb% reboot recovery
%sleep% 25

:stage2
color 0e
set rwcheck=0
cls
echo.
echo Mounting System as RW...
echo.
%shell% "mount -o rw /system"

echo.
echo Check For RW Mount Status
echo.
echo Press 1 if there is an error, otherwise just press ENTER
echo.
set /p rwcheck=

if %rwcheck%==1 echo.
if %rwcheck%==1 echo Waiting on Reboot...
if %rwcheck%==1 echo.
if %rwcheck%==1 %adb% reboot recovery
if %rwcheck%==1 %sleep% 25
if %rwcheck%==1 goto stage2

cls
echo Debloating Amazon Apps...
echo.

%sleep% 3

:: FireOS 5.05 and Higher
%shell% "rm -r /system/priv-app/amazon.jackson-19/"
%shell% "rm -r /system/priv-app/AmazonKKWebViewLib/"
%shell% "rm -r /system/priv-app/BackupRestoreConfirmation/"
%shell% "rm -r /system/priv-app/com.amazon.ags.app/"
%shell% "rm -r /system/priv-app/com.amazon.avod/"
%shell% "rm -r /system/priv-app/com.amazon.bueller.music/"
%shell% "rm -r /system/priv-app/com.amazon.device.sync/"
%shell% "rm -r /system/priv-app/com.amazon.device.sync.sdk.internal/"
%shell% "rm -r /system/priv-app/com.amazon.kindle.cms-service/"
%shell% "rm -r /system/priv-app/com.amazon.kindle.devicecontrols/"
%shell% "rm -r /system/priv-app/com.amazon.kso.blackbird/"
%shell% "rm -r /system/priv-app/com.amazon.ods.kindleconnect/"
%shell% "rm -r /system/priv-app/com.amazon.securitysyncclient/"
%shell% "rm -r /system/priv-app/com.amazon.sharingservice.android.client.proxy.release/"
%shell% "rm -r /system/priv-app/com.amazon.shoptv.client/"
%shell% "rm -r /system/priv-app/com.amazon.tv.aiv.support/"
%shell% "rm -r /system/priv-app/com.amazon.tv.legal.notices/"
%shell% "rm -r /system/priv-app/com.amazon.tv.parentalcontrols/"
%shell% "rm -r /system/priv-app/com.amazon.venezia/"
%shell% "rm -r /system/priv-app/com.amazon.visualonawv/"
%shell% "rm -r /system/priv-app/ContentSupportProvider/"
%shell% "rm -r /system/priv-app/CrashManager/"
%shell% "rm -r /system/priv-app/ConnectivityDiag/"
%shell% "rm -r /system/priv-app/DeviceClientPlatformContractsFramework/"
%shell% "rm -r /system/priv-app/DeviceMessagingAndroid/"
%shell% "rm -r /system/priv-app/DeviceMessagingAndroidInternalSDK/"
%shell% "rm -r /system/priv-app/DeviceMessagingAndroidSDK/"
%shell% "rm -r /system/priv-app/DownloadProvider/"
%shell% "rm -r /system/priv-app/FireApplicationCompatibilityEnforcer/"
%shell% "rm -r /system/priv-app/FireApplicationCompatibilityEnforcerSDK/"
%shell% "rm -r /system/priv-app/FireRecessProxy/"
%shell% "rm -r /system/priv-app/FireTVDefaultMediaReceiver/"
%shell% "rm -r /system/priv-app/FireTvNotificationService/"
%shell% "rm -r /system/priv-app/FireTVSystemUI/"
%shell% "rm -r /system/priv-app/FusedLocation/"
%shell% "rm -r /system/priv-app/ManagedProvisioning/"
%shell% "rm -r /system/priv-app/marketplace_service_receiver/"
%shell% "rm -r /system/priv-app/sync-provider_ipc-release/"
%shell% "rm -r /system/priv-app/sync-service-fireos-release/"
%shell% "rm -r /system/priv-app/UnifiedShareActivityChooser/"
%shell% "rm -r /system/priv-app/WallpaperCropper/"

:: Launcher
%shell% "rm -r /system/priv-app/com.amazon.tv.launcher/"

:: OTA Updates
%shell% "rm -r /system/priv-app/DeviceSoftwareOTA/"
%shell% "rm -r /system/priv-app/DeviceSoftwareOTAIdleOverride/"

:: Help
%shell% "rm -r /system/priv-app/com.amazon.tv.csapp/"
%shell% "rm -r /system/priv-app/com.amazon.tmm.tutorial/"

:: Remote Update Service
::%shell% "rm -r /system/priv-app/com.amazon.device.bluetoothdfu/"

:: Fitbit Support?
%shell% "rm -r /system/priv-app/com.amazon.h2clientservice/"

:: Amazon Voice Support
%shell% "rm -r /system/priv-app/com.amazon.vizzini/"

:: VoiceView
%shell% "rm -r /system/priv-app/logan/"

:: USB Tuner
::%shell% "rm -r /system/priv-app/com.amazon.malcolm/"

:: FireOS 5.2.1.1
%shell% "rm -r /system/priv-app/AdvertisingIdSettings/"
%shell% "rm -r /system/priv-app/com.amazon.tv.nimh/"
%shell% "rm -r /system/priv-app/FireTvSaleService/"
%shell% "rm -r /system/priv-app/IvonaTTS/"
%shell% "rm -r /system/priv-app/IvonaTtsOrchestrator/"
%shell% "rm -r /system/priv-app/TvProvider/"

:: FireOS 5.2.6.2
%shell% "rm -r /system/priv-app/com.amazon.alexashopping/"
%shell% "rm -r /system/priv-app/com.amazon.tv.livetv/"
%shell% "rm -r /system/priv-app/com.amazon.amazonvideo.livingroom/"
%shell% "rm -r /system/priv-app/com.amazon.kor.demo/"

:: FireOS 5.2.6.3
%shell% "rm -r /system/priv-app/TIFObserverService/"

:: WiFi Locker
%shell% "rm -r /system/priv-app/CredentialLockerAndroid-tablet-release/

:: com.amazon.webview.awvdeploymentservice Developer Build
%shell% "rm -r /system/priv-app/AwvDeploymentService/"

:: Amazon WebView Metrics Service
%shell% "rm -r /system/priv-app/AwvMetricsService/"

:: OttSsoLib
::%shell% "rm -r /system/priv-app/com.amazon.tv.ottssolib/"

:: OttSsoCompanionApp
::%shell% "rm -r /system/priv-app/com.amazon.tv.ottssocompanionapp/"

:: Log Manager
%shell% "rm -r /system/priv-app/LogManager-logd/"

:: Amazon Echo?
%shell% "rm -r /system/priv-app/SsdpService/"

:: Settings Notification Center
%shell% "rm -r /system/priv-app/com.amazon.tv.notificationcenter/"

:: DIAL (Discovery-and-Launch) protocol (allow apps to access via second screen)
%shell% "rm -r /system/priv-app/DialService/"

:: CustomMediaController
%shell% "rm -r /system/priv-app/com.amazon.cardinal/"

:: Under /system/app/
%shell% "rm -r /system/app/DocumentsUI/"
%shell% "rm -r /system/app/fdrw/"
%shell% "rm -r /system/app/PicoTts/"
%shell% "rm -r /system/app/UnifiedSettingsProvider/"
%shell% "rm -r /system/app/WhiteListedUrlProvider/"

:: Fire Basic Keyboard (Simplified Chinese)
%shell% "rm -r /system/app/PinyinIME/"

:: FrameworksMetrics
%shell% "rm -r /system/app/FrameworksMetrics/"

%sleep% 5

cls
echo Setting Up Directories For Restore...
echo.
%shell% "rm -r /sdcard/restore/"
%shell% "mkdir /sdcard/restore/"
%shell% "rm -r /sdcard/TitaniumBackup/"
%shell% "mkdir /sdcard/restore/apk/"
%shell% "mkdir /sdcard/restore/apk/system/"
%sleep% 2

cls
echo Pushing Restore Data to /sdcard/...
echo.
%push% "..\..\data\tank\post-debloated\restore" /sdcard/restore/
%sleep% 2

cls
echo Copying TitaniumBackup Data For Restore...
echo.
%shell% "cp -r /sdcard/restore/TitaniumBackup/ /sdcard/"
%sleep% 2

cls
echo Creating System Restore Directories and Setting Permissions...
echo.
%shell% "rm -r /system/restore/"
%shell% "mkdir /system/restore/"
%shell% "mkdir /system/restore/apk/"
%shell% "mkdir /system/restore/apk/system/"

%shell% "chmod 0777 /system/restore/"
%shell% "chown root:root /system/restore/"

%shell% "chmod 0777 /system/restore/apk/"
%shell% "chown root:root /system/restore/apk/"

%shell% "chmod 0777 /system/restore/apk/system/"
%shell% "chown root:root /system/restore/apk/system/"

cls
echo Copying Data from /sdcard to /system...
echo.
%shell% "cp -r /sdcard/restore/ /system/"
%sleep% 2

cls
echo Settings Permissions and Copying Custom OOBE App to /system/priv-app/...
echo.
%shell% "rm -r /system/priv-app/com.amazon.tv.oobe/"
%shell% "mkdir /system/priv-app/com.amazon.tv.oobe/"
%shell% "chmod 0775 /system/priv-app/com.amazon.tv.oobe/"
%shell% "chown root:root /system/priv-app/com.amazon.tv.oobe/"
%shell% "cp /system/restore/apk/system/com.amazon.tv.oobe.apk /system/priv-app/com.amazon.tv.oobe/com.amazon.tv.oobe.apk"
%shell% "chmod 0644 /system/priv-app/com.amazon.tv.oobe/com.amazon.tv.oobe.apk"
%shell% "chown root:root /system/priv-app/com.amazon.tv.oobe/com.amazon.tv.oobe.apk"
%sleep% 2

cls
echo Removing Unused Images and Sounds...
echo.
%shell% "rm -r /system/res/images/*.*"
%shell% "rm -r /system/res/sound/*.*"
%sleep% 2

cls
echo Installing Magisk for SU and ADB Access on Stock Rom...
echo.
%push% "..\..\rooting\tank\Magisk-v19.3.zip" /data/local/tmp/
%shell% "twrp install /data/local/tmp/Magisk-v19.3.zip"
%sleep% 3

cls
echo Wiping Data and Cache...
echo.
%twrp% wipe data
%sleep% 5

cls
echo Waiting For Cache Rebuild and ADB Service...
echo.
echo This may take up to 5 minutes or more and Remote Find screen will be loaded
echo.
echo Do not interact with the device yet!
echo.

%shell% reboot
%adbWait%

cls
echo Rebooting Back To Recovery To Continue...
echo.
%shell% reboot recovery
%sleep% 25

:stage3
set rwcheck=0
cls
echo Mounting System as RW...
echo.
%shell% "mount -o rw /system"

echo.
echo Check For RW Mount Status
echo.
echo.
echo Press 1 if there is an error, otherwise just press ENTER
echo.
set /p rwcheck=

if %rwcheck%==1 echo.
if %rwcheck%==1 echo Waiting on Reboot...
if %rwcheck%==1 echo.
if %rwcheck%==1 %adb% reboot recovery
if %rwcheck%==1 %sleep% 25
if %rwcheck%==1 goto stage3

%sleep% 3

cls
echo Pushing Settings Scripts to Temp...
echo.
%push% %accessibility% /data/local/tmp/
%push% %applications% /data/local/tmp/
%push% %device% /data/local/tmp/
%push% %displaysounds% /data/local/tmp/
%push% %help% /data/local/tmp/
%push% %myaccount% /data/local/tmp/
%push% %network% /data/local/tmp/
%push% %notifications% /data/local/tmp/
%push% %preferences% /data/local/tmp/

%sleep% 2

cls
echo Pushing Restore Home Script to Temp...
echo.
%push% "..\restore-home.sh" /data/local/tmp/

%sleep% 2

cls
echo Making Directories and Setting Permissions for Settings Scripts...
echo.
%shell% "rm -r /system/scripts/"
%shell% "mkdir /system/scripts/"
%shell% "chmod 0777 /system/scripts/"

%sleep% 2

cls
echo Copying Settings Scripts From Temp to /system...
echo.
%shell% "cp /data/local/tmp/accessibility.sh /system/scripts/accessibility.sh"
%shell% "cp /data/local/tmp/applications.sh /system/scripts/applications.sh"
%shell% "cp /data/local/tmp/device.sh /system/scripts/device.sh"
%shell% "cp /data/local/tmp/display-sounds.sh /system/scripts/display-sounds.sh"
%shell% "cp /data/local/tmp/help.sh /system/scripts/help.sh"
%shell% "cp /data/local/tmp/my-account.sh /system/scripts/my-account.sh"
%shell% "cp /data/local/tmp/network.sh /system/scripts/network.sh"
%shell% "cp /data/local/tmp/notifications.sh /system/scripts/notifications.sh"
%shell% "cp /data/local/tmp/preferences.sh /system/scripts/preferences.sh"

%sleep% 2

cls
echo Copying Restore Home Script From Temp to /system...
echo.
%shell% "cp /data/local/tmp/restore-home.sh /system/scripts/restore-home.sh"

%sleep% 2

cls
echo Setting Permissions...
echo.
%shell% "chmod 0777 /system/scripts/*.sh"
%shell% "chown root:root /system/scripts/*.sh"

%sleep% 2

cls
echo Copying Apps to /system/app/...
echo.
%shell% "rm -r /system/app/Launcher/"
%shell% "mkdir /system/app/Launcher/"
%shell% "chmod 0775 /system/app/Launcher/"
%shell% "chown root:root /system/app/Launcher/"
%shell% "cp /system/restore/apk/system/Launcher.apk /system/app/Launcher/Launcher.apk"

%shell% "rm -r /system/app/ScriptRunner/"
%shell% "mkdir /system/app/ScriptRunner/"
%shell% "chmod 0775 /system/app/ScriptRunner/"
%shell% "chown root:root /system/app/ScriptRunner/"
%shell% "cp /system/restore/apk/system/ScriptRunner.apk /system/app/ScriptRunner/ScriptRunner.apk"

%shell% "rm -r /system/app/TitaniumBackup/"
%shell% "mkdir /system/app/TitaniumBackup/"
%shell% "chmod 0775 /system/app/TitaniumBackup/"
%shell% "chown root:root /system/app/TitaniumBackup/"
%shell% "cp /system/restore/apk/system/TitaniumBackup.apk /system/app/TitaniumBackup/TitaniumBackup.apk"

%shell% "rm -r /system/app/TitaniumBackupAddon/"
%shell% "mkdir /system/app/TitaniumBackupAddon/"
%shell% "chmod 0775 /system/app/TitaniumBackupAddon/"
%shell% "chown root:root /system/app/TitaniumBackupAddon/"
%shell% "cp /system/restore/apk/system/TitaniumBackupAddon.apk /system/app/TitaniumBackupAddon/TitaniumBackupAddon.apk"

%sleep% 2

cls
echo Setting Permissions For System Apps...
echo.
%shell% "chmod 0644 /system/app/Launcher/Launcher.apk"
%shell% "chown root:root /system/app/Launcher/Launcher.apk"

%shell% "chmod 0644 /system/app/ScriptRunner/ScriptRunner.apk"
%shell% "chown root:root /system/app/ScriptRunner/ScriptRunner.apk"

%shell% "chmod 0644 /system/app/TitaniumBackup/TitaniumBackup.apk"
%shell% "chown root:root /system/app/TitaniumBackup/TitaniumBackup.apk"

%shell% "chmod 0644 /system/app/TitaniumBackupAddon/TitaniumBackupAddon.apk"
%shell% "chown root:root /system/app/TitaniumBackupAddon/TitaniumBackupAddon.apk"

%sleep% 2

::cls
::echo Copying App Data back to /data/data/
::echo.
::%shell% "cp -r /system/restore/ca.dstudio.atvlauncher.pro/ /data/data/"
::%shell% "cp -r /system/restore/com.adamioan.scriptrunner/ /data/data/"
::%shell% "cp -r /system/restore/com.fluxii.android.mousetoggleforfiretv/ /data/data/"
::%shell% "chmod -R 0777 /data/data/ca.dstudio.atvlauncher.pro/"
::%shell% "chmod 0660 /data/data/ca.dstudio.atvlauncher.pro/databases/sections.db"
::%shell% "chmod 0660 /data/data/ca.dstudio.atvlauncher.pro/databases/sections.db-shm"
::%shell% "chmod 0660 /data/data/ca.dstudio.atvlauncher.pro/databases/sections.db-wal"
::%shell% "chmod -R 0777 /data/data/com.adamioan.scriptrunner/"
::%shell% "chmod -R 0777 /data/data/com.fluxii.android.mousetoggleforfiretv/"

::%sleep% 2

cls
echo Installing BusyBox...
echo.
%push% "..\..\bin\android\busybox" /data/local/tmp/
%shell% "chmod 0777 /data/local/tmp/busybox"
%shell% "/data/local/tmp/busybox --install"

%sleep% 2

cls
echo Wiping Cache and Dalvik Cache...
echo.
%twrp% wipe cache
%sleep% 5
%twrp% wipe dalvik
%sleep% 5

cls
echo Fixing Permissions...
echo.
%twrp% fixperms /
%sleep% 5

cls
echo Re-Installing Magisk for SU Access...
echo.
%push% "..\..\rooting\tank\Magisk-v19.3.zip" /data/local/tmp/
%shell% "twrp install /data/local/tmp/Magisk-v19.3.zip"

%sleep% 2

cls
echo Preparing For Reboot...
echo.

%sleep% 8

cls
echo Waiting For Cache Rebuild and ADB Service...
echo.
echo This may take up to 5 minutes or more and Remote Find screen will be loaded
echo.
echo Do not interact with the device yet!
echo.

%adb% reboot
%adbWait%

:: Check For ADB and if Not Available, Go Back and Wait
:chkadb
%sleep% 5
%shell% "nothing=nothing"
if %errorlevel%==0 goto stage4
%sleep% 30
goto chkadb

:stage4
:: Enable ADB and Unknown Sources
cls
echo Enabling ADB and Unknown Sources...
echo.
%shell% settings --user 0 put global adb_enabled 1
if %errorlevel%==0 set adb_success=1
%shell% settings --user 0 put secure install_non_market_apps 1
if %errorlevel%==0 set unk_sources_success=1

:chk1
if %adb_success%==1 goto chk2

:chk2
if %unk_sources_success%==1 goto final

:: If anything fails, go back to check adb status
goto chkadb

:final
set unkadb=0
echo.
echo Check For ADB and Unknown Sources Enable Status
echo.
echo NOTE: ADB is already enabled as a system service
echo This will also set these values in Amazon Settings app
echo.
echo.
echo Press 1 if there is an error, otherwise just press ENTER
echo.
set /p unkadb=

if %unkadb%==1 echo.
if %unkadb%==1 echo Waiting For ADB Service...
if %unkadb%==1 echo.
if %unkadb%==1 %sleep% 10
if %unkadb%==1 goto stage4

%sleep% 3

cls
color 0a
echo Finished!
echo.
echo Complete the user setup to configure remote, wifi, and Amazon account
echo.
echo Once on Launcher, use TitaniumBackup to restore data for
echo Home, Mouse Toggle, Reboot, and SH Script Runner Settings
echo.
echo Press any key to exit...
pause>nul


:end



