@echo off
@echo Cleaning SpecFlow Cache ...
c:
DEL %temp%\specflow-stepmap-* /s
@echo Done.