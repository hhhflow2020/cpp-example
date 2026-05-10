from conan import ConanFile
from conan.tools.cmake import cmake_layout

class AppConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps", "CMakeToolchain"

    def layout(self):
        cmake_layout(self)

    def requirements(self):
        self.requires("fmt/12.1.0", options={
            "shared": False,
        })
        self.requires("gtest/1.17.0", options={
            "shared": False,
        })


    # def build(self):
    #     cmake = CMake(self)
    #     cmake.configure()
    #     cmake.build()