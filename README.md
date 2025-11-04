# 🔥 MatterStates

A **sandbox simulation** exploring **thermodynamics**, **material transitions**, and **elemental interactions** — all computed in real time with **Lua** and **LÖVE2D**.

---

> ⚠️ **Development status:** actively evolving.  
> The core physics engine is functional, but most materials and reactions are still experimental.

---

## 🌍 Overview

**MatterStates** models how matter behaves and transforms under simple physical rules:
- Each **cell** of the map represents a particle of matter.
- Each particle has **temperature**, **state**, **stability**, and **chemical properties**.
- Materials can **burn**, **melt**, **evaporate**, or **crumble** depending on local conditions.
- Heat, gravity, and chemical reactions propagate across neighboring cells in real time.

Originally developed as an isolated simulation, MatterStates now also powers the physical core of **The Burning Flock** — where these systems are embedded in a gameplay environment.

---

## 🚀 Features

- 🔥 **Dynamic combustion chain**  
  Wood → Charcoal → Ash, each stage with its own ignition temperature and heat output.  

- 🌫️ **Gas mechanics**  
  Oxygen and carbon dioxide react to fire and influence combustion; gases can move and expand naturally.  

- 🪨 **Granular and solid materials**  
  Solids (stone, charcoal) and granulars (soil, ash) obey gravity differently — they fall, slide, and compact.  

- 🧊 **Stability system**  
  Particles continuously test their surroundings and can become unstable again if their support disappears — allowing collapses and realistic debris behavior.  

- 🌡️ **Thermal diffusion**  
  Temperature propagates between particles; flammable materials ignite when reaching their ignition point.  

- 🎨 **Visual feedback**  
  Each particle is color-coded by material and temperature; tooltips show live data (state, temp, stability, etc.).  

---

## 🧠 Architecture

- **Core:** cellular simulation engine managing particle logic and interactions.  
- **Modules:** `DensityManager`, `ChemicalProperties`, `temperatureManager`, `Map`, and `Particle` and `Button`.  
- **Front-end:** rendered and updated by LÖVE’s real-time loop.  

All materials follow the same update cycle but use different motion models:
| State | Handler | Example materials |
|--------|----------|-------------------|
| solid | `didFall()` | Stone, Charcoal |
| granular | `didSlide()` | Soil, Ash |
| liquid | `didMove()` | Water (WIP) |
| gas | `didMove()` | Oxygen, CO₂ |

---

## 🧪 Current Material States

| Material | State | Flammable | Ignition Point | Transforms into |
|-----------|--------|------------|----------------|-----------------|
| Wood | Solid | ✅ | 300 °C | Charcoal |
| Charcoal | Solid | ✅ | 400 °C | Ash |
| Ash | Granular | ❌ | — | — |
| Oxygen | Gas | — | — | Combines with Carbon |
| Carbon Dioxide | Gas | — | — | — |
| Soil | Granular | ❌ | — | — |
| Stone | Solid | ❌ | — | — |

---

## 📁 Folder Structure
