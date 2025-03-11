#!/bin/bash
if [ -n "$1" ]; then
  jq 'def recurse_keys(path):
    if type == "object" then
      keys_unsorted[] as $k |
      (if path == "" then
        $k else
        (path + "." + $k)
      end) as $path |
      $path,
      if .[$k] | type == "object" then
        .[$k] | recurse_keys($path)
      else
        if .[$k] | type == "array" then
          .[$k][0] | recurse_keys($path + ".[]")
        else
          empty
        end
      end
    else
      empty
    end;
    recurse_keys("")' "$1"
else
  if [ -s /dev/stdin ]; then
    cat /dev/stdin | jq 'def recurse_keys(path):
      if type == "object" then
        keys_unsorted[] as $k |
        (if path == "" then
          $k else
          (path + "." + $k)
        end) as $path |
        $path,
        if .[$k] | type == "object" then
          .[$k] | recurse_keys($path)
        else
          if .[$k] | type == "array" then
            .[$k][0] | recurse_keys($path + ".[]")
          else
            empty
          end
        end
      else
        empty
      end;
      recurse_keys("")'
  else
    echo "Usage: jq_recurse_keys [file]"
    echo "       jq_recurse_keys < [file]"
    exit 1
  fi
fi

