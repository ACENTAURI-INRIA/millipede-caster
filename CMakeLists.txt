cmake_minimum_required(VERSION 3.20)

project(caster C)

option(BUILD_TESTS "Build tests" OFF)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall")

# Detect BSD systems and set CMAKE_C_FLAGS accordingly
if(${CMAKE_SYSTEM_NAME} MATCHES "BSD")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DDEBUG_JEMALLOC")
endif()

file(GLOB SOURCES "caster/*.c")
get_filename_component(TESTS_C_ABS "caster/tests.c" ABSOLUTE)
list(REMOVE_ITEM SOURCES ${TESTS_C_ABS})

find_package(PkgConfig REQUIRED)
pkg_search_module(OPENSSL openssl REQUIRED)
if (NOT OPENSSL_FOUND)
    message(FATAL_ERROR "OpenSSL not found. Please install OpenSSL development package (libssl-dev).")
endif()

pkg_search_module(LIBCYAML libcyaml REQUIRED)
if (NOT LIBCYAML_FOUND)
    message(FATAL_ERROR "libcyaml not found. Please install libcyaml development package (libcyaml-dev).")
endif()
pkg_search_module(LIBYAML yaml-0.1 REQUIRED)
if (NOT LIBYAML_FOUND)
    message(FATAL_ERROR "libyaml not found. Please install libyaml development package (libyaml-dev).")
endif()

pkg_search_module(EVENT libevent REQUIRED)
if (NOT EVENT_FOUND)
    message(FATAL_ERROR "libevent not found. Please install libevent development package (libevent-dev).")
endif()
pkg_search_module(EVENT_CORE libevent_core REQUIRED)
if (NOT EVENT_CORE_FOUND)
    message(FATAL_ERROR "libevent_core not found. Please install libevent development package (libevent-dev).")
endif()
pkg_search_module(EVENT_PTHREADS libevent_pthreads REQUIRED)
if (NOT EVENT_PTHREADS_FOUND)
    message(FATAL_ERROR "libevent_pthreads not found. Please install libevent development package (libevent-dev).")
endif()
pkg_search_module(EVENT_EXTRA libevent_extra REQUIRED)
if (NOT EVENT_EXTRA_FOUND)
    message(FATAL_ERROR "libevent_extra not found. Please install libevent development package (libevent-dev).")
endif()
pkg_search_module(EVENT_OPENSSL libevent_openssl REQUIRED)
if (NOT EVENT_OPENSSL_FOUND)
    message(FATAL_ERROR "libevent_openssl not found. Please install libevent development package (libevent-dev).")
endif()

find_package(json-c REQUIRED)
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

add_executable(caster ${SOURCES})
if (BUILD_TESTS)
    add_executable(tests caster/tests.c caster/util.c)
endif()

target_include_directories(caster PRIVATE
                            ${OPENSSL_INCLUDE_DIRS} ${LIBCYAML_INCLUDE_DIRS} ${LIBYAML_INCLUDE_DIRS}
                            ${EVENT_CORE_INCLUDE_DIRS} ${EVENT_PTHREADS_INCLUDE_DIRS}
                            ${EVENT_EXTRA_INCLUDE_DIRS})
target_link_directories(caster PRIVATE
                            ${OPENSSL_LIBRARY_DIRS} ${LIBCYAML_LIBRARY_DIRS} ${LIBYAML_LIBRARY_DIRS}
                            ${EVENT_CORE_LIBRARY_DIRS} ${EVENT_PTHREADS_LIBRARY_DIRS}
                            ${EVENT_EXTRA_LIBRARY_DIRS})
target_link_libraries(caster PRIVATE
                            ${OPENSSL_LIBRARIES} ${LIBCYAML_LIBRARIES} ${LIBYAML_LIBRARIES}
                            ${EVENT_CORE_LIBRARIES} ${EVENT_PTHREADS_LIBRARIES}
                            ${EVENT_EXTRA_LIBRARIES} ${EVENT_OPENSSL_LIBRARIES} ${OPENSSL_LIBRARIES}
                            json-c m Threads::Threads)
if (BUILD_TESTS)
target_include_directories(tests PRIVATE
                            ${OPENSSL_INCLUDE_DIRS} ${LIBCYAML_INCLUDE_DIRS}
                            ${EVENT_CORE_INCLUDE_DIRS} ${EVENT_PTHREADS_INCLUDE_DIRS}
                            ${EVENT_EXTRA_INCLUDE_DIRS})
target_link_directories(tests PRIVATE
                            ${OPENSSL_LIBRARY_DIRS} ${LIBCYAML_LIBRARY_DIRS}
                            ${EVENT_CORE_LIBRARY_DIRS} ${EVENT_PTHREADS_LIBRARY_DIRS}
                            ${EVENT_EXTRA_LIBRARY_DIRS})
target_link_libraries(tests PRIVATE
                            ${OPENSSL_LIBRARIES} ${LIBCYAML_LIBRARIES} ${LIBYAML_LIBRARIES}
                            ${EVENT_CORE_LIBRARIES} ${EVENT_PTHREADS_LIBRARIES}
                            ${EVENT_EXTRA_LIBRARIES} ${EVENT_OPENSSL_LIBRARIES} ${OPENSSL_LIBRARIES}
                            json-c m Threads::Threads)
endif()

include(GNUInstallDirs)
install(TARGETS caster
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
configure_file(sample-config/caster.yaml.in caster.yaml @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/caster.yaml
        DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/millipede
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)
install(FILES sample-config/host.auth sample-config/source.auth sample-config/sourcetable.dat sample-config/blocklist
        DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/millipede
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)
install(FILES systemd/caster.options
        DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/millipede
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)
install(FILES systemd/millipede-caster.service
        DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/systemd/system)
install(FILES debian/logrotate/millipede-caster
        DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/logrotate.d
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)
install(FILES debian/millipede-caster.1
        DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)
