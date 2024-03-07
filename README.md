# consolebrot-zig

                                                                                0
                                                                                0
                                                                            00000000
                                                                           00000000
                                                                            0000000
                                                                          0   000        0
                                                                0     00000000000000000000
                                                               0000 00000000000000000000000   000
                                                                 0000000000000000000000000000 000
                                                               00000000000000000000000000000000
                                                            00000000000000000000000000000000000000
                                                            0000000000000000000000000000000000000
                                                          000000000000000000000000000000000000000000
                                              0          000000000000000000000000000000000000000000
                                        00 0000000       0000000000000000000000000000000000000000000
                                        0000000000000   0000000000000000000000000000000000000000000
                                       000000000000000  0000000000000000000000000000000000000000000
                                      00000000000000000 000000000000000000000000000000000000000000
                                 000 000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
                                 000 000000000000000000000000000000000000000000000000000000000000
                                      00000000000000000 000000000000000000000000000000000000000000
                                       000000000000000  0000000000000000000000000000000000000000000
                                        0000000000000   0000000000000000000000000000000000000000000
                                        00 0000000       0000000000000000000000000000000000000000000
                                              0          000000000000000000000000000000000000000000
                                                          000000000000000000000000000000000000000000
                                                            0000000000000000000000000000000000000
                                                            00000000000000000000000000000000000000
                                                               00000000000000000000000000000000
                                                                 0000000000000000000000000000 000
                                                               0000 00000000000000000000000   000
                                                                0     00000000000000000000
                                                                          0   000        0
                                                                            0000000
                                                                           00000000
                                                                            00000000
                                                                                0
                                                                                0

## Introduction
Reacreation of my [original C# Consolebrot](https://github.com/bencookman/consolebrot), rewritten in zig to help me learn the language.

Currently Windows platforms do not work, due to [this issue](https://github.com/ziglang/zig/issues/6845). I'm hoping to add Windows support in the future.

## Installation
Simply clone the GitHub repository (repo) and build the zig project:
```bash
git clone https://github.com/bencookman/consolebrot-zig # Clone the repo
cd consolebrot-zig                                      # Move into the repo
zig build                                               # Build the project
./zig-out/bin/consolebrot                               # Run the binary
```

## Goals
- High portability
    - Only a single binary
    - Compilation to all popular operating systems (Windows, Mac, Linux)
- Ease of use
    - Simple, self-explanatory UI
- High accuracy
    - Infinite zooming into the Mandelbrot set, forever
    - Minimal cost of zooming
- Image saving
    - Press a button to save the current view window to a text file
    - Files should be placed where the user calls consolebrot from
    - Copying to clipboard (probably very OS dependent)
- Code flexibility
    - Should be easy for a consolebrot user with zig experience to understand and modify code
