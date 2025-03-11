def json2header:
  [paths(scalars)];

def json2array($header):
  [$header[] as $p | getpath($p)];

# given an array of conformal objects, produce "CSV" rows, with a header row:
def json2csv:
  (.[0] | json2header) as $h
  | ([$h[]|join(".")], (.[] | json2array($h))) 
  | @csv ;

# `main`
json2csv

