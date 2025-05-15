<div align="center">

# RayTracing

### *Project by Alberto Lazzeri, Riccardo Natale and Davide Riva*

Repository of "Tecniche Numeriche per la Generazione di Immagini Fotorealistiche" course by Professor Maurizio Tomasi (AY 2024/25). This code has been implemented in `Julia` and has the intent to create photorealistic images.

</div>

## DEMO
### DEMO
Run:
```shell
julia demo_gif.jl <camera_type> <angle>
```
A GIF file called `<camera_type>.gif` will appear in `myraytracer/`.

### DEMO GIF
Before executing [demo_gif.jl](./demo_gif.jl), you need to install [ffmpeg](https://ffmpeg.org/):
- Ubuntu / Debian bash:
    ```shell 
    sudo apt install ffmpeg
    ```
- Windows prompt:
```shell
choco install ffmpeg
```
- macOS bash:
```shell
brew install ffmpeg
```

Then in directory `myraytracer/` run:
```shell
mkdir demo
```

Now you can run:
```shell
julia demo_gif.jl <camera_type>
```
A GIF file called `<camera_type>.gif` will appear in `myraytracer/`.
