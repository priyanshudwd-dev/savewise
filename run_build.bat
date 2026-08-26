@echo off
set PATH=C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32;C:\Windows;C:\Program Files\Git\cmd;C:\Users\Shweta\AppData\Local\Android\Sdk\platform-tools;C:\src\flutter\bin
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
cd /d "C:\Users\Shweta\Documents\Default Project\savewise"
del /f /q "C:\src\flutter\bin\cache\lockfile" 2>nul
rmdir /s /q "C:\Users\Shweta\Documents\Default Project\savewise\android\.gradle" 2>nul
echo START_%DATE%_%TIME% > "C:\Users\Shweta\Documents\Default Project\savewise\build_log.txt"
call flutter build apk --debug --no-pub --no-tree-shake-icons >> "C:\Users\Shweta\Documents\Default Project\savewise\build_log.txt" 2>&1
echo BUILD_EXIT_%ERRORLEVEL% >> "C:\Users\Shweta\Documents\Default Project\savewise\build_log.txt"