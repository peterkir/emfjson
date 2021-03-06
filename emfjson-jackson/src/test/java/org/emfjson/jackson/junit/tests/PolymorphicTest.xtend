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
package org.emfjson.jackson.junit.tests

import java.io.ByteArrayOutputStream
import java.io.IOException
import org.eclipse.emf.common.util.URI
import org.emfjson.EMFJs
import org.emfjson.jackson.junit.model.ConcreteTypeOne
import org.emfjson.jackson.junit.model.ConcreteTypeTwo
import org.emfjson.jackson.junit.model.Container
import org.emfjson.jackson.junit.model.ModelFactory
import org.emfjson.jackson.junit.model.ModelPackage
import org.emfjson.jackson.junit.support.TestSupport
import org.junit.Test

import static org.junit.Assert.*

class PolymorphicTest extends TestSupport {

	override setUp() {
		super.setUp()
		options.put(EMFJs.OPTION_INDENT_OUTPUT, true)
	}

	@Test
	def testSaveTwoObjectsWithTypeInformation() throws IOException {
		val expectedString = '''
			{
			  "eClass" : "http://www.eclipselabs.org/emfjson/junit#//Container",
			  "elements" : [ {
			    "eClass" : "http://www.eclipselabs.org/emfjson/junit#//ConcreteTypeOne",
			    "name" : "First"
			  }, {
			    "eClass" : "http://www.eclipselabs.org/emfjson/junit#//ConcreteTypeTwo",
			    "name" : "Two"
			  } ]
			}'''

		val resource = resourceSet.createResource(URI.createURI("types.json"))
		assertNotNull(resource)

		val c = ModelFactory.eINSTANCE.createContainer()
		val one = ModelFactory.eINSTANCE.createConcreteTypeOne()
		one.setName("First")
		val two = ModelFactory.eINSTANCE.createConcreteTypeTwo()
		two.setName("Two")
		c.getElements().add(one)
		c.getElements().add(two)
		resource.getContents().add(c)

		val outStream = new ByteArrayOutputStream()
		resource.save(outStream, options)

		assertEquals(expectedString, new String(outStream.toByteArray()))
	}

	@Test
	def testLoadTwoObjectsWithTypeInformation() throws IOException {
		val resource = resourceSet.createResource(uri("test-load-types.json"))
		assertNotNull(resource)
		options.put(EMFJs.OPTION_ROOT_ELEMENT, ModelPackage.eINSTANCE.getContainer())

		resource.load(options)

		assertEquals(1, resource.getContents().size())

		val root = resource.getContents().get(0)
		assertTrue(root instanceof Container)

		val container = root as Container

		assertEquals(2, container.getElements().size())
		val first = container.getElements().get(0)
		val second = container.getElements().get(1)

		assertTrue(first instanceof ConcreteTypeOne)
		assertTrue(second instanceof ConcreteTypeTwo)

		assertEquals("First", first.getName())
		assertEquals("one", (first as ConcreteTypeOne).getPropTypeOne())
		assertEquals("Two", second.getName())
		assertEquals("two", (second as ConcreteTypeTwo).getPropTypeTwo())
	}

	@Test
	def testLoadTwoObjectsWithReferenceAndTypeInformation() throws IOException {
		val resource = resourceSet.createResource(uri("test-load-types-2.json"))
		assertNotNull(resource)
		options.put(EMFJs.OPTION_ROOT_ELEMENT, ModelPackage.eINSTANCE.getContainer())

		resource.load(options)

		assertEquals(1, resource.getContents().size())

		val root = resource.getContents().get(0)
		assertTrue(root instanceof Container)

		val container = root as Container

		assertEquals(2, container.getElements().size())
		val first = container.getElements().get(0)
		val second = container.getElements().get(1)

		assertTrue(first instanceof ConcreteTypeOne)
		assertTrue(second instanceof ConcreteTypeTwo)
		assertEquals(1, first.getRefProperty().size())

		val ref = first.getRefProperty().get(0)
		assertSame(second, ref)
	}

}