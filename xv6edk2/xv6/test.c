#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char *argv[])
{
    int pid, child_pid;
    char *message;
    int n, status, exit_code;

    pid = fork();
    switch (pid)
    {
        case -1:
            printf(2, "fork failed\n");
            exit2(1);
        case 0: // 자식 프로세스
            message = "This is the child";
            n = 5;
            exit_code = 37; // 자식의 유언 번호
            break;
        default: // 부모 프로세스
            message = "This is the parent";
            n = 3;
            exit_code = 0;
            break;
    }

    // n번 반복하면서 메시지 출력
    for(; n > 0; n--) {
        printf(1, "%s\n", message);
        sleep(1);
    }

    // 부모만 실행하는 구간 (자식이 죽을 때까지 기다림)
    if (pid != 0) {
        child_pid = wait2(&status); 
        printf(1, "Child has finished: PID = %d\n", child_pid);
        printf(1, "Child exited with code %d\n", status); 
    }

    exit2(exit_code); 
}