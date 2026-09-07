// SPDX-License-Identifier: Apache-2.0
//
// Drives the Verilated model of counter.v and checks that it resets and then
// counts one step per rising clock edge.

#include <cstdint>
#include <memory>

#include "Vcounter.h"
#include "gtest/gtest.h"
#include "verilated.h"

// Verilator expects this symbol to exist.
double sc_time_stamp() { return 0; }

namespace {

// Advances the design by one full clock period.
void Tick(Vcounter* dut) {
  dut->clk = 0;
  dut->eval();
  dut->clk = 1;
  dut->eval();
}

// Holds reset across one rising edge, which is what clears the count.
void ApplyReset(Vcounter* dut) {
  dut->reset = 1;
  Tick(dut);
  dut->reset = 0;
}

TEST(CounterTest, ResetClearsTheCount) {
  auto dut = std::make_unique<Vcounter>();
  ApplyReset(dut.get());
  EXPECT_EQ(dut->out[0], 0u);
}

TEST(CounterTest, CountsOneStepPerRisingEdge) {
  auto dut = std::make_unique<Vcounter>();
  ApplyReset(dut.get());
  for (uint32_t want = 1; want <= 5; ++want) {
    Tick(dut.get());
    EXPECT_EQ(dut->out[0], want);
  }
}

TEST(CounterTest, ResetClearsAPartialCount) {
  auto dut = std::make_unique<Vcounter>();
  ApplyReset(dut.get());
  Tick(dut.get());
  Tick(dut.get());
  ASSERT_EQ(dut->out[0], 2u);
  ApplyReset(dut.get());
  EXPECT_EQ(dut->out[0], 0u);
}

}  // namespace
