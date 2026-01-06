@echo off
:: ============================================
:: ULTIMATE AKKU-OPTIMIERUNG - 25+ TWEAKS
:: ============================================
:: Doppelklick zum Ausfuehren (fragt nach Admin-Rechten)
:: ============================================

powershell -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0Ultimate-Tweaks.ps1\"' -Verb RunAs"
