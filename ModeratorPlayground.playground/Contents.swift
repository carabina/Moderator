//: Playground - noun: a place where people can play


extension ArgumentParser {
	static func flag(short: Character, long: String, description: String? = nil) -> ArgumentParser<Bool> {
		let usage: UsageText = description.map { ("-\(short), --\(long):", $0) }
		return ArgumentParser<Bool>(usage: usage) { (var args) in
			guard let index = args.indexOf({
				return $0 == "-\(short)" || $0 == "--\(long)"
			}) else {
				return (false, args)
			}
			args.removeAtIndex(index)
			return (true, args)
		}
	}
}


extension ArgumentParser {
	public func next <Outvalue> (f: (Value, Array<String>.Index?, [String]) throws -> (value: Outvalue, remainder: [String]) ) -> ArgumentParser<Outvalue> {

		return ArgumentParser<Outvalue>(usage: self.usage) { args in
			let result = try self.parse(args)
			let firstchange = result.remainder.indexOfFirstDifference(args)
			return try f(result.value, firstchange, result.remainder)
		}
	}
}

extension Array where Element: Equatable {
	public func indexOfFirstDifference (other: Array<Element>) -> Index? {
		for i in self.indices {
			if i >= other.endIndex || self[i] != other[i] { return i }
		}
		return nil
	}
}

extension ArgumentParser {
	static func flagWithValue (short: Character, long: String, description: String? = nil) -> ArgumentParser<String> {
		return ArgumentParser.flag(short, long: long, description: description)
			.next { (flagfound, firstchange, var args) in
				guard flagfound, let firstchange = firstchange else { throw ArgumentError(errormessage: "missing value") }
				let result = args.removeAtIndex(firstchange)
				return (result, args)
		}
	}
}

let m = Moderator()
let aoption = m.add(.flag("a", long: "aaa", description: "A lot of as"))
//let soption = m.add(ArgumentParser<String>.flagWithValue("b", long: "bbb"))

try m.parse(["-b", "-a", "--aaa", "-c"])
aoption.value
//m.remaining
//m.usagetext


let short = [1,2,3]
let long = [1,2,3,4,5]
Array(zip(short,long))
Array(zip(long,short))

short.indexOfFirstDifference(long)
long.indexOfFirstDifference(short)
[1,2,3].indexOfFirstDifference([0,2,2])

	/*


	func preprocess (arguments: [String]) -> [String] {
		return arguments.flatMap { s -> [String] in
			let c = s.characters
			if c.startsWith("--".characters) {
				return c.split("=" as Character, maxSplit: 1, allowEmptySlices: true)
			} else if c.startsWith("-".characters) && c.count > 2 {
				return c.dropFirst().map { "-\($0)".characters }
			} else {
				return [c]
			}
		}
	}

}

*/
