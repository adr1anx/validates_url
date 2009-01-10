<h1>validate_url</h1>
<p>Provides <code>validate_url</code> validation to <code>ActiveRecord</code> models.</p>


<h2>Usage</h2>
<p>Install, then</p>
	class User < ActiveRecord::Base
	  validate_url :url, :check_http => true
	end

<p>Has the same options as <code>validates_format_of</code> with the addition of <code>check_http</code>.  All
this does is check to see if the url returns a HTTPSuccess response.  If it doesn't, it will throw the error.</p>

<p>See lib/validate_url.rb for specific options.</p>

Copyright (c) 2009 Adrian Titus, released under the MIT license
