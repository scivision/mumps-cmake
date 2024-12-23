# LAPACK options

The underlying "LAPACK" linear algebra interface is available from several vendors.
By default, the generic LAPACK library "lapack" is searched for.

To specify a particular LAPACK library, use CMake configure variable "LAPACK_VENDOR" using one of the following vendors:

* AOCL  [AMD Optimizing CPU Libraries](https://www.amd.com/en/developer/aocl.html)
* Atlas [Automatically Tuned Linear Algebra Software](http://math-atlas.sourceforge.net/)
* MKL  [Intel oneMKL](https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl.html): requires [oneMKL >= 2021.3](https://www.intel.com/content/www/us/en/docs/onemkl/developer-guide-linux/2023-2/cmake-config-for-onemkl.html)
* Netlib [Netlib LAPACK](http://www.netlib.org/lapack/)  (default)
* OpenBLAS [OpenBLAS](https://www.openblas.net/)

For example, to use OpenBLAS:

```sh
cmake -DLAPACK_VENDOR=OpenBLAS
```

Optionally, hint the location the LAPACK library like:

```sh
cmake -DLAPACK_ROOT=/path/to/lapack
```

## Intel MKL

CMake searches for Intel oneMKL if environment variables MKLROOT is set:

* Base Toolkit: MKL LAPACK
* HPC toolkit: SCALAPACK.

## GEMMT symmetric matrix-matrix multiplication

For MUMPS &ge; 5.2.0, GEMMT symmetric matrix-matrix multiplication is recommended by the MUMPS User Guide if available.
By default GEMMT is ON, but may be disabled like:

```sh
cmake -Dgemmt=off
```

## Build LAPACK

If the compiler doesn't have LAPACK and SCALAPACK, first build and install them:

```sh
cmake -S scripts -B scripts/build -DCMAKE_INSTALL_PREFIX=~/mylibs
cmake --build scripts/build -t scalapack

# mumps
cmake -B build -DCMAKE_PREFIX_PATH=~/mylibs
cmake --build build
```

Since oneAPI comes with LAPACK and ScaLAPACK with oneAPI in oneMKL, there is no need to build them with oneAPI + oneMKL.
