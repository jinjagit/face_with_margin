# Cube-sphere face with margin

Idea: Adding a margin means that triangles at edge of 'face' will be correctly curved to fit with curve formed by margin, rather than creating a visible 'seam' due to having no information on the mesh curve beyond the edge (as is case when mesh ends at the face edge).

This should also mean we can tile the texture 9 times, using calculated uvs, if we somehow include vertices 'around' the face corners (to overcome the 3-way intersections of cube-sphere face corners which would make such tiling impossible.)

We should also be able to 'flip' the triangles of the margin to effectively nmake their material / textures invisible from outside of the cube-sphere. All this taken together should provide us with seamless materials and the ability to place a single (and different) texture on each face (which could even, later, be a representation of 3-d noise, including noise that matches any used to displace vertices)

Thinking some more about this: We only need correct uvs for the face mesh. We don't care what happens to the texture on the margin triangles, since we will be flipping them. But, won't flipping the triangles also invert their normals, meaning the curve will be messed up? (Not convinced this would be a problem, since I think the curve of the surface and the normals might be unrelated in this sense. But, if a problem, maybe we can hide texture by inverting triangles, but also flip the normals back?). Probably best to try a simplified version with margins that dont use inserted corners? (Just small sections of neighboring faces)

And now we have already got a way to calculate offset along face normal for margin vertices, maybe try creating face mesh first, then add a ring of vertices 'around' edge of face for each margin row? This would make grouping triangles and normals easier (for subsequent flipping). If this works, the code would be much simpler (and faster) than that developed here.