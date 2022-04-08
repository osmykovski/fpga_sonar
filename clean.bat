@echo off 

echo Cleaning ip folder
FOR /D %%x IN (.\sources\ip\*) DO rmdir /s /q "%%x\hdl"
FOR /D %%x IN (.\sources\ip\*) DO rmdir /s /q "%%x\synth"
FOR /D %%x IN (.\sources\ip\*) DO rmdir /s /q "%%x\sim"
FOR /D %%x IN (.\sources\ip\*) DO rmdir /s /q "%%x\simulation"
FOR /D %%x IN (.\sources\ip\*) DO del "%%x\*.vhdl"
FOR /D %%x IN (.\sources\ip\*) DO del "%%x\*.veo"
FOR /D %%x IN (.\sources\ip\*) DO del "%%x\*.vho"
FOR /D %%x IN (.\sources\ip\*) DO del "%%x\*.v"
FOR /D %%x IN (.\sources\ip\*) DO del "%%x\*.xdc"
FOR /D %%x IN (.\sources\ip\*) DO del "%%x\*.xml"
FOR /D %%x IN (.\sources\ip\*) DO del "%%x\*.dcp"

echo Cleaning bd folder
rmdir /s /q ".\sources\bd\hdl"
rmdir /s /q ".\sources\bd\hw_handoff"
rmdir /s /q ".\sources\bd\ip"
rmdir /s /q ".\sources\bd\ipshared"
rmdir /s /q ".\sources\bd\sim"
rmdir /s /q ".\sources\bd\synth"
rmdir /s /q ".\sources\bd\ui"
del .\sources\bd\*.xdc
del .\sources\bd\*.bxml

echo Cleaning Vivado folder
rmdir /s /q .\vivado
mkdir vivado

echo Cleaning root folder
rmdir /s /q .\.Xil
del *.jou
del *.log
del *.debug
del *.str
