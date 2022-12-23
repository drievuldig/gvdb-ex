helloworldgvdb : helloworldgvdb.cu libgvdb.so

CXX = nvcc
CXXFILES = helloworldgvdb.cu

CXXFLAGS = -o out -lGLEW -lGLU -lGL -lglut
LIBS = ../gvdb-voxels/lib/libgvdb.so
INC = ../gvdb-voxels/include

all:
	$(CXX) $(CXXFILES) $(LIBS) $(CXXFLAGS) -I$(INC)