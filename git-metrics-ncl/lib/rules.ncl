# Inference rules — derived knowledge from the git-metrics schema
let B = import "../../typedb-ncl/lib/builders.ncl" in
{
  schema = {
    attributes = [],
    entities = [],
    relations = [],
    rules = [
      B.rule_commented "infer-merge-commit"
        "A commit with multiple parents is a merge commit"
        m%"
    $c isa commit;
    (child: $c, parent: $p1) isa parentage;
    (child: $c, parent: $p2) isa parentage;
    not { $p1 is $p2; };"%
        m%"
    $c has is-merge true;"%,

      B.rule_commented "transitive-ancestry"
        "If A is parent of B and B is parent of C, A is ancestor of C"
        m%"
    (child: $b, parent: $a) isa parentage;
    (child: $c, parent: $b) isa parentage;"%
        m%"
    (child: $c, parent: $a) isa parentage;"%,

      B.rule_commented "infer-contribution"
        "A contributor who authored commits on a branch contributed to the repo"
        m%"
    $contributor isa contributor;
    (author: $contributor, authored-commit: $commit) isa authoring;
    (branch-ref: $branch, branch-commit: $commit) isa branching;
    (host-repo: $repo, hosted-branch: $branch) isa hosting;"%
        m%"
    (contributor: $contributor, contributed-to: $repo) isa contribution;"%,

      B.rule_commented "infer-file-ownership"
        "File ownership inferred from blame majority"
        m%"
    $author isa contributor;
    (blamed-file: $file, blamed-author: $author) isa blaming;"%
        m%"
    (owned-file: $file, owner: $author) isa ownership;"%,
    ],
  }
}
