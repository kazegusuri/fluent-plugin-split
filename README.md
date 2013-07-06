# fluent-plugin-split

Fluentd output plugin to split a record into multiple records with key/value pair.

## Overview
This plugin splits a record and parses each results to make key/value pairs.

Normally you can use a regular expression to parse a record.
It is difficult to parse a record which has ambiguous numbers of data like a following record.
```json
{"message":"key1=val1 key2=val2 key3=val3"}
```

Now you can easily generate a following result with this plugin.
```json
{"key1":"val1","key2":"val2","key3":"val3"}
```

## Installation

```
$ gem install fluent-plugin-split
```

## Configuration

### Example
```
<match *>
  type        split
  tag         split.message
  separator   \s+
  format      ^(?<key>[^=]+?)=(?<value>.*)$
  key_name    data
  reserve_msg yes
</match>
```

### Parameters

|parameter|description|default|
|---|---|---|
|tag| key name for tag | |
|format| regexp to parse a record after split | ^(?\<key\>[^=]+?)=(?\<value\>.*)$ |
|separator| regexp used by split | \s+ |
|key_name| key name to be split | |
|out_key| key name of json object which includes divided records | nil |
|reserve_msg| if original message is reserved or not | nil |
