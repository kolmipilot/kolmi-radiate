# kolmi's Radiate

Mod introduces new ultimate radiation system to the Arma 3. It includes multiple devices, advanced radiation system, medical symptoms, and even more.

**Mod is still WIP:**
known bugs:

- zeus module dosent work as intented. It opens two times window, just type values two times and click okay. Everything should work then. Will be fixed soon.

**Contribution:**
Leave feedback on the Steam Workshop page or report bugs via GitHub.

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

| Item              | Base Reduction | Protection Bonus | Protection Duration | Efficiency Setting                   |
|-------------------|----------------|------------------|---------------------|--------------------------------------|
| EDTA              | 400 mSv (10%)  | +10              | 180 s               | `edtaEfficiencyMultiplier`           |
| Prussian Blue     | 300 mSv (7.5%) | +10              | 180 s               | `PrussianBlueEfficiencyMultiplier`   |
| Potassium Iodate  | 200 mSv (5%)   | +20              | 180 s               | `potassiumIodateEfficiencyMultiplier`|
| Vodka             | 40 mSv (1%)    | +5               | configurable        | `vodkaEfficiencyMultiplier`          |

---

## Radiation Sickness

Radiation sickness is automatically applied to any unit that has accumulated a radiation dose above defined thresholds.  
The system runs as a per-frame handler (`fnc_radiationSicknessPFH`) and evaluates every local unit every **2 seconds**.

### How It Works

Symptoms are defined as templates. Each template has:

| Field              | Description                                              |
|--------------------|----------------------------------------------------------|
| `symptomId`        | Unique string identifier                                 |
| `thresholdOn`      | Dose (mSv) at which the symptom activates                |
| `thresholdOff`     | Dose (mSv) at which the symptom deactivates (hysteresis) |
| `effectType`       | What kind of in-game effect is applied                   |
| `chance`           | Probability (0.0–1.0) per evaluation tick                |
| `effectParams`     | Parameters passed to the effect handler                  |

Once a symptom is **active**, it continues to re-apply its effect every `Symptom Tick Interval` seconds (default: 5s). Damage **scales with dose** — the further the dose exceeds the activation threshold, the stronger the effect.

**Severity formula:**

```sqf
severityMultiplier = 1 + (severityCoeff × (dose − thresholdOn) / thresholdOn)
```

### Symptom Progression

#### Mild (1000–2000 mSv)

| Symptom   | Threshold ON | Threshold OFF | Effect                        |
|-----------|--------------|---------------|-------------------------------|
| Nausea    | 1000 mSv     | 800 mSv       | Pain increase (+0.15)         |
| Vomiting  | 1200 mSv     | 900 mSv       | Vomiting sound / KAT puking   |
| Headache  | 1200 mSv     | 900 mSv       | Pain increase (+0.20)         |

#### Moderate (2000–3000 mSv)

| Symptom       | Threshold ON | Threshold OFF | Effect                        |
|---------------|--------------|---------------|-------------------------------|
| Blurred Vision| 2000 mSv     | 1500 mSv      | Post-process blur (0.1–0.4)   |
| Fatigue       | 2200 mSv     | 1600 mSv      | Pain increase (+0.30)         |
| Skin Burns    | 2300 mSv     | 1700 mSv      | ACE burn damage (0.2)         |
| Weakness      | 2600 mSv     | 1900 mSv      | Blood volume loss (−0.1)      |

#### Severe (3000–4000 mSv)

| Symptom            | Threshold ON | Threshold OFF | Effect                           |
|--------------------|--------------|---------------|----------------------------------|
| Severe Pain        | 3000 mSv     | 2200 mSv      | Pain increase (+0.50)            |
| Internal Bleeding  | 3100 mSv     | 2300 mSv      | Blood volume loss / KAT bleeding |
| Deep Burns         | 3400 mSv     | 2500 mSv      | ACE burn damage (0.4)            |
| Collapsed Lung     | 3500 mSv     | 2500 mSv      | Severe pain (+0.70)              |
| Fever              | 3600 mSv     | 2600 mSv      | Pain increase (+0.50)            |
| Unconsciousness    | 3800 mSv     | 2800 mSv      | ACE unconscious (10 s)           |

