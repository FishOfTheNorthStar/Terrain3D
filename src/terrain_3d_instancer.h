// Copyright © 2023 Cory Petkovsek, Roope Palmroos, and Contributors.

#ifndef TERRAIN3D_INSTANCER_CLASS_H
#define TERRAIN3D_INSTANCER_CLASS_H

#include <godot_cpp/classes/multi_mesh.hpp>
#include <godot_cpp/classes/multi_mesh_instance3d.hpp>

#include "constants.h"

using namespace godot;

class Terrain3D;

class Terrain3DInstancer : public Resource {
	GDCLASS(Terrain3DInstancer, Resource);
	CLASS_NAME();

	Terrain3D *_terrain = nullptr;

	MultiMeshInstance3D *_multimesh_instance = nullptr;
	Ref<MultiMesh> _multimesh;

	Dictionary _instances;
	//TypedArray<Terrain3DInstance> _instances;

	void _set_instances(Dictionary p_instances);
	Dictionary _get_instances() { return _instances; }

public:
	Terrain3DInstancer();
	~Terrain3DInstancer();

	void initialize(Terrain3D *p_terrain);
	void destroy();

	void set_terrain(Terrain3D *p_terrain) { _terrain = p_terrain; }
	Terrain3D *get_terrain() const { return _terrain; }

	Ref<MultiMesh> get_multimesh() { return _multimesh; };
	void add_instances(Vector3 p_global_position, real_t p_radius, uint32_t p_count);
	void remove_instances(Vector3 p_global_position, real_t p_radius, uint32_t p_count);

	void save();

	void print_multimesh_buffer(MultiMeshInstance3D *p_mmi);

protected:
	static void _bind_methods();
};

#endif // TERRAIN3D_INSTANCER_CLASS_H