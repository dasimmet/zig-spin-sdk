# zig-spin-sdk

A Zig CGI Application compiled to WASM (WAGI), running on Fermyon Spin.

Hosted to and Hosted at: [Fermyon Cloud](https://spinapp-21hfxd8b.fermyon.app)

## Publish

```console
zig build -Doptimize=ReleaseSmall
spin deploy
```