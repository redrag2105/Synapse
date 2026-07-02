@echo off
setlocal

REM ========= CONFIG =========
set DEVICE=23090RA98G
set GOOGLE_EMAIL=areddragon2018@gmail.com
set COMMON=--device %DEVICE% --dart-define-from-file=.env
set AUTH=%COMMON% --dart-define=PATROL_GOOGLE_EMAIL=%GOOGLE_EMAIL%
REM ==========================

IF /I "%~1"=="auth" (
    patrol test %AUTH% -t patrol_tests/authentication_test.dart
) ELSE IF /I "%~1"=="pub" (
    patrol test %COMMON% -t patrol_tests/publication_test.dart
) ELSE IF /I "%~1"=="journal" (
    patrol test %COMMON% -t patrol_tests/journal_test.dart
) ELSE IF /I "%~1"=="export" (
    patrol test %AUTH% -t patrol_tests/export_test.dart
) ELSE IF /I "%~1"=="logout" (
    patrol test %AUTH% -t patrol_tests/logout_test.dart
) ELSE (
    echo.
    echo ===============
    echo Usage:
    echo   test auth
    echo   test pub
    echo   test journal
    echo   test export
    echo   test logout
    echo ===============
    echo.
)