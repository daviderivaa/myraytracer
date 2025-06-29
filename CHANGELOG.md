# HEAD

## VERSION 1.0.1

- Fix [Bug #16](https://github.com/daviderivaa/myraytracer/issues/16) for CSG. fix#16: [PR #17](https://github.com/daviderivaa/myraytracer/pull/17).
- In scene definition: add image dimensions and number of rays per pixel for antialiasing; allow to use default values. imageparser: [PR #15](https://github.com/daviderivaa/myraytracer/pull/15).

## VERSION 1.0.0
- Add scene examples with images. scene: [PR #10](https://github.com/daviderivaa/myraytracer/pull/10).
- Add lexer and parser for scene definition to render with [main](./main.jl). scene: [PR #10](https://github.com/daviderivaa/myraytracer/pull/10).
- Add `Cylinder` shape in [`shapes.jl`](./myRayTracing/src/shapes.jl). newshapes: [PR #13](https://github.com/daviderivaa/myraytracer/pull/13).
- Add `Cone` shape in [`shapes.jl`](./myRayTracing/src/shapes.jl). newshapes: [PR #13](https://github.com/daviderivaa/myraytracer/pull/13).
- Add Point-light Tracing algorithm for diffusive objects. pointlight: [PR #14](https://github.com/daviderivaa/myraytracer/pull/14).
- Update profiling of `fire_all_rays` method with [PProf](https://github.com/JuliaPerf/PProf.jl). antialiasing: [PR #9](https://github.com/daviderivaa/myraytracer/pull/9).
- Fix CSG [bug #11](https://github.com/daviderivaa/myraytracer/issues/11). fix#11: [PR #12](https://github.com/daviderivaa/myraytracer/pull/12).
- Add Antialiasing in [`demo_path.jl`](./demo_path.jl). antialiasing: [PR #9](https://github.com/daviderivaa/myraytracer/pull/9).
- Fix PathTracer [bug #7](https://github.com/daviderivaa/myraytracer/issues/7), started as furnace test failure. fix#7: [PR #8](https://github.com/daviderivaa/myraytracer/pull/8).

## VERSION 0.4.0
- Add profiling and time evaluation in [`demo_path.jl`](./demo_path.jl), [`box.jl`](./box.jl), [`check_csg.jl`](./check_csg.jl). pathtracing: [PR #6](https://github.com/daviderivaa/myraytracer/pull/6). 
- Implement demo project [`demo_path.jl`](./demo_path.jl) with Path Tracing algorithm. pathtracing: [PR #6](https://github.com/daviderivaa/myraytracer/pull/6).
- Add `Box` shape in [`shapes.jl`](./myRayTracing/src/shapes.jl) and new script [`box.jl`](./box.jl). pathtracing: [PR #6](https://github.com/daviderivaa/myraytracer/pull/6).
- New demo_images and demo GIF with colored spheres. pathtracing: [PR #6](https://github.com/daviderivaa/myraytracer/pull/6), demo: [PR #3](https://github.com/daviderivaa/myraytracer/pull/3).
- Create [`check_csg.jl`](./check_csg.jl) that creates an image with 3 different operations on 2 spheres: Union, Intersection, Difference. demo: [PR #3](https://github.com/daviderivaa/myraytracer/pull/3).
- Implement Renderers in [`render.jl`](./myRayTracing/src/render.jl) for color evaluation: `Renderer` (abstract), `OnOffRenderer`, `FlatRenderer`, `PathTracer`. pathtracing: [PR #6](https://github.com/daviderivaa/myraytracer/pull/6).
- Fix CSG with new shapes. pathtracing: [PR #6](https://github.com/daviderivaa/myraytracer/pull/6).
- Add `Rectangle` shape in [`shapes.jl`](./myRayTracing/src/shapes.jl). pathtracing: [PR #6](https://github.com/daviderivaa/myraytracer/pull/6).
- Add `Materials` type and methods for a shape, in [`materials.jl`](./myRayTracing/src/materials.jl). pathtracing: [PR #6](https://github.com/daviderivaa/myraytracer/pull/6).
- Add Pigment and BRDF types and methods in [`materials.jl`](./myRayTracing/src/materials.jl): `Pigment` and `BRDF` are abstract types. pathtracing: [PR #6](https://github.com/daviderivaa/myraytracer/pull/6).
- Fixing [bug #4](https://github.com/daviderivaa/myraytracer/issues/4): upside-down images [PR #5](https://github.com/daviderivaa/myraytracer/pull/5).
- camera: [PR #2](https://github.com/daviderivaa/myraytracer/pull/2).
- geometry: [PR #1](https://github.com/daviderivaa/myraytracer/pull/1).

## VERSION 0.3.0
- Create demo images and demo GIF. demo: [PR #3](https://github.com/daviderivaa/myraytracer/pull/3).
- Create [`check_csg.jl`](./check_csg.jl) that creates an image with 3 different operations on 2 spheres: Union, Intersection, Difference.
- Methods and strcut that creates shapes (sphere and plane) and CSG. Compute intersections with light rays. `Shape` (`Sphere` and `Plane`), `ray_intersection()`, `Union()`, `Difference()`, `Intersection()`.
- Methods and strcut to store informations: `World`, `HitRecord`.
- Fixing bug [#4](https://github.com/daviderivaa/myraytracer/issues/4): upside-down images [PR #5](https://github.com/daviderivaa/myraytracer/pull/5).

## VERSION 0.2.0
- Methods and structs that allows to describe a light ray (`ray`), an observer point of view (`camera`) and an `ImageTracer` strcut with a `fire_all_rays` method, which modifies pixels hit by rays. camera: [PR #2](https://github.com/daviderivaa/myraytracer/pull/2).

## VERSION 0.1.0
- First release of the code.
- `Point`, `Vec` and `Normal` data type with geometry methods and `Transformation` struct with operations on new data types. geometry: [PR #1](https://github.com/daviderivaa/myraytracer/pull/1).
- Create an Ldr Image and save a png or jpg file.
- Read a PFM file.
- Tone mapping and Hdr Image creation.