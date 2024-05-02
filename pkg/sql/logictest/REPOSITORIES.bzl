# DO NOT EDIT THIS FILE MANUALLY! Use `release update-releases-file`.
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

CONFIG_LINUX_AMD64 = "linux-amd64"
CONFIG_LINUX_ARM64 = "linux-arm64"
CONFIG_DARWIN_AMD64 = "darwin-10.9-amd64"
CONFIG_DARWIN_ARM64 = "darwin-11.0-arm64"

_CONFIGS = [
    ("23.1.20", [
        (CONFIG_DARWIN_AMD64, "fa14020a1ab13a798391fc580b58e9b4400e39b96b699230c599c7752f537c7e"),
        (CONFIG_DARWIN_ARM64, "a79167f14fb8e07343280abdd70922bd941b72e5891b466699333e71b08fd54b"),
        (CONFIG_LINUX_AMD64, "3893662b800d1bd113c8e2b934597d8a31ad99316c246a32952e1ee1eb4b1e23"),
        (CONFIG_LINUX_ARM64, "93c6b3608027be39be781e9075d0632e14721637b112f0f680f9e8a3c0ef3c09"),
    ]),
    ("23.2.4", [
        (CONFIG_DARWIN_AMD64, "ddc299285a973af9bd11f35b94461799deccbca020ace262c358f5fc3ce9ce00"),
        (CONFIG_DARWIN_ARM64, "0e7065e7d3221c75090568a076743182ef957deb7eb09f8f00831c77f4fb613c"),
        (CONFIG_LINUX_AMD64, "2d7b33e23549c8d89892b12b2e3237029a012154437fc82754ac861ba6fcc61c"),
        (CONFIG_LINUX_ARM64, "621c075ea8dea11b18d2a71326127a92cf23f7af6221966df0476a0a0bdff7b1"),
    ]),
]

def _munge_name(s):
    return s.replace("-", "_").replace(".", "_")

def _repo_name(version, config_name):
    return "cockroach_binary_v{}_{}".format(
        _munge_name(version),
        _munge_name(config_name))

def _file_name(version, config_name):
    return "cockroach-v{}.{}/cockroach".format(
        version, config_name)

def target(config_name):
    targets = []
    for versionAndConfigs in _CONFIGS:
        version, _ = versionAndConfigs
        targets.append("@{}//:{}".format(_repo_name(version, config_name),
                                         _file_name(version, config_name)))
    return targets

def cockroach_binaries_for_testing():
    for versionAndConfigs in _CONFIGS:
        version, configs = versionAndConfigs
        for config in configs:
            config_name, shasum = config
            file_name = _file_name(version, config_name)
            http_archive(
                name = _repo_name(version, config_name),
                build_file_content = """exports_files(["{}"])""".format(file_name),
                sha256 = shasum,
                urls = [
                    "https://binaries.cockroachdb.com/{}".format(
                        file_name.removesuffix("/cockroach")) + ".tgz",
                ],
            )
