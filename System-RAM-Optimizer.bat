@echo off
:: SYSTEM-LEVEL RAM OPTIMIZER - Einmalig ausfuehren!
:: Wirkt permanent ohne laufendes Script

powershell -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0System-Level-RAM-Optimizer.ps1\"' -Verb RunAs"
