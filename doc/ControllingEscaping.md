# Controlling escaping in handlebars-objc #

## Warning 

This document describes an extension to handlebars available only in handlebars-objc. While most is implemented using helpers, those helpers leverage an internal mechanism that, to our knowledge, is not available yet in other implementations. 

## The need for some control 

By default, handlebars escapes content so that generated text can be safely and correctly rendered when inserted within an HTML node. And this is fine, since handlebars is mostly used to generate html documents. 

For instance 

	<span> 1 {{ "<=" }} 2 </span>

Would render as

	<span> 1 &lt;= 2 </span>

And this is what we expect so the html document displays "1 < 2".
Unfortunately, "HTML escaping" is an ill-defined notion. HTML documents are made of different parts that require different escaping. 

Let's illustrate this with a simple example: the ampersand character ('&').

The ampersand char must be escaped in HTML Text nodes. The 'R&D' word must is thus be escaped this way

	<span> R&amp;D </span>
    
So far, handlebars does this perfectly: template 

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

Two helpers provide control over escaping in handlebars-objc. 

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

















