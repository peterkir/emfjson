/*
 * Copyright (c) 2011-2014 Guillaume Hillairet.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    Guillaume Hillairet - initial API and implementation
 */
package org.emfjson.gwt.map;

import static org.emfjson.common.Constants.EJS_REF_KEYWORD;
import static org.emfjson.common.Constants.EJS_TYPE_KEYWORD;

import java.util.Collection;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.resource.Resource;
import org.emfjson.common.Cache;
import org.emfjson.common.Options;

import com.google.gwt.json.client.JSONArray;
import com.google.gwt.json.client.JSONObject;
import com.google.gwt.json.client.JSONString;

public class References {

	private final Options options;
	private final Cache cache;
	private final Resource resource;

	public References(Cache cache, Resource resource, Options options) {
		this.cache = cache;
		this.resource = resource;
		this.options = options;
	}

	public void serialize(JSONObject parent, String key, EReference reference, Object value) {
		if (reference.isMany()) {
			serializeMany(parent, key, (Collection<?>) value);
		} else {
			serializeOne(parent, key, (EObject) value);
		}
	}

	public void serializeMany(JSONObject parent, String key, Collection<?> values) {
		if (values == null || values.isEmpty()) return;

		JSONArray arrayNode = new JSONArray();
		parent.put(key, arrayNode);

		int i = 0;
		for (Object current: values) {
			if (current instanceof EObject) {
				EObject value = (EObject) current;
				String ref = cache.getHref(resource, value);
				String type = cache.getHref(null, value.eClass());
				arrayNode.set(i, createObjectRef(new JSONObject(), ref, type));
				i++;
			}
		}
	}

	public void serializeOne(JSONObject parent, String key, EObject value) {
		if (value != null) {
			final String ref = cache.getHref(resource, value);
			final String type = cache.getHref(null, value.eClass());

			parent.put(key, createObjectRef(new JSONObject(), ref, type));
		}
	}

	public JSONObject createObjectRef(JSONObject node, String ref, String type) {
		if (options.serializeRefTypes) {
			node.put(EJS_TYPE_KEYWORD, new JSONString(type));
		}
		node.put(EJS_REF_KEYWORD, new JSONString(ref));
		return node;
	}

	public JSONObject createObjectRef(JSONObject target, EObject object) {
		final String ref = cache.getHref(resource, object);
		final String type = cache.getHref(null, object.eClass());

		return createObjectRef(target, ref, type);
	}

}
