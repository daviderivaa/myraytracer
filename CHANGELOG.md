# HEAD
- Fixing bug [#4](https://github.com/daviderivaa/myraytracer/issues/4): upside-down images [PR #5](https://github.com/daviderivaa/myraytracer/pull/5)

## VERSION 0.2.0
- Methods and structs that allows to describe a light ray (`ray`), an observer point of view (`camera`) and an `ImageTracer` strcut with a `fire_all_rays` method, which modifies pixels hit by rays. camera: [PR #2](https://github.com/daviderivaa/myraytracer/pull/2)
- geometry: [PR #1](https://github.com/daviderivaa/myraytracer/pull/1)

## VERSION 0.1.0
- First release of the code
- `Point`, `Vec` and `Normal` data type with geometry methods and `Transformation` struct with operations on new data types. geometry: [PR #1](https://github.com/daviderivaa/myraytracer/pull/1)
- Create an Ldr Image and save a png or jpg file
- Read a PFM file
- Tone mapping and Hdr Image creation