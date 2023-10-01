# bazel-verilog-test ![build](https://github.com/filmil/bazel-verilog-test/actions/workflows/build.yml/badge.svg)
> Automated builds are executed on each PR, and once a week even if no code changed the week prior.

Testing verilog build rules from https://github.com/hdl/bazel_rules_hdl

This is the answer to the question posed at:
https://github.com/hdl/bazel_rules_hdl/issues/123

## Prerequisites

### `/usr/bin/python`

You need to have the binary `/usr/bin/python` on your system.

On my system, the following ensures that this happens:

```
sudo apt-get install python-is-python3
```

### Bazelisk

Download `bazelisk` from here:
https://github.com/bazelbuild/bazelisk#installation

When you download the appropriate version for your system, place it somewhere
in your `$PATH`, and name it `bazelisk`. From here on I will assume that this
is the case.

### Clone this repository

```
git clone https://github.com/filmil/bazel-verilog-test
```

## Building the example

```
bazelisk build //:counter_place_and_route
```

After a considerable amount of time spent in downloading and compiling the
prerequisites, you should have your placed and routed design.

### Example

This is what my computer said. (Compilation was quick because I already spent
a long time compiling the prerequisites.)

```
$ bazelisk build //:counter_place_and_route
INFO: Analyzed target //:counter_place_and_route (23 packages loaded, 10985 targets configured).
INFO: Found 1 target...
Target //:counter_place_and_route up-to-date:
  bazel-bin/counter_place_and_route_detail_routed.def
  bazel-bin/counter_place_and_route__detailed_routing.db
  bazel-bin/counter_place_and_route__floorplan.log
  bazel-bin/counter_place_and_route__place_pins.log
  bazel-bin/counter_place_and_route__pdn_generation.log
  bazel-bin/counter_place_and_route__global_placement.log
  bazel-bin/counter_place_and_route__resizing.log
  bazel-bin/counter_place_and_route__clock_tree_synthesis.log
  bazel-bin/counter_place_and_route__global_routing.log
  bazel-bin/counter_place_and_route__detailed_routing.log
  bazel-bin/counter_place_and_route_verilog_based_power_results.textproto
  bazel-bin/counter_place_and_route_verilog_based_area_results.textproto
  bazel-bin/counter_place_and_route_general_routing_power_results.textproto
  bazel-bin/counter_place_and_route_general_routing_area_results.textproto
  bazel-bin/counter_place_and_route_commands.tcl
INFO: Elapsed time: 4.611s, Critical Path: 0.09s
INFO: 1 process: 1 internal.
INFO: Build completed successfully, 1 total action
```

### What needed resolving

This is a short list of things that needed resolving to get this working repo
up and running.

The repository rules at https://github.com/hdl/bazel_rules_hdl are sensitive
to bazel version, actually.  This has to do with the not backwards compatible
evolution of `@bazel_tools` but also the approaches the prerequisite deps are
taking to bazel compilation.  I tried to fix the HDL rules at top of tree, but
could not do that easily. To resolve this issue, I added `.bazelversion` at the
project root and pegged the bazel version needed at `4.0.0`.

This, in turn, means that the best way to compile this repository is by using
`bazelisk`. `bazelisk` will read `.bazelversion` and automatically download and
apply the appropriate bazel version to your repository.

The README.md in the `bazel_rules_hdl` repository is lacking a sample working
set of `git hash` and `sha_256`, and has no clear instruction to choose a
working set.  It is also offering a syntactically incorrect `WORKSPACE` example,
which one should also work around.

The WORKSPACE file example in the repository is also lacking some needed
declarations. I supplanted those based on the `WORKSPACE` file in
`bazel_rules_hdl`, and the observations given in
https://github.com/hdl/bazel_rules_hdl/issues/123.

The repository is not complete with a set of carefully placed `.bazelrc`
directives.  This is not mentioned in `README.md`, but is required for the
build to work. At minimum, the dependency code requires C++17 or higher, which
you don't get by default.

The rules are not fully hermetic, and depend on having `/usr/bin/python`. Which
you might not have if your system only installs `/usr/bin/python3`. My computer
luckily had a package `python-is-python3` that I could install to fix this.

With all of that fixed, I was able to build the sample basic design without
errors.

### Troubleshooting

I intend to keep this repository in working order. If something does not work,
[file a bug][fb].

[fb]: https://github.com/filmil/bazel-verilog-test/issues
