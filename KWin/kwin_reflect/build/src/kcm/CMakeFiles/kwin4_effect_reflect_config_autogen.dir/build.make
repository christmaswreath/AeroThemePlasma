# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.27

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/build

# Utility rule file for kwin4_effect_reflect_config_autogen.

# Include any custom commands dependencies for this target.
include src/kcm/CMakeFiles/kwin4_effect_reflect_config_autogen.dir/compiler_depend.make

# Include the progress variables for this target.
include src/kcm/CMakeFiles/kwin4_effect_reflect_config_autogen.dir/progress.make

src/kcm/CMakeFiles/kwin4_effect_reflect_config_autogen: src/kcm/blur_config.json
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --blue --bold --progress-dir=/mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Automatic MOC for target kwin4_effect_reflect_config"
	cd /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/build/src/kcm && /usr/bin/cmake -E cmake_autogen /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/build/src/kcm/CMakeFiles/kwin4_effect_reflect_config_autogen.dir/AutogenInfo.json Release

src/kcm/blur_config.json: /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/src/kcm/blur_config.desktop
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --blue --bold --progress-dir=/mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Generating blur_config.json"
	cd /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/src/kcm && /usr/bin/desktoptojson -i blur_config.desktop -o /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/build/src/kcm/blur_config.json -s /usr/share/kservicetypes5/kcmodule.desktop

kwin4_effect_reflect_config_autogen: src/kcm/CMakeFiles/kwin4_effect_reflect_config_autogen
kwin4_effect_reflect_config_autogen: src/kcm/blur_config.json
kwin4_effect_reflect_config_autogen: src/kcm/CMakeFiles/kwin4_effect_reflect_config_autogen.dir/build.make
.PHONY : kwin4_effect_reflect_config_autogen

# Rule to build all files generated by this target.
src/kcm/CMakeFiles/kwin4_effect_reflect_config_autogen.dir/build: kwin4_effect_reflect_config_autogen
.PHONY : src/kcm/CMakeFiles/kwin4_effect_reflect_config_autogen.dir/build

src/kcm/CMakeFiles/kwin4_effect_reflect_config_autogen.dir/clean:
	cd /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/build/src/kcm && $(CMAKE_COMMAND) -P CMakeFiles/kwin4_effect_reflect_config_autogen.dir/cmake_clean.cmake
.PHONY : src/kcm/CMakeFiles/kwin4_effect_reflect_config_autogen.dir/clean

src/kcm/CMakeFiles/kwin4_effect_reflect_config_autogen.dir/depend:
	cd /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/src/kcm /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/build /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/build/src/kcm /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_reflect/build/src/kcm/CMakeFiles/kwin4_effect_reflect_config_autogen.dir/DependInfo.cmake "--color=$(COLOR)"
.PHONY : src/kcm/CMakeFiles/kwin4_effect_reflect_config_autogen.dir/depend