#### Critical (4000+ mSv — above LD50/60)

| Symptom                  | Threshold ON | Threshold OFF | Effect                              |
|--------------------------|--------------|---------------|-------------------------------------|
| Critical Bleeding        | 4000 mSv     | 3000 mSv      | Blood volume loss (−0.3)            |
| Coagulation Failure      | 4200 mSv     | 3200 mSv      | KAT coagulation disruption (lvl 15) |
| Deep Coma                | 4500 mSv     | 3500 mSv      | ACE unconscious (30 s)              |
| Hypoxia                  | 4600 mSv     | 3600 mSv      | Blood volume loss / KAT hypoxia     |
| Cardiac Arrest           | 4800 mSv     | 3800 mSv      | ACE/KAT cardiac arrest              |
| Total Coagulation Failure| 5000 mSv     | 4000 mSv      | KAT coagulation disruption (lvl 35) |
| Collapsed Lung (KAT)     | 5000 mSv     | 4000 mSv      | KAT pneumothorax (volume 5)         |
| Bleedout                 | 5200 mSv     | 4200 mSv      | ACE bleedout cardiac arrest         |

> **LD50/60:** A dose of ~4000 mSv is the approximate lethal dose for 50% of unprotected individuals within 60 days without treatment.

### KAT (KAM) Integration

When the **KAT Extended Medical** mod is detected, several symptoms are automatically upgraded to use KAT-native effects:

| Symptom              | ACE fallback          | KAT upgrade                                       |
|----------------------|-----------------------|---------------------------------------------------|
| Vomiting             | Sound effect          | `kat_airway` puking sounds (no airway block)      |
| Internal Bleeding    | Blood volume loss     | `kat_circulation` internal bleeding (TXA-aware)   |
| Hypoxia              | Blood volume loss     | `kat_vitals` smooth SpO₂ drop to 60%              |
| Cardiac Arrest       | ACE FatalVitals       | `kat_circulation` cardiac arrest (type 4 VT)      |
| Coagulation Failure  | Custom (no-op)        | `kat_pharma` coagulation factor reduction (lvl 15)|
| Total Coag. Failure  | Custom (no-op)        | `kat_pharma` coagulation factor reduction (lvl 35)|
| Collapsed Lung       | Pain increase         | `kat_breathing` pneumothorax + volume drop        |

---

## Radiation Sickness — CBA Settings

All sickness parameters can be configured in the **CBA Settings** menu in-game.

| Setting                                | Type     | Default | Range        | Description                                                                       |
|----------------------------------------|----------|---------|--------------|-----------------------------------------------------------------------------------|
| `enableRadiationSickness`              | Checkbox | `true`  | —            | Enables/disables the entire radiation sickness system                             |
| `radiationSicknessRandomness`          | Slider   | `1.0`   | 0.0 – 2.0    | Multiplier for symptom activation chance. `0` = no symptoms, `2` = double chance |
| `radiationSicknessSpeed`               | Slider   | `1.0`   | 0.1 – 5.0    | How fast symptoms appear. Higher = symptoms trigger at lower doses               |
| `radiationSymptomInterval`             | Slider   | `5 s`   | 1 – 1000 s   | How often repeating symptoms re-apply their effect                                |
| `radiationSeverityCoefficient`         | Slider   | `0.5`   | 0.0 – 3.0    | Scales how much extra damage is dealt above the threshold (0 = no scaling)        |

### Configuration Examples

**Realistic / Hard mode:**

```sqf
enableRadiationSickness        = true
radiationSicknessRandomness    = 1.5
radiationSicknessSpeed         = 1.5
radiationSymptomInterval       = 30
radiationSeverityCoefficient   = 1.0
```

**Casual / Soft mode:**

```sqf
enableRadiationSickness        = true
radiationSicknessRandomness    = 0.5
radiationSicknessSpeed         = 0.5
radiationSymptomInterval       = 120
radiationSeverityCoefficient   = 0.2
```

**Disable sickness entirely:**

```sqf
enableRadiationSickness = false
```

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
- **Radiation Sickness** system with progressive symptoms, configurable speed and severity
- **KAT (KAM) integration** for advanced medical effects when the mod is present
