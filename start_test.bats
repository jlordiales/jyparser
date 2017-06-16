#!/usr/bin/env bats

in_docker() {
  docker run -i --rm -v "`pwd`/start":/bin/start  -v "`pwd`":/jyparser:ro jlordiales/jyparser $@
}

@test "operation different than set or get shows usage instructions" {
  run in_docker test.yml invalid
  [ $status -eq 1 ]
  [ $(expr "${lines[0]}" : "Usage:.*") -ne 0 ]
}

@test "get with too few parameters shows usage instructions" {
  run in_docker test.yml get
  [ $status -eq 1 ]
  [ $(expr "${lines[0]}" : "Usage:.*") -ne 0 ]
}

@test "set with too many parameters shows usage instructions" {
  run in_docker test.yml set . extra param
  [ $status -eq 1 ]
  [ $(expr "${lines[0]}" : "Usage:.*") -ne 0 ]
}

@test "set with too few parameters shows usage instructions" {
  run in_docker test.yml set
  [ $status -eq 1 ]
  [ $(expr "${lines[0]}" : "Usage:.*") -ne 0 ]
}

@test "get can parse JSON input from stdin" {
  result=$(cat test.json | in_docker get .menu.popup.menuitem[0].value)
  [ "$result" = "\"New\"" ]
}

@test "get can parse JSON input from file" {
  result=$(in_docker test.json get .menu.popup.menuitem[0].value)
  [ "$result" = "\"New\"" ]
}

@test "get can parse YAML input from stdin" {
  result=$(cat test.yml | in_docker get .menu.popup.menuitem[0].value)
  [ "$result" = "\"New\"" ]
}

@test "get can parse YAML input from file" {
  result=$(in_docker test.yml get .menu.popup.menuitem[0].value)
  [ "$result" = "\"New\"" ]
}

@test "set can update JSON coming from stdin" {
  result=$(cat test.json | in_docker set .menu.id 1 | in_docker get .menu.id)
  [ "$result" = "1" ]
}

@test "set can update JSON coming from file" {
  result=$(in_docker test.json set .menu.id 1 | in_docker get .menu.id)
  [ "$result" = "1" ]
}

@test "set can update YAML coming from stdin" {
  result=$(cat test.yml | in_docker set .menu.id 1 | in_docker get .menu.id)
  [ "$result" = "1" ]
}

@test "set can update YAML coming from file" {
  result=$(in_docker test.yml set .menu.id 1 | in_docker get .menu.id)
  [ "$result" = "1" ]
}

@test "get can perform complex jq queries with YAML" {
  run in_docker test.yml get ".menu | to_entries | .[] | [\"command\", .key, \"\(.value)\"] | @sh"
  [ $(expr "${lines[0]}" : ".*command.*") -ne 0 ]
}

@test "get can perform complex jq queries with JSON" {
  run in_docker test.json get ".menu | to_entries | .[] | [\"command\", .key, \"\(.value)\"] | @sh"
  [ $(expr "${lines[0]}" : ".*command.*") -ne 0 ]
}

@test "get can use jq built-in parameters (like -r for raw output)" {
  result=$(cat test.yml | in_docker get -r .menu.popup.menuitem[0].value)
  [ "$result" = "New" ]
}
