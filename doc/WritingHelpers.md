# Writing Helpers #

The most important feature of handlebars is the ability for the hosting application to provide application-specific formatting features to templates. 
This ability is enabled by the use of helpers. 



There are two kinds of helpers. Handlebars.js documentation calls them "helpers" and "block helpers":
 - Simple Helpers are used to transform values. Those values are passed by template writers as parameters. In the example above, model.date is the only parameter passed to short_date helpers. 
 - Block Helpers generally provide iterative or conditional constructs. Like normal helpers, they are passed parameters, but they also enclose block statements. 

For example, suppose the hosting application need to display dates in a localed-dependent short format. 
The application could define a helper named "short_date_format" that takes an iso8601 date value and tranforms it into a short date format in users locale. 

 Templates may then use it this way:

 ```
   Date is {{short_date_format model.date}}. 
 ```

In this case, short_date_format is a simple helper that simple transforms a parameter into a formatted date string. 

An application could also provide a helper named "reverse_each" that iterates over an array in reverse order and execute a block of statements at each step: 

Templates may then use it this way: 

```
  Sorted elements from last to first :
  {{reverse_each model.elements}}
    element value : {{value}}
  {{/reverse_each}}
```

In this case, reverse_each is a block helper. 


## Helper parameters ##

Helpers can take as many parameters as they need. Those parameters can be either passed in sequence, or by name. For instance the short_date_format above could take an additional parameter named "with_year" that takes a boolean value: 

```
  Date is {{short_date_format model.date with_year=false}}
```

In this case model.date sets a positional parameter (with index 0) and with_year=false sets a named parameter with name "with_year". 

Helpers can use as many parameters as they need. Positional parameters are obviously ordered, and the come first. Named parameters come then and can be given in any order. 

## Writing Helpers in Objective-C ##

In handlebars-objc, helpers are Objective-C blocks with the following signature 

```objc
NSString* (^HBHelperBlock)(HBHelperCallingInfo* callingInfo)
{
  ...
}
```

All contextual information a helper can use if provided in the callingInfo object: 


 - positional parameters 
 - named parameters 
 - handlebars context 
 - handlebars private data

In addition, block helpers have access to the following block information: 

 - block statements 
 - inverse section statements 

(please see [HBHelperCallingInfo refence](http://fotonauts.github.io/handlebars-objc/api_doc/Classes/HBHelperCallingInfo.html) for a complete API documentation of HBHelperCallingInfo). 


### Our first helper ###

Let's write a helper than simply prints the current date and register it as a global helper available to all templates:

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

// render a template using the helper
NSString* renderedTemplate =
    [HBHandlebars renderTemplateString:@"Date is: {{formatted_date}}"
                           withContext:@{}];

NSLog(@"rendered value : %@", renderedTemplate);
// --> rendered value : Date is: Oct 13, 2013
```

