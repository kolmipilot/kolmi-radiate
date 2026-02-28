# Radiate

To create a radiation zone use the module from Eden or Zeus.

---

## Radiation Power

Instead of defining a fixed radius, you now define **radiation power** in **mSv/h**.

**Power range:**  
`0 – 100000 mSv/h`

---

## Radius Calculation

The radiation radius is **not linear**.

**Formula:**
radius = 10 * sqrt(power)

### Examples

| Power (mSv/h) | Radius            |
|---------------|-------------------|
| 100           | 100 m             |
| 3000          | ~547 m            |
| 10000         | 1000 m (1 km)     |
| 100000        | ~3162 m (~3.1 km) |

This prevents unrealistic extreme distances for high radiation values.  
Scaling is non-linear.

---

## Radiation Falloff

Radiation intensity decreases using an inverse square model:
intensity = power / (1 + distance²)

This means:

- Very strong near the source  
- Drops rapidly with distance  
- Physically inspired behavior  

---

## Dose Calculation

Radiation is calculated per second.
dose += (effectiveIntensity * deltaTime) / 3600

Division by `3600` converts **mSv/h → mSv per second**.

---

## Radiation Types

The system supports multiple simultaneous radiation types:

- `alpha`
- `beta`
- `gamma`

Each unit stores active radiation types as:
[
["alpha", intensity],
["beta", intensity],
["gamma", intensity]
]

All types contribute independently to the total accumulated dose.

---

## Protection System

Base protection value:
protection = 1

### Equipment modifiers

- Gas mask: `+10`
- Suit: `+5`
- Backpack: `+5`

---

## Alpha Radiation

- Mask → **90% reduction**
- Mask + Suit → **100% protection**
- No mask → full exposure

Alpha mainly represents inhalation hazard.

---

## Beta Radiation

doseRate = intensity / (protection * 1)

Standard protection scaling.

---

## Gamma Radiation

doseRate = intensity / (protection * 0.1)

Gamma is much harder to block.  
Protection is **10× less effective** than for beta.

---

## Summary

- Radius scales with **√power** (non-linear)
- Falloff follows inverse square law
- Multiple radiation types supported simultaneously
- Protection effectiveness depends on radiation type
- Dose accumulates per second and converts correctly from mSv/h
