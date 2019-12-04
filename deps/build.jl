using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libgswteos"], :libgswteos),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/kouketsu/GSWCBuilder/releases/download/v0.1.1"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/GSWC.v3.0.5.aarch64-linux-gnu.tar.gz", "68ab0d9e995e28689f56ff736e79fac3863bd0c1cbb95e7f12b092887349273b"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/GSWC.v3.0.5.aarch64-linux-musl.tar.gz", "e1b049ce969684c19942edc05af644ec92e3fae94a98926001147860e80eb84a"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/GSWC.v3.0.5.arm-linux-gnueabihf.tar.gz", "3f859aa75f4a2f77b1ad43edf40bcc75f540709353630fe5c6e26a2645d0f749"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/GSWC.v3.0.5.arm-linux-musleabihf.tar.gz", "98a92bfb19be0b006b45f55d6d24dc6a44b858ac820016354388bff45dbf4414"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/GSWC.v3.0.5.i686-linux-gnu.tar.gz", "5b066d845f862a60bdc1a87eb955e0102a689b2e5b6b6856e93013fe64d7ae74"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/GSWC.v3.0.5.i686-linux-musl.tar.gz", "ee63f0ff256812a1c1a19d7984474f48d67ba6b4bfe58734ef36f212231648d0"),
    Windows(:i686) => ("$bin_prefix/GSWC.v3.0.5.i686-w64-mingw32.tar.gz", "6ce7abb673bbe5ba25ea23ad82eb23d5274e51ee36148e7c1f9e9f4f9c76c554"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/GSWC.v3.0.5.powerpc64le-linux-gnu.tar.gz", "f91d0b4b34d0ee189b7fe82f7ebbdfdf8fb200e0301423854756844ee8cf8c91"),
    MacOS(:x86_64) => ("$bin_prefix/GSWC.v3.0.5.x86_64-apple-darwin14.tar.gz", "7884b3a7a1ac9ce61aaaf80d6ae64beef6ee328605597c8359d188c424a81b17"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/GSWC.v3.0.5.x86_64-linux-gnu.tar.gz", "adf493054036d8fcd0a2d3250fe68a4bdbc3c102cef419a95a9968ce4ebfc9fa"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/GSWC.v3.0.5.x86_64-linux-musl.tar.gz", "9e52da24438aa24c77ba5d9ef29050219cae36335345e18456f97161ff8ac8b5"),
    FreeBSD(:x86_64) => ("$bin_prefix/GSWC.v3.0.5.x86_64-unknown-freebsd11.1.tar.gz", "56c4b5d63c2f5deb6356f795ab4b6bc9ab0adf3189d516d8553f8945b85ef72a"),
    Windows(:x86_64) => ("$bin_prefix/GSWC.v3.0.5.x86_64-w64-mingw32.tar.gz", "dcc5a0f3292964ef1708eacc2845f6baedb6b0081dc8f084d825187408ea9701"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)