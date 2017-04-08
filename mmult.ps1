nvcc -O3 -lcublas --shared mmult.cu -o mmult.dll -Xcompiler /wd4819
