# stdout-hook

## Purpose

Stdout-hook is a ruby gem that allow users to log data without running a daemon process (such as td-agent) locally. Users can output directly log info directly to stdout where stdout-hook parses it and sends it via HTTP/HTTPS to a remote log collector service. This makes it easier than ever to import data into Treasure Data.

This feature is also available for the Treasure Data addon on Heroku: 
http://docs.treasure-data.com/articles/heroku-ruby#data-import

## Feature

Stdout-hook monitors the standard output and performs regexp matching on every line to see if it should be collected. If matched, stdout-hook parses the input line and sends the result to Treaure Data or Fluentd.

### Syntax

To have data picked up by stdout-hook, simply output to stdout in this format:

`@[db_name.table_name] json_in_one_line`

Thus, in Ruby:

`puts '@[service.users] { "first_name": "Bob", "last_name": "Smith" }'`

### Usage

Inject `stdout-hook` before actual command

In Ruby with bundle:

`bundle exec stdout-hook rails s`

or using pipe:

`bundle exec rails s | stdout-hook`


### Option

* --mode: Choose running mode (default is 'td')

#### for Treasure Data

* --apikey: TD account API key (default is ENV["TD_API_KEY"])
* --use_ssl: Enable SSL connection to TD (default is false)

#### for Fluentd

Note: In fluentd mode, ‘service.users’ is a tag.

* --host: Fluentd host (default is localhost)
* --port: Fluentd port (default is 24224)

## Comparison

Here’s how stdout-hook compares to some related tools

*stdout-hook

Picks up the relevant lines via regex and ignores other lines

Example:

```
[2013-02-14 16:22:27] INFO  WEBrick 1.3.1
[2013-02-14 16:22:27] INFO  ruby 1.9.3 (2013-02-06) [x86_64-darwin12.2.1]
== Sinatra/1.3.4 has taken the stage on 4567 for development with backup from WEBrick
[2013-02-14 16:22:27] INFO  WEBrick::HTTPServer#start: pid=34235 port=4567
@[foo.bar] {"foo":"bar","num":100}
127.0.0.1 - - [14/Feb/2013 16:22:29] "GET / HTTP/1.1" 200 12 0.0022
localhost - - [14/Feb/2013:16:22:29 JST] "GET / HTTP/1.1" 200 12
- -> /
```

stdout-hook processes `@[foo.bar] {"foo":"bar","num":100}` line and ignores other lines.

* fluent-cat

This assumes all inputs are one-line JSON lines.

Example:

```
$ echo '{"json":"message"}' | fluent-cat debug.test
2011-12-15 18:43:53 +0900 debug.test: {"json":"message"}
```

* fluent-agent-lite

This converts raw log into JSON.

Example:

```
$ echo "log message" | /path/to/bin/fluent-agent-lite myapp.info - localhost
2012-06-11 09:10:21 +0900 myapp.info: {"message":"log message"}
```

## TODO

* For ruby, removing explicit 'stdout-hook' command.
I am digging bundle hacks.

== Copyright

Copyright:: Copyright (c) 2013 Treasure Data Inc.
License::   Apache License, Version 2.0
