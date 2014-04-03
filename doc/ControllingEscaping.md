# Controlling escaping in handlebars-objc #

## Warning

This document describes an extension to handlebars that is available only in handlebars-objc. While most is implemented using helpers, those helpers leverage internal APIs that are not yet available in other implementations of handlebars.

## The need for some control over escaping

By default, handlebars escapes content so that generated text can be safely and correctly rendered when inserted within an HTML node. And this is fine, since handlebars is mostly used to generate html documents. 

For instance

	<span> 1 {{ "<=" }} 2 </span>

Would render as

	<span> 1 &lt;= 2 </span>

And this is what we expect so the html document displays "1 < 2".
Unfortunately, "HTML escaping" is an ill-defined notion. HTML documents are made of different parts that require different escaping. 

Let's illustrate this with a simple example: the ampersand character ('&').

The ampersand char must be escaped in HTML Text nodes. The 'R&D' word must thus be escaped this way

	<span> R&amp;D </span>

So far, handlebars does this perfectly: the template 

	<span> {{ word } </span

with data

	@{ @"word" : @"R&D" }

will render as

	<span> R&amp;D </span>

Complications arise if ampersands are used outside text nodes: the following template

	<a href="http://google.com?q={{word}}"> {{ word }} </a>

will render as

	<a href="http://google.com?q=R&amp;D"> R&amp;D </a>

where the URL "http://google.com?q=R&amp;D" is incorrect.

The ampersand in the URL parameter must indeed be escaped, but the proper escaping in that case is 'R%26D'.

As you can see, the notion of escaping is somehow vague without some information about the context where text is to be inserted.

# Controlling escaping in handlebars-objc

Two helpers provide control over escaping in handlebars-objc. One is used to escape a single value. The other provides control over the escaping used within a block. 

## Escaping a value

The #escape helper is useful when only one value needs escaping:

	{{escape mimetype value}}

where mimetype indicates the requested escaping format and value is the content to escape. Both parameters can be any value supported by handlebars but mimetype will generally be a string litteral and value will be a provided by data context.

For instance

	{{escape 'text/x-query-parameter' word}}

with data

	@{ @"word" : @"R&D" }

will render as

	http://google.com?q=R%26D


## Controlling ambient escaping mode

Internally, handlebars-objc maintains a "current escaping mode", which tells the rendering engine what escaping to apply when a value is rendered.

By default, current mode is 'text/html'.

The #setEscaping block helper provides control over current escaping mode:

	{{#setEscaping 'text/x-query-parameter'}} ... {{/setEscaping}}

The following template:

	<a 
    	{{#setEscaping 'text/x-query-parameter'}}
    		href="http://foo.com?q={{query}}&title={{title}}"
       	{{/setEscaping}
        > 
    
       	{{title}} 
    </a>

With data 

	@{ @"query" : @"R&D", @"title" : @"Research & Development" }

Will render as 

	<a href="http://foo.com?q=R%26D&title=Research%32%26%32Development">
    	Research &amp; Development
    </a>

(Some carriage returns have been removed for the sake of readability)

As illustrated above allow escaping within the #setEscaping helper block has been done using percent escapes, as appropriate in url query parameters.

As soon as the block closes, the engine comes back to previous escaping mode (text/html in that case) and the ampersand is escaped as '&amp;'.

The ambient escaping mode is implemented as a stack, meaning you can safely call #setEscaping recursively:

	
    ... {{! values escaped as html here (this is the default) }}
    
	{{#setEscaping 'text/format1'}}
    	
        content... {{! values escaped as format1 here }}
        
        {{#setEscaping 'text/format2'}}
        
        	content... {{! values escaped as format2 here }}
            
        {{/setEscaping}}
        
        content... {{! back to format1 }}
        
    {{/setEscaping}}
	
	content... {{! back to html escaping }}
    

## Adding support for custom escaping modes

Handlebars.objc supports two escaping modes by default: 
 - html escaping mode 
 - url query parameters escaping mode 

You might need a totally different escape mode, for instance to escape values within JSON strings. 

You can implement your own escaping mode by adding a delegate to your execution context. All you need is to implement a method in your delegate  

	// Declaration of a simple delegate
	@interface SimpleExecutionContextDelegate
    
        - (void)replaceString:(NSString*)source withString:(NSString*)target inMutableString:(NSMutableString*)string;
        
    @end
        
    // Implementation of delegate class
	@implementation SimpleExecutionContextDelegate
    
        - (void)replaceString:(NSString*)source withString:(NSString*)target inMutableString:(NSMutableString*)string
        {
            [string replaceOccurrencesOfString:source withString:target options:NSCaseInsensitiveSearch range:NSMakeRange(0, [string length])];
        }

        - (NSString*) escapeString:(NSString*)rawString forTargetFormat:(NSString*)formatName forExecutionContext:(HBExecutionContext*)executionContext
        {
            NSString* result = nil;

            if ([formatName isEqual:@"application/x-json-string"]) {
                // mostly copied from http://www.codza.com/converting-nsstring-to-json-string
                NSMutableString *s = [NSMutableString stringWithString:rawString];
                [self replaceString:@"\"" withString:@"\\\"" inMutableString:s];
                [self replaceString:@"/"  withString:@"\\/"  inMutableString:s];
                [self replaceString:@"\n" withString:@"\\n"  inMutableString:s];
                [self replaceString:@"\b" withString:@"\\b"  inMutableString:s];
                [self replaceString:@"\f" withString:@"\\f"  inMutableString:s];
                [self replaceString:@"\r" withString:@"\\r"  inMutableString:s];
                [self replaceString:@"\t" withString:@"\\t"  inMutableString:s];
                result = [NSString stringWithString:s];
            }

            return result;
        }

	@end

Now we can use this delegate to get support for json string escaping:

    SimpleExecutionContextDelegate* delegate = [[SimpleExecutionContextDelegate new] autorelease];
    HBExecutionContext* executionContext = [[HBExecutionContext new] autorelease];
    executionContext.delegate = delegate;
    HBTemplate* template = [executionContext templateWithString:@"{{escape 'application/x-json-string' 'hel\"lo'}}"];
    NSLog("template renders as: '%@'", [template renderWithContext:nil error:nil]);

And in your console you should see: 

	template renders as: 'hel\"lo'


















