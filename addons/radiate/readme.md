# Radiate

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

## Medical & Treatment

The system includes specialized medical items to manage accumulated radiation dose.

### EDTA Auto-Injector

- **Type:** Medical Item (ACE Medical)
- **Effect:** Reduces radiation dose by **400 units** (10% of lethal dose) per injection. Provides +10 temporary radiation protection for 180 seconds.
- **Efficiency Multiplier:** Configurable via CBA setting (default 1.0, range 0.1–10.0).
- **Usage:** Applied through the ACE Medical treatment menu on arms or legs.

### Prussian Blue

- **Type:** Medical Item (ACE Medical)
- **Effect:** Reduces radiation dose by **300 units** (7.5% of lethal dose) per dose. Provides +10 temporary radiation protection for 180 seconds.
- **Efficiency Multiplier:** Configurable via CBA setting (default 1.0, range 0.1–10.0).
- **Usage:** Applied through the ACE Medical treatment menu.

### Potassium Iodate

- **Type:** Medical Item (ACE Medical)
- **Effect:** Reduces radiation dose by **200 units** (5% of lethal dose) per dose. Provides +20 temporary radiation protection for 180 seconds (stronger protection than EDTA or Prussian Blue).
- **Efficiency Multiplier:** Configurable via CBA setting (default 1.0, range 0.1–10.0).
- **Usage:** Applied through the ACE Medical treatment menu.

### Absolute Vodka

- **Type:** Consumable
- **Effect:** Reduces radiation dose by **40 units** (1% of lethal dose) per drink. Provides +5 temporary radiation protection. Adds vodka level for visual effects (chromatic aberration).
- **Efficiency Multiplier:** Configurable via CBA setting (default 1.0, range 0.1–10.0).
- **Progression:** Full Bottle → Half Bottle → Empty Bottle.
- **Usage:** Can be consumed through self-interaction or inventory actions.

### Blood Tester (Blood Analyzer)

- **Type:** Medical Item (ACE Medical)
- **Usage:** Used to examine a patient's blood to check radiation levels.
- **Action:** Applied through the ACE Medical "Examine" menu on the left or right arm.
- **Time:** Takes 10 seconds by default (configurable via CBA settings).
- **Effect:** Measures the patient's accumulated radiation dose with a realistic variance of ±5% and logs the result in the patient's ACE Medical log (e.g., `Radiation Check: 120.5`).
- **Consumption:** Reusable item; is not consumed upon use.

### Treatment Comparison

| Item              | Base Reduction | Protection Bonus | Protection Duration | Efficiency Setting                    |
|-------------------|----------------|------------------|---------------------|---------------------------------------|
| EDTA              | 400 mSv (10%)  | +10              | 180 s               | `edtaEfficiencyMultiplier`            |
| Prussian Blue     | 300 mSv (7.5%) | +10              | 180 s               | `PrussianBlueEfficiencyMultiplier`    |
| Potassium Iodate  | 200 mSv (5%)   | +20              | 180 s               | `potassiumIodateEfficiencyMultiplier` |
| Vodka             | 40 mSv (1%)    | +5               | configurable        | `vodkaEfficiencyMultiplier`           |

---

## Contamination

When a unit is exposed to high-intensity radiation (above **500 mSv/h**), the unit becomes **contaminated**. Contamination means the unit itself becomes a moving radiation source, emitting radiation of the same type it was exposed to.

### How Contamination Works

1. **Exposure Timer:** The unit must remain in the radiation zone for a configurable amount of time (default: **30 seconds**, CBA setting `contaminationTime`).
2. **Protection Check:** Contamination only occurs if the unit lacks **full CBRN protection** — both a gas mask and a protective suit from the available equipment lists.
3. **Contamination Source:** Once contaminated, a new radiation source is created and **attached to the unit**. The contamination power is **10% of the original source power**.
4. **Duration:** The contamination persists as long as the unit is alive and the contamination entry exists in its variable. The unit will continue to emit radiation to nearby units until decontaminated.

### Decontamination

Decontamination clears all active contaminations from a unit and removes the attached radiation sources.

- **Action:** Applied through the ACE Medical treatment menu.
- **Effect:** Removes all contamination entries and stops the unit from emitting radiation.
- **Server-side:** The function runs on the server to ensure proper cleanup of global radiation sources.

### CBRN Protection

Full CBRN protection (gas mask + protective suit) **prevents contamination entirely**. Units wearing both items from the configured available lists will not become contaminated, regardless of radiation intensity.

| Equipment | Effect on Contamination |
|-----------|------------------------|
| Gas Mask + Suit | **Full protection** — no contamination |
| Gas Mask only | No protection — contamination possible |
| Suit only | No protection — contamination possible |
| Neither | No protection — contamination possible |

---

## Summary

- Radius scales with **√power × 3** (realistic ranges)
- Falloff follows **inverted quadratic** law (intensity = power × (1 - (d/r)²))
- Multiple radiation types supported simultaneously
- Protection effectiveness depends on radiation type
- Dose accumulates per second and converts correctly from mSv/h
- Reusable **Blood Tester** allows checking patient radiation dose via the ACE Medical examine menu
- Three medical treatments available: **EDTA**, **Prussian Blue**, and **Potassium Iodate** — each with configurable efficiency
- **Absolute Vodka** provides minor radiation reduction with visual side effects
- **Contamination system** — units become mobile radiation sources when exposed to high radiation without CBRN protection
- **Decontamination** available through ACE Medical treatment menu

## Credits

- Bottle of Vodka Model -  "Absolut Vodka 1L Bottle" (https://skfb.ly/oEVpX) by Saandy is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).