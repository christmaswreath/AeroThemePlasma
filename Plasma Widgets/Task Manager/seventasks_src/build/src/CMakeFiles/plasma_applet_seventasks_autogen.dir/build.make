# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.22

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
CMAKE_SOURCE_DIR = /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src/build

# Utility rule file for plasma_applet_seventasks_autogen.

# Include any custom commands dependencies for this target.
include src/CMakeFiles/plasma_applet_seventasks_autogen.dir/compiler_depend.make

# Include the progress variables for this target.
include src/CMakeFiles/plasma_applet_seventasks_autogen.dir/progress.make

src/CMakeFiles/plasma_applet_seventasks_autogen: src/metadata.json
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Automatic MOC for target plasma_applet_seventasks"
	cd /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src/build/src && /usr/bin/cmake -E cmake_autogen /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src/build/src/CMakeFiles/plasma_applet_seventasks_autogen.dir/AutogenInfo.json ""

src/metadata.json: ../src/package/metadata.desktop
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Generating metadata.json"
	cd /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src/src && /usr/bin/desktoptojson -i package/metadata.desktop -o /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src/build/src/metadata.json -s /usr/share/kservicetypes5/plasma-applet.desktop

plasma_applet_seventasks_autogen: src/CMakeFiles/plasma_applet_seventasks_autogen
plasma_applet_seventasks_autogen: src/metadata.json
plasma_applet_seventasks_autogen: src/CMakeFiles/plasma_applet_seventasks_autogen.dir/build.make
.PHONY : plasma_applet_seventasks_autogen

# Rule to build all files generated by this target.
src/CMakeFiles/plasma_applet_seventasks_autogen.dir/build: plasma_applet_seventasks_autogen
.PHONY : src/CMakeFiles/plasma_applet_seventasks_autogen.dir/build

src/CMakeFiles/plasma_applet_seventasks_autogen.dir/clean:
	cd /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src/build/src && $(CMAKE_COMMAND) -P CMakeFiles/plasma_applet_seventasks_autogen.dir/cmake_clean.cmake
.PHONY : src/CMakeFiles/plasma_applet_seventasks_autogen.dir/clean

src/CMakeFiles/plasma_applet_seventasks_autogen.dir/depend:
	cd /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src/src /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src/build /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src/build/src /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/gitgud-repositories/KDE/seventasks_src/build/src/CMakeFiles/plasma_applet_seventasks_autogen.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : src/CMakeFiles/plasma_applet_seventasks_autogen.dir/depend

