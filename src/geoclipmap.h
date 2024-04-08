// Copyright © 2023 Cory Petkovsek, Roope Palmroos, and Contributors.

#ifndef GEOCLIPMAP_CLASS_H
#define GEOCLIPMAP_CLASS_H

#include <godot_cpp/templates/vector.hpp>

#include "constants.h"

using namespace godot;

class GeoClipMap {
	CLASS_NAME_STATIC("Terrain3DGeoClipMap");

	static inline int _patch_2d(int x, int y, int res);
	static RID _create_mesh(PackedVector3Array p_vertices, PackedInt32Array p_indices, AABB p_aabb);

public:
	enum MeshType {
		TILE,
		FILLER,
		TRIM,
		CROSS,
		SEAM,
	};

	static Vector<RID> generate(int p_resolution, int p_clipmap_levels);
};

// Inline Functions

inline int GeoClipMap::_patch_2d(int x, int y, int res) {
	return y * res + x;
}

#endif // GEOCLIPMAP_CLASS_H