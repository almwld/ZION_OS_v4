#include <jni.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <termios.h>
#include <unistd.h>
#include <pty.h>

static int master_fd = -1;
static pid_t child_pid = -1;

static void close_master(void) {
    if (master_fd >= 0) { close(master_fd); master_fd = -1; }
}

JNIEXPORT jint JNICALL
Java_com_zion_os_MainActivity_nativeStartPty(JNIEnv* env, jobject thiz, jstring command, jstring cwd, jobjectArray argv, jobjectArray envp, jint rows, jint cols) {
    (void)thiz;
    if (master_fd >= 0 && child_pid > 0) return master_fd;

    const char* cmd = (*env)->GetStringUTFChars(env, command, NULL);
    const char* dir = (*env)->GetStringUTFChars(env, cwd, NULL);

    int argc = (*env)->GetArrayLength(env, argv);
    char** args = calloc((size_t)argc + 1, sizeof(char*));
    for (int i = 0; i < argc; ++i) {
        jstring s = (jstring)(*env)->GetObjectArrayElement(env, argv, i);
        const char* p = (*env)->GetStringUTFChars(env, s, NULL);
        args[i] = strdup(p);
        (*env)->ReleaseStringUTFChars(env, s, p);
        (*env)->DeleteLocalRef(env, s);
    }

    int envc = (*env)->GetArrayLength(envp);
    char** envs = calloc((size_t)envc + 1, sizeof(char*));
    for (int i = 0; i < envc; ++i) {
        jstring s = (jstring)(*env)->GetObjectArrayElement(envp, i);
        const char* p = (*env)->GetStringUTFChars(env, s, NULL);
        envs[i] = strdup(p);
        (*env)->ReleaseStringUTFChars(env, s, p);
        (*env)->DeleteLocalRef(env, s);
    }

    struct winsize ws = { .ws_row=(unsigned short)rows, .ws_col=(unsigned short)cols, .ws_xpixel=0, .ws_ypixel=0 };
    int fd = -1;
    pid_t pid = forkpty(&fd, NULL, NULL, &ws);
    if (pid == 0) {
        setsid();
        if (chdir(dir) != 0) _exit(126);
        clearenv();
        for (int i = 0; envs[i]; ++i) putenv(envs[i]);
        execv(cmd, args);
        _exit(127);
    }
    if (pid < 0) {
        close(fd);
        fd = -1;
    } else {
        master_fd = fd;
        child_pid = pid;
        fcntl(master_fd, F_SETFL, fcntl(master_fd, F_GETFL, 0) | O_NONBLOCK);
    }

    for (int i=0; args[i]; ++i) free(args[i]);
    for (int i=0; envs[i]; ++i) free(envs[i]);
    free(args); free(envs);
    (*env)->ReleaseStringUTFChars(env, command, cmd);
    (*env)->ReleaseStringUTFChars(env, cwd, dir);
    return fd;
}

JNIEXPORT jbyteArray JNICALL
Java_com_zion_os_MainActivity_nativeReadPty(JNIEnv* env, jobject thiz) {
    (void)thiz;
    if (master_fd < 0) return NULL;
    char buf[8192];
    ssize_t n = read(master_fd, buf, sizeof(buf));
    if (n <= 0) return NULL;
    jbyteArray out = (*env)->NewByteArray(env, (jsize)n);
    (*env)->SetByteArrayRegion(env, out, 0, (jsize)n, (jbyte*)buf);
    return out;
}

JNIEXPORT jint JNICALL
Java_com_zion_os_MainActivity_nativeWritePty(JNIEnv* env, jobject thiz, jbyteArray data) {
    (void)thiz;
    if (master_fd < 0) return -1;
    jsize n = (*env)->GetArrayLength(env, data);
    jbyte* bytes = (*env)->GetByteArrayElements(env, data, NULL);
    ssize_t written = write(master_fd, bytes, (size_t)n);
    (*env)->ReleaseByteArrayElements(env, data, bytes, JNI_ABORT);
    return (jint)written;
}

JNIEXPORT jboolean JNICALL
Java_com_zion_os_MainActivity_nativeResizePty(JNIEnv* env, jobject thiz, jint rows, jint cols) {
    (void)env; (void)thiz;
    if (master_fd < 0) return JNI_FALSE;
    struct winsize ws = { .ws_row=(unsigned short)rows, .ws_col=(unsigned short)cols, .ws_xpixel=0, .ws_ypixel=0 };
    return ioctl(master_fd, TIOCSWINSZ, &ws) == 0 ? JNI_TRUE : JNI_FALSE;
}

JNIEXPORT void JNICALL
Java_com_zion_os_MainActivity_nativeStopPty(JNIEnv* env, jobject thiz) {
    (void)env; (void)thiz;
    if (child_pid > 0) kill(child_pid, SIGHUP);
    if (master_fd >= 0) close_master();
    if (child_pid > 0) { waitpid(child_pid, NULL, WNOHANG); child_pid = -1; }
}
