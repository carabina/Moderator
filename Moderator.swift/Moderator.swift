//
// File.swift
// Moderator.swift
//
// Created by Kåre Morstøl on 03.11.15.
// Copyright © 2015 NotTooBad Software. All rights reserved.
//


public protocol ArgumentType: class {
	func parse (arguments: [String.CharacterView]) throws -> [String.CharacterView]
}

public final class ArgumentParser {
	private var argumenttypes: [ArgumentType] = []

	public func add <T:ArgumentType> (a: T) -> T {
		argumenttypes.append(a)
		return a
	}

	func parse () throws {
		try parse(Array(Process.arguments.dropFirst()))
	}

	public func parse (arguments: [String]) throws {
		var remainingarguments = preprocess(arguments)
		try argumenttypes.forEach {
			remainingarguments = try $0.parse(remainingarguments)
		}
	}

	func preprocess (arguments: [String]) -> [String.CharacterView] {
		return arguments.flatMap { s -> [String.CharacterView] in
			let c = s.characters
			if c.startsWith("--".characters) {
				return c.split("=" as Character, maxSplit: 2, allowEmptySlices: true)
			} else {
				return [c]
			}
		}
	}
}

public struct ArgumentError: ErrorType {
	let errormessage: String
}

public final class BoolArgument: ArgumentType {
	let shortname: Character
	let longname: String
	public private(set) var value = false

	init (shortname: Character, longname: String) {
		self.longname = longname
		self.shortname = shortname
	}

	public func parse(var arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		if let index = arguments.indexOf({
			let s = String($0)
			return s == "-\(shortname)" || s == "--\(longname)"
		}) {
			value = true
			arguments.removeAtIndex(index)
		}
		return arguments
	}
}

public final class StringArgument: ArgumentType {
	let shortname: Character
	let longname: String
	public private(set) var value: String?

	init (shortname: Character, longname: String) {
		self.longname = longname
		self.shortname = shortname
	}

	public func parse(var arguments: [String.CharacterView]) throws -> [String.CharacterView] {
		if let index = arguments.indexOf({
			let s = String($0)
			return s == "-\(shortname)" || s == "--\(longname)"
		}) {
			let usedflag = arguments.removeAtIndex(index)
			guard index < arguments.endIndex else {
				throw ArgumentError(errormessage: "Missing value for argument '\(usedflag)'")
			}
			let newvalue = String(arguments.removeAtIndex(index))
			guard !newvalue.hasPrefix("-") else {
				throw ArgumentError(errormessage: "Illegal value '\(newvalue)' for argument '\(usedflag)")
			}
			value = newvalue
		}
		return arguments
	}
}

