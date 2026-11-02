// Intentional-fail harness for the CMake `sim-fail` target.
//
// DUT is the original NPTEL CSD multiplier (no RTL copy). The checker
// demands y==0 for x=1, *29 (true result is 29) so a working sim MUST
// print FAIL and exit 1. ExpectFail.cmake succeeds only when that
// failure is caught — same inject-and-catch idea as protosim-apb.

#include "Vcsd_mul.h"
#include "tb_util.hpp"

int main() {
    Sim<Vcsd_mul> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->x = 0;
    t->sel_m19 = 0;
    s.reset(3);

    t->x = 1;
    t->sel_m19 = 0;  // CSD *29 → hardware y should be 29
    t->in_valid = 1;
    s.tick();

    // Inject: demand 0 instead of 29.
    if (!t->out_valid || s32(t->y) != 0) {
        fail("intentional mismatch (cmake sim-fail harness)");
    }

    std::printf("UNEXPECTED PASS sim-fail harness (checker did not fire)\n");
    return 0;
}
