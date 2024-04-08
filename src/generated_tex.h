// Copyright © 2023 Cory Petkovsek, Roope Palmroos, and Contributors.

#ifndef GENERATEDTEX_CLASS_H
#define GENERATEDTEX_CLASS_H

#include <godot_cpp/classes/image.hpp>

#include "constants.h"

using namespace godot;

class GeneratedTex {
	CLASS_NAME_STATIC("Terrain3DGenTex");

private:
	RID _rid = RID();
	Ref<Image> _image;
	bool _dirty = false;

public:
	void clear();
	bool is_dirty() { return _dirty; }
	void create(const TypedArray<Image> &p_layers);
	void create(const Ref<Image> &p_image);
	Ref<Image> get_image() const { return _image; }
	RID get_rid() { return _rid; }
};

#endif // GENERATEDTEX_CLASS_H