# Minimal bash job — just name, owner, and script
let B = import "../lib/builders.ncl" in

B.job "hello-world" "myorg" "hello.sh"
