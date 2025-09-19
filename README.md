# 🔥 matterStates

A sandbox simulation exploring simplified thermodynamics, matter transitions and elemental interactions — all running in real-time using Lua and Love2D.

---
> ⚠️ This project is currently under development. Many mechanics are still experimental or incomplete.

## 🚀 Features

- 🌡️ Each tile contains one or more materials with temperature and combustion properties.
- 🔥 Flammable materials can ignite and evolve over time (wood → charcoal → ash).
- 🧪 Gases like oxygen and carbon dioxide can be modeled (WIP).
- 📊 Tooltips show tile data: material composition, temperature, and burning status.
- 🧠 Minimal rules approximating heat propagation and oxidation.

---

## 🎮 Tech Stack

- **Engine**: [Love2D](https://love2d.org/)  
- **Language**: Lua  
- **UI**: Custom lightweight components (Buttons, Tooltip, etc.)

---

## 🧪 Current Material States

| Material | Flammable | Ignition Point | Transforms into |
|----------|-----------|----------------|-----------------|
| Wood     | ✅        | 300°C          | Charcoal        |
| Charcoal | ✅        | 400°C          | Ash             |
| Ash      | ❌        | —              | —               |
| Oxygen   | —         | —              | Carbon (WIP)    |


---

## 📁 Folder Structure

