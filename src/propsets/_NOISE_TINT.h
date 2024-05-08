#pragma once

#ifndef TERRAIN3D_NOISE_TINT_H
#define TERRAIN3D_NOISE_TINT_H

#include <godot_cpp/classes/texture2d.hpp>

//Code Templates for Terrain3D Managed GLSL/Godot NOISE_TINT Properties

// ################################################################################
#pragma region _NOISE_TINT_
// ****************
// ** NOISE_TINT **
// ****************

#pragma region _HELP_
#define HELP_NOISE_TINT()\
	ADD_HELP_TOPIC_DECL(noise_tint, R"(
Adds a two-tone tinting affect to the ground as it approaches the camera. The 
various Noise1 settings control the placement and size of Macro Variation 1, 
and Noise2 for Macro Variation 2.  Additionally, Noise 3 adds variation to 
height blending.  Because of how the colors you select are multiplied against 
the terrains texture colors, that process reduces overall brightness some.  
So keep the variation colors you select close to pastels/white to minimize 
garish tones.
)")
#pragma endregion _HELP_

#pragma region _noise_tint_helper_macros_
#define   GETR_NTINT(m_bind_id, m_type)					     GSTR( noise_tint_##m_bind_id, m_type )
#define    VAR_NTINT(m_bind_id, m_type, m_value)		     VARR( noise_tint_##m_bind_id, m_type##, m_value )
#define   PROP_NTINT(m_member_id, m_var_type, ...)  __PROP_GENGRP( noise_tint, m_member_id, m_var_type, __VA_ARGS__ )
#define   BIND_NTINT(m_bind_id, m_param_label)		     ADD_BIND( noise_tint_##m_bind_id, m_param_label )
#define SETUPD_NTINT(m_bind_id, m_type, s_log_desc)	  SETUPD__GRP( noise_tint, noise_tint_##m_bind_id, m_type, s_log_desc )
#define _SETPR_NTINT(m_bind_id, m_type, s_log_desc)	  __SETPR_GRP( noise_tint, noise_tint_##m_bind_id, m_type, s_log_desc )
#define _UPDSH_NTINT(m_member_id)				    UPDATE_SHADER( noise_tint_##m_member_id )
#pragma endregion _noise_tint_helper_macros_

#define UPDATE_NOISE_TINT() UPDATE_GROUP(noise_tint)

#define PRIV_NOISE_TINT_VARS()\
	GROUP_VARS(noise_tint)\
	VAR_NTINT(enabled,			bool,	false)\
	VAR_NTINT(texture,			Ref<Texture2D>, Ref<Texture2D>())\
	VAR_NTINT(macro_variation1,	Color,	Color("9fcc9f"))\
	VAR_NTINT(macro_variation2,	Color,	Color("ab8b72"))\
	VAR_NTINT(noise1_scale,		float,	0.5f)\
	VAR_NTINT(noise1_angle,		float,	42.0f)\
	VAR_NTINT(noise1_offset,	Vector2,Vector2(0.37, 0.12))\
	VAR_NTINT(noise2_scale,		float,	0.36143f)\
	VAR_NTINT(noise3_scale,		float,	0.23921f)

#define PUBLIC_NOISE_TINT_FUNCS()\
	GETR_NTINT(enabled,				bool)\
	GETR_NTINT(texture,				Ref<Texture2D>)\
	GETR_NTINT(macro_variation1,	Color)\
	GETR_NTINT(macro_variation2,	Color)\
	GETR_NTINT(noise1_scale,		float)\
	GETR_NTINT(noise1_angle,		float)\
	GETR_NTINT(noise1_offset,		Vector2)\
	GETR_NTINT(noise2_scale,		float)\
	GETR_NTINT(noise3_scale,		float)

#define BIND_NOISE_TINT_VARS() \
	BIND_NTINT(enabled,				enabled)\
	BIND_NTINT(texture,				texture)\
	BIND_NTINT(macro_variation1,	color)\
	BIND_NTINT(macro_variation2,	color)\
	BIND_NTINT(noise1_scale,		size)\
	BIND_NTINT(noise1_angle,		radians)\
	BIND_NTINT(noise1_offset,		offset)\
	BIND_NTINT(noise2_scale,		size)\
	BIND_NTINT(noise3_scale,		size)

#define PROPS_NOISE_TINT()\
	ADD_GROUP("Tinting", "noise_tint_");\
	PROP_NTINT(enabled,				BOOL,	NONE)\
	PROP_NTINT(texture,				OBJECT,	RESOURCE_TYPE, "Texture2D")\
	PROP_NTINT(macro_variation1,	COLOR,	NONE)\
	PROP_NTINT(macro_variation2,	COLOR,	NONE)\
	PROP_NTINT(noise1_scale,		FLOAT,	RANGE, "0.001, 1.0, 0.001")\
	PROP_NTINT(noise1_angle,		FLOAT,	RANGE, "0.25, 20.0, 0.01")\
	PROP_NTINT(noise1_offset,		VECTOR2,NONE)\
	PROP_NTINT(noise2_scale,		FLOAT,	RANGE, "0.001, 1.0, 0.001")\
	PROP_NTINT(noise3_scale,		FLOAT,	RANGE, "0.001, 1.0, 0.001")\
	ADD_INLINE_HELP(noise_tint, Tinting, About Global Tint By Noise)

#define MAKE_NOISE_TINT_FUNCTIONS() \
	UPDATE_GRP_START(noise_tint)\
		_UPDSH_NTINT(macro_variation1)\
		_UPDSH_NTINT(macro_variation2)\
		_UPDSH_NTINT(noise1_scale)\
		_UPDSH_NTINT(noise1_angle)\
		_UPDSH_NTINT(noise1_offset)\
		_UPDSH_NTINT(noise2_scale)\
		_UPDSH_NTINT(noise3_scale)\
	UPDATE_GRP_END()\
	SETUPD_NTINT(enabled,			bool,			"Enable Tint Noise: ")\
	SETUPD_NTINT(texture,			Ref<Texture2D>,	"Tint Noise Texture: ")\
	_SETPR_NTINT(macro_variation1,	Color,			"Tint Noise Macro Variation Color #1: ")\
	_SETPR_NTINT(macro_variation2,	Color,			"Tint Noise Macro Variation Color #2: ")\
	_SETPR_NTINT(noise1_scale,		float,			"Tint Noise Phase 1 Scale: ")\
	_SETPR_NTINT(noise1_angle,		float,			"Tint Noise Phase 1 Angle: ")\
	_SETPR_NTINT(noise1_offset,		Vector2,		"Tint Noise Phase 1 Offset: ")\
	_SETPR_NTINT(noise2_scale,		float,			"Tint Noise Phase 2 Scale: ")\
	_SETPR_NTINT(noise3_scale,		float,			"Tint Noise Phase 3 Scale: ")

#pragma endregion _NOISE_TINT_
// ################################################################################
#endif

//		_set("_noise_tint_texture", _noise_tint_texture  );\
//	__SETC__(noise_tint_texture,	Ref<Texture2D>,	"Tint Noise Texture: ", if(_noise_tint_texture.is_valid()) { RS->material_set_param(_material, "_noise_tint_texture", _noise_tint_texture->get_rid() ); } )\
