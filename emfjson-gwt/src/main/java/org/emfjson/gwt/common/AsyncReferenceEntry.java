package org.emfjson.gwt.common;

import org.eclipse.emf.common.util.Callback;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.resource.Resource;
import org.emfjson.common.EObjects;
import org.emfjson.common.ReferenceEntry;

public class AsyncReferenceEntry extends ReferenceEntry {

	public AsyncReferenceEntry(EObject owner, EReference reference, String id) {
		super(owner, reference, id);
	}

	public void resolve(final Resource resource, final Callback<Resource> callback) {
		final URI ref = createURIFromID(owner.eResource(), id);

		if (ref == null) {
			EObject target = owner.eResource().getEObject(id);
			if (target != null) {
				EObjects.setOrAdd(owner, reference, target);
				callback.onSuccess(resource);
			} else {
				callback.onFailure(new Exception());
			}
		} else {
			resource.getResourceSet().getEObject(ref, new Callback<EObject>() {
				@Override
				public void onSuccess(EObject result) {
					if (result != null) {
						EObjects.setOrAdd(owner, reference, result);
					}
					callback.onSuccess(resource);
				}
				@Override
				public void onFailure(Throwable caught) {
					callback.onFailure(caught);
				}			
			});
		}
	}
}
