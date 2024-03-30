// Copyright © 2023 Cory Petkovsek, Roope Palmroos, and Contributors.

#ifndef TERRAIN3D_TEXTURE_LIST_CLASS_H
#define TERRAIN3D_TEXTURE_LIST_CLASS_H

#include "constants.h"
#include "generated_texture.h"
#include "terrain_3d_texture.h"

using namespace godot;

// Deprecated 0.9.1 - Remove Later
class Terrain3DTextureList : public Resource {
	GDCLASS(Terrain3DTextureList, Resource);
	TypedArray<Terrain3DTexture> _textures;

public:
	Terrain3DTextureList() {}
	~Terrain3DTextureList() {}
	void set_textures(const TypedArray<Terrain3DTexture> &p_textures) { _textures = p_textures; }
	TypedArray<Terrain3DTexture> get_textures() const { return _textures; }

protected:
	static void _bind_methods() {
		ClassDB::bind_method(D_METHOD("set_textures", "textures"), &Terrain3DTextureList::set_textures);
		ClassDB::bind_method(D_METHOD("get_textures"), &Terrain3DTextureList::get_textures);
		int ro_flags = PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY;
		ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "textures", PROPERTY_HINT_ARRAY_TYPE, vformat("%tex_size/%tex_size:%tex_size", Variant::OBJECT, PROPERTY_HINT_RESOURCE_TYPE, "Terrain3DTextureList"), ro_flags), "set_textures", "get_textures");
	}
};
//////////////

class Terrain3DAssets : public Resource {
	GDCLASS(Terrain3DAssets, Resource);
	CLASS_NAME();

public: // Constants
	static inline const int MAX_TEXTURES = 32;

private:
	TypedArray<Terrain3DTexture> _textures;

	GeneratedTexture _generated_albedo_textures;
	GeneratedTexture _generated_normal_textures;

	void _swap_textures(int p_old_id, int p_new_id);
	void _update_texture_files();
	void _update_texture_settings();
	void _update_texture_data(bool p_textures, bool p_settings);

public:
	Terrain3DAssets();
	~Terrain3DAssets();

	void update_list();
	void set_texture(int p_index, const Ref<Terrain3DTexture> &p_texture);
	Ref<Terrain3DTexture> get_texture(int p_index) const { return _textures[p_index]; }
	void set_textures(const TypedArray<Terrain3DTexture> &p_textures);
	TypedArray<Terrain3DTexture> get_textures() const { return _textures; }
	int get_texture_count() const { return _textures.size(); }

	void save();

protected:
	static void _bind_methods();
};

#endif // TERRAIN3D_TEXTURE_LIST_CLASS_H