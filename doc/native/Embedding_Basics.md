This document focuses on jxcore's new public interface located under (`src/public`). We want this interface to be very easy to use and embedabble on any platform.  If you need to reach all the core features, you may want to check `src/public/jx.cc` to see how we have actually implemented this interface. So you can add your custom methods.

In order to embed jxcore into your application, you should first compile it as a library.

`./configure --static-library --prefix=/targetFolder --engine-mozilla` (for V8 remove --engine-mozilla)  
`./make install`

Additional useful parameters
```
--dest-cpu=ia32   ->  32 bit  (ia32, arm, armv7s, arm64, x86_64)
--dest-os=ios     ->   (ios, android, or leave empty for your current platform)
```

In the end you will have all the binaries and include files. The new public interface only expects `jx.h` and `jx_result.h` files in addition to the libraries under the `bin` folder. You can find the headers files under `include/node/src/public`

The sample below demonstrates a basic usage of the interface
```c++
#include <stdlib.h>
#include <string.h>
#include <sstream>

#include "jx.h"

#define flush_console(...) do { fprintf(stdout, __VA_ARGS__); fflush(stdout); } while(0)

void ConvertResult(JXResult *result, std::string &to_result) {
  switch (result->type_) {
    case RT_Null:
      to_result = "null";
      break;
    case RT_Undefined:
      to_result = "undefined";
      break;
    case RT_Boolean:
      to_result = JX_GetBoolean(result) ? "true" : "false";
      break;
    case RT_Int32: {
      std::stringstream ss;
      ss << JX_GetInt32(result);
      to_result = ss.str();
    } break;
    case RT_Double: {
      std::stringstream ss;
      ss << JX_GetDouble(result);
      to_result = ss.str();
    } break;
    case RT_Buffer: {
      to_result = JX_GetString(result);
    } break;
    case RT_JSON:
    case RT_String: {
      to_result = JX_GetString(result);
    } break;
    case RT_Error: {
      to_result = JX_GetString(result);
    } break;
    default:
      to_result = "null";
      return;
  }
}

void callback(JXResult *results, int argc) {
  flush_console("received a callback ");

  std::stringstream ss_result;
  for (int i=0; i<argc; i++) {
    std::string str_result;
    ConvertResult(&results[i], str_result);
    ss_result << i << " : ";
    ss_result << str_result << "\n";
  }

  flush_console("%s", ss_result.str().c_str());
}


int main(int argc, char **args){
  char *path = args[0];
  JX_Initialize(path, callback);

  char *contents = "console.log('hello world');";
  JX_DefineMainFile(contents);
  JX_StartEngine();

  // or JX_Loop() without usleep
  while(JX_LoopOnce() != 0) usleep(1);

  JXResult result;
  JX_Evaluate("process.natives.asyncCallback(Date.now());", "myscript", &result);

  std::string str_result;
  ConvertResult(&result, str_result);

  flush_console("return: %s\n", str_result.c_str());

  JX_StopEngine();
}
```

Expected output should be;
```
hello world
received a callback 0 : 1.42549e+12
return: undefined
```

In order to compile above source code (lets say you saved it into sample.cpp)
```bash
g++ sample.cpp -stdlib=libstdc++ -lstdc++ -m32 -std=c++11 -O3 -I/targetFolder/include/node/public \
    /targetFolder/bin/libcares.a	/targetFolder/bin/libjx.a /targetFolder/bin/libsqlite3.a \
    /targetFolder/bin/libchrome_zlib.a /targetFolder/bin/libmozjs.a  /targetFolder/bin/libuv.a \
    /targetFolder/bin/libhttp_parser.a	/targetFolder/bin/libopenssl.a -Wl \
    -o sample
```

If you are compiling it under OSX, you should also add `-framework CoreServices` before `-o` 

That's It!
