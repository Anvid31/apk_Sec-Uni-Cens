# CENS Caracterización — Design Contract

## Identity
- **App:** CENS Caracterización (field survey for educational sede characterization)
- **Register:** Utility — design serves the task; trust and clarity over flourish
- **Primary theme:** Light
- **Brand seed:** `#2E7D32` (CENS green)
- **Accent:** Primary green only — never a second accent
- **Voice:** Clear, operational Spanish; verb-specific actions ("Continuar", "Enviar encuesta", "Exportar Shapefile")

## Dials
| Dial | Value | Rationale |
|------|-------|-----------|
| DESIGN_VARIANCE | 4 | Symmetric form anatomy across phases |
| MOTION_INTENSITY | 3 | Press feedback + short state transitions only |
| VISUAL_DENSITY | 5 | Comfortable field-device density for outdoor use |

## Tokens
- Spacing: 4pt scale (`Insets` in `lib/config/tokens.dart`)
- Radius: soft family 8 / 12 / 16 / 24 (`Radii`)
- Motion: 150 / 250 / 400 ms (`Motion`)
- Depth: `surfaceContainer*` ladder, elevation 0 on cards with hairline borders

## Decisions log
| Date | Decision |
|------|----------|
| 2026-08-06 | Adopted beautify-flutter skill (Utility register); centralized ThemeData + tokens; home + form chrome redesigned |
