// Copyright © 2023 Cory Petkovsek, Roope Palmroos, and Contributors.

R"(

//INSERT: AUTO_SHADER_TEXTURE_ID
	// Enable Autoshader if outside regions or painted in regions, otherwise manual painted
	bool auto_shader = region<0 || bool(control & 0x1u);
	out_mat.base = int(auto_shader)*_auto_shader_base_texture + int(!auto_shader)*int(control >>27u & 0x1Fu);
	out_mat.over = int(auto_shader)*_auto_shader_overlay_texture + int(!auto_shader)*int(control >> 22u & 0x1Fu);
	out_mat.blend = float(auto_shader)*clamp(
			dot(vec3(0., 1., 0.), normal * _auto_shader_slope*2. - (_auto_shader_slope*2.-1.)) 
			- _auto_shader_height_reduction*.01*v_vertex.y // Reduce as vertices get higher
			, 0., 1.) + 
			 float(!auto_shader)*float(control >>14u & 0xFFu) * 0.003921568627450; // 1./255.0		

//INSERT: TEXTURE_ID
	out_mat.base = int(control >>27u & 0x1Fu);
	out_mat.over = int(control >> 22u & 0x1Fu);
	out_mat.blend = float(control >>14u & 0xFFu) * 0.003921568627450; // 1./255.0

)"