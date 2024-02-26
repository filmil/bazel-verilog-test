# bazel-verilog-test ![build](https://github.com/filmil/bazel-verilog-test/actions/workflows/build.yml/badge.svg)
> Automated builds are executed on each PR, and once a week even if no code
> changed the week prior.

Testing verilog build rules from https://github.com/hdl/bazel_rules_hdl

This is the answer to the question posed at:
https://github.com/hdl/bazel_rules_hdl/issues/123

## Troubleshooting

I intend to keep this repository in working order. If something does not work,
[file a bug][fb].

[fb]: https://github.com/filmil/bazel-verilog-test/issues

## Prerequisites

This is a prep-work checklist to be able to compile the code in this repo with
success. I hope you will find it quite modest.

### Bazelisk

Download and install `bazelisk` (not `bazel`) following the [instructions][bii].

[bii]: https://github.com/bazelbuild/bazelisk#installation

When you download the appropriate version for your system, place it somewhere
in your `$PATH`, and name it `bazel`.  This will give you a command-for-command
compatible `bazel` binary, with the added bonus that it will download the exact
`bazel` binary version that each project needs.  This is of big help when dealing
with various projects that use bazel.

> I recommend using `bazelisk` instead of `bazel` wherever you can, and installing
> it under the binary name `bazel` in your `$PATH`, *always*.


From here on I will assume that you did as advised in the prerequisites.

## Doing things

Now that you installed the needed tools, we can try some examples out.  `bazel`
will download any needed libraries the first time you run it, so give it some
time.

### Clone this repository

```bash
git clone https://github.com/filmil/bazel-verilog-test
cd bazel-verilog-test  # to go to the directory you just cloned
```

### Build the example

```bash
bazel build //:counter_place_and_route
```

After a considerable amount of time spent in downloading and compiling the
prerequisites, you should have your placed and routed design.

## What needed resolving

Somewhat surprisingly, the `bazel_rules_hdl` repository does *not* show a functional
example of using the repository rules. The example given in the README.md is
not only incorrect, but also incomplete. Substantial additions are needed to go
from that example to this repository. See the list below.

This is a short list of things that needed resolving to get this working repo
up and running. With all of that fixed, I was able to build the sample basic
design without errors.

* The repository rules at https://github.com/hdl/bazel_rules_hdl are sensitive
  to bazel version.  This has to do with the backwards incompatible evolution of
  `@bazel_tools` but also the approaches the prerequisite deps are taking to
  bazel compilation.  I tried to fix the HDL rules at top of tree, but could not
  do that easily. To resolve this issue, I added `.bazelversion` at the project
  root and pegged the bazel version needed.

* This, in turn, means that the best way to compile this repository is by using
  `bazelisk`. `bazelisk` will read `.bazelversion` and automatically download and
  apply the appropriate bazel version to your repository.

* The README.md in the `bazel_rules_hdl` repository is lacking a sample working
  set of `git hash` and `sha_256`, and has no clear instruction to choose a
  working set.  It is also offering a syntactically incorrect `WORKSPACE` example,
  which one should also work around.

* The WORKSPACE file example in the repository is also lacking some needed
  declarations. I supplanted those based on the `WORKSPACE` file in
  `bazel_rules_hdl`, and the observations given in
  https://github.com/hdl/bazel_rules_hdl/issues/123.

* The repository is not complete with a set of carefully placed `.bazelrc`
  directives.  This is not mentioned in `README.md`, but is required for the
  build to work. At minimum, the dependency code requires C++17 or higher, which
  you don't get by default.

* I added a hermetic python interpreter configuration to the `WORKSPACE` file,
  so you don't need to worry about having the correct python interpreter for the
  project.

## Example output

This is what my computer printed when I built the example counter. Compilation
was quick because I already spent a long time compiling the prerequisites, and
this was at least the second time I ran it.  The first time around, your output
will be significantly more wordy.

```bash
$ bazel build //:counter_place_and_route
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

