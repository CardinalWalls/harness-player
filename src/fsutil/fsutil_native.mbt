///|
#external
priv type Handler

///|
#borrow(path, mode)
extern "C" fn fopen_ffi(path : Bytes, mode : Bytes) -> Handler = "finall_start_fsutil_fopen_ffi"

///|
extern "C" fn is_null(ptr : Handler) -> Int = "finall_start_fsutil_is_null"

///|
#borrow(ptr)
extern "C" fn fwrite_ffi(
  ptr : Bytes,
  size : Int,
  nitems : Int,
  stream : Handler,
) -> Int = "finall_start_fsutil_fwrite_ffi"

///|
extern "C" fn fflush_ffi(stream : Handler) -> Int = "finall_start_fsutil_fflush_ffi"

///|
extern "C" fn fclose_ffi(file : Handler) -> Int = "finall_start_fsutil_fclose_ffi"

///|
extern "C" fn get_error_message_ffi() -> Bytes = "finall_start_fsutil_get_error_message"

///|
#borrow(path)
extern "C" fn create_dir_ffi(path : Bytes) -> Int = "finall_start_fsutil_create_dir_ffi"

///|
#borrow(path)
extern "C" fn is_dir_ffi(path : Bytes) -> Int = "finall_start_fsutil_is_dir_ffi"

///|
#borrow(path)
extern "C" fn is_file_ffi(path : Bytes) -> Int = "finall_start_fsutil_is_file_ffi"

///|
fn get_error_message() -> String {
  utf8_bytes_to_mbt_string(get_error_message_ffi())
}

///|
fn write_string_to_file_internal(
  path : String,
  content : String,
  encoding? : String = "utf8",
) -> Unit raise IOError {
  guard encoding == "utf8" else {
    raise IOError(
      "Unsupported encoding: \{encoding}, only utf8 is supported for now",
    )
  }
  let file = fopen_ffi(mbt_string_to_utf8_bytes(path, true), b"wb\x00")
  guard is_null(file) == 0 else { raise IOError(get_error_message()) }
  let bytes = mbt_string_to_utf8_bytes(content, false)
  let bytes_written = fwrite_ffi(bytes, 1, bytes.length(), file)
  guard bytes_written == bytes.length() else {
    raise IOError(get_error_message())
  }
  guard fflush_ffi(file) == 0 else { raise IOError(get_error_message()) }
  guard fclose_ffi(file) == 0 else { raise IOError(get_error_message()) }
}

///|
fn create_dir_internal(path : String) -> Unit raise IOError {
  guard create_dir_ffi(mbt_string_to_utf8_bytes(path, true)) == 0 else {
    raise IOError(get_error_message())
  }
}

///|
fn is_dir_internal(path : String) -> Bool raise IOError {
  let res = is_dir_ffi(mbt_string_to_utf8_bytes(path, true))
  guard res != -1 else { raise IOError(get_error_message()) }
  res == 1
}

///|
fn is_file_internal(path : String) -> Bool raise IOError {
  let res = is_file_ffi(mbt_string_to_utf8_bytes(path, true))
  guard res != -1 else { raise IOError(get_error_message()) }
  res == 1
}

///|
fn mbt_string_to_utf8_bytes(str : String, is_filename : Bool) -> Bytes {
  let res : Array[Byte] = []
  let len = str.length()
  let mut i = 0
  while i < len {
    let mut c = str.code_unit_at(i).to_int()
    if 0xD800 <= c && c <= 0xDBFF {
      c -= 0xD800
      i = i + 1
      let l = str.code_unit_at(i).to_int() - 0xDC00
      c = (c << 10) + l + 0x10000
    }
    if c < 0x80 {
      res.push(c.to_byte())
    } else if c < 0x800 {
      res.push((0xc0 + (c >> 6)).to_byte())
      res.push((0x80 + (c & 0x3f)).to_byte())
    } else if c < 0x10000 {
      res.push((0xe0 + (c >> 12)).to_byte())
      res.push((0x80 + ((c >> 6) & 0x3f)).to_byte())
      res.push((0x80 + (c & 0x3f)).to_byte())
    } else {
      res.push((0xf0 + (c >> 18)).to_byte())
      res.push((0x80 + ((c >> 12) & 0x3f)).to_byte())
      res.push((0x80 + ((c >> 6) & 0x3f)).to_byte())
      res.push((0x80 + (c & 0x3f)).to_byte())
    }
    i = i + 1
  }
  if is_filename {
    res.push((0).to_byte())
  }
  Bytes::from_array(res)
}

///|
fn utf8_bytes_to_mbt_string(bytes : Bytes) -> String {
  let res : Array[Char] = []
  let len = bytes.length()
  let mut i = 0
  while i < len {
    let mut c = bytes[i].to_int()
    if c < 0x80 {
      res.push(Int::unsafe_to_char(c))
      i += 1
    } else if c < 0xE0 {
      if i + 1 >= len {
        break
      }
      c = ((c & 0x1F) << 6) | (bytes[i + 1].to_int() & 0x3F)
      res.push(Int::unsafe_to_char(c))
      i += 2
    } else if c < 0xF0 {
      if i + 2 >= len {
        break
      }
      c = ((c & 0x0F) << 12) |
        ((bytes[i + 1].to_int() & 0x3F) << 6) |
        (bytes[i + 2].to_int() & 0x3F)
      res.push(Int::unsafe_to_char(c))
      i += 3
    } else {
      if i + 3 >= len {
        break
      }
      c = ((c & 0x07) << 18) |
        ((bytes[i + 1].to_int() & 0x3F) << 12) |
        ((bytes[i + 2].to_int() & 0x3F) << 6) |
        (bytes[i + 3].to_int() & 0x3F)
      c -= 0x10000
      res.push(Int::unsafe_to_char((c >> 10) + 0xD800))
      res.push(Int::unsafe_to_char((c & 0x3FF) + 0xDC00))
      i += 4
    }
  }
  String::from_array(res)
}
