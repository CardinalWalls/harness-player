#ifdef __cplusplus
extern "C" {
#endif

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>

#ifdef _WIN32
#include <direct.h>
#include <windows.h>
#endif

#include "moonbit.h"

MOONBIT_FFI_EXPORT FILE *finall_start_fsutil_fopen_ffi(moonbit_bytes_t path,
                                                       moonbit_bytes_t mode) {
  return fopen((const char *)path, (const char *)mode);
}

MOONBIT_FFI_EXPORT int finall_start_fsutil_is_null(void *ptr) {
  return ptr == NULL;
}

MOONBIT_FFI_EXPORT size_t finall_start_fsutil_fwrite_ffi(moonbit_bytes_t ptr,
                                                         int size, int nitems,
                                                         FILE *stream) {
  return fwrite(ptr, size, nitems, stream);
}

MOONBIT_FFI_EXPORT int finall_start_fsutil_fflush_ffi(FILE *file) {
  return fflush(file);
}

MOONBIT_FFI_EXPORT int finall_start_fsutil_fclose_ffi(FILE *stream) {
  return fclose(stream);
}

MOONBIT_FFI_EXPORT moonbit_bytes_t finall_start_fsutil_get_error_message(void) {
  const char *err_str = strerror(errno);
  size_t len = strlen(err_str);
  moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
  memcpy(bytes, err_str, len);
  return bytes;
}

MOONBIT_FFI_EXPORT int finall_start_fsutil_create_dir_ffi(moonbit_bytes_t path) {
#ifdef _WIN32
  return _mkdir((const char *)path);
#else
  return mkdir((const char *)path, 0777);
#endif
}

MOONBIT_FFI_EXPORT int finall_start_fsutil_is_dir_ffi(moonbit_bytes_t path) {
#ifdef _WIN32
  DWORD attrs = GetFileAttributes((const char *)path);
  if (attrs == INVALID_FILE_ATTRIBUTES) {
    return -1;
  }
  return (attrs & FILE_ATTRIBUTE_DIRECTORY) ? 1 : 0;
#else
  struct stat buffer;
  int status = stat((const char *)path, &buffer);
  if (status == -1) {
    return -1;
  }
  return S_ISDIR(buffer.st_mode) ? 1 : 0;
#endif
}

MOONBIT_FFI_EXPORT int finall_start_fsutil_is_file_ffi(moonbit_bytes_t path) {
#ifdef _WIN32
  DWORD attrs = GetFileAttributes((const char *)path);
  if (attrs == INVALID_FILE_ATTRIBUTES) {
    return -1;
  }
  return !(attrs & FILE_ATTRIBUTE_DIRECTORY) ? 1 : 0;
#else
  struct stat buffer;
  int status = stat((const char *)path, &buffer);
  if (status == -1) {
    return -1;
  }
  return S_ISREG(buffer.st_mode) ? 1 : 0;
#endif
}

#ifdef __cplusplus
}
#endif
