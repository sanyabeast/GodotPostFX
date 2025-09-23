# PostFX

PostFX is a Shader Based Post Processing plugin for Godot 4.3+ (might work on older 4.x versions)

**Original Author:** [ItsKorin](https://github.com/ItsKorin)  
**Fork Maintainer:** sanyabeast

## Installation

### Method 1: Git Submodule (Recommended)
```bash
# Add as submodule to your project
git submodule add https://github.com/sanyabeast/GodotPostFX addons/postfx

# Update submodule
git submodule update --init --recursive
```

### Method 2: Manual Installation
1. Download or clone this repository
2. Copy the `postfx` folder to your project's `addons/` directory
3. Enable the plugin in Project Settings > Plugins

## Usage

### 1. Add PostFX Node
- In your scene, add a new node
- Search for "PostFX" in the Create Node dialog
- Add the PostFX node to your scene

### 2. Configure Effects
- Select the PostFX node in the scene tree
- In the Inspector, expand the "Effects" array
- Add effect resources to the array (e.g., AsciiFX, ChromaticAberration, ColorCorrection, Vignette)
- Configure effect properties in the Inspector

### 3. Available Effects
- **AsciiFX**: ASCII art style effect with configurable character size
- **CasFX**: Contrast Adaptive Sharpening with intensity, threshold, and edge boost controls
- **ChromaticAberrationFX**: Color channel separation effect with adjustable strength
- **ColorCorrectionFX**: Brightness, saturation, and tint adjustments
- **CRTFX**: CRT monitor simulation with scanlines, curvature, and vintage display effects
- **DitherFX**: Dithering effect for retro/pixelated appearance
- **KaleidoscopeFX**: Kaleidoscope effect with configurable segments and polar coordinates
- **KuwaharaFX**: Artistic oil painting filter with kernel size and quality controls
- **LensFlareFX**: Lens flare effect (experimental)
- **UnderwaterFX**: Underwater distortion with wave animation, frequency, and tint controls
- **VignetteFX**: Dark border effect with customizable intensity, opacity, and color

**Note:** Currently works best with 2D scenes.
