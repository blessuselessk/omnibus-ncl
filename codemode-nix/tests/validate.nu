#!/usr/bin/env nu
# codemode-nix validation — nushell version
let ncl_dir = ($env.FILE_PWD | path dirname)
let tests_dir = $"($ncl_dir)/tests"
let nickel = ($env | get -o NICKEL | default "nickel")
let tmp = "/tmp/ncl-cnix"
mut pass = 0
mut fail = 0
print "=== codemode-nix validation ==="
print ""
# --- Step 1: Nickel export validation ---
print "Step 1: Nickel export validation"
for f in [nix-tools-export, nix-registry, provider-config] {
    let out = $"($tmp)-($f).json"
    let result = (do { ^$nickel export --format json $"($ncl_dir)/examples/($f).ncl" } | complete)
    if $result.exit_code == 0 {
        $result.stdout | save -f $out
        print $"  PASS: ($f).ncl exports as JSON"
        $pass += 1
    } else {
        print $"  FAIL: ($f).ncl export failed"
        $fail += 1
    }
}
print ""
# --- Step 2: Structure validation ---
print "Step 2: Structure validation"
let tools = (open $"($tmp)-nix-tools-export.json")
let tool_count = ($tools | columns | length)
if $tool_count == 5 {
    print "  PASS: Nix tool count is 5"
    $pass += 1
} else {
    print $"  FAIL: Nix tool count is ($tool_count) (expected 5)"
    $fail += 1
}
let all_have_schema = ($tools | columns | all {|name|
  let t = ($tools | get $name)
  ("description" in ($t | columns)) and ("inputSchema" in ($t | columns))
})
if $all_have_schema {
    print "  PASS: All LLM-facing tools have description + inputSchema"
    $pass += 1
} else {
    print "  FAIL: Some tools missing description or inputSchema"
    $fail += 1
}
let registry = (open $"($tmp)-nix-registry.json")
let all_have_sandbox = ($registry | columns | all {|name|
  let t = ($registry | get $name)
  ("sandbox" in ($t | columns)) and ("flakeRef" in ($t | columns))
})
if $all_have_sandbox {
    print "  PASS: All registry entries have sandbox + flakeRef"
    $pass += 1
} else {
    print "  FAIL: Some registry entries missing sandbox or flakeRef"
    $fail += 1
}
let valid_levels = ($registry | columns | all {|name|
  ($registry | get $name | get securityLevel) in ["strict" "network" "io" "full"]
})
if $valid_levels {
    print "  PASS: All security levels are valid"
    $pass += 1
} else {
    print "  FAIL: Some security levels are invalid"
    $fail += 1
}
let aspects = (open $"($tmp)-provider-config.json")
let aspect_count = ($aspects.aspects | length)
if $aspect_count == 3 {
    print "  PASS: Aspect config has 3 aspects"
    $pass += 1
} else {
    print $"  FAIL: Aspect config has ($aspect_count) aspects (expected 3)"
    $fail += 1
}
print ""
# --- Step 3: Snapshot comparison ---
print "Step 3: Snapshot comparison"
for pair in [[name, snap]; [nix-tools-export, snapshot.json], [nix-registry, snapshot-registry.json]] {
    let exported = (open $"($tmp)-($pair.name).json" | to json --indent 2)
    let snap_path = $"($tests_dir)/($pair.snap)"
    if ($snap_path | path exists) {
        let snapshot = (open $snap_path | to json --indent 2)
        if $exported == $snapshot {
            print $"  PASS: ($pair.name) matches committed snapshot"
            $pass += 1
        } else {
            print $"  FAIL: ($pair.name) differs from committed snapshot"
            $fail += 1
        }
    } else {
        print $"  FAIL: No ($pair.snap) found"
        $fail += 1
    }
}
print ""
let total = $pass + $fail
print $"=== Results: ($pass)/($total) passed ==="
if $fail > 0 { exit 1 }
