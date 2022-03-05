# Cube-sphere face with margin

Idea: Adding a margin means that triangles at edge of 'face' will be correctly curved to fit with curve formed by margin, rather than creating a visible 'seam' due to having no information on the mesh curve beyond the edge (as is case when mesh ends at the face edge).

This should also mean we can tile the texture 9 times, using calculated uvs, if we somehow include vertices 'around' the face corners (to overcome the 3-way intersections a cube-sphere face corners which would make such tiling impossible.)

We should also be able to 'flip' the triangles of the margin to effectively nmake their material / textures invisible from outside of the cube-sphere. All this taken together should provide us with seamless materials and the ability to place a single (and different) texture on each face (which could even, later, be a representation of 3-d noise, including noise that matches any used to displace vertices)