Get-WmiObject Win32_process | select name, commandline > C:\work\process.txt
notepad C:\work\process.txt