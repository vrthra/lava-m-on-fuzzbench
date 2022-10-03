#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stddef.h>
#include <stdarg.h>
#include <unistd.h>
char **new_argv(int count, ...) {
    va_list args;
    int i;
    char **argv = malloc((count+1) * sizeof(char*));
    char *temp;
    va_start(args, count);
    for (i = 0; i < count; i++) {
        temp = va_arg(args, char*);
        argv[i] = strdup(temp);
    }
    argv[i] = 0;
    va_end(args);
    return argv;
}

static bool initialized = false;

#ifdef __cplusplus
extern "C"
#endif
int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (!initialized) {
       ignore_stdout();
       initialized = true;
    }
    /*FILE* tmp = tmpfile();
    fwrite(data, sizeof(uint8_t), size, tmp);
    rewind(tmp);
    / *dup2(fileno(tmp), fileno(stdin));* /
    stdin = fdopen(fileno(tmp), "r");
    */
    /*https://github.com/google/security-research-pocs/blob/master/autofuzz/fuzz_utils.cc*/
    const char* file = buf_to_file(data, size);
    char** argv = new_argv(2, "@@", file);
    if (file == NULL) {
       exit(EXIT_FAILURE);
    }

    main_x(2, argv);
    /*check_file(file, "-", '\n');*/
    if (delete_file(file) != 0) {
       exit(EXIT_FAILURE);
    }
    return EXIT_SUCCESS;
}
