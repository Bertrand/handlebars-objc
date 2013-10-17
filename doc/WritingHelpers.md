# Writing Helpers #

The most important feature of handlebars is the ability for the hosting application to provide application-specific formatting features to templates. 
This ability is enabled by the use of helpers. 



There are two kinds of helpers. Handlebars.js documentation calls them "helpers" and "block helpers":
 - Helpers are used to transform values. Those values are passed by template writers as parameters. 
 - Block Helpers generally provide iterative or conditional constructs. Like normal helpers, they are passed parameters, but they also enclose block statements. 

For example, suppose the hosting application needs to display dates in a locale-dependent short format. 
The application could define a helper named "short_date_format" that takes an iso8601 date value and tranforms it into a short date format in user's locale. 

Templates may then use it this way:

 ```
   Date is {{short_date_format model.date}}. 
 ```

In this case, short_date_format is a simple helper that transforms a parameter into a formatted date string. 
In our example, the parameter value is 'model.date' and thus is a value coming from the context. 
As we'll see in later examples, parameters can also be literal (string, numbers, boolean). 

An application could also provide a helper named "reverse_each" that iterates over an array in reverse order and executes a block of statements at each step: 

Templates may then use it this way: 

```
  Sorted elements from last to first:
  {{reverse_each model.elements}}
    element value : {{value}}
  {{/reverse_each}}
```

In this case, reverse_each is a block helper that takes one parameter. 

Last, let's see a more complex example. 
The hypothetical 'sort' helper would sort an array of elements based on values inside those elements. 

```mustache
 Elements sorted by ascending first name: 
 {{sort model.elements criteria="first_name" order="ascending"}}
  {{first_name}} {{last_name}}
 {{/sort}}
 
 Elements sorted by descending last name: 
 {{sort model.elements criteria="last_name" order="descending"}}
  {{first_name}} {{last_name}}
 {{/sort}}
```

Evaluated against the following context

```json
{ "elements": 
  [
    { "first_name": "Alan", "last_name": "Turing" },
    { "first_name": "David", "last_name": "Hilbert" }, 
    { "first_name": "Daniel", "last_name": "Goossens" }
  ] 
}
```

That would give 

```
 Elements sorted by ascending first name: 
  Alan Turing
  Daniel Goossens
  David Hilbert
  
 Elements sorted by descending last name: 
  Alan Turing
  David Hilbert
  Daniel Goossens
```

In this case, the sort helper takes 3 parameters. At invocation time, our template uses values 
 from the context (model.elements), and  litteral values ("last_name", "ascending", ...)
 
The ability to use litteral values in helpers is one of the features that make Handlebars so powerful compared to other Mustache-like implementations. 

## Helper parameters ##

Helpers can take as many parameters as they need. Those parameters can be either passed in sequence, or by name. For instance the short_date_format helper above could take an additional parameter named "with_year" taking a boolean value: 

```
  Date is {{short_date_format model.date with_year=false}}
```

In this case model.date sets a positional parameter (with index 0) and with_year=false sets a named parameter with name "with_year". 

Helpers can use as many parameters as they need. Positional parameters are obviously ordered, and they come first. Named parameters come then and can be given in any order. 

## Writing Helpers in Objective-C ##

In handlebars-objc, helpers are Objective-C blocks with the following signature 

```objc
NSString* (^HBHelperBlock)(HBHelperCallingInfo* callingInfo)
{
  ...
}
```

All contextual information a helper can use is provided in the callingInfo object: 

 - positional parameters 
 - named parameters 
 - handlebars context 
 - handlebars private data

In addition, block helpers have access to the following block information: 

 - block statements 
 - inverse section statements 

