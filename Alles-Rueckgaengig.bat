@echo off
:: ============================================
:: ALLE AENDERUNGEN RUECKGAENGIG MACHEN
:: ============================================

powershell -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0Revert-Tweaks.ps1\"' -Verb RunAs"
