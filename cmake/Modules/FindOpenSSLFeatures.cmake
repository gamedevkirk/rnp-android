# Copyright (c) 2021 Ribose Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

#.rst:
# FindOpenSSLFeatures
# -----------
#
# Find OpenSSL features: supported hashes, ciphers, curves and public-key algorithms.
# Requires FindOpenSSL to be included first, and C compiler to be set as module
# compiles and executes program which do checks against installed OpenSSL library.
#
# Result variables
# ^^^^^^^^^^^^^^^^
#
# This module defines the following variables:
#
# ::
#
#   OPENSSL_SUPPORTED_HASHES    - list of the supported hash algorithms
#   OPENSSL_SUPPORTED_CIPHERS   - list of the supported ciphers
#   OPENSSL_SUPPORTED_CURVES    - list of the supported elliptic curves
#   OPENSSL_SUPPORTED_PUBLICKEY - list of the supported public-key algorithms
#   OPENSSL_SUPPORTED_FEATURES  - all previous lists, glued together
#
# Functions
# ^^^^^^^^^
# OpenSSLHasFeature(FEATURE <VARIABLE>)
# Check whether OpenSSL has corresponding feature (hash/curve/public-key algorithm name, elliptic curve).
# Result is stored in VARIABLE as boolean value, i.e. TRUE or FALSE
#
if (NOT OPENSSL_FOUND)
  message(FATAL_ERROR "OpenSSL is not found. Please make sure that you call find_package(OpenSSL) first.")
endif()

message(STATUS "Querying OpenSSL features")

# Copy and build findopensslfeatures.c in fossl-build subfolder.
set(_fossl_work_dir "${CMAKE_BINARY_DIR}/fossl")
file(MAKE_DIRECTORY "${_fossl_work_dir}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/findopensslfeatures.c"
  DESTINATION "${_fossl_work_dir}"
)

message(STATUS "Using OpenSSL root directory at ${OPENSSL_ROOT_DIR}")

file(WRITE "${_fossl_work_dir}/CMakeLists.txt"
"cmake_minimum_required(VERSION 3.18)\n\
project(findopensslfeatures LANGUAGES C)\n\
set(CMAKE_C_STANDARD 99)\n\
find_package(OpenSSL REQUIRED)\n\
add_executable(findopensslfeatures findopensslfeatures.c)\n\
target_include_directories(findopensslfeatures PRIVATE ${OPENSSL_INCLUDE_DIR})\n\
target_link_libraries(findopensslfeatures PRIVATE OpenSSL::Crypto)\n\
if (OpenSSL::applink)\n\
  target_link_libraries(findopensslfeatures PRIVATE OpenSSL::applink)\n\
endif(OpenSSL::applink)\n"
)

set(MKF ${MKF}
  "-DCMAKE_BUILD_TYPE=Release"
  "-DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR}"
  "-DOPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR}"
  "-DOPENSSL_CRYPTO_LIBRARY=${OPENSSL_CRYPTO_LIBRARY}"
  "-DOPENSSL_SSL_LIBRARY=${OPENSSL_SSL_LIBRARY}"
)

if(CMAKE_PREFIX_PATH)
  set(MKF ${MKF} "-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}")
endif(CMAKE_PREFIX_PATH)

if(CMAKE_TOOLCHAIN_FILE)
  set(MKF ${MKF}
    "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
    "-DANDROID_ABI=${ANDROID_ABI}"
    "-DANDROID_PLATFORM=${ANDROID_PLATFORM}"
  )
endif(CMAKE_TOOLCHAIN_FILE)

if(CMAKE_GENERATOR_PLATFORM)
  set(MKF ${MKF} "-A" "${CMAKE_GENERATOR_PLATFORM}")
endif(CMAKE_GENERATOR_PLATFORM)

if(CMAKE_GENERATOR_TOOLSET)
  set(MKF ${MKF} "-T" "${CMAKE_GENERATOR_TOOLSET}")
endif(CMAKE_GENERATOR_TOOLSET)

