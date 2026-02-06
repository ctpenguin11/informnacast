@echo off
color F0
:: InformN/Acast - Cisco Messaging Tool
:: Version 1.2 - Fixed menu looping thingy

:: These shouldn't need to be changed unless you have actual web passwords setup.
set USER=cisco
set PASS=cisco

:: Dont touch anything here
for /f %%A in ('powershell -NoProfile -Command "[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('%USER%:%PASS%'))"') do set AUTH=%%A

cls
echo =================================================
echo 	CREATED BY CTPENGUIN11 ON GITHUB
echo 		 VERSION 1.0.2
echo =================================================
echo		 	InformN/Acast
pause

:MENU
cls
echo =============================================
echo      InformN/Acast - Cisco Messaging Tool
echo =============================================
echo 1 - Basic Message
echo 2 - Alert Message
echo 3 - Exit
echo 4 - Help
echo =============================================
set /p choice=Select an option: 

if "%choice%"=="1" goto AUDIOLESS
if "%choice%"=="2" goto AUDIO
if "%choice%"=="3" goto EXIT
if "%choice%"=="4" goto HELP
echo Invalid option, press try again...
pause
goto MENU

:AUDIOLESS
:: Dont touch anything here
set /p PHONES=Enter the phone IPs (separated by spaces): 
set /p MSG=Enter the message to send: 

for %%I in (%PHONES%) do (
    echo Sending audioless message to %%I...
    curl -s -H "Authorization: Basic %AUTH%" --data "XML=<CiscoIPPhoneText><Title>InformN/Acast Message</Title><Prompt> </Prompt><Text>%MSG%</Text></CiscoIPPhoneText>" http://%%I/CGI/Execute
    echo Done.
)

echo Message sent to all phones.
pause
goto MENU

:AUDIO
set /p PHONES=Enter the phone IPs (separated by spaces): 
set /p MSG=Enter the message to send: 

:: If you have brain cells you can add any .raw file that is on your provisioning server here

echo Select an alert sound:
echo 1 - CallBack
echo 2 - Chime
echo 3 - Pulse
set /p ALERTCHOICE=Choose an alert sound: 

if "%ALERTCHOICE%"=="1" set ALERT=CallBack.raw
if "%ALERTCHOICE%"=="2" set ALERT=Chime.raw
if "%ALERTCHOICE%"=="3" set ALERT=Pulse1.raw

:: Dont touch anything here
for %%I in (%PHONES%) do (
    echo Sending alert message to %%I...
    :: Send the text message first
    curl -s -H "Authorization: Basic %AUTH%" --data "XML=<CiscoIPPhoneText><Title>InformN/Acast Alert</Title><Prompt> </Prompt><Text>%MSG%</Text></CiscoIPPhoneText>" http://%%I/CGI/Execute
    :: Play the built-in alert sound
    curl -s -H "Authorization: Basic %AUTH%" --data "XML=<CiscoIPPhoneExecute><ExecuteItem URL=""Play:%ALERT%"" /></CiscoIPPhoneExecute>" http://%%I/CGI/Execute
    echo Done.
)

echo Alert message sent to all phones.
pause
goto MENU

:HELP
cls
echo - If no text shows up when sending an alert, make sure CGI is
echo working on your CUCM, CME, FPBX, or whatever your running.
echo - You can test CGI by doing http://PHONE-IP/CGI/Screenshot
echo - If audio isn't working make sure Callback.raw, Chime.raw,
echo and Pulse1.raw are avaliable on your tftp/http provisioning server.
echo these are standard on CUCM (and I believe CME aswell).
echo but lets be honest who is using this with CUCM/CME?
pause
goto MENU

:EXIT
echo Exiting InformN/Acast...
exit
