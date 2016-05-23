JSON/YAML Parser
--------------------------------

Small script that allows to read/set a value for a specific path in a JSON or YAML
file.

The main motivation behind this is to quickly be able to read a specific
property from a JSON/YAML file, do something with that value and then change the
original value with a new one in the document. And being able to do that
transparently regardless of the source format.

To accomplish this, YAML input is converted behind the scenes to JSON using
Python, a `jq` filter is applied on the JSON and the result is converted back
into YAML.

Like I said before, the goal is to get/set a specific value associated with a
key in the document.
If you are looking to run arbitrary jq-like filters on YAML I'd recommend you to
take a look at [y2j](https://github.com/wildducktheories/y2j).

# Usage
The script's entry point accepts 2 operations: `get` and `set`. The script can
take its inputs from stdin or read from a file if this is passed as the first
parameter. We'll see some examples below.

## Get a value
The `get` command takes an arbitrary `jq` filter. If the result is a number,
string or boolean then that value is returned. Otherwise, the resulting JSON or
YAML is returned (depending on what the input was).

Given the following JSON file:

```bash
$ cat test.json

{"menu": {
  "id": "file",
  "value": "File",
  "popup": {
    "menuitem": [
      {"value": "New", "onclick": "CreateNewDoc()"},
      {"value": "Open", "onclick": "OpenDoc()"},
      {"value": "Close", "onclick": "CloseDoc()"}
    ]
  }
}}
```

If you wanted to get the value of the _id_ property you could use:
```bash
$ cat test.json | docker run -i --rm jlordiales/jyparser get ".menu.id"

"file"
```

The json is passed via stdin, which is useful if you get that from something like
`curl`. If you have an actual file that you want to use as input then you can
pass it directly as the first parameter to the script:

```bash
$ docker run -i --rm -v `pwd`:/jyparser:ro jlordiales/jyparser test.json get ".menu.id"

"file"
```

The example above mounts the current dir with the file into `/jyparser` (which
is the default WORKDIR for the docker image) and then uses that file as input.

Exactly the same command works for YAML as well. Given the YAML file:

```bash
$ cat test.yml
menu:
  id: file
  value: File
  popup:
    menuitem:
    - onclick: CreateNewDoc()
      value: New
    - onclick: OpenDoc()
      value: Open
    - onclick: CloseDoc()
      value: Close
```

We can get the `id` property with:
```bash
$ cat test.yml | docker run -i --rm jlordiales/jyparser get ".menu.id"

"file"
```

If the result from running the `jq` filter is not a simple value, then the
corresponding JSON or YAML is returned:

```bash
$ cat test.json | docker run -i --rm jlordiales/jyparser get ".menu.popup.menuitem[1]"

{
  "value": "Open",
  "onclick": "OpenDoc()"
}

$ cat test.yml | docker run -i --rm jlordiales/jyparser get ".menu.popup.menuitem[1]"

onclick: OpenDoc()
value: Open
```

## Set a value
Similarly to the `get` operation, there's a `set` one. This operation takes 2
parameters: a jq filter to select a specific element of the input and a new
value to update that element to. The result is the original input with the value
updated.

```bash

$ cat test.json | docker run -i --rm jlordiales/jyparser set ".menu.id" \"new_id\"
{
  "menu": {
    "id": "new_id",
    "value": "File",
    "popup": {
      "menuitem": [
        {
          "value": "New",
          "onclick": "CreateNewDoc()"
        },
        {
          "value": "Open",
          "onclick": "OpenDoc()"
        },
        {
          "value": "Close",
          "onclick": "CloseDoc()"
        }
      ]
    }
  }
}
```

**Important**: given the way bash scripts handle quotes on parameters passed to
them, if the new value you want to set for the property is a string you need to
explicitly escape the quotes as in the example. Otherwise, `jq` will complain
that the value is not valid (rightfully so). This is not needed for numbers or
booleans.
So the following works as expected:

```bash
$ cat test.json | docker run -i --rm jlordiales/jyparser set ".menu.id" 15
{
  "menu": {
    "id": 15,
    "value": "File",
    "popup": {
      "menuitem": [
        {
          "value": "New",
          "onclick": "CreateNewDoc()"
        },
        {
          "value": "Open",
          "onclick": "OpenDoc()"
        },
        {
          "value": "Close",
          "onclick": "CloseDoc()"
        }
      ]
    }
  }
}
```
The same works for YAML:
```bash
$ cat test.yml | docker run -i --rm jlordiales/jyparser set ".menu.id" \"new_id\"

menu:
  id: new_id
  popup:
    menuitem:
    - onclick: CreateNewDoc()
      value: New
    - onclick: OpenDoc()
      value: Open
    - onclick: CloseDoc()
      value: Close
  value: File
```

# Limitations
Since YAML is actually a [superset of
JSON](http://yaml.org/spec/1.2/spec.html#id2759572) this will only work for those YAML files
that can be correctly converted to JSON.

# Acknowledgments
The JSON <=> YAML conversion to be able to apply `jq` filters seamlessly is
heavily inspired by [y2j](https://github.com/wildducktheories/y2j).
