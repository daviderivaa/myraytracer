<div align="center">

# RayTracing

### *Project by Alberto Lazzeri, Riccardo Natale and Davide Riva*

Repository of "Tecniche Numeriche per la Generazione di Immagini Fotorealistiche" course by Professor Maurizio Tomasi (AY 2024/25). This code has been implemented in `Julia` and has the intent to create photorealistic images.

</div>

# <span style="color: red;">**PROFILING**</span>
From [Version 0.4.0](https://github.com/daviderivaa/myraytracer/releases/tag/v0.4.0) you can profile `fire_all_rays` method.

If not using `--profile` flag, `@btime` method of [Profile pkg](https://docs.julialang.org/en/v1/manual/profile/) will be used, which gives **Minimum time**, **Allocated memory** and **Garbage Collector (GC) time**. Here's an output example:
```shell
Profiling fire_all_rays method:
Time: 3.250902643 s
Allocated memory: 1785.623448 MB
GC: 0.577122232 s
For a complete profiling use --profile flag
```

When using `--profile` flag, a `profile.pb.gz` will be created (ignore errors, see Issue [here](https://github.com/JuliaPerf/PProf.jl/issues/102)), with [PProf](https://github.com/JuliaPerf/PProf.jl). In order to visualize it, open **Julia REPL** and use:
```shell
julia> using Pkg
```
```shell
julia> Pkg.activate("myRayTracing/")
```
```shell
julia> using PProf
```
```shell
julia> PProf.refresh(file = "profile.pb.gz")
```
Which will produce an output as:
```shell
Serving web UI on http://localhost:57599
Process(`/home/alberto/.julia/artifacts/579b2972c1e7b798ee4281dd37d60a362be0e1f5/bin/pprof -http=localhost:57599 -relative_percentages profile.pb.gz`, ProcessRunning)
```
Then open `http://localhost:57599`.

# <span style="color: red;">**SCRIPT EXAMPLES**</span>
# <span style="color: blue;">DEMO</span>
## <span style="color: green;">DEMO SINGLE IMAGE</span>

If `myraytracer/demo/` directory doesn't exist, in `myraytracer/` run:
```shell
mkdir demo
```

### If you have [Version 0.3.0](https://github.com/daviderivaa/myraytracer/releases/tag/v0.3.0), in `myraytracer/script_examples/` you can run:
```shell
julia -t <n_threads> demo.jl <camera_type> <angle>
```
where:
- `<n_threads> = auto` allows to use all available threads.
- `<n_threads> = 1` means not using multi-threading.

A GIF file called `<camera_type>.gif` will appear in `myraytracer/script_examples/`.

### From *Version 0.4.0*, in `myraytracer/script_examples/` you can run:
```shell
julia -t <n_threads> demo.jl <camera_type> <angle> <w_colors>
```
where:
- `<n_threads> = auto` allows to use all available threads.
- `<n_threads> = 1` means not using multi-threading.
- `<w_colors> = "yes"` makes 2 colored spheres.
- `<w_colors> = "no"` makes only white spheres.

In `myraytracer/demo/` creates a `pfm` file and the corresponding `png` image.

## <span style="color: green;">DEMO GIF</span>

<img src="./script_examples/orthogonal.gif" alt="GIF 1" width="500" style="display:inline-block; margin-right:10px;">
<img src="./script_examples/perspective_c.gif" alt="GIF 2" width="500" style="display:inline-block;">

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

If `myraytracer/demo/` directory doesn't exist, in `myraytracer/` run:
```shell
mkdir demo
```

### If you have [Version 0.3.0](https://github.com/daviderivaa/myraytracer/releases/tag/v0.3.0), in `myraytracer/script_examples/` you can run:
```shell
julia -t <n_threads> demo_gif.jl <camera_type>
```
where:
- `<n_threads> = auto` allows to use all available threads.
- `<n_threads> = 1` means not using multi-threading.

A GIF file called `<camera_type>.gif` will appear in `myraytracer/script_examples/`.

### From [Version 0.4.0](https://github.com/daviderivaa/myraytracer/releases/tag/v0.4.0), in `myraytracer/script_examples/` you can run:
```shell
julia -t <n_threads> demo_gif.jl <camera_type> <w_colors>
```
where:
- `<n_threads> = auto` allows to use all available threads.
- `<n_threads> = 1` means not using multi-threading.
- `<w_colors> = "yes"` makes 2 colored spheres. A GIF file called `<camera_type>_c.gif` will appear in `myraytracer/script_examples/`.
- `<w_colors> = "no"` makes only white spheres. A GIF file called `<camera_type>.gif` will appear in `myraytracer/script_examples/`.

# <span style="color: blue;">CHECK CSG (*CONSTRUCTIVE SOLID GEOMETRY*)</span>

If `myraytracer/CSG/` directory doesn't exist, in `myraytracer/` run:
```shell
mkdir CSG
```

In `myraytracer/script_examples/` run:
```shell
julia -t <n_threads> check_csg.jl <camera_type> <angle_z> <angle_y> 
```
where:
- `<n_threads> = auto` allows to use all available threads.
- `<n_threads> = 1` means not using multi-threading.

In `myraytracer/CSG/` creates a `pfm` file and the corresponding `png` image.

# <span style="color: blue;">DRAW BOX</span>

If `myraytracer/CSG/` directory doesn't exist, in `myraytracer/` run:
```shell
mkdir CSG
```

In `myraytracer/script_examples/` run:
```shell
julia -t <n_threads> box.jl <camera_type> <angle_z> <angle_y> --profile(optional)
```
where:
- `<n_threads> = auto` allows to use all available threads.
- `<n_threads> = 1` means not using multi-threading.
- `--profile` prints a complete profiling of `fire_all_rays` method.

In `myraytracer/CSG/` creates a `pfm` file and the corresponding `png` image.

# <span style="color: blue;">DEMO (WITH PATHTRACING ALGORITHM)</span>

If `myraytracer/` directory doesn't exist, in `myraytracer/` run:
```shell
mkdir demo_path
```

Then in `myraytracer/script_examples/` run:
```shell
julia -t <n_threads> demo_path.jl <camera_type> <angle_z> <angle_y> --profile(optional)
```
where:
- `<n_threads> = auto` allows to use all available threads.
- `<n_threads> = 1` means not using multi-threading.
- `--profile` prints a complete profiling of `fire_all_rays` method.

In `myraytracer/demo_path/` creates a `pfm` file and the corresponding `png` image.
