#!/usr/bin/env bats

@test "operation different than set or get shows usage instructions" {
  run ./start test.yml invalid
  [ $status -eq 1 ]
  [ $(expr "${lines[0]}" : "Usage:.*") -ne 0 ]
}

@test "get with too few parameters shows usage instructions" {
  run ./start test.yml get
  [ $status -eq 1 ]
  [ $(expr "${lines[0]}" : "Usage:.*") -ne 0 ]
}

@test "set with too many parameters shows usage instructions" {
  run ./start test.yml set . extra param
  [ $status -eq 1 ]
  [ $(expr "${lines[0]}" : "Usage:.*") -ne 0 ]
}

@test "set with too few parameters shows usage instructions" {
  run ./start test.yml set
  [ $status -eq 1 ]
  [ $(expr "${lines[0]}" : "Usage:.*") -ne 0 ]
}

@test "get can parse JSON input from stdin" {
  result=$(cat test.json | ./start get .menu.popup.menuitem[0].value)
  [ "$result" = "\"New\"" ]
}

@test "get can parse JSON input from file" {
  result=$(./start test.json get .menu.popup.menuitem[0].value)
  [ "$result" = "\"New\"" ]
}

@test "get can parse YAML input from stdin" {
  result=$(cat test.yml | ./start get .menu.popup.menuitem[0].value)
  [ "$result" = "\"New\"" ]
}

@test "get can parse YAML input from file" {
  result=$(./start test.yml get .menu.popup.menuitem[0].value)
  [ "$result" = "\"New\"" ]
}

@test "set can update JSON coming from stdin" {
  result=$(cat test.json | ./start set .menu.id 1 | ./start get .menu.id)
  [ "$result" = "1" ]
}

@test "set can update JSON coming from file" {
  result=$(./start test.json set .menu.id 1 | ./start get .menu.id)
  [ "$result" = "1" ]
}

@test "set can update YAML coming from stdin" {
  result=$(cat test.yml | ./start set .menu.id 1 | ./start get .menu.id)
  [ "$result" = "1" ]
}

@test "set can update YAML coming from file" {
  result=$(./start test.yml set .menu.id 1 | ./start get .menu.id)
  [ "$result" = "1" ]
}
