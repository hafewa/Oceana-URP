# Oceana-URP
Oceana water for Unity URP

![Water_1](https://github.com/user-attachments/assets/94db5237-4c6b-4ef9-a4bf-bc3753aed8b3)

This is solution for Unity Universal Render Pipline. Supported version 2023.2+
Repository contains of source project files and unity package for simpler installation.

![Water_0](https://github.com/user-attachments/assets/425f320e-af3d-4391-8b01-8b737c15302a)

Features:
- Floating bodies
- Reallistic look like
- Subsurface scattering
- Multiple cascades technique
- Back surface shading
- Foam
- Underwater fog
- God rays

YouTube preview: https://www.youtube.com/watch?v=dJbRxulwyZU&t=2s

Artstation preview: https://www.artstation.com/artwork/XJeZ3n

Solution contains:
- 2 Graphics shaders for ocean surface & underwater post-processing
- 3 Compute shaders for generating mesh & rendering ocean scrolls & calculating floating bodies
- C# scripts for handling CPU part of code
- 1 Demo Scene

Solution requiers:
- Unity ver. 2023.2+
- Universal RP
- FullScreen Render Feature (for underwater effects)

IMPORTANT NOTES: 
- For rendering ocean surface correctly toggles "Depth Texture" & "Opaque Texture" in URP Asset must be enabled.
- For rendering post processing toggle "Deferred render path" and select After Transparent Depth Texture in URP renderer.

If there will be any issues or bugs found in this asset, report them to this e-mail: mitrofan3452@gmail.com
