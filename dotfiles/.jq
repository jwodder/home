def maybeNum: tonumber? // .;

def get($k): if has($k)? then .[$k] else empty end;

def get($k; $default): if has($k)? then .[$k] else $default end;

def elem($xs): . as $v | (xs | any(. == $v));

def mele($v): any(. == $v);

def filter(f): map(select(f));

# Filter the keys of an object based on the values
# (Is this already a function?)
def filter_by_val(f): to_entries | map(select(.value | f) | .key);

def zip(xs): [., xs] | transpose;

def pairs2dict: map({key: .[0], value: .[1]}) | from_entries;

def dict2pairs: to_entries | map([.key, .value]);

def allfields($k): .. | get($k);

def isSubsetOf($xs): all(elem($xs));

def alterfields($field; f): (.. | select(has($field)?) | .[$field]) |= f;

# Map String [a] -> (String, a) -> Map String [a]
def addtomap($k; $v): .[$k] |= (. // []) + [$v];

# [{"key": String, "value": a}] -> Map String [a]
def multiset: reduce .[] as $pair ({}; addtomap($pair.key; $pair.value));

# "Transposes"/"inverts" a `String -> [String]` object
def invert_rel: to_entries | map({key: .value[], value: .key}) | multiset;

def del_nulls: del(.. | objects | .[] | nulls);

###def rename_field($k1; $k2): if has($k1)? then del(.[$k1]) + {($k2): .[$k1]} else . end;