if(CMAKE_CROSSCOMPILING)
  message(STATUS "Cross-compiling: skipping runtime OpenSSL feature probe")

  set(OPENSSL_SUPPORTED_HASHES
    SHA1
    SHA224
    SHA256
    SHA384
    SHA512
    SHA3-256
    SHA3-384
    SHA3-512
    RIPEMD160
    MD5
  )

  set(OPENSSL_SUPPORTED_CIPHERS
    AES-128
    AES-192
    AES-256
    AES-128-CFB
    AES-192-CFB
    AES-256-CFB
    AES-128-CBC
    AES-192-CBC
    AES-256-CBC
    AES-128-ECB
    AES-192-ECB
    AES-256-ECB
    AES-128-OCB
    AES-192-OCB
    AES-256-OCB
    CAMELLIA-128
    CAMELLIA-192
    CAMELLIA-256
    CAMELLIA-128-CFB
    CAMELLIA-192-CFB
    CAMELLIA-256-CFB
    CAMELLIA-128-CBC
    CAMELLIA-192-CBC
    CAMELLIA-256-CBC
    CAMELLIA-128-ECB
    CAMELLIA-192-ECB
    CAMELLIA-256-ECB
    CAST5
    DES
    DES-EDE3
    TRIPLEDES
  )

  set(OPENSSL_SUPPORTED_CURVES
    NIST-P-256
    NIST-P-384
    NIST-P-521
    PRIME256V1
    SECP384R1
    SECP521R1
    SECP256K1
    CURVE25519
    X25519
    ED25519
  )

  set(OPENSSL_SUPPORTED_PUBLICKEY
    RSA
    RSAENCRYPTION
    DSA
    DSAENCRYPTION
    DHKEYAGREEMENT
    ID-ECPUBLICKEY
    ELGAMAL
    ECDSA
    ECDH
    EDDSA
  )

  set(OPENSSL_SUPPORTED_PROVIDERS
    DEFAULT
    LEGACY
  )

  set(OPENSSL_SUPPORTED_FEATURES
    ${OPENSSL_SUPPORTED_HASHES}
    ${OPENSSL_SUPPORTED_CIPHERS}
    ${OPENSSL_SUPPORTED_CURVES}
    ${OPENSSL_SUPPORTED_PUBLICKEY}
    ${OPENSSL_SUPPORTED_PROVIDERS}
  )

  list(LENGTH OPENSSL_SUPPORTED_HASHES hashes_len)
  list(LENGTH OPENSSL_SUPPORTED_CIPHERS ciphers_len)
  list(LENGTH OPENSSL_SUPPORTED_CURVES curves_len)
  list(LENGTH OPENSSL_SUPPORTED_PUBLICKEY publickey_len)
  list(LENGTH OPENSSL_SUPPORTED_PROVIDERS providers_len)
else()
  execute_process(
    COMMAND "${CMAKE_COMMAND}" "-Bbuild" ${MKF} "."
    WORKING_DIRECTORY "${_fossl_work_dir}"
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
    RESULT_VARIABLE result
    COMMAND_ECHO STDOUT
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
  )

  if (NOT ${result} EQUAL 0)
    message(FATAL_ERROR "Error configuring findopensslfeatures")
  endif()

  execute_process(
    COMMAND "${CMAKE_COMMAND}" "--build" "build" --config "Release"
    WORKING_DIRECTORY "${_fossl_work_dir}"
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
    RESULT_VARIABLE result
    COMMAND_ECHO STDOUT
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
  )

  if (NOT ${result} EQUAL 0)
    message(FATAL_ERROR "Error building findopensslfeatures")
  endif()

  set(OPENSSL_SUPPORTED_FEATURES "")
  if(WIN32 AND NOT MINGW)
    set(FOF "build/Release/findopensslfeatures")
  else(WIN32 AND NOT MINGW)
    set(FOF "build/findopensslfeatures")
  endif(WIN32 AND NOT MINGW)

  foreach(feature "hashes" "ciphers" "curves" "publickey" "providers")
    execute_process(
      COMMAND "${FOF}" "${feature}"
      WORKING_DIRECTORY "${_fossl_work_dir}"
      OUTPUT_VARIABLE feature_val
      ERROR_VARIABLE error
      RESULT_VARIABLE result
    )

    if(NOT ${result} EQUAL 0)
      message(FATAL_ERROR "Error getting supported OpenSSL ${feature}: ${result}\n${error}")
    endif()

    string(TOUPPER ${feature} feature_up)
    string(TOUPPER ${feature_val} feature_val)
    string(REPLACE "\n" ";" feature_val ${feature_val})
    set(OPENSSL_SUPPORTED_${feature_up} ${feature_val})
    list(LENGTH OPENSSL_SUPPORTED_${feature_up} ${feature}_len)
    list(APPEND OPENSSL_SUPPORTED_FEATURES ${OPENSSL_SUPPORTED_${feature_up}})
  endforeach()
endif()

message(STATUS "Fetched OpenSSL features: ${hashes_len} hashes, ${ciphers_len} ciphers, ${curves_len} curves, ${publickey_len} publickey, ${providers_len} providers.")

function(OpenSSLHasFeature FEATURE VARIABLE)
  string(TOUPPER ${FEATURE} _feature_up)
  set(${VARIABLE} FALSE PARENT_SCOPE)
  if (${_feature_up} IN_LIST OPENSSL_SUPPORTED_FEATURES)
      set(${VARIABLE} TRUE PARENT_SCOPE)
  endif()
endfunction(OpenSSLHasFeature)
