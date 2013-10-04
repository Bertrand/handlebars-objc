#!/usr/bin/env ruby

require 'json'

class Hash
	def to_objc_literal
		'@{ ' + self.map {|k,v| k.to_objc_literal + ': ' + v.to_objc_literal}.join(', ') + ' }'
	end
end

class Array
	def to_objc_literal
		'@[ ' + self.map {|e| e.to_objc_literal}.join(' ,') + ' ]'
	end
end

class String 
	def to_objc_literal
		'@"' + self + '"'
	end
end


class Symbol 
	def to_objc_literal
		'@"' + self.to_s + '"'
	end
end

class  FixNum
	def to_objc_literal
		'@' + self
	end
end

class TrueClass
	def to_objc_literal
		'@' + self
	end
end

class FalseClass
	def to_objc_literal
		'@' + self
	end
end

def replace_variable(input, variable_name)
input.gsub!(/var\s+#{variable_name}\s*=\s*([^;]*);/m) { |json_hash|
	h = eval($1)
	"id #{variable_name} = #{h.to_objc_literal};"
}
end

inp = $stdin.read

# it("if", function() {
inp.gsub!(/it\("([^"]*)", function\(\) \{/) { |m| 
	val = $1
	cleanedUpDesc = val.gsub(/[\#\@]/, '#' => 'sharpSign', '@' => "at", '-' => 'dash')
	"// #{val}\n" + "- (void) test" + cleanedUpDesc.split(' ').map {|s| s.capitalize}.join('') + "\n{"
}

inp.gsub!(/\[hash, helpers\]/, "hash")

replace_variable(inp, "string")
replace_variable(inp, "out")
replace_variable(inp, "byes")
#replace_variable(inp, "data")
replace_variable(inp, "source")
replace_variable(inp, "messageString")
replace_variable(inp, "dude")
replace_variable(inp, "url")
#replace_variable(inp, "partial")

# var hash   = 
inp.gsub!(/var\s+hash\s*=\s*([^;]*);/m) { |json_hash|
	h = eval($1)
	"id hash = #{h.to_objc_literal};"
}

# describe("basic context", function() {
inp.gsub!(/describe\("([^"]*)\).*/, "// \\1")

if true then
#  shouldCompileTo(string, hash, "goodbye! Goodbye! GOODBYE! cruel world!", "pouet");
inp.gsub!(/shouldCompileTo\(([^,]*),\s*([^,]*),\s*([^,]*),\s*([^,]*)\)\;/m) { |m| 
	<<-STRING
	    XCTAssertEqualObjects([HBHandlebars renderTemplate:@#{$1} withContext:#{$2}],
	    	@#{$3});
	STRING
}

inp.gsub!(/shouldCompileTo\(([^,]*),\s*\{([^\}]*)\},\s*([^,]*),\s*([^,]*)\)\;/m) { |m| 
	<<-STRING
	    XCTAssertEqualObjects([HBHandlebars renderTemplate:@#{$1} withContext:{#{$2}}],
	    	@#{$3});
	STRING
}
end

inp.gsub!(/\}\)\;/, "}")

puts inp