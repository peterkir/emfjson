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

import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.IOException
import org.eclipse.emf.common.util.URI
import org.emfjson.EMFJs
import org.emfjson.jackson.junit.model.ModelFactory
import org.emfjson.jackson.junit.model.ModelPackage
import org.emfjson.jackson.junit.model.PrimaryObject
import org.emfjson.jackson.junit.model.Sex
import org.emfjson.jackson.junit.model.SomeKind
import org.emfjson.jackson.junit.model.User
import org.emfjson.jackson.junit.support.TestSupport
import org.junit.Test

import static org.junit.Assert.*

class EnumTest extends TestSupport {
	
	override setUp() {
		super.setUp()
		options.put(EMFJs.OPTION_INDENT_OUTPUT, true)
	}
	
	@Test
	def testEnums() throws IOException {
		val expectedString = '''
			[ {
			  "eClass" : "http://www.eclipselabs.org/emfjson/junit#//User",
			  "sex" : "MALE"
			}, {
			  "eClass" : "http://www.eclipselabs.org/emfjson/junit#//User",
			  "sex" : "FEMALE"
			} ]'''

		val resource = resourceSet.createResource(URI.createURI("tests/test.json"))

		val u1 = ModelFactory.eINSTANCE.createUser()
		u1.setSex(Sex.MALE)

		val u2 = ModelFactory.eINSTANCE.createUser()
		u2.setSex(Sex.FEMALE)

		resource.getContents().add(u1)
		resource.getContents().add(u2)

		val outStream = new ByteArrayOutputStream()
		resource.save(outStream, options)

		assertEquals(expectedString, new String(outStream.toByteArray()))
	}

	@Test
	def testLoadEnums() throws IOException {
		val inputString = '''
			[ {
			  "name":"A",
			  "sex" : "MALE"
			}, {
			  "name" : "B",
			  "sex" : "FEMALE"
			} ]'''

		val resource = resourceSet.createResource(URI.createURI("tests/test.json"))

		options.put(EMFJs.OPTION_ROOT_ELEMENT, ModelPackage.Literals.USER)
		val inStream = new ByteArrayInputStream(inputString.getBytes())
		resource.load(inStream, options)

		assertEquals(2, resource.getContents().size())

		assertEquals(ModelPackage.Literals.USER, resource.getContents().get(0).eClass())
		assertEquals(ModelPackage.Literals.USER, resource.getContents().get(1).eClass())

		val u1 = resource.getContents().get(0) as User
		val u2 = resource.getContents().get(1) as User

		assertEquals("A", u1.getName())
		assertEquals(Sex.MALE, u1.getSex())
		assertEquals("B", u2.getName())
		assertEquals(Sex.FEMALE, u2.getSex())
	}

	@Test
	def testSaveEnumDifferentCases() throws IOException {
		val expectedString = '''
			[ {
			  "eClass" : "http://www.eclipselabs.org/emfjson/junit#//PrimaryObject",
			  "kind" : "one"
			}, {
			  "eClass" : "http://www.eclipselabs.org/emfjson/junit#//PrimaryObject",
			  "kind" : "two"
			}, {
			  "eClass" : "http://www.eclipselabs.org/emfjson/junit#//PrimaryObject",
			  "kind" : "Three-is-Three"
			} ]'''

		val resource = resourceSet.createResource(URI.createURI("tests/test.json"))
		{
			val p = ModelFactory.eINSTANCE.createPrimaryObject()
			p.setKind(SomeKind.ONE)
			resource.getContents().add(p)
		}
		{
			val p = ModelFactory.eINSTANCE.createPrimaryObject()
			p.setKind(SomeKind.TWO)
			resource.getContents().add(p)
		}
		{
			val p = ModelFactory.eINSTANCE.createPrimaryObject()
			p.setKind(SomeKind.THREE)
			resource.getContents().add(p)
		}

		val outStream = new ByteArrayOutputStream()
		resource.save(outStream, options)

		assertEquals(expectedString, new String(outStream.toByteArray()))
	}
	
	@Test
	def testLoadEnumDifferentCases() throws IOException {
		val inputString = '''
			[ {
			  "eClass" : "http://www.eclipselabs.org/emfjson/junit#//PrimaryObject",
			  "kind" : "one"
			}, {
			  "eClass" : "http://www.eclipselabs.org/emfjson/junit#//PrimaryObject",
			  "kind" : "two"
			}, {
			  "eClass" : "http://www.eclipselabs.org/emfjson/junit#//PrimaryObject",
			  "kind" : "Three-is-Three"
			} ]'''

		val resource = resourceSet.createResource(URI.createURI("tests/test.json"))

		val inStream = new ByteArrayInputStream(inputString.getBytes())
		resource.load(inStream, options)

		assertEquals(3, resource.getContents().size())

		val one = resource.getContents().get(0)
		val two = resource.getContents().get(1)
		val three = resource.getContents().get(2)

		assertEquals(ModelPackage.Literals.PRIMARY_OBJECT, one.eClass())
		assertEquals(ModelPackage.Literals.PRIMARY_OBJECT, two.eClass())
		assertEquals(ModelPackage.Literals.PRIMARY_OBJECT, three.eClass())

		assertEquals(SomeKind.ONE, (one as PrimaryObject).getKind())
		assertEquals(SomeKind.TWO, (two as PrimaryObject).getKind())
		assertEquals(SomeKind.THREE, (three as PrimaryObject).getKind())
	}

}