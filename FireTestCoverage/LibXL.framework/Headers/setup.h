#ifndef LIBXL_SETUP_C_H
#define LIBXL_SETUP_C_H

#if !defined(LIBXL_STATIC) && (defined(_MSC_VER) || defined(__WATCOMC__))

  #ifdef libxl_EXPORTS
      #define XLAPI __declspec(dllexport)
  #else
      #define XLAPI __declspec(dllimport)
  #endif

  #define XLAPIENTRY __cdecl

#else

  #define XLAPI
  #define XLAPIENTRY

#endif

#endif
