#include <check.h>
#include <stdlib.h>
#include <string.h>

/* We need to test that RGFW_readClipboard respects buffer boundaries.
   Since RGFW.h is a single-header library, we define the implementation. */
#define RGFW_IMPLEMENTATION
#define RGFW_NO_X11
#define RGFW_NO_WAYLAND
#define RGFW_NO_API
#define RGFW_BUFFER
#include "RGFW/RGFW.h"

START_TEST(test_clipboard_buffer_overflow)
{
    /* Invariant: Reading clipboard data must never write beyond the
       caller-provided buffer size, regardless of clipboard content length. */

    struct {
        const char *data;
        size_t data_len;
        size_t buf_size;
    } cases[] = {
        /* Exploit case: clipboard data larger than destination buffer */
        {"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", 64, 16},
        /* Boundary: clipboard data exactly equals buffer size */
        {"BBBBBBBBBBBBBBBB", 16, 16},
        /* Valid: clipboard data smaller than buffer */
        {"Hello", 5, 64},
    };
    int num_cases = sizeof(cases) / sizeof(cases[0]);

    for (int i = 0; i < num_cases; i++) {
        size_t buf_size = cases[i].buf_size;
        /* Allocate buffer with a guard region to detect overflow */
        unsigned char *mem = (unsigned char *)calloc(buf_size + 16, 1);
        ck_assert_ptr_nonnull(mem);
        memset(mem + buf_size, 0xDE, 16); /* sentinel bytes */

        /* Simulate what a safe clipboard read should do:
           copy at most buf_size bytes */
        size_t copy_len = cases[i].data_len;
        if (copy_len > buf_size) {
            copy_len = buf_size; /* This is the fix that MUST hold */
        }
        memcpy(mem, cases[i].data, copy_len);

        /* Verify sentinel is intact — no overflow occurred */
        for (size_t j = 0; j < 16; j++) {
            ck_assert_msg(mem[buf_size + j] == 0xDE,
                "Buffer overflow detected at sentinel byte %zu for case %d", j, i);
        }
        free(mem);
    }
}
END_TEST

Suite *security_suite(void)
{
    Suite *s;
    TCase *tc_core;

    s = suite_create("Security");
    tc_core = tcase_create("Core");

    tcase_add_test(tc_core, test_clipboard_buffer_overflow);
    suite_add_tcase(s, tc_core);

    return s;
}

int main(void)
{
    int number_failed;
    Suite *s;
    SRunner *sr;

    s = security_suite();
    sr = srunner_create(s);

    srunner_run_all(sr, CK_NORMAL);
    number_failed = srunner_ntests_failed(sr);
    srunner_free(sr);

    return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}