(please see [HBHelperCallingInfo refence](http://fotonauts.github.io/handlebars-objc/api_doc/Classes/HBHelperCallingInfo.html) for a complete API documentation of HBHelperCallingInfo). 


### Our first helper ###

Let's write a helper than simply prints the current date, and let register it as a global helper available to all templates:

```objc
// helper implementation
HBHelperBlock formattedDateHelper = ^(HBHelperCallingInfo* callingInfo)
{
    
    // get current date
    NSDate* date = [NSDate date];
    
    // create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    // format the date
    NSString* result = [dateFormatter stringFromDate:date];
    
    return result;
};

// register the helper globally
[HBHandlebars registerHelperBlock:formattedDateHelper forName:@"formatted_date"];
```

Now let's use our new helper 

```objc
// render a template using the helper
NSError* error = nil;
NSString* renderedTemplate =
    [HBHandlebars renderTemplateString:@"Date is: {{formatted_date}}"
                           withContext:@{} error:&error];

NSLog(@"rendered value : '%@'", renderedTemplate);
```
In your console, you should see: 
```
rendered value : 'Date is: Oct 13, 2013'
```

Well... if you run this code on October 13 2013. 

### Using positional parameters ###

Let's make our formatted_date helper a bit more useful, let's add a date parameter. 
If this parameter is set by template, we'll render the passed date, otherwise we'll fallback on previous behaviour and format current date. 

```objc
// helper implementation
HBHelperBlock formattedDateHelper = ^(HBHelperCallingInfo* callingInfo)
{
    
    // the date is the first positional parameter, or current date if no parameter is passed.
    NSDate* date = nil;
    if (callingInfo.positionalParameters.count > 0) {
        NSString* dateString = callingInfo.positionalParameters[0];
        date = [NSDate dateWithNaturalLanguageString:dateString];
    } else {
        date = [NSDate date];
    }
    
    // create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    // format the date
    NSString* result = [dateFormatter stringFromDate:date];
    
    return result;
}
// register the helper globally
[HBHandlebars registerHelperBlock:formattedDateHelper forName:@"formatted_date"];
```
(Note that I strongly encourage you not to use the +[NSDate dateWithNaturalLanguageString] method. I used it for brievity's sake only). 

Now let's render a template
```
    // render a template using the helper
    NSError* error = nil;
    NSString* renderedTemplate =
        [HBHandlebars renderTemplateString:@"Birthday is: {{formatted_date birthday_date}}"
                               withContext:@{ @"birthday_date": @"01/23/1862"} error:&error];
    
    NSLog(@"rendered value : '%@'", renderedTemplate);
```
You should see the following in your console:
```
rendered value : 'Birthday is: Jan 23, 1862'
```

Note that you can also access positional parameters by using the obj-C indexed subscripting operator on callingInfo. 
The following expression:
```
NSString* dateString = callingInfo.positionalParameters[0];
```
can thus be rewritten
```
NSString* dateString = callingInfo[0];
```

### Using named parameters ###

Using positional parameters is fine if you helper doesn't take more than one parameter. 
As soon as you have two parameters, the meaning of those is in many case less obvious for those reading a template. 

In this case, it's much better to use another great features of Handlebars: Named Parameters. 

Let's add an extra paramter to our formatted_date helper that will let the template decide how to format the date. 
Since we'll use a named parameter, let's name it "date_format". 

```objc
// helper implementation
HBHelperBlock formattedDateHelper = ^(HBHelperCallingInfo* callingInfo)
{
    
    // the date is the first positional parameter, or current date if no parameter is passed.
    NSDate* date = nil;
    if (callingInfo.positionalParameters.count > 0) {
        NSString* dateString = callingInfo.positionalParameters[0];
        date = [NSDate dateWithNaturalLanguageString:dateString];
    } else {
        date = [NSDate date];
    }
    
    // Initialize a dictionary that will help us map date_format string parameter
    // to an NSDateFormatterStyle value. And let's do it in a thread safe way.
    static NSDictionary* formatStyleMapping = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        formatStyleMapping = @{ @"short"    : @(NSDateFormatterShortStyle),
                                @"medium"   : @(kCFDateFormatterMediumStyle),
                                @"long"     : @(kCFDateFormatterLongStyle),
                                @"full"     : @(kCFDateFormatterFullStyle)
                                };
    });

    // get the date_format named parameter
    NSDateFormatterStyle formatStyle = NSDateFormatterMediumStyle; // default value
    NSString* dateFormatParameter = callingInfo.namedParameters[@"date_format"];
    if (dateFormatParameter && formatStyleMapping[dateFormatParameter]) {
        formatStyle = [formatStyleMapping[dateFormatParameter] unsignedIntegerValue];
    }
    
    // create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:formatStyle];
    
    // format the date
    NSString* result = [dateFormatter stringFromDate:date];
    
    return result;
};


// register the helper globally
[HBHandlebars registerHelperBlock:formattedDateHelper forName:@"formatted_date"];
```
The thread safe string-to-enum mapping might look like a pedantic optimization. We could have simply reinstanciated
the mapping dictionary at each run. But since helpers can be called quite often during template rendering, it's 
good to know how to avoid re-instantiating the same objects over and over. 

Now let's render a template using our new parameter:
```objc
// render a template using the helper
NSError* error = nil;
NSString* renderedTemplate =
    [HBHandlebars renderTemplateString:@"Birthday is: {{formatted_date birthday_date date_format='full'}}"
                           withContext:@{ @"birthday_date": @"01/23/1862"} error:&error];

NSLog(@"rendered value : '%@'", renderedTemplate);
```
And in your console, you should see:
```
rendered value : 'Birthday is: Thursday, January 23, 1862'
```

As with positional parameters, named parameters can be accessed using keyed subscripting operator: 
```
NSString* dateFormatParameter = callingInfo.namedParameters[@"date_format"];
```
can be written
```
NSString* dateFormatParameter = callingInfo[@"date_format"];
```

### Writing block helpers ###

In the introduction above, we've described a block helper named "sort" that would sort an array using any attribute of its elements. 
Let's write it!

```objc
// helper implementation
HBHelperBlock sortHelper = ^(HBHelperCallingInfo* callingInfo)
{
    // retrieve the value to sort
    id value = callingInfo[0];
    if (!value) return (NSString*)nil;
        
    // transform the value into an array. It it's already an NSArray, this is a no-op;
    NSArray* array = [HBHelperUtils arrayFromValue:value];
    if (!array) return (NSString*)nil;
    
    // retrieve sort criterion
    NSString* criterion = callingInfo[@"criterion"];
    if (!criterion) return (NSString*)nil;
    
    // retrieve sort order
    NSInteger order = 1;
    NSString* orderParameter = callingInfo[@"order"];
    if ([orderParameter isEqualToString:@"descending"]) order = -1;

    
    // actual sort
    NSArray* sortedArray = [array sortedArrayWithOptions:0 usingComparator:^(id obj1, id obj2) {
        
        id value1 = [HBHelperUtils valueOf:obj1 forKey:criterion];
        id value2 = [HBHelperUtils valueOf:obj2 forKey:criterion];

        return order * [value1 compare:value2];
    }];
    
    // prepare empty result string.
    NSMutableString* result = [NSMutableString string];
    
    // iterate over sorted elements
    for (id object in sortedArray) {
        // invoke block statements
        NSString* iterationResult = callingInfo.statements(object, callingInfo.data);
        // concatenate iteration evaluation with helper result
        if (iterationResult) [result appendString:iterationResult];
    }
    
    return (NSString*)result;
};

[HBHandlebars registerHelperBlock:sortHelper forName:@"sort"];
```

Let's use it:

```objc
id context = @{ @"elements":
                    @[
                     @{ @"first_name": @"Alan", @"last_name": @"Turing" },
                     @{ @"first_name": @"David", @"last_name": @"Hilbert" },
                     @{ @"first_name": @"Daniel", @"last_name": @"Goossens" }
                     ] 
                };

NSString* template = @"Elements sorted by ascending first name:\n\
{{#sort elements criterion='first_name' order='ascending'}}\
{{first_name}} {{last_name}}\n\
{{/sort}}\n\
Elements sorted by descending last name:\n\
{{#sort elements criterion='last_name' order='descending'}}\
{{first_name}} {{last_name}}\n\
{{/sort}}";

NSError* error = nil;
NSString* renderedTemplate = [HBHandlebars renderTemplateString:template withContext:context error:&error];

NSLog(@"rendered value : '%@'", renderedTemplate);
```

In your console, you should see: 
```
rendered value : 'Elements sorted by ascending first name:
Alan Turing
Daniel Goossens
David Hilbert

Elements sorted by descending last name:
Alan Turing
David Hilbert
Daniel Goossens
'
```

Let's come back to this new helper implementation. 

Many things in this implementation are similar to what we've seen before. In the first part, we retrieve the parameters. We've done this in other helpers. Business as usual. However, one line is new:

```objc
    NSArray* array = [HBHelperUtils arrayFromValue:value];
```

The HBHelperUtils class contains some methods useful when you write helpers. The method we've used here (<[HBHelperUtils arrayFromValue:]>) should be used everytime you want to manipulate a parameter as an NSArray object.

Once we've got all the calling parameters, we actually sort the array. Once again, we'll use a method from HBHelperUtils: 

```objc
id value1 = [HBHelperUtils valueOf:obj1 forKey:criterion];
```

The method <[HBHelperUtils valueOf:forKey:]> is what you should use when you try to access a key of a dictionary-like value in your helpers. 

The reason why you should use those methods form HBHelperUtils rather than directly cast parameters is beyond the scope of this article and will be covered elsewhere. For now, just keep in mind this is how to property write your helpers. 

Once the array is properly sorted, comes the moment to evaluate the block passed to our helper. After having created an empty string buffer, we iterate over the elements array, and at each iteration we render the passed block this way:

```objc
NSString* iterationResult = callingInfo.statements(object, callingInfo.data);
```

The 'statements' property in callingInfo is an objective-C block that you invoke each time you want to evaluate the handlebars block passed to your helper. It takes two parameters: 
 - a context 
 - a private data context (handlebars private variables)

In our case, since we iterate over array elements, at each iteration we pass the current element as the context to the statements block. And since we don't add any private data, we simply pass the data context we received in callingInfo as is. 

When invoked, the objective-C block returns a string containing the evaluation of the handlebars block for the given context.
In our helper, we take these strings and concatenate them to form our helper result string.

### Conditional block helpers - Inverse section - Private variables ###

Block helpers can be used to implement conditional constructs. Since this is a quite obvious modification of the block helper implementation we've already seen, we'll use this example to see two other features:
 - inverse sections: block passed to the helper that is executed when a helper condition is not meant 
 - private variables: variables that helpers can set and that is available to descendant scopes

Let's write a helper that executes a handlebars block when its parameter is positive and execute another block when it's negative. 
In addition, a private data named @isZero is set to true when the parameter is equal to zero. 

```objc
// helper implementation
HBHelperBlock ifPositiveHelper = ^(HBHelperCallingInfo* callingInfo)
{
    // retrieve the value
    id value = callingInfo[0];
    
    // compute conditionals
    NSInteger conditional = [HBHelperUtils evaluateObjectAsInteger:value] >= 0;
    BOOL isZero = [HBHelperUtils evaluateObjectAsInteger:value] == 0;
    
    // prepare a new data context. We MUST NEVER modify data context we receive in helpers.
    HBDataContext* currentDataContext = callingInfo.data;
    HBDataContext* descendantDataContext = currentDataContext ? [currentDataContext copy] : [HBDataContext new];
    descendantDataContext[@"isZero"] = @(isZero);
    
    if (conditional) {
        // condition is met: call block statements
        return callingInfo.statements(callingInfo.context, descendantDataContext);
    } else {
        // condition is not met: call inverse section statements
        return callingInfo.inverseStatements(callingInfo.context, descendantDataContext);
    }
};

[HBHandlebars registerHelperBlock:ifPositiveHelper forName:@"ifPositive"];
    
NSString* template = @"temperature '{{temperature}}' is {{#ifPositive temperature}}not negative {{#@isZero}}(but not positive either){{/@isZero}} {{else}}negative{{/ifPositive}}.";

NSError* error = nil;
NSLog(@"%@", [HBHandlebars renderTemplateString:template withContext:@{ @"temperature" : @(10) } error:&error]);
NSLog(@"%@", [HBHandlebars renderTemplateString:template withContext:@{ @"temperature" : @(-10) } error:&error]);
NSLog(@"%@", [HBHandlebars renderTemplateString:template withContext:@{ @"temperature" : @(0) } error:&error]);
```

In your console you should see: 

```
temperature '10' is not negative  .
temperature '-10' is negative.
temperature '0' is not negative (but not positive either) .
```

You know enough now to understand the example by reading its sources. Two comments though: 

 - When setting (or changing) a private variable for the descendant scope, you must always create a new data context (as in the example). 
 - Invoking the inverse statements of your helper is lot like calling its normal statements except that you invoke the 'inverseStatements' block provided in HBHelperCallingInfo.
