---
name: Liquid Neon
colors:
  surface: '#131315'
  surface-dim: '#131315'
  surface-bright: '#39393b'
  surface-container-lowest: '#0e0e10'
  surface-container-low: '#1c1b1d'
  surface-container: '#201f21'
  surface-container-high: '#2a2a2c'
  surface-container-highest: '#353437'
  on-surface: '#e5e1e4'
  on-surface-variant: '#b9cacb'
  inverse-surface: '#e5e1e4'
  inverse-on-surface: '#313032'
  outline: '#849495'
  outline-variant: '#3b494b'
  surface-tint: '#00dbe9'
  primary: '#dbfcff'
  on-primary: '#00363a'
  primary-container: '#00f0ff'
  on-primary-container: '#006970'
  inverse-primary: '#006970'
  secondary: '#a7ffb3'
  on-secondary: '#003915'
  secondary-container: '#00ee70'
  on-secondary-container: '#00662c'
  tertiary: '#fff3f0'
  on-tertiary: '#5a1c00'
  tertiary-container: '#ffcfbd'
  on-tertiary-container: '#a73b00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#7df4ff'
  primary-fixed-dim: '#00dbe9'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f54'
  secondary-fixed: '#66ff8f'
  secondary-fixed-dim: '#00e46b'
  on-secondary-fixed: '#00210a'
  on-secondary-fixed-variant: '#005322'
  tertiary-fixed: '#ffdbce'
  tertiary-fixed-dim: '#ffb599'
  on-tertiary-fixed: '#370e00'
  on-tertiary-fixed-variant: '#7f2b00'
  background: '#131315'
  on-background: '#e5e1e4'
  surface-variant: '#353437'
typography:
  display-lg:
    fontFamily: Sora
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Sora
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Sora
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.1em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  unit: 8px
  container-margin: 24px
  gutter: 16px
  safe-area: 32px
---

## Brand & Style
The brand personality is high-energy, futuristic, and immersive. This design system targets a competitive, tech-forward audience that values performance and visual flair. 

The aesthetic is **Liquid Glass**, a hybrid style merging Glassmorphism with organic, fluid movements. It utilizes vibrant, neon-glow accents against deep, dark backgrounds to create a sense of infinite depth. The emotional response should be one of "controlled intensity"—exciting yet highly functional. Every interface element should feel like a tangible piece of luminous hardware floating in a pressurized, dark environment.

## Colors
This design system operates exclusively in a dark mode environment to maximize the impact of neon luminosity.

- **Primary (Electric Blue):** Used for core actions, focus states, and primary brand indicators.
- **Secondary (Lime Green):** Used for success states, progress tracking, and secondary highlights.
- **Tertiary (Hot Orange):** Reserved for urgent notifications, critical warnings, and "high-heat" interactive zones.
- **Neutral:** A deep, obsidian black serves as the base layer, providing the necessary contrast for the frosted glass overlays.

Backgrounds are never flat; they should feature high-saturation blurs of the primary and secondary colors (300px - 500px radius) positioned behind the glass containers to create the "liquid" glow effect.

## Typography
The typography strategy balances the futuristic geometry of **Sora** for headlines with the high readability of **Hanken Grotesk** for long-form content. **JetBrains Mono** is utilized for technical labels and metadata to reinforce the high-tech, precise nature of the system.

Headlines should occasionally utilize a subtle outer glow matching the primary or secondary color when placed on the darkest backgrounds. Avoid using pure white for body text; use a 90% opacity "cool grey" to maintain the dark-mode harmony.

## Layout & Spacing
The design system employs a **Fluid Grid** model with a 12-column structure for desktop and a 4-column structure for mobile. 

Spacing is governed by an 8px base unit. Because the "liquid glass" elements use heavy blurs and outer glows, the "safe-area" between major containers is increased to 32px to prevent visual clutter and allow the glows to "breathe." Layouts should feel airy and expansive, avoiding dense clusters of information. Containers should use organic, varying widths to mimic the fluidity of liquid rather than rigid blocks.

## Elevation & Depth
Depth is the defining characteristic of this system. It is achieved through a multi-layered approach:

1.  **Background Layer:** Deep neutral (#0A0A0C) with oversized, soft color orbs.
2.  **Glass Layer:** Semi-transparent surfaces (`backdrop-filter: blur(24px)`) with a 1px inner border (linear-gradient) to simulate light catching the edge of the glass.
3.  **Accent Layer:** Neon glow elements that sit either inside the glass or float just above it.
4.  **Shadows:** Shadows are deep and colored. Instead of black shadows, use 40% opacity of the primary or secondary color with a large spread (e.g., `0 20px 40px rgba(0, 240, 255, 0.3)`) to create a "floating light" effect.

## Shapes
Shapes are unapologetically fluid. Rectangles are avoided in favor of **pill-shaped** elements and hyper-rounded containers. 

The high `roundedness` value (3) ensures that even large dashboard cards feel soft and organic. When multiple glass layers are stacked, the corner radii should be concentric (the inner element has a slightly smaller radius than the outer container) to maintain the liquid aesthetic.

## Components
- **Buttons:** Primary buttons are "liquid-filled" with a gradient of the primary color and a high-intensity outer glow on hover. Secondary buttons are ghost-style with a 1px glass border.
- **Glass Cards:** Must feature a `backdrop-filter: blur(20px)` and a subtle `top-to-bottom` white-to-transparent gradient stroke.
- **Inputs:** Fields are dark and recessed with a "glow-on-focus" state that illuminates the entire perimeter in the primary color.
- **Chips:** Small, high-contrast capsules with 100% border radius. Use secondary and tertiary colors for status categorization.
- **Lists:** Items are separated by soft glass dividers (1px height, 10% opacity) with ample vertical padding (16px) to maintain the airy feel.
- **The "Pulse" Indicator:** A custom component for active states—a small neon dot with a multi-layered expanding shadow animation to signify "live" activity.