cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES C CXX)

# Embed the shared master so the window icon also works from an unpacked bundle.
find_program(GLIB_COMPILE_RESOURCES glib-compile-resources)
if(NOT GLIB_COMPILE_RESOURCES)
  message(FATAL_ERROR "glib-compile-resources is required for the app icon")
endif()
set(ICON_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/smara_icon.c")
set(ICON_ASSET_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/branding")
add_custom_command(
  OUTPUT "${ICON_SOURCE}"
  COMMAND "${GLIB_COMPILE_RESOURCES}"
    "${CMAKE_CURRENT_SOURCE_DIR}/resources.gresource.xml"
    --sourcedir=${ICON_ASSET_DIR}
    --target=${ICON_SOURCE}
    --generate-source
    --c-name=smara_icon
  DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/resources.gresource.xml"
    "${ICON_ASSET_DIR}/app_icon.png"
  VERBATIM
)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME}
  "${ICON_SOURCE}"
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the application ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Add dependency libraries. Add any application-specific dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
