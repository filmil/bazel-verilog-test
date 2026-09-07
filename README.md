# bazel-verilog-test

[![Build](https://github.com/filmil/bazel-verilog-test/actions/workflows/build.yml/badge.svg)](https://github.com/filmil/bazel-verilog-test/actions/workflows/build.yml)

A small worked example of building and testing Verilog with Bazel, using
rules that come from the Bazel Central Registry.

The design is a 128 bit counter in `counter.v`.
`rules_verilog` describes it as a `verilog_library`, `rules_verilator`
verilates it into a C++ model, and a `cc_test` drives that model and checks
that it resets and counts.
Yosys then synthesizes the same source to a gate level netlist, and that
netlist is verilated and driven by the same test.

## Building

```bash
bazel build //...
bazel test //...
```

The Bazel version is pinned in `.bazelversion`, so install `bazelisk` under
the name `bazel` and the right version is fetched for you.
Nothing else needs to be installed.
Verilator, its runtime, and the C++ test framework are all fetched and built
by Bazel.

## What the build contains

Simulation of the source:

```
verilog_library(name = "counter")                 # the RTL, from rules_verilog
verilator_cc_library(name = "counter_verilator")  # the C++ model
cc_test(name = "counter_test")                    # drives the model
```

Synthesis, and simulation of the result:

```
genrule(name = "counter_synth")                   # yosys, from the registry
sh_test(name = "counter_synth_test")              # checks the netlist
verilog_library(name = "counter_netlist")         # the netlist as a library
verilator_cc_library(name = "counter_netlist_verilator")
cc_test(name = "counter_netlist_test")            # same test, on the netlist
```

`counter_test.cc` holds the design in reset across a rising edge, checks the
count is zero, then clocks it and checks it advances by one each time.
It runs twice: once against the source and once against the synthesized
netlist.
Running the same assertions on both is what says synthesis did not change
what the design does.

`counter_synth_test.sh` checks the netlist structurally.
It asserts the netlist declares `module counter`, that no arithmetic operator
survived, that the logic is continuous assignments of bitwise operators, and
that yosys reported exactly 128 flip flops.

Every one of these was checked against a deliberate break.
Changing the increment from one to two fails both simulation tests.
Narrowing the counter to 64 bits fails the structural test with
`netlist has 64 flip flops; wanted 128`.

## History

This repository used to depend on
[bazel_rules_hdl](https://github.com/hdl/bazel_rules_hdl), pinned by git
commit through a `WORKSPACE` file, and it ran synthesis and place and route
through Yosys and OpenROAD.
That was written before those rules were available any other way, and it
answered a question raised in
[bazel_rules_hdl#123](https://github.com/hdl/bazel_rules_hdl/issues/123).

Two things changed since.
Verilog and Verilator rules are now published in the Bazel Central Registry,
so a project can name them as ordinary `bazel_dep` entries and get a pinned,
versioned release.
`bazel_rules_hdl` is still not published in any registry, so using it means
pinning a commit and repeating each of its own overrides in the consuming
module, because Bazel applies an override only from the root module.

So this example now uses `rules_verilog` and `rules_verilator` from the
registry.
The build no longer compiles OpenROAD and Yosys, which is why it finishes in
minutes rather than hours.

Synthesis is covered, because `yosys` and `abc` are both published in the
registry.

Place and route is not.
There is no `openroad` module in the Bazel Central Registry, and no PDK
either, so OpenROAD can only be reached by pinning its git repository.
For that, `bazel_rules_hdl` is still the place to look.

## Troubleshooting

If something does not work, [file a bug][fb].

[fb]: https://github.com/filmil/bazel-verilog-test/issues
