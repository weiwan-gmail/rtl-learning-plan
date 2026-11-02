from conan import ConanFile
from conan.errors import ConanException
from conan.tools.files import copy, get
import os
import shutil
from pathlib import Path


class VerilatorConan(ConanFile):
    name = "verilator"
    version = "5.052"
    license = "LGPL-3.0-only"
    homepage = "https://verilator.org"
    url = "https://github.com/withlimon/verilator-windows"
    description = (
        "Local Verilator recipe for rtl-learning-plan / ProtoSim dual-tree: "
        "withlimon prebuilt PE on Windows; wrap the system kit on Linux."
    )
    topics = ("verilog", "hdl", "verilator")
    package_type = "application"
    settings = "os", "arch", "build_type"

    def export_sources(self):
        fallback = Path(self.recipe_folder).parents[2] / "cmake" / "verilator-config.fallback.cmake"
        if fallback.is_file():
            copy(self, fallback.name, src=str(fallback.parent), dst=self.export_sources_folder)

    def package_id(self):
        self.info.clear()

    def _local_windows_kit(self):
        roots = []
        env_root = os.environ.get("VERILATOR_ROOT")
        if env_root:
            roots.append(Path(env_root))
        roots.extend([Path(r"D:\verilator"), Path(r"C:\msys64\mingw64")])
        for root in roots:
            pe = root / "bin" / "verilator_bin.exe"
            hdr = root / "include" / "verilated.h"
            hdr2 = root / "share" / "verilator" / "include" / "verilated.h"
            if pe.is_file() and (hdr.is_file() or hdr2.is_file()):
                return root
        return None

    def source(self):
        # Conan 2 forbids settings in source(). Windows tarball is fetched in package().
        pass

    def build(self):
        pass

    def _copy_file(self, src: Path, dst: Path):
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)

    def _package_windows(self):
        # Prefer an already-extracted withlimon tree (PC2023: D:\verilator).
        kit = self._local_windows_kit()

        pkg = Path(self.package_folder)
        if kit is not None:
            self.output.info(f"Packaging local withlimon kit at {kit}")
            bin_src = kit / "bin"
            if bin_src.is_dir():
                for f in bin_src.iterdir():
                    if f.is_file():
                        self._copy_file(f, pkg / "bin" / f.name)
            inc = kit / "include"
            if not (inc / "verilated.h").is_file():
                inc = kit / "share" / "verilator" / "include"
            if inc.is_dir():
                shutil.copytree(inc, pkg / "include", dirs_exist_ok=True)
        else:
            self.output.info("No local withlimon kit; downloading withlimon tarball")
            get(self, **self.conan_data["sources"][self.version],
                strip_root=False, destination=self.build_folder)
            src = Path(self.build_folder)
            # tarball may unpack as . or as a top-level dir
            candidates = [src] + [p for p in src.iterdir() if p.is_dir()]
            unpacked = None
            for c in candidates:
                if (c / "bin" / "verilator_bin.exe").is_file():
                    unpacked = c
                    break
            if unpacked is None:
                raise ConanException(
                    "withlimon tarball missing bin/verilator_bin.exe. "
                    "See https://github.com/withlimon/verilator-windows"
                )
            for f in (unpacked / "bin").iterdir():
                if f.is_file():
                    self._copy_file(f, pkg / "bin" / f.name)
            inc = unpacked / "include"
            if inc.is_dir():
                shutil.copytree(inc, pkg / "include", dirs_exist_ok=True)

        pe = pkg / "bin" / "verilator_bin.exe"
        if not pe.is_file():
            raise ConanException(
                "Windows package missing bin/verilator_bin.exe (must be the PE engine, "
                "not the extensionless Perl driver)"
            )

        fallback = Path(self.export_sources_folder) / "verilator-config.fallback.cmake"
        cfg = pkg / "verilator-config.cmake"
        if fallback.is_file() and not cfg.is_file():
            shutil.copy2(fallback, cfg)

    def _package_system_unix(self):
        kit_candidates = []
        env_root = os.environ.get("VERILATOR_ROOT")
        if env_root:
            kit_candidates.append(Path(env_root))
        kit_candidates.extend(
            [Path("/usr/share/verilator"), Path("/usr/local/share/verilator")]
        )
        kit = next((p for p in kit_candidates if (p / "include" / "verilated.h").is_file()), None)
        if kit is None:
            raise ConanException(
                "System Verilator kit not found (need include/verilated.h). "
                "Install verilator (e.g. apt install verilator) or set VERILATOR_ROOT."
            )
        pkg = Path(self.package_folder)
        inc = kit / "include"
        shutil.copytree(inc, pkg / "include", dirs_exist_ok=True)
        cfg = kit / "verilator-config.cmake"
        if cfg.is_file():
            shutil.copy2(cfg, pkg / "verilator-config.cmake")
        else:
            fallback = Path(self.export_sources_folder) / "verilator-config.fallback.cmake"
            if fallback.is_file():
                shutil.copy2(fallback, pkg / "verilator-config.cmake")

        bindir = pkg / "bin"
        bindir.mkdir(parents=True, exist_ok=True)
        for name in (
            "verilator_bin",
            "verilator_bin_dbg",
            "verilator_coverage",
            "verilator_coverage_bin_dbg",
            "verilator_gantt",
            "verilator_profcfunc",
            "verilator",
        ):
            src = Path("/usr/bin") / name
            which = shutil.which(name)
            if which:
                src = Path(which)
            if src.is_file():
                self._copy_file(src, bindir / name)

        if not (bindir / "verilator_bin").is_file():
            raise ConanException("system verilator_bin not found")

    def package(self):
        if self.settings.os == "Windows":
            self._package_windows()
        else:
            self._package_system_unix()

    def package_info(self):
        self.cpp_info.bindirs = ["bin"]
        self.cpp_info.libdirs = []
        self.cpp_info.includedirs = ["include"]
        self.cpp_info.builddirs = ["."]
        self.cpp_info.set_property("cmake_file_name", "verilator")
        self.cpp_info.set_property("cmake_target_name", "verilator::verilator")
        # CMakeDeps will generate a config; RtlLabSim still loads verilate()
        # from the kit / bundled fallback (withlimon does not ship cmake).

        root = self.package_folder
        self.buildenv_info.define("VERILATOR_ROOT", root)
        self.runenv_info.define("VERILATOR_ROOT", root)
        pe = "verilator_bin.exe" if self.settings.os == "Windows" else "verilator_bin"
        self.buildenv_info.define("VERILATOR_BIN", pe)
