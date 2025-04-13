# 💸 TIPJARV1 – Smart Contract on Monad

**TIPJARV1** is a smart contract written in Solidity for the Monad blockchain.  
It allows users to send MON (Monad native token) along with a short message as a tip.  
Tips are stored on-chain and can be viewed by anyone. Only the contract owner can withdraw the funds.

---

## ✨ Features

- 💰 Accept tips in MON with custom messages
- 🧾 Store sender address, amount, message, and timestamp for each tip
- 🧠 Fallback function supports plain transfers (empty message)
- 👑 Owner-only withdrawals
- 🔐 Ownership transfer functionality
- 📜 View individual or all tips

---

## 🚀 How to Deploy on Remix (Monad)

1. Open [Remix IDE](https://remix.ethereum.org)
2. Create a new file: `TIPJARV1.sol`
3. Paste the smart contract code from this repository
4. Compile using **Solidity v0.8.24**
5. Connect MetaMask to Monad and deploy

---

## 🔗 Deploy to Remix

Click below to open the contract in Remix with one click:  
[![Open in Remix](https://img.shields.io/badge/Deploy%20in-Remix-blue?logo=ethereum&style=for-the-badge)](https://remix.ethereum.org/#url=https://raw.githubusercontent.com/keizerh1/TIPJARV1/main/TIPJARV1.sol)

---

## 📦 Contract Overview

| Function               | Description                                     |
|------------------------|-------------------------------------------------|
| `sendTip(string)`      | Send MON with a message                         |
| `getTip(uint index)`   | View a specific tip                             |
| `getAllTips()`         | View all tips                                   |
| `getContractBalance()` | View contract balance in MON                    |
| `withdrawFunds()`      | Owner-only: Withdraw all funds                  |
| `transferOwnership()`  | Owner-only: Transfer contract ownership         |
| `receive()`            | Accept plain MON (empty message)                |

---

## ⚠️ License

**This project is not open source. All rights reserved.**

---

## 🧑‍💻 Author

Made with 💜 by [keizerh1](https://github.com/keizerh1)
