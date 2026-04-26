# kolmi's Radiate

Mod introduces new ultimate radiation system to the Arma 3. It includes multiple  devices, advenced radiation system, medical symphotmps, and even more.

## Radiate

To create a radiation zone use the module from Eden or Zeus.

---

## Radiation Power

Instead of defining a fixed radius, you now define **radiation power** in **mSv/h**.

**Power range:**  
`0 – 100000 mSv/h`

---

## Radius Calculation

The radiation radius scales with the square root of power for realistic behavior.

**Formula:**
radius = sqrt(power) × 3

### Examples

| Power (mSv/h) | Radius            |
|---------------|-------------------|
| 100           | 30 m              |
| 3000          | ~164 m            |
| 10000         | ~300 m            |
| 100000        | ~949 m            |
| 300000        | ~1,643 m (~1.6 km)|

This provides realistic ranges where high radiation levels have appropriate effective distances.

---

## Radiation Falloff

Radiation intensity decreases using an inverted quadratic function:
intensity = power × (1 - (distance / radius)²)

This means:

- Full power at the source (distance = 0)
- Drops quadratically with distance
- Reaches zero exactly at the radius boundary
- Realistic falloff for point radiation sources  

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

- Radius scales with **√power × 3** (realistic ranges)
- Falloff follows **inverted quadratic** law (intensity = power × (1 - (d/r)²))
- Multiple radiation types supported simultaneously
- Protection effectiveness depends on radiation type
- Dose accumulates per second and converts correctly from mSv/h
