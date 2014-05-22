# Localizing Strings #

## Localization in templates ##

Within templates, strings can be localized using the 'localize' helper. 
This helper translates a string into another.

For instance, the template

	hello is '{{localize "hello"}}' in current locale

Would render as "hello is 'bonjour' in current locale". 
(if locale is french)

Of course, in this case, the translation of 'hello' into 'bonjour' is not known to handlebars-objc and has to be provided by the client application.

## Providing localization from the client application ##

As seen above, the client application is responsible for providing the actual mapping between untranslated and translated strings. This section documents the various ways an application can provide string translations.

### Using standard MacOS and iOS localization process ###

The simplest way to provide translations to your templates is to add them to your application localization strings.
When looking for a translation, if none is provided by other mechanisms, handlebars-objc falls back to standard translation mechanism. 

Please read [Offical Apple Documentation](https://developer.apple.com/library/ios/documentation/MacOSX/Conceptual/BPInternational/Articles/StringsFiles.html) for detailed instructions on how to provide localization strings to your application. 

### Using custom translation mappings ### 

If MacOS and iOS localization strings are not enough, handlebars-objc provides delegation APIs you can use to provide your own translations. 

Let's first create a simple delegate:

    @interface SimpleLocalizationDelegate : NSObject<HBExecutionContextDelegate>

    - (NSString*) localizedString:(NSString*)string forExecutionContext:(HBExecutionContext*)executionContext;

    @end

    @implementation SimpleLocalizationDelegate

    - (NSString*) localizedString:(NSString*)string forExecutionContext:(HBExecutionContext*)executionContext
    {
        // if string to translate is "handlebars", return french translation
        if ([string isEqual:@"handlebars"]) return @"guidon";
        // otherwise, provide no translation at all. Handlebars-objc will then fallback to other mechanisms
        else return nil;
    }

    @end

This delegate implements the -localizedString:forExecutionContext: method to return the French translation for the world "handlebars". 

Of course, a real world example would return the translation in current locale, and not always in French. 

Now let's see how we can use this delegate class when rendering a template: 

        // create a new execution context
        HBExecutionContext* executionContext = [[HBExecutionContext new] autorelease];

        // set its delegate (will provide localization of "handlebars" string)
        executionContext.delegate = [[SimpleLocalizationDelegate new] autorelease];

        // render template
        HBTemplate* template = [executionContext templateWithString:@"hello {{localize 'handlebars'}}!"];

        NSError* error = nil;
        NSString* evaluation = [template renderWithContext:nil error:&error];

		// evaluation now contains "hello guidon!"




