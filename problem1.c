#include <stdio.h>
#include <string.h>

int main(int argc, const char * argv[]) {
    FILE *f = fopen(argv[1], "r");
    char temp[100];
    fgets(temp, 100, f);
    fgets(temp, 100, f);
    int time[1000];
    int n = 0;
    while (1) {
        fgets(temp, 100, f);
        if (strcmp(temp, "\n") == 0) break;
        n++;
        int h, m;
        char name[100];
        sscanf(temp, "%s %d:%d", name, &h, &m);
        time[n] = h * 60 + m;
    }
    printf("TaskFinishTimes = [F_001");
    for (int i = 2; i <= n; i++) {
        printf(", F_%03d", i);
    }
    printf("],\nTaskStartTimes = [S_001");
    for (int i = 2; i <= n; i++) {
        printf(", S_%03d", i);
    }
    printf("],\n\nTaskFinishTimes :: 0..1000000,\nTaskStartTimes :: 0..1000000,\n\n");
    for (int i = 1; i <= n; i++) {
        printf("F_%03d - S_%03d #= %d,\n", i, i, time[i]);
    }
    fgets(temp, 100, f);
    while (1) {
        fgets(temp, 100, f);
        if (strcmp(temp, "\n") == 0) break;
        int l, r;
        sscanf(temp, "asm_1.step_%d asm_1.step_%d", &l, &r);
        printf("S_%03d #>= F_%03d,\n", r, l);
    }
    fclose(f);
    printf("\nEndTime #= max(TaskFinishTimes),\n");
    printf("flatten([TaskStartTimes,TaskFinishTimes,EndTime], AllVars),\n");
    printf("minimize(labeling(AllVars), EndTime),\n\n");
    for (int i = 1; i <= n; i++) {
        printf("printf(\"asm_1.step_%03d %%d\\n\", S_%03d),\n", i, i);
    }
    return 0;
}
