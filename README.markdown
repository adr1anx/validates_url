<h1>validate_url</h1>
<p>Provides <code>validate_url</code> validation to <code>ActiveRecord</code> models.</p>


<h2>Usage</h2>
<p>Install, then</p>
<code>
class User < ActiveRecord::Base
  validate_url :url, :check_http => true
end
</code>

<p>Has the same options as <code>validates_format_of</code> with the addition of <code>check_http</code>.  All
this does is check to see if the url returns a 200 response.  If it doesn't, it will throw the error.</p>

<h2>To Do</h2>
<p>I'd like to add better error messaging based on the specific error/code, and add more handling for different
response codes.</p>

Copyright (c) 2009 Adrian Titus, released under the MIT license